# Parameters - change as needed
$resourceGroup = "azuredoc-vm_group"
$vmName        = "vm1"
$osTargetSku   = "Premium_LRS"        # OS disk SKU: use Premium_LRS (not PremiumV2)
$dataTargetSku = "PremiumV2_LRS"      # Data disks SKU: Premium SSD v2
$targetZone    = "1"                 # set to '1' (string/number) if you want to create disks in a specific zone; else $null
$timestamp     = (Get-Date -Format "yyyyMMddHHmmss")
$location      = (Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName).Location

# Get VM
$vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

if (-not $vm) { throw "VM $vmName not found in RG $resourceGroup" }

# STOP the VM to get a consistent snapshot (recommended)
Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force -ErrorAction Stop

# Build a table of disks (OS + data)
$osDiskRef = [pscustomobject]@{
    Role = "OS"
    OriginalName = $vm.StorageProfile.OsDisk.Name
    ManagedDiskId = $vm.StorageProfile.OsDisk.ManagedDisk.Id
    DiskSizeGB = (Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $vm.StorageProfile.OsDisk.Name).DiskSizeGB
    Caching = $vm.StorageProfile.OsDisk.Caching
    Lun = -1
    SkuName = (Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $vm.StorageProfile.OsDisk.Name).Sku.Name
}

# Data disks: preserve Lun, Name, caching, size and original sku
$dataDiskRefs = @()
foreach ($d in $vm.StorageProfile.DataDisks) {
    $diskObj = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $d.Name
    $dataDiskRefs += [pscustomobject]@{
        Role = "Data"
        OriginalName  = $d.Name
        ManagedDiskId  = $d.ManagedDisk.Id
        DiskSizeGB     = $diskObj.DiskSizeGB
        Caching        = "None"
        Lun            = $d.Lun
        SkuName        = $diskObj.Sku.Name
    }
}

# Combine OS + data list for snapshot/restore operations (OS first)
$allDisks = @($osDiskRef) + ($dataDiskRefs | Sort-Object -Property Lun)

Write-Output "Disks to snapshot and recreate:"
$allDisks | Format-Table Role, OriginalName, Lun, DiskSizeGB, SkuName, Caching

# Snapshot + disk creation loop (with conditional SKU per Role)
$createdDisks = @()
foreach ($d in $allDisks) {
    $role = $d.Role
    $origName = $d.OriginalName
    $snapName = "$($origName)-snapshot-$timestamp"
    Write-Output "Creating snapshot for $role disk: $origName -> $snapName"

    $snapshotConfig = New-AzSnapshotConfig -SourceUri $d.ManagedDiskId -Location $location -CreateOption Copy
    $snapshot = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapName -ResourceGroupName $resourceGroup

    # Poll until snapshot succeeded
    $state = $null
    do {
        Start-Sleep -Seconds 5
        $state = (Get-AzSnapshot -ResourceGroupName $resourceGroup -SnapshotName $snapName).ProvisioningState
        Write-Verbose "Snapshot $snapName state: $state"
    } while ($state -ne "Succeeded")

    # Choose SKU based on role (OS vs Data)
    if ($role -eq "OS") {
        $skuToUse = $osTargetSku
    } else {
        $skuToUse = $dataTargetSku
    }

    $newDiskName = "$($origName)-new-$timestamp"
    Write-Output "Creating managed disk from snapshot: $newDiskName (target SKU: $skuToUse)"
    
    $diskConfig = New-AzDiskConfig -Location $location `
                                  -CreateOption Copy `
                                  -SourceResourceId $snapshot.Id `
                                  -SkuName $skuToUse `
                                  -DiskSizeGB $d.DiskSizeGB `
                                  -Zone $targetZone


    $newDisk = New-AzDisk -ResourceGroupName $resourceGroup -DiskName $newDiskName -Disk $diskConfig

    $createdDisks += [pscustomobject]@{
        Role = $d.Role
        OriginalName = $origName
        NewDiskName  = $newDiskName
        NewDiskId    = $newDisk.Id
        Lun          = $d.Lun
        DiskSizeGB   = $d.DiskSizeGB
        Caching      = $d.Caching
        SkuName      = $skuToUse
    }
}

# Create VM configuration and attach disks (unchanged)
Write-Output "Building new VM config: $vmName"
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vm.HardwareProfile.VmSize -Zone $targetZone

$osCreated = $createdDisks | Where-Object { $_.Role -eq "OS" }
if (-not $osCreated) { throw "OS disk creation failed; aborting VM creation." }

# If original is Windows; for Linux set -Linux instead
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -CreateOption Attach -ManagedDiskId $osCreated.NewDiskId -Name $osCreated.NewDiskName -Windows

# Attach data disks in original LUN order
$dataToAttach = $createdDisks | Where-Object { $_.Role -eq "Data" } | Sort-Object Lun
foreach ($dd in $dataToAttach) {
    Write-Output "Attaching data disk $($dd.NewDiskName) as LUN $($dd.Lun)"
    $vmConfig = Add-AzVMDataDisk -VM $vmConfig `
                                 -Name $dd.NewDiskName `
                                 -CreateOption Attach `
                                 -ManagedDiskId $dd.NewDiskId `
                                 -Lun $dd.Lun `
                                 -DiskSizeInGB $dd.DiskSizeGB `
                                 -Caching $dd.Caching
}

# Attach primary NIC from source VM (re-using NIC). If you need a new NIC, create it separately.
$nicId = $vm.NetworkProfile.NetworkInterfaces[0].Id
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nicId -Primary

# Optional: enable boot diagnostics / copy other security profiles as needed
$vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Enable


##comment this line if you have not created the VM with option DeleteOption = Delete
$vm.NetworkProfile.NetworkInterfaces[0].DeleteOption = 'Detach'
$vm.StorageProfile.OsDisk.DeleteOption = 'Detach'
foreach ($dataDisk in $vm.StorageProfile.DataDisks) {
    $dataDisk.DeleteOption = 'Detach'
}
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
##

#Delete existing VM
Remove-AzVM -ResourceGroupName $resourceGroup -Name $vmName


# Create VM
Write-Output "Creating new VM $vmName"
New-AzVM -ResourceGroupName $resourceGroup -Location $vm.Location -VM $vmConfig -DisableBginfoExtension

Write-Output "VM creation triggered. New VM: $vmName; verify inside OS that disks are present and mounted as expected."
