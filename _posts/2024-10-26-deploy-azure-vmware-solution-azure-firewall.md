---
title: "Deploying Azure VMware Solution with Azure Firewall"
date: 2024-10-26 12:00:00 +500
categories: [tech-blog]
tags: [Azure VMware Solutions]
description: "Explore Azure VMware Solution in a hub-and-spoke setup and using existing Azure Firewall, BGP peer with open-source NVA for advertising default route"
---

* **Scenario**: During a recent engagement, a customer wanted to deploy Azure VMware Solution in their existing landing zone. This LZ was already deployed to serve their multiple spoke environments deployed in different Azure subscriptions. One of the challenges that we encountered was the customer using traditional hub and spoke model and using Azure Firewall in the Hub VNET, essentially utilizing this firewall to reach out to internet for outbound communication.

    If you deploy AVS, there are many ways you can deploy Firewall for egress/outbound traffic. One inside AVS, which can be third party NGFW or one outside in Azure LZ.

    If you want to use Azure Firewall present in the hub, the challenge that you’ll face is advertising the default route to AVS. (0.0.0.0/0). This blog addresses this particular use case.

* **Solution**: Since AVS is not hosted in a VNET. And it has its own networking construct on Azure. You cannot attach a UDR as you would to a subnet.\
As there is no concept of UDR in AVS you cannot force Internet bound traffic to Azure Firewall.\
AVS learns all routes dynamically through BGP; thus, we’ll need to push these routes to AVS in different ways. 

    The solution is to have an Azure Route server in the Hub VNET and then deploy NVA which can do BGP peering with ARS and then NVA will push default route which points to the Azure Firewall.\
    This NVA can be any BGP capable device. It can be a Cisco, Palo Alto or FortiGate appliance.\
    If your customer doesn’t have any 3P NVA appliance, then you can deploy open-source FRR on a Linux VM on Azure.

![Azure architecture diagram showing AVS and Azure Firewall with ARS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/26102024/azure-architecture-diagram.jpg)
_Download [visio file](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/26102024/avs-architecture-with-azure-firewall.vsdx) of this architecture_


## AVS Networking options
Before exploring the third party (3P) NVA option, I wanted to share the official documentation which has multiple networking scenarios documented related to AVS. It contains vWAN approach with Secure Hub, basically Azure Firewall in the Hub. The reason I’m highlighting this is because if your deployment is greenfield and the customer wants to proceed with Azure Firewall then you can use vWAN and then you don’t need a third-party (3P) NVA device to do BGP peer and push default route. This can be done easily.

The documentation below will assist with network design.\
[https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/network-hub-spoke](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/network-hub-spoke)

Also below guide will help in entire network design.\
[https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/network-design-guide-intro](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/network-design-guide-intro)

## Azure Route Server in the Hub VNET
I thought of first covering ARS and why it is required in the Hub when you’re planning to have AVS.

There are a few main reasons to deploy ARS in the Hub VNET:

* When you deploy AVS and you wanted to connect it to Hub VNET you’ll deploy Express Route Gateway in the Hub VNET and connect it to AVS Dedicated ExR circuit.\
In order advertise all network segment present inside AVS to all the Spoke VNET which are peered with Hub, ARS will do this dynamically without any manual intervention.

* ARS will also help in publishing default route (0.0.0.0/0) to AVS so that existing firewall can be utilized. additionally, if you want all communication from AVS to the spoke VNET to pass through the NGFW, this can be achieved.

* If you’ve VPN S2S IPSec tunnel between on-premises and Azure with Azure VPN Gateway then in order to propagate the on-premises route into AVS and enabling transit connectivity between VPN gateway and ExR Gateway that is connected to AVS, you require ARS.

For all the above, you’ll need an Azure Route Server in the Hub VNET.

>Please note: 
when you deploy ARS there is a brief amount of downtime till the time deployment is completed so plan this accordingly.\
ARS requires Active-Active VPN Gateway. If you’ve a VPN without this deployment method, you’ll need to enable active-active mode first before deploying ARS.
{: .prompt-warning }

## AVS with Azure Firewall
Now that the groundwork of sharing AVS networking scenarios and explaining why ARS is required is done, we’ll discuss AVS with Azure Firewall and how does it really work in little detail.

As I mentioned we cannot attach UDRs on AVS to force Internet traffic to pass through Azure Firewall. AVS gets deployed along with a dedicated express route circuit which is free. We’ll need to create Express Route gateway can connect to the AVS provided ExR circuit. Once this is done we’re connected with HUB VNET, now we’ll be able to push routes to AVS via Express Route gateway through BGP. This routes can be default route 0.0.0.0/0 or any other route.

We’ll need some third-party NVA device to connect with ARS and then advertise default routes which then gets advertised into AVS. After which routes will be received by T0 and T1 gateways.

If you have an SD-WAN device like Cisco or Fortigate SDWAN then these devices can do BGP peering with ARS. However if you’ve basic VNET design without 3P devices then you can deploy open source NVA like FRR on two Linux VMs, providing high availability. Once FRR is installed then you can do BGP peering with ARS and then publish static routes to AVS via BGP.

Below document will help you install FRR and configure routes

[https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/BrownField/Networking/Step-By-Step-Guides/Expressroute connectivity for AVS without Global Reach#step-7---configure-routing-on-the-bgp-capable-nvas](https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/BrownField/Networking/Step-By-Step-Guides/Expressroute connectivity for AVS without Global Reach#step-7---configure-routing-on-the-bgp-capable-nvas)

>Keep in mind that this NVA is only required to advertise routes, NVA will not be in the data path. VMs in AVS will directly talk to Firewall via Express Route gateways. Hence you don’t need to size the VMs with high CPU and memory, as it will only be used to advertise routes to AVS.
{: .prompt-info }

The Azure Route Server is also only for learning and advertising routes. It doesn’t come anywhere in the data traffic flow.

![Azure architecture diagram showing egress traffic through Azure firewall from VMs hosted in AVS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/26102024/azure-architecture-diagram-internet-flow.jpg)

I hope this blog helps you in your AVS deployment.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }