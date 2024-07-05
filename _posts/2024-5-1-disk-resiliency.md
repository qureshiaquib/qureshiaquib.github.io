---
title: "ZRS Disk: Disk consideration while building infra resiliency"
date: 2024-5-01 12:00:00 +500
categories: [tech-blog]
tags: [Azure ZRS Disk]
description: "Explore Azure ZRS Disk and VM resilience strategies: utilize zonal VMs for isolated workloads, and leverage ZRS disks for synchronous replication across AZs"
---

Before we deep-dive into Azure ZRS Disk and VM resiliency scenarios, the recommendation from Microsoft is to always choose high availability options for App and DB servers. This may lead you to deploy more than one VM, which can be hosted in Availability Zone or using Availability Set for fault isolation to minimize downtime and attaining higher SLA.

If the HA option is not viable for business reasons, here are some scenarios you can follow as general best practices.

## LRS Disk scenarios

Using a Regional VM

If we create a regional VM, the disk (default LRS) can land in any zone regardless of where your VM compute lands. With Compute and Disk in different zones, you experience higher latencies and have an unpredictable resiliency posture. If the zone which hosts either your disk or VM goes down, your application will go down too. The data in a default LRS disk is replicated for data durability, but you can’t see or control the zone where the disk will land within the region.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/01052024/picture1.jpg)

## Using a Zonal VM

If you don’t need zonal resilience but want to achieve zonal isolation, then containing the VM in a single zone with its disk can help. When you create a VM pinned to a zone, then its disks are also created in the same zone which avoid cross zone communication and avoid an outage in a different zone from impacting your workload. Azure still replicates the data for durability, but everything is contained in the same Availability Zone.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/01052024/picture2.jpg)

## ZRS Disk Scenario

If you choose a ZRS disk, the data is synchronously replicated across all three AZs in a region, making the disk resilient to a zone down scenario. So, if the same AZ as the above scenario 1 were to go down, your application wouldn’t go down because of the disk.
Please note that VMs can still go down if the zone hosting the VM compute is down, but in this section, we’re majorly focusing on Disk resiliency! You always have the option to deallocate the VM or create a new VM in a healthy zone.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/01052024/picture3.jpg)

### Zone Down Scenario

Detaching the ZRS disk from VMs wasn’t possible if the Zone hosting your VM compute went down. The workaround being to take a snapshot/copy of the disk to attach to a new VM present in the active zone. Disk data still would be available, as there are two healthy zones, but you wouldn’t be able to directly attach the ZRS disk to a new VM.

### Force Detach ZRS Disk comes to your rescue

There is an ongoing private preview which can help you speed up this process! You can now use the force-detach flag to free the disk from the downed VM, making it immediately available to attach to a new VM.

Command:
```shell
az vm disk detach -g MyResourceGroup --vm-name MyVm --name disk_name --force-detach
```
[https://learn.microsoft.com/en-us/cli/azure/vm/disk?view=azure-cli-latest#az-vm-disk-detach](https://learn.microsoft.com/en-us/cli/azure/vm/disk?view=azure-cli-latest#az-vm-disk-detach)

This continues to provide zero RPO during downtime, but now your RTO is greatly reduced, allowing you to take full advantage of ZRS Disks. 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/01052024/picture4.jpg)

You can opt for private preview, check out the link below.

[https://azure.microsoft.com/en-in/updates/private-preview-force-detach-zone-redundant-disks-during-zone-outage/](https://azure.microsoft.com/en-in/updates/private-preview-force-detach-zone-redundant-disks-during-zone-outage/)

I hope this information helps you in designing more resilient architecture
Special thanks to Bea Vincent from Azure Disk team in validating the content.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
