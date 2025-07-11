---
title: "Demystifying DR Costs with ASR: A Comprehensive Guide"
date: 2024-2-7 12:00:00 +500
categories: [tech-blog]
tags: [Azure Site Recovery]
description: "Discover Azure Site Recovery (ASR) costs for IaaS DR solutions, covering licensing, disk replication, bandwidth, and all related cost"
---

I’ve come across multiple times when architects and sales team are designing DR solutions with ASR and wonder what would be the cost that they need to factor or share with customer. Finding cost is an integral part of the solution which we make. But it can only be extracted once you understand all the moving parts which makes DR as a solution.

There are multiple architecture types which involves PaaS components and also services which has redundancy built in. In this article I will majorly focus on IaaS based DR approach via ASR and mostly on the costing piece of it. This would be helpful to my fellow Sales specialist and architect colleagues who are pricing during pre-sales stage.

Solution component consists of below:

*	App VMs running in DC region.
*	There are networking services like application gateway, Internal load balancer and firewall deployed in HUB VNET.
*	SQL DB deployed in the same VNET as application server in DC region.

## ASR license
I call this license cost; this is the service charge which you pay once you protect the VM via ASR.
Mostly it will be Azure to Azure DR scenario. Previously we used to use ASR for on-premises to On-premises DR scenario as well, which is out of scope.

ASR Recovery services vault gets created in DR region hence you'll need to select DR region while fetching the price.
I've seen folks selecting DC region. which is misleading.

![ASR cost in azure pricing calculator](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/07022024/asr-cost-azure-pricing-calculator.jpg)

## ASR Disk

When ASR is used to replicate VMs from source to target region it does block level replication of the disk. So, there wouldn’t be any VMs involved, it’ll be disk which gets created in DR region. Disk is present in customer’s subscription hence disk cost needs to be factored. If you’ve premium disk on source region then you can replicate it to standard SSD or standard HDD as well. This disk cost would be of target region.

![Disk cost in Azure pricing calculator](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/07022024/disk-cost-azure-pricing-calculator.jpg)

## ASR Bandwidth cost in DC Region

When disk is replicated via ASR service there is data replication which happens continuously. This happens over Microsoft backbone network as both the regions are connected via Azure backbone.

Bandwidth cost is Internet bandwidth from DC region as anything going outside the region is egress and cost is involved. As inbound on DR region is free hence no cost there. For the first time the initial replication would be the entire data which gets replicated and after that it’ll be incremental data replication. So, what would be the size? It’ll be the data change rate which happens every day with compression of 50%. We can factor 3-5% of the total data which gets replicated with 50% compression.

![Bandwidth cost in for ASR](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/07022024/bandwidth-cost-asr.jpg)

## Cache storage

Before incremental data gets into the disk snapshot, first data goes into a temporary cache storage account in blob present in source region and then from there ASR service picks it up and replicates to target region into disk snapshot. This data is stored temporarily and wouldn’t hold entire replicated data in blob. So, consider the data change rate of the entire data that you’re replicating. For example, if you’re replicating 1 TB of managed disk then concurrently if your data change rate is 5% then that much amount of data would stay in the blob storage. Which means 51GB per month. 

![Cache blob storage cost for DR](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/07022024/cache-storage-cost-dr.jpg)

## Snapshot

Once disk is created in DR, ASR retains almost 15 days of data which customer can select as RPO. You can consider 10GB for standard SSD and 20GB for premium SSD as the snapshot size. It depends upon the data change rate and the retention of the RPO.

![Snapshot required for incremental replication](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/07022024/snapshot-required-incremental-replication.jpg)

## Database VM

You can replicate SQL and other DBs via ASR but due to crash consistent nature of the replication whatever is there in-memory won’t be replicated. Also, this is no VSS writer compliant copy. The rate of change of DBs is high and sometime this won’t be supported either. We’ve 100MBps high throughput support for A2A ASR scenario too which you can validate. You can look for app consistent snapshot which can be enabled in the policy. So, considering all these factors if you’ve gone for DB native replication method and not ASR then you would need a lean DB VM up and running on DR region for A-sync replication to happen. If you’re running MS SQL then you can go for SQL Always On replication or Log shipping. If you’ve oracle DB you can choose Data Guard which is part of enterprise edition Etc.
Consider lean DB size, depending upon the CPU and Memory it takes for DBs to process the replication. It can be between 30 – 50% of the source DB CPU/Memory size. So you don't need exact same size of VM as source.

You can cover this as part of Reserved Instance to lower the cost.

## DR Drill (App and DB both)
You would want to run DR Drill just to see if your DR is functional. Considering DR Drill of 2 days half yearly would result in 96 hours of uptime for VMs. You would like to consider Production App VM and full-size DB for 96 hours per year. Consider premium disk cost for that many number of days.
Azure pricing calculator shows per month price, you may want to divide and find per day cost and then do the multiplication into number of days you run the DR Drill.

> Reserved Instanced purchased for running source VM won't be applied to VMs running in target(DR) region.
This is because RI is a regional construct. Savings plan can span region.
{: .prompt-tip }

## VNET peering

In the previous bandwidth section, it was for App VM replication via ASR but when you replicate DB it’ll be VNET Peering cost between two regions which is applicable, and you may want to consider that.

>First time it would be full replication of entire DB and hence cost would be higher. But once full replication completes it'll be incremental/ transactional replication which happens. Same full/incremental replication is applicable for ASR bandwidth size also.
{: .prompt-info }

![Cost of VNET peering in DR](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/07022024/cost-vnet-peering-dr.jpg)

## Common LZ Component

While you replicate VMs via ASR and do DB native replication this doesn’t make the entire solution. You may want to factor VPN Gateway from DR region or Express Route so that your branches can connect to servers. You may want to factor Firewall, Application gateway and traffic manager. traffic manager is important when you don't want DNS record to be updated. All these services shouldn’t be missed during DR pricing as this are important services which makes up your infra.

These are the components that we factor during DR.
I hope this is helpful.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
