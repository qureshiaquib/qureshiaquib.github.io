---
title: "Migrating VMs between tenants without copying disks"
date: 2025-1-10 12:00:00 +500
categories: [tech-blog]
tags: [VM Migration]
description: "Streamline Azure VM migrations across tenants. Eliminate VHD copy process between storage account across tenant and directly take snapshot in destination tenant"
---
* **Scenario**: Customers undergoing a divestiture or merger often need to migrate Azure VMs from one Entra ID (Azure AD) tenant to another. The entire migration process is documented below. However, the critical step of copying the VHD file from the source storage account to the storage account in the destination tenant can be time-consuming, as it depends on the size of the VHD file. If you have thousands of disks, you may need to wait a significant amount of time for this process to be completed.

* **Solution**:
Through the UI, you cannot create a snapshot of a disk across tenants. However, using REST API calls, you can create a snapshot and specify the destination as the target tenant and resource group. By skipping the intermediate step of copying, the following advantages are achieved:
1.	Time Efficiency: This approach eliminates the copy process entirely. In the older method, the time required for copying disks from the source storage account to the destination storage account depended on the disk size. Additionally, IOPS and throughput are throttled based on the disk size — smaller disks offer lower IOPS and throughput. By eliminating the copy process, the new method allows the source disk to remain in the source tenant while snapshots are created directly in the target tenant.
2.	Cost Savings: Temporarily maintaining VHD files in both the source and destination storage accounts incurs additional costs. By removing this intermediate step, these costs are completely avoided.

* **Current process**
1.	Create a Snapshot: Generate a snapshot of the source disk to begin the migration process.
2.	Convert the Snapshot to VHDs: Save the snapshot as VHD files in a storage account.
3.	Use AzCopy: Transfer the VHD files to a storage account in the destination tenant or subscription.
4.	Create a Managed Disk: Use the transferred VHD to create a managed disk in the destination tenant.
5.	Create the VM: Build the VM from the newly created managed disk.

* **New improved process**
1.	Create a Snapshot: Generate a snapshot in the target tenant using the disk present in the source tenant.
2.	Create a Managed Disk: Use the snapshot in the target tenant to create a managed disk.
3.	Create a Virtual Machine: Build a VM in the target tenant using the managed disk.

![Process diagram of VM migration from one tenant to another](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10012025/disksnapshot-process.jpg)

##	ARM – Token information

Let’s discuss how this process is achieved. Currently, no PowerShell command supports creating snapshots across tenants. However, REST API calls provide a solution. These calls allow authentication to the primary tenant and include the option to use an auxiliary token from another tenant. This auxiliary token is passed as an auxiliary header in the same REST call. Additionally, multiple auxiliary headers can be included if needed.

![REST API header details which contains primary and auxiliary token](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10012025/rest-header-details.jpg)

[https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/authenticate-multi-tenant](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/authenticate-multi-tenant)

* **In the context of disk snapshots**:
Using the multi-bearer token ARM capability, you can access both the source tenant/subscription and the target tenant/subscription within a single REST API call.
In this process, you reference the URI of the source disk and pass it in the request to create the snapshot directly in the target subscription.

* **Requirements**:
The account used must have a relationship with both the source and target tenants, satisfying one of the following conditions:
1.	The primary token is from a user who is a member of the source tenant, while the auxiliary token is from the same user present as a guest in the target tenant.
2.	The primary token is from a user who is a member of the target tenant, while the auxiliary token is from the same user present as a guest in the source tenant.

## Permissions

* **Approach**:
    - Push uses a source account with guest access in the target.
    - Pull uses a target account with guest access in the source.

Either approach requires the user account to be a member in one tenant and guest in the other.

* **Required permissions**:
If you have Disk Snapshot Contributor on source and VM contributor and Disk Snapshot contributor on the target subscription then you should be able to take snapshot from source tenant/subscription and then create disk from snapshot and finally you should be able to create VM in the target tenant/subscription.
However, in some circumstances you’ll find due to merger/divestitures the policies are defined in such a way you shouldn’t have write permission on the source subscription. Because Disk snapshot contributor can also write snapshot in the source subscription too, along with that the source organization won’t monitor audit logs to see what all activities you’re performing.\
So let’s find out minimum role required to execute this step.

* Source Subscription Permission:

    We require only two permission:
    1. read access on the disk
    2. Microsoft.Compute/disks/beginGetAccess/action

* Target Subscription Permission:

    Disk snapshot contributor: This role is required so that you can create disks from the snapshots.\
    VM Contributor: to create VM from the disk.

![Azure custom RBAC for disk copy across Azure AD tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10012025/custom-role.jpg)


## Step by Step approach

* **Step-by-Step Approach: Push from Source Tenant**
1.	In the Source Tenant Subscription, create a resource group with a VM with a NIC and Disk
2.	Take an account in the source tenant sourceuser@sourcetenant.com and grant it RBAC permissions to the Source VM using the custom role
3.	In the Target Tenant, add the sourceuser@sourcetenant.com as a guest user
4.	In the Target Tenant Subscription where the VM will be created, grant the new guest user minimum VM Contributor and Disk Snapshot contributor RBAC access so it can create the snapshot and the VM from the Snapshot.
5.	Enter the parameters for the script for the source and target
6.	Execute the script


* **Step-by-Step Approach: Pull from Target Tenant**
1.	In the Source Tenant Subscription, create a resource group with a VM with a NIC and Disk.
2.	In the Target Tenant, create the targetuser@targettenant.com user account.
3.	In the Source Tenant, add the targetuser@targettenant.com as a guest user.
4.	In the Source Subscription, grant the targetuser@targettenant.com user RBAC permissions to the Source VM Disk, using the custom role.
5.	In the Target Tenant Subscription where the VM will be created, grant targetuser@targettenant.com minimum VM Contributor & Disk Snapshot contributor RBAC access so it can create the snapshot and the VM from the Snapshot.
6.	Enter the parameters for the script for the source and target.
7.	Execute the script.

## Script

```shell
# Below are the parameters which will be used.
$source_tenant_id = ""
$source_subscription_id = ""
$source_location = ""
$source_resource_group = ""
$Source_diskforsnapshot_name = ""

$target_tenant_id = ""
$target_subscription_id = ""
$target_location = ""
$target_resource_group = ""
$target_disksnapshot_name = ""


#Login to Azure and get the primary token for the target tenant
Connect-AzAccount -tenant $target_tenant_id
$accessToken = Get-AzAccessToken
$PrimaryToken = $accessToken.Token

#Login to Azure and get the auxiliary token for the source tenant
Connect-AzAccount -Tenant $source_tenant_id
$accessToken = Get-AzAccessToken
$auxilaryToken = $accessToken.Token

#Set up the headers for the REST Call which includes primary token and auxiliary token
$headers = @{
    "Authorization" = "Bearer $PrimaryToken"
    "x-ms-authorization-auxiliary" = "Bearer $auxilaryToken"
    "Content-Type" = "application/json"
    }

#Here we’re specifying the source disk name
 
$diskforsnapbody = @{
    location = $source_location
    properties = @{
    creationdata = @{
        createOption = "Copy"
        sourceResourceId =
        "/subscriptions/$source_subscription_id/resourcegroups/$source_resource_group/providers/Microsoft.Compute/disks/$Source_diskforsnapshot_name"
        }
    }

} | ConvertTo-Json -Depth 5

#Here we’re making REST call and providing target subscription as destination however the snapshot source is the source disk from source subscription.

$disksnapresponse = Invoke-RestMethod -Uri `
"https://management.azure.com/subscriptions/$target_subscription_id/resourceGroups/$target_resource_group/providers/Microsoft.Compute/snapshots/$target_disksnapshot_name ?api-version=2024-03-02" `
-Method Put -Headers $headers -Body $diskforsnapbody -ContentType "application/json"

```
Using above script you'll only get snapshot in the target tenant/subscription.
After this process you'll need to perform below two tasks in target subscription.
1. Create disk from snapshot
2. create VM from existing disks

I've not covered these two task in this blog because these are well known and you should be able to perform these easily.
please find below link for both the tasks.\
[https://learn.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-powershell-sample-create-managed-disk-from-snapshot](https://learn.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-powershell-sample-create-managed-disk-from-snapshot)

[https://learn.microsoft.com/en-us/azure/virtual-machines/attach-os-disk?tabs=powershell](https://learn.microsoft.com/en-us/azure/virtual-machines/attach-os-disk?tabs=powershell)

I've observed that one method for disk copying involves using Storage Explorer. By adding both tenant accounts in a single Storage Explorer session, we can perform the copy-paste operation for the disks. However, it's important to note that this action is actually a copy operation. You can monitor the progress on the status screen at the bottom, where you'll see that each disk takes some time to complete, based on its size.

I hope you found this useful and through this your migration becomes smoother in less time.

Special thanks to [Aleem Mohammed](https://www.linkedin.com/in/aleemmr/) & [Robert Larson](https://www.linkedin.com/in/larsonrobert/) for their collaboration and for helping bring this solution to the community.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }