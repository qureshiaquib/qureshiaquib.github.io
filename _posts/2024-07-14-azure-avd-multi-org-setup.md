---
title: "Implement Azure Virtual Desktop in Multi-Organization Setup"
date: 2024-7-14 12:00:00 +500
categories: [tech-blog]
tags: [Azure Virtual Desktop]
description: "Learn how to implement Azure Virtual Desktop in a multi-org structure with disconnected AD forests using AD Connect Cloud Sync for seamless identity management"
---

* **Scenario**: One of my customers reached out, and they wanted to use Azure Virtual Desktop in their setup. The challenge they were facing was that they had two different sub-companies under one parent company, with two individual Active Directory Forests, and they wanted to adopt a single Azure Tenant for hosting AVD host pools. This would make management easier.

* **Solution**:
Two forests can be synchronized to Entra ID with the AD Connect tool if they had a Forest Trust. But in our scenario, these sub-companies didn’t want to establish a forest trust between each other.
The IT team was unified for both companies.

The solution in this scenario was to use the new AD Connect Cloud Sync tool. 
It provides synchronization of identities in disconnected forest scenarios. Both forests will have a machine running the AD Connect Cloud Sync tool. In contrast, with the AD Connect sync tool, we usually install it on one machine and have a forest trust established between each of the domains which you want to sync the identities.
This blog isn’t about the step-by-step setup of the AD Connect Cloud Sync tool, as the configuration is very similar to the old AD Connect tool. Also, we’ll mainly focus on the overall strategy adopted to host AVD in a single tenant and its architecture, which can be reused.

![Azure architecture diagram showing multi org VDI deployment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14072024/azure-architecture-avd-multi-org.jpg)
_Download [visio file](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14072024/azure-architecture-multi-org.vsdx) of this architecture_


The following flow corresponds to the preceding diagram:
1.	AD Connect Cloud Sync: We’ve installed AD Connect Cloud Sync tool on-premises, which supports disconnected forest – which don’t have any forest trust in between.
here in our scenario both the Active Directory would be synchronized to single Entra ID tenant where our Azure Landing zone is configured.
This is only done because both the companies are part of the single parent organization and also their IT team is centralized.
2.	VPN Gateway: We’ve Virtual Network Gateway connected with both the on-premises sites. There can be multiple tunnels from single VPN GW. As an alternate pattern if you need further segregation of network traffic then another VPN Gateway can be deployed in separate HUB VNET which will be multi Hub deployment. We’ve considered single VNET deployment for connectivity. There will be a Route table attached on the VPN gateway subnet which points traffic destined for spokes VNET sent to Firewall.
3. Firewall: We’ve Azure Firewall in the HUB VNET for network isolation between both the VNETs of the customer 1 and customer 2. Also on-premises traffic from customer 1 would only reach customer 1 VNET. Hence achieving traffic isolation.
4.	Additional Active Directory: We’ve separate ADC servers deployed in individual subnets. Also we’ve NSG (network security group) attached to subnets for network filtering.
5.	Resource Group: We’ve two different Resource Groups for segregating AVD specific resources which will be deployed. Both the resource groups will be created in AVD specific subscription created in the ALZ.
6.	Spoke Virtual Network: We’ll deploy 2 separate VNETs for hosting the host pools of AVD and also to create private endpoints. This provides separate isolated host pools for two different companies. We'll have Route table attached on the subnets where host pool VDI is deployed. Routes will have next hop as Azure Firewall.
7.	Azure Virtual Desktop: We’ll be deploying two separate host pools, workspace and application groups for hosting VDIs. Windows Images for preparing host pools would be separate.
8.	Storage Account: We’ll have two separate Storage accounts for hosting Azure File share. . AFS is used to store profiles in Pooled session host scenario. These file shares would be enabled with private endpoint in their respective VNETs.

I hope above scenario will help when you want to configure VDI environment in a multi organization structure.

Happy Learning! 

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }