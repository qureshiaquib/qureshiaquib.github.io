---
title: "Automate Premium SSD to SSD v2 & AV Zone VM conversion"
date: 2025-10-30 01:00:00 +500
categories: [tech-blog]
tags: [AV Zone conversion]
description: "Automate conversion of Azure VMs from regional to av zone and premium disk to premium SSD v2 using PowerShell. With snapshot, achieve huge cost savings"
---

If you haven’t gone through Part 1 of my blog, where I explained the benefits of Premium SSD v2, you can use the link below to understand the differences and conditions involved.
[https://www.azuredoctor.com/posts/convert-premium-ssd-to-premium-ssd-v2/](https://www.azuredoctor.com/posts/convert-premium-ssd-to-premium-ssd-v2/)

Recently, a reader approached me and asked about his VMs in an availability set. The approach I mentioned in my previous blog primarily covers the new functionality of moving VMs to an availability zone, which isn’t supported for VMs in an availability set. At the same time, performing this activity in bulk is very time-consuming and requires a manual approach. He wanted to automate the entire process, which was a great idea. I believe many architects and administrators might find this helpful.

You can find the PowerShell script here:
[ConvertvmToZonalandPremiumV2Disk.ps1t](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30102025/ConvertvmToZonalandPremiumV2Disk.ps1)

Below are the high-level steps performed in the script:.

1. First, we stop the existing VM to take a consistent snapshot.
2. We create snapshots of all the disks, including the OS disk..
3. We create a new disk from the snapshot in the same resource group. This new disk will be Premium SSD v2.
4. Create a VM configuration by copying the existing configuration.
5. Use the existing NIC instead of creating a new one.
6. Ensure the disks and NIC are not deleted when deleting the VM by updating the existing VM configuration.
7. Remove the existing VM.
8. Create a new VM in the target availability zone.


```shell
# Parameters - change as needed
$resourceGroup = "azuredoc-vm_group"
$vmName        = "vm1"
$osTargetSku   = "Premium_LRS"        # You can choose Standard SSD
$dataTargetSku = "PremiumV2_LRS"      # Data disks SKU: Premium SSD v2
$targetZone    = "1"                 # set to '1' or other zones
$timestamp     = (Get-Date -Format "yyyyMMddHHmmss")
$location      = (Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName).Location

# Get VM
$vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

if (-not $vm) { throw "VM $vmName not found in RG $resourceGroup" }

# STOP the VM to get a consistent snapshot (recommendede)
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

# Combine OS + data list for snapshot operations
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

    # Choose SKU based on role OS or Data Disk as Premium SSDv2 cannot be used as OS Disk
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

# If original is Windows, for Linux set -Linux instead
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

# Attach primary NIC from source VM (re-using NIC). If you need a new NIC, create it separately. We've assumed you only have one disk, if you've more than one nic you'll need to modify this cmdlet.

$nicId = $vm.NetworkProfile.NetworkInterfaces[0].Id
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nicId -Primary

# Optional: enable boot diagnostics / copy other security profiles as needed
$vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Enable

##As we'll be removing the Orignal VM, if you've set the VM with Deletion Option for NIC and Disk to be deleted once the VM is deleted then you'll lose the nic and then our script will fail as we're not creating nic and utilizing the same nic. Also if orignal disk is created you can't go back to the previous state. Hence comment this line if you have not created the VM with option DeleteOption = Delete.

$vm.NetworkProfile.NetworkInterfaces[0].DeleteOption = 'Detach'
$vm.StorageProfile.OsDisk.DeleteOption = 'Detach'
foreach ($dataDisk in $vm.StorageProfile.DataDisks) {
    $dataDisk.DeleteOption = 'Detach'
}
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
##

#Delete existing VM, you want to create a new VM with a new Name you'll need to modify this $vmname
Remove-AzVM -ResourceGroupName $resourceGroup -Name $vmName


# Create VM
Write-Output "Creating new VM $vmName"
New-AzVM -ResourceGroupName $resourceGroup -Location $vm.Location -VM $vmConfig -DisableBginfoExtension

Write-Output "VM creation triggered. New VM: $vmName; verify inside OS that disks are present and mounted as expected."
```

I hope this helps you automate your task. There might be minor changes required based on your environment or the specific request you’ve received. Feel free to download the script and make the necessary changes as per your environment.


Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
