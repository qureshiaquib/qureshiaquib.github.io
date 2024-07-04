---
title: "How does Azure Backup Traffic Flow works?"
date: 2024-2-16 12:00:00 +500
categories: [tech-blog]
tags: [Azure Backup]
---

## Scenario
Few of my customers inquired about how data transfer happens when using Azure Backup and whether if they have a firewall configured in the Hub, does the backup data flow through the firewall?

## Explanation

Let’s talk about customers who’s using Azure Backup or any third party backup. The destination is most likely Azure Blob Storage as that’s the cheapest form of storage on Azure cloud. But very few would have a single VNET and also a Recovery Services vault which is deployed in the same subscription to take the backup. Most of the enterprises would use some type of firewall for traffic inspection for outbound traffic from VMs. This can be Azure Firewall or a third-party firewall like Palo Alto, Fortigate, etc.

There are two types of backup. First is non-stream backup and other is streaming backup. 

## Non-stream backup

Non-stream backup happens without needing to open any public IP communication. The Azure Backup extension is installed on each of the protected VMs. The extension helps in taking an app-consistent snapshot of the disk. Once the snapshot is taken, the Azure Backup service would transfer only the changed bits from that snapshot to the Azure Backup managed storage account. This happens in the backend over Azure Fabric without any Public IP communication involved, and hence no traffic passes through the Firewall. You really don’t need to allow any public IP in the NSG or Firewall for this as this happens over the management plane. This case is only applicable to Azure VM backup.

## Streaming backup
Applicable to SQL or HANA on Azure VMs this streaming backup means there would be agent which would be installed as part of backup onboarding and that agent would help data transfer to azure backup managed storage. As this is a DB backup, hence we require agents which basically take the incremental and transactional backup of the DBs. This doesn’t happen over the management plane or Azure Fabric and as data transfer happens from within the VMs, hence all the network restrictions also apply to this type of traffic. If you’re using Azure Firewall and all your outbound traffic to the internet traverses through it, then you’ll need to open Entra ID, Azure Backup, and Azure Storage account public IP addresses in Firewall, we do have service tags so you can make use of that. These are by default public communication. You can configure a private endpoint for Azure backup and all this traffic apart from Entra ID would be private. Which I’ll cover as part of the next blog.

### Backup Data via Firewall

Assume you’ve gone with public communication of Azure Backup for stream aware backup (SQL or HANA) as you’re using firewall appliance the UDR route of 0.0.0.0/0 applies to the backup traffic. Which results in all the backup data to be passed through the firewall. When you’ve large data to be backed up or have multiple SQL and HANA DBs your data path would be first from spoke VNET to Hub VNET over VNET peering. And then from firewall outbound over to public IP. The traffic stays within Microsoft backbone but Firewall processing charge applies and so do VNET peering charges. 

Along with above If you’re using third party NVA then you’ll need to factor the licensing basis on the throughput it handles and because of Backup traffic FW license cost also blows up.

Below architecture diagram shows how backup traffic flows through Firewall.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16022024/picture1.jpg)

1 – Management traffic with Azure Backup Service\
2- Data path for backup\
In this scenario, path is same and not different.

### Backup Data bypassing the Firewall

Assume you don’t want backup traffic to flow through Firewall. This can be because of multiple reasons, but do you have a choice in this scenario? Yes. Below method can be used.\
When we enable Azure Backup there are two types of traffic. First is management traffic and second is actual data traffic in which data gets copied to Microsoft managed storage account.

You must be aware about Service Endpoints feature. Which basically is available for multiple PaaS services. This feature is available for Storage account too. So when we enable Service Endpoint on a Subnet, VMs where backup is initiated would connect to backup management plane over internet and follow the UDR. Which basically takes the management plane traffic to hit firewall. Once that is done and actual backup starts the data transfer over to *.blob.core.windows.net happens over service endpoint and this doesn’t traverse through firewall. The data traffic is bypassed. The reason is we’ll have service endpoint applicable for entire resources present in the subnet which tells that this is known traffic and doesn’t fall under the 0.0.0.0/0 traffic. You can validate this by going to NIC of the VM and checking the effective route.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16022024/picture2.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16022024/picture3.jpg)

1 – Management traffic with Azure Backup Service\
2- Data path for backup

Now story doesn't end here, there are some disadvantages associated with this. When Service endpoint is enabled allows communications for all the storage account in the same subscription or any storage account from any tenant (technically any customer). You can block rest of the storage account and only allow specific storage account to be accessible via service endpoint policies which is available with azure storage. But this is applicable for storage account that you know. As Azure backup uses Microsoft managed storage account because of the isolation and air gap hence you won’t be able to configure service endpoint policies in such scenarios. If you’re using third party backup solutions and you own the SA in your own subscription then Service Endpoint Policies can be configured.
If you really needed protection against data exfiltration with Azure backup then using private endpoint is the only choice as of now.

I hope above article was useful and will help you make backup and networking decisions in your architecture.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }

