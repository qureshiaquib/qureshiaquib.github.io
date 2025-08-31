---
title: "How to build a quick POC for Azure VMware Solution"
date: 2025-4-15 12:00:00 +500
categories: [tech-blog]
tags: [AVS]
description: "Learn how to set up an AVS POC using HCX, VPN Gateway, Express Route gateway and azure route server. In this blog we'll build architecture for quick POC"
---
* **Scenario**:
We’ve often seen customers planning to migrate to Azure VMware Solution who want to know how this migration would take place, how seamless it’ll be and whether the IP address can be retained when using L2 Stretch. All of this can be validated by conducting a POC, however where to start and what the network architecture of the POC setup would look like and how to have a disconnected/isolated POC is the main question.

* **Approach**:
In this blog post, we’ll cover how to quickly set up a POC for AVS and then migrate a few VMs to cement your understanding of how AVS works and how your servers can be migrated to AVS. Although, from a networking perspective, the setup in the POC can be very different than your actual production setup. This is because you’ll be using ExpressRoute to connect to AVS from on-premises. So, this POC setup is just to get the feel of AVS and how it really works. This really helps customers make informed decisions to adopt AVS and start the network architecture discussion for production workload.

    Please note: In this blog post I’ll not do step by step deployment of entire architecture. I’ll share the approach that you’ll need to take, which services need to be considered for POC and also some helpful links which will help you deploy services which are required for POC.

    We’ll now walk through the architecture in detail.

![Azure architecture showcasing VPN Gateway and Express Route with ARS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15042025/avs-poc-architecture.jpg)
_Download [architecture](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/15042025/avs-poc-architecture.vsdx) diagram_

1.  **HUB VNET creation**:
As this is POC, I suggest creating a separate VNET for HUB connectivity. Which will host all networking-related services.

2.  **VPN Gateway**:
This will be used for creating Site-to-Site IPSec tunnel so that you can connect on-premises HCX appliance to HCX appliance deployed within AVS. Once HCX pairing is completed, you can use it to migrate VMs from on-premises cluster to AVS.
You can also test connectivity between on-premises machines with migrated VMs privately.

3.  **Express Route gateway**:
You might wonder, if we already have a VPN gateway for site to site connectivity then why we have deployed Express Route gateway. This is used because AVS is currently not deployed within a VNET. These are physical nodes, isolated from Azure VMs that are deployed in a VNET. The feature of AVS in a VNET is currently in preview. So whenever you deploy AVS nodes and if you want it to connect to a VNET, you’ll need to do this via Express Route gateway. ExR Gateway can only connect to ExR circuit. So whenever AVS nodes are deployed there is a dedicated Express Route circuit which gets deployed and is available to you for free of cost.
    
    Kindly refer to the following link, which outlines how to create the required connections from Express Route gateway with the dedicated circuit of AVS.

    [https://techcommunity.microsoft.com/discussions/azure/avs-lab-deploying-avs-and-routing-internet-traffic-via-hub-azure-firewall-in-azu/4368807](https://techcommunity.microsoft.com/discussions/azure/avs-lab-deploying-avs-and-routing-internet-traffic-via-hub-azure-firewall-in-azu/4368807)

    Please Note: Data transfer between AVS and VNET via Express Route circuit is free of cost.

4.  **Azure Route Server(ARS)**:
You must be wondering, if we have IPsec tunnel established from on-premises to Azure, and connect Express Route gateway to AVS D-ExR circuit then both can talk to each other and your work is done. But it is not the case, since we have deployed the Hub VNET, it is non-transitive in nature. That means any site connected via VPN gateway cannot talk to site connected via Express Route gateway. You either need vWAN or you’ll need to deploy Azure Route Server in the HUB VNET.

    Once you’ve done that, you can go to the configuration and enable Branch-to-Branch connectivity which will help VPN sites connect with sites which are connected via ExR. i.e AVS.

    ![ARS config showing branch to branch](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15042025/ars-branch-to-branch.jpg)

5.  **HCX on-Azure**: 
You’ll need to deploy HCX appliance on AVS side, as the AVS product team has made this process straightforward with just a few clicks. Follow below link for the deployment.

    [https://learn.microsoft.com/en-us/azure/azure-vmware/install-vmware-hcx](https://learn.microsoft.com/en-us/azure/azure-vmware/install-vmware-hcx)

6.  **HCX on-premises**:
We’ll be using HCX to migrate VMs hosted on-premises vmware to AVS. 
HCX also provides a Network Extension (NE) appliance, which will stretch your port groups so that you can retain your IPs when you migrate your VMs from on-premises to AVS.

    Please note: you cannot extend a standard switch, so you need to have vDS (Distributed Switch) which only comes with Enterprise Plus perpetual license (it is also available if you’re using VVF/VCF)
    Make sure the vDS is tagged with a VLAN ID as untagged VLAN is unsupported.
    for a list of all unsupported configuration you can [click here](https://techdocs.broadcom.com/us/en/vmware-cis/hcx/vmware-hcx/4-7/vmware-hcx-user-guide-4-7/extending-networks-with-vmware-hcx/about-vmware-hcx-network-extension/restrictions-and-limitations-for-network-extension.html) to access the Broadcom documentation. 

    First, you’ll enable HCX on the AVS side, you’ll then download and install HCX Appliance on-premises, and then configure HCX Service Mesh which binds both the HCX appliances together. During the service mesh creation you’ll also select NE Appliance to be deployed if you need IP retention once server gets migrated. Once service mesh is online then you can Extend port group.

    A few important links are provided below.

    * HCX Installation:
    [https://www.youtube.com/watch?v=07W6u1d9kwE](https://www.youtube.com/watch?v=07W6u1d9kwE)

    * HCX Service Mesh creation:
    [https://www.youtube.com/watch?v=nzSjaOFh0Cs](https://www.youtube.com/watch?v=nzSjaOFh0Cs)

    * Migration over Network extension:
    [https://www.youtube.com/watch?v=6Hf2Kdq56zU](https://www.youtube.com/watch?v=6Hf2Kdq56zU)

    * Migration via HCX:
    [https://www.youtube.com/watch?v=wA--eKbTxzE](https://www.youtube.com/watch?v=wA--eKbTxzE)

7.  **Spoke VNET**:
This spoke VNET is deployed so that you can test and showcase connectivity from Azure VMs present in the Spoke VNET and those deployed within AVS. You’ll need to do VNET peering between HUB and Spoke. Once it is done, your VM can talk to each other with no further connectivity required.

We have not covered Firewall flows for VM which is migrated to AVS. You can refer below blog which I had written if you want to use Azure firewall with AVS.\
please note when you perform L2 Stretch then the gateway of that VM will reside on-premises and hence Azure Firewall won't take effect. Easiest approach is to migrate VM without L2 Stretch and you can use Azure Firewall for traffic Inspection. There are other option of MON, which we'll cover next time.

[Deploying Azure VMware Solution with Azure Firewall](https://www.azuredoctor.com/posts/deploy-azure-vmware-solution-azure-firewall/)

Once the POC is completed you can delete the temp POC Hub VNET and its components, although the AVS nodes can still be reused for VM deployment and you can connect AVS to your existing HUB VNET if you’ve production HUB running on Azure.

I hope you find this post helpful and that it assists you in deploying your POC environment quickly. Share the blogpost if you like it.

Happy learning

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }