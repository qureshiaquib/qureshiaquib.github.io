---
title: "Why Choose Azure Elastic SAN? Cost and Use Cases Compared"
date: 2024-12-27 12:00:00 +500
categories: [tech-blog]
tags: [Elastic SAN]
description: "Explore Azure Elastic SAN features, cost comparisons, and use cases for production and non-prod workloads. Learn how it compares with Premium and Standard SSDs"
---

This blog is intended for folks who have not explored Azure ESAN storage yet, though they have heard about ESAN and its basics but unaware about the value it brings for their workload.
By reading this blog, you’ll gain insights to answer the following questions.
1. Why should I use ESAN? and whether there is any price benefit if I choose this service over manage disk and how much you can save?
2. Can I consider ESAN for my Prod workload?
3. What are the limitations associated with ESAN before I deploy this for my workload?

We’ll not be covering step by step creation of ESAN volumes and attaching it to VM. This is well covered in Microsoft learn document.

## Basic Information
Let us get started, Azure Elastic SAN (ESAN) was introduced in Oct 2022. ESAN provides iSCSI LUNs which can be used to mount VMs, AKS & AVS. Since 2022 there has been a lot of improvements in Elastic SAN and now most Azure regions currently support this service.

How Elastic SAN calculates IOPS and Storage - you create ESAN and based on the Base unit you get the total IOPS and throughput with increment of 1TiB. Base unit of 1 TiB provides 5000 IOPS and 200MBps throughput. If you just want cheaper storage, then you can add an additional Capacity Unit which does not provide IOPS/Throughput but only additional storage.

One important aspect of Elastic SAN is, whenever you create an Elastic SAN, entire IOPS and throughput of ESAN are shared amongst multiple volumes. For example, if you create 20 TiB of ESAN, you will get 100,000 IOPS and 4000 MBps throughput in total. If you create two volumes of 200Gb each, it can scale up to 80K IOPS and 1280 MBps throughput individually. However, it’ll share the total IOPS and throughput provided by the parent Base unit of Elastic SAN. If one VM gets 60K IOPS and at the same time if the second VM requires 50K IOPS then the second VM will only get 40K IOPS because max limit for ESAN of 20TiB is 100K IOPS.
Minimum volume required to get max 80K IOPS is 106GiB and to get max 1280GB/s we need minimum 21 GiB.

Now, you can combine your storage requirements for multiple applications and put that in single Elastic SAN. You get cost and consolidated storage advantages.
One thing you’ll need to keep in mind, you can’t put all critical prod applications which requires IOPS and throughput at same time in single ESAN. Hence you need to spread evenly across multiple ESAN instances. This is because of the IOPS/Throughput if all the apps require at the same time then ESAN would need to be either scaled to that limit or else ESAN will start throttling. 
You can have 200 Volume groups, and one volume group can have up to 1000 volumes. So, you can have a large set of applications clubbed in single ESAN.

## ESAN volume data travels over network
As an Azure Admin, you may already know every VM has got disk and network throttling limit assigned to it. Lower the VM SKU, lower the limit. If you attach a 4TB Premium SSD disk to a VM with size D4s_v5, even though disk IOPS is 7500 IOPS, you’ll not be able to use this much IOPS. Because VM itself supports max of 6400 IOPS. You’ll need to change your VM size and choose higher SKU even though you don’t require higher CPU and Memory.
As Azure Elastic SAN uses network to connect to storage, VM disk throttling limit doesn’t apply. Though VM network limits still apply in this case. However VM network throughput is always on higher side. You need to make sure you have enough network throughput left for your workload along with running iSCSI based connection for ESAN.

I’ll provide an example below where if you had faced above problem of going to next available SKU just to meet IOPS and throughput then how much you could save by moving your disk from managed disk to Elastic SAN Volumes.

![ESAN data traverse via network path hence VM SKU throttling never happens](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27122024/esan-over-network-price.jpg){: w="1100" h="600" }

Let’s now compare how ESAN is placed when compared to disk storage. Also we’ll only consider one disk of 4TiB as of now. When considering ESAN when you deploy Base Unit which is typically combination of larger storage size you’ll get much higher throughput which any of your volume can use. This isn’t possible in single disk as it is attached to only one VM and the IOPS can’t be shared with other VMs.\
please note: we’ve not considered the preview functionality of of performance plus which provides higher IOPS and Throughput.
More info in below link.

[https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-performance?tabs=azure-powershell](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-performance?tabs=azure-powershell)

## ESAN vs Premium SSD
we’ll start with production grade disk which is Azure Premium SSD. This is one of most used disk for production workload.\
As you can see we had 4TB disk which provides us with 7500 IOPS and 250 MB/s throughput. In order to meet this we had to take 2 TiB Base Unit of Elastic SAN and rest 2 TiB in capacity Unit.\
With just one disk you can save 266.40$ Per Month.

![Table showing cost comparisons of ESAN vs Premium SSD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27122024/premiumssd-vs-esan.jpg){: w="1100" h="600" }

## ESAN vs Standard SSD
In my experience, customers often use standard SSD for non-prod workload. Though the throughput and IOPS are pretty low. this can be a cheaper alternative for non-prod workload where you can compromise performance to save some cost.\
However now when you compare standard SSD with Elastic SAN which is premium you can see from below table, you’ll be able to get much higher IOPS and throughput and still save cost.\
With ESAN you get 5K IOPS and standard SSD would provide 500 IOPS with 4TiB of workload.\
Still with such performance increase you can save cost of around 29.28$ Per Month.

![Table showing cost comparisons of ESAN vs Standard SSD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27122024/standardssd-vs-esan.jpg){: w="1100" h="600" }

## ESAN vs Premium SSD v2
While going through above examples of Premium v1 disk you might wonder why we don’t compare it with premium SSD v2 which provides much better performance and cost is cheaper than the Premium SSD v1 disk. So here you go. With Base price of Premium SSD v2 you get 3000 IOPS and 125 MB/s throughput. When you compare this with our ESAN you get 1 Base Unit of ESAN and 3 TiB of Capacity Unit, you can save around 70.90$ Per month
There are certain considerations in this scenario
1. ESAN can be used by VMs which are Zonal or Regionally deployed.
However Premium SSDv2 requires VMs to be in zone.
2. We can’t use this disk if your VM is in Availability Set or regionally deployed.
3. Though ESAN has to be deployed in a specific zone, VMs can be connected to it from any of the zone within region. It is preferred to have VMs and ESAN in the same zone so that you get better performance.

![Table showing cost comparisons of ESAN vs Premium SSD v2](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27122024/premiumssdv2-vs-esan.jpg){: w="1100" h="600" }

## AVS Scenario : ESAN vs ANF standard
ESAN is a block storage, attached to VMs via iSCSI protocol. ANF is a NAS which can be available via NFS or SMB protocol.\
As ESAN can also be used in Azure VMware Solution scenarios, hence we thought about comparing ESAN vs ANF as latter is also supported for AVS workload.\
We’ll consider 8KB IOPS which is common read/write I/O. If you’ve Database this can be higher and if it is a web or app server it can also be lower based on which IOPS achieved can increase or descrease.\
We’ve considered the cheaper tier of ANF which is standard tier.\
We get overall savings of 271$ per month when you consider ESAN.

![Table showing cost comparisons of ESAN vs Azure NetApp Files](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27122024/anf-vs-esan.jpg){: w="1100" h="600" }

However there are few considerations which I would like to highlight.
1.	If you want to use AVS with ESAN, we’ll have to deploy private endpoint for ESAN.
If you know pricing of private endpoint there is a slight charge for inbound and outbound data transfer per GB. This is visible in our private endpoint pricing page.
So every month based on the data transfer to ESAN, there will be bandwidth cost involved. 
This doesn’t happen when you deploy ANF with AVS,as ANF gets deployed in a VNET hence we don’t have to worry about the data transfer cost involved.
2. ESAN currently only provides storage, however ANF is mature service in terms of storage with AVS. It provides cloud backup extension for VMs hosted in ANF datastore.
[https://learn.microsoft.com/en-us/azure/azure-vmware/install-cloud-backup-virtual-machines](https://learn.microsoft.com/en-us/azure/azure-vmware/install-cloud-backup-virtual-machines)
3. ANF is supported for SAP on Azure, while ESAN is still unsupported.

## Limitations and considerations:
As Elastic SAN is just 2 years old service, many enhancements are still in roadmap. Before you consider deploying ESAN for your workload you’ll need to keep below considerations in mind.
1. If you replicate your VM to another region via Azure Site recovery, ESAN volumes attached to a VM are unsupported.
2. Backup of ESAN Volume via Azure Backup is currently not GA. Not available in public preview as of now.
3. Backup is available via volume snapshots which is in preview, this is ESAN functionality. 
3. SAP on Azure VM is currently unsupported with ESAN, it is only supported with Azure Managed disk and ANF.
4. You can take snapshots of normal disk and then create ESAN volume from that. This is in preview and it can be used to move to ESAN volume.
5. If you use Azure Migrate for assessment and sizing your DC migration, the tool currently only supports managed disk as a target for assessment as well as for migration.\
[https://learn.microsoft.com/en-us/azure/storage/elastic-san/elastic-san-snapshots?tabs=azure-portal#create-a-volume-from-a-managed-disk-snapshot](https://learn.microsoft.com/en-us/azure/storage/elastic-san/elastic-san-snapshots?tabs=azure-portal#create-a-volume-from-a-managed-disk-snapshot)

I hope the above comparisons and descriptions help you validate whether ESAN is a better fit for your deployment and can achieve cost savings.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }