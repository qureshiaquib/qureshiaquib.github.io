---
title: "Demystifying Storage types in Azure VMware solution"
date: 2024-6-02 12:00:00 +500
categories: [tech-blog]
tags: [Azure VMware solution - storage]
---

When performing a lift and shift migration, you’ll encounter different types of destinations on Azure.
One of the destinations on Azure is Azure VMware Solution (AVS), a private cloud offering on Azure.
Essentially, it involves vSphere clusters on dedicated bare metal servers. There are multiple storage options on Azure if you need to expand the storage for AVS. In this blog, we’ll focus on first-party offerings.

## vSAN: Local Storage

This type of storage comes from disk which is locally attached to bare metal servers. These are NVMe SSDs, providing the fastest storage as it comes directly from the node itself. 

Storage size depends on the number of nodes you deploy in your cluster. A minimum of 3 and a maximum of 16 nodes can be deployed in a single cluster.
The size will be based on the RAID configuration you do.


FTT indicates the number of nodes a cluster can withstand failure and still retain your data without any loss. The higher the FTT rate, the higher the minimum host requirement will be.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture1.jpg)


Keep in mind that whatever usable space you get after configuring RAID, you’ll need to keep 25% free space in vSAN as slack space. This is for host failure, updates, and vSAN policy changes. You should maintain 25% free space to meet SLA requirements.

To calculate the usable storage you can get from your AVS host, you can use the website mentioned below.
The example is of AV36P. which has 2 Disk groups with 3 capacity disk each of 3.2 TB.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture2.jpg){: w="400" h="1000" }
![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture3.jpg){: w="400" h="1000" }


Based on observations, you’ll get anywhere between 10 – 13 TB of usable space per node.
Capacity disks with AVS nodes can be found in screenshot below.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture4.png)

These are split into two disk groups.

If your space requirement is higher than the usable space you get from vSAN, you’ll need to opt for remote storage or get extra node which expands your vSAN as node in AVS comes with attached storage. As node addition in the cluster is costly option hence you can check for remote storage options which basically means expanding your storage without adding extra node. 

This can be in any form, such as ANF or Elastic SAN, which are first-party offerings, but AVS also supports third-party storage like Pure Storage.

## Azure NetApp Files with AVS

Azure NetApp Files can be used to mount NFS shares inside the VM and can also be used as NFS datastores in vCenter.
Since AVS is hosted on a separate bare metal server and not in a VNET, if you need to connect to an ANF volume, it must be connected via the ExpressRoute, which is provided inbuilt in AVS.
ANF would be deployed in a separate VNET connected to the ExpressRoute circuit via a gateway – the ExpressRoute gateway.

Data transfer between AVS and ANF is free of cost as it’s connected via the inbuilt ExpressRoute connection.

The diagram below shows the connectivity mechanism.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture5.jpg)


As AVS is deployed in a specific zone, you’ll need to ensure ANF is also deployed in the same zone to achieve a low latency connection for datastores. This can be achieved with the availability zone volume group placement feature, which places ANF in a specific zone.

In AVS, the connectivity with ANF happens through a separate VMK that handles datastore traffic, providing traffic isolation.

For better throughput, customers can deploy Ultra VPN GW or ErGw3Az SKU, which provides the FastPath feature. Once enabled, FastPath sends network traffic directly to AVS, bypassing the gateway.

If your VMDKs of VMs are placed in ANF, you can utilize their cloud backup plug-in, which can back up VMs.
This tool is currently in preview and free.

> While AFS also provides the NFS protocol, it is currently not supported as a datastore.
{: .prompt-tip }

## Azure Elastic SAN with AVS

In addition to ANF, Microsoft offers a first-party solution to meet storage needs: Elastic SAN. It is cheaper than Azure NetApp Files and scalable. Elastic SAN can be used to provide datastores to AVS. We’ll get iSCSI LUNs that can be mapped to AVS, and then VMs can be created in that datastore.

Elastic SAN would be exposed as a VMFS datastore.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture6.jpg){: w="500" h="900" }


Elastic SAN by default comes in a premium SKU. You can purchase a base SKU in TBs, which increases IOPS and throughput. However, if your throughput and IOPS requirements are sufficient with the base SKU, you can add additional storage, which is cheaper and doesn’t increase IOPS and throughput.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/Picture7.jpg)


As shown in the screenshot above, the base size increases IOPS and throughput, while additional capacity, which is cheaper, doesn’t commit to any IOPS/Throughput.

Elastic SAN is fully integrated into the AVS blade on the Azure portal. You can create datastores from the same blade, making it easier to map and extend datastores.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/03062024/picture8.jpg)

We've covered the Storage options in AVS architecture. I hope this will help you in sizing AVS for any new opportunity.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }