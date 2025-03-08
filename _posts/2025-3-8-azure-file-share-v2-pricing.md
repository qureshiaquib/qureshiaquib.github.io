---
title: "Azure File Share v2: Cost-Effective & Predictable Pricing"
date: 2025-3-8 12:00:00 +500
categories: [tech-blog]
tags: [Azure File Share v2]
description: "Learn how Azure File Share Provisioned v2 simplifies pricing, improves cost predictability, and enhances BCDR with Azure File Sync and vaulted backup in Azure"
---

We have been using Azure File Share for a while. There are many use cases AVD, SAP, General File Server etc. The Standard and Premium tiers cater to most NAS requirements. Whether the workload consuming the share resides on Azure or on-premises.

With the new introduction of Azure File Share provisioned v2 model, the adoption of Azure File Share is expected to change significantly, as the new tier provides better price predictability and a more cost-efficient NAS option on Azure.

In this blog, we’ll explore how the new tier differs from the older one. And then we’ll cover one of the BCDR use cases. Where you can replace your on-premises backup and DR solution for File Share with Azure File Sync feature.

## How Azure File was priced previously:

* **Azure File Standard was charged based on the following parameters (tier name: Pay-As-You-Go)**
    * Storage size (Transaction Optimized, Hot, Cool)
    * Transaction cost (Read, write, list, other transactions)
    * Data retrieval Cost (Only for cool tier)

* **Azure Files premium (Provisioned v1)**
    * Storage Size
    * Provisioned IOPS
    * Provisioned Throughput

For simplicity, I have not included snapshot costs or data egress costs associated with Azure File Share.

* In standard tier, the challenge was price predictability, as there was no IOPS and throughput which was used for billing, the transactions count was used for billing purpose. And predicting the transaction count was difficult. 
* As the transaction cost was high on Cool tier and data storage was cheaper, Choosing between hot, cool, or 
transaction-optimized tiers was a difficult decision for customers.

## How Azure Files v2 is priced:
The new Provisioned v2 model simplifies both of these challenges. Customers no longer have to worry about transaction counts, and tier selection (hot, cool, etc.) is no longer necessary.

* **Advantages**:
    * Price Predictability: Since there is no transaction count involved, costs are more controlled through IOPS and throughput selection, which customers can manage. They can set the IOPS/Throughput on particular file share and also monitor the usage via Azure Monitor. If particular file share is not used much then they can reduce it.
    Similar to Disk IOPS burst, Microsoft allows IOPS/Throughput bursting if credits are available. 
    * Lower Cost: Since there are no cool, hot, or transaction-optimized tiers the base cost of the file storage itself is low. Customers now don’t need to worry about which tier to select. They just have to move the data to file share and enjoy the low cost storage. 
    * The price difference between the PayG tier and the Provisioned v2 tier can be as much as 50%, making it a significantly more cost-effective option.

* **Things to be aware about**:\
Since this is a new tier that recently became GA, there are a few considerations to be aware of.
    * No availability of hot and cool tier.
    * Currently, it does not support reserved instances. However, the price is still lower compared to the three-year reserved instance cost of the Azure Files PayG tier. RI is in roadmap.
    * Azure File Sync is fully supported.

The new Azure File Share provisioned v2 is GA.

![Storage account creation for azure file share provisioned v2](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/08032025/file-share-creation.jpg)

![File share creation step](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/08032025/file-share-creation-step2.jpg)

![Specifying IOPS and Throughput in Azure File share](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/08032025/fileshare-creation-step3.jpg)

## Azure File Sync with Provisioned v2 Model:
Azure File sync is used to sync file share from on-premises to Azure. You can enable cloud tiering, which ensures that the on-premises file server has free space by tiering older, unused files to Azure Files. File metadata remains on-premises, and whenever a user clicks on a file, the data is downloaded and presented to them. Along with that it provides File server DR option.
While Azure File Sync has been available for a while, you can now use it with the Provisioned v2 File Share to achieve a low-cost backup and DR solution.

![Architecture showing Azure File Sync](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/08032025/file-sync-architecture.jpg)_architecture diagram from azure architecture centre_

## Backup Types: 
The reason I mention Azure File Sync is that you can use Azure Backup to back up on-premises file shares once they are synced to Azure File Share. So basically, you don’t have to take on-premise backup and let azure backup continue to take incremental backup on Azure. It meets both off-site backup purpose along with that DR of your file share.
* **There are two types of backup for Azure File share**
    * **Snapshot based**: Snapshot backup has been available for a while; the data is stored in the file share itself as a snapshot. However the scheduling and restoration happens through the Recovery services vault.
    * **Vault Based**: Vaulted backup for Azure File share stores data in recovery services vault just like Azure VM backup, backup storage is different than actual file share. This saves you if you lose access to file share itself because of rogue admin deleting the file share or because of ransomware.
    Vaulted backup recently became GA, and its pricing was released on March 8, 2025. 

* **Things to be aware about vault backup**:
    * Vault backup currently doesn't support item level recovery. You can only do full file share level recovery.
    currently it is in roadmap and soon will be available. In order to get Item level recovery functionality when you consider backup, make sure you keep snapshot for longer period of time. Assume you often do recovery for accidental deletion and users come to you after 2 weeks then you keep snapshot for 14 days. As you can do item level recovery for snapshot based backup this can come to you for rescue while still opting for vault backup.
    * Currently vault backup support max file share size upto 10TB. very soon you should be able to back larger share.

Below diagram shows the snapshot setting which you can modify.
![Snapshot in the vault backup policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/08032025/backup-policy.jpg)

Below architecture diagram shows about the Azure Backup, File Share and Azure File Sync.

![Architecture showing backup of Azure Files](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/08032025/backup-of-azure-file-share.jpg)

Using Azure File Share Provisioned v2, syncing files via Azure File Sync, and backing up these synced file shares via Azure Backup can help address the BCDR challenges of your on-premises hosted file server.

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }