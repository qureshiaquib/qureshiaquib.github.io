---
title: "Cisco SDWAN Deployment in Azure with Hub-Spoke Model"
date: 2024-11-20 12:00:00 +500
categories: [tech-blog]
tags: [Cisco SDWAN]
description: "Learn how to deploy Cisco SDWAN in Azure using a hub-spoke model, integrate Azure Firewall, and simplify routing with Azure Route Server and UDR configurations"
---

* **Scenario**: I’ve come across a scenario where a customer wanted to deploy Cisco SDWAN in a transit hub deployment (Hub and Spoke model). Cisco SDWAN integrates with Azure vWAN and all the routes are pushed via the vManage portal which makes the entire routing simpler, but customer had selected Hub and Spoke model of VNET design for them. They also had Azure Firewall in the hub VNET.

* **Challenge**: Cisco team has provided very detailed article where different types of deployment model are covered. vWAN and Hub and spoke both are covered. However it showed VPN gateway in all the spoke VNETs where the workload is hosted and it connects with HUB where Cisco SDWAN is deployed.

    [https://www.cisco.com/c/en/us/td/docs/solutions/CVD/SDWAN/cisco-sdwan-cloud-onramp-iaas-azure-deploy-guide.html](https://www.cisco.com/c/en/us/td/docs/solutions/CVD/SDWAN/cisco-sdwan-cloud-onramp-iaas-azure-deploy-guide.html)

    There were two main challenges.\
    a) Customer wanted to use VNET peering between spoke and hub instead of deploying VPN Gateway in spoke.\
    b) They wanted dynamic route propagation so that whatever routes are learned by Cisco SDWAN is also learned by Azure Firewall so that they don’t have to keep on updating route table whenever a new route is learnt by Cisco SDWAN.

* **Solution**: We used Azure Route server in the Hub VNET. Also we used VNET peering between Hub and spoke VNET. VNET peering is simple however customer wanted traffic inspection through Azure Firewall which makes entire routing a little complex.

This blog discusses the services required to set this up, we won't go through the cisco sdwan configuration step by step, instead we show you UDR configuration and guidance regarding the traffic flow.

![Azure architecture diagram showing cisco sdwan and azure firewall along with Azure Route server](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20112024/cisco-sdwan-architecture.jpg)
_Download [visio file](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/20112024/cisco-sdwan-architecture.vsdx) of this architecture_

The list of services used in the architecture is below:

* Cisco SDWAN: This is the Cisco SDWAN deployment which will be on two NVA VMs. There will be an external public load balancer which will have a public IP for inbound connectivity to SDWAN, this will be inbound from internet. Also there will be a private load balancer for accepting traffic from spoke VNET or Firewall. 

* Azure Firewall: This is Azure Firewall. In a scenario where traffic needs to be inspected for outbound internet connectivity from spoke VNET. Also traffic from spoke VNET and SDWAN branches can be inspected via Azure Firewall with the help of UDRs.

* Azure Route Server: Azure Route Server is required to exchange routes learned by Cisco SDWAN and propagate them to the local VNET. You’ll need to do BGP peering between ARS and Cisco SDWAN. Without ARS you’ll need to update routes in the UDR every time there is an update in the system.

* Spoke VNET: This VNET will host spoke VMs.

* UDR: UDR is required in this design, and it is crucial to maintain symmetric routing. UDR will be associated to multiple subnets.

    - UDR1 - Route from Spoke to Firewall: This UDR is attached on the subnet present in spoke VNET. It’ll have 0.0.0.0/0 route which is pointed to Azure Firewall private IP Address. This is done because of two reasons, 
	a) Traffic from spoke to internet should be inspected via Azure Firewall.
	b) Traffic from spoke to SDWAN branches should also be inspected via Azure Firewall.

        One important thing, you need to goto configuration of UDR and make sure you set propagate gateway routes to No. The reason you need to do this is because ARS will propagate all the SDWAN routes to it’s peered VNET which is spoke VNET. And if that happens then Spoke VNET will directly route traffic to Cisco NVA instead of Azure Firewall.
    
    - UDR 2 – Route from SDWAN to Azure Firewall: This UDR is attached on the Cisco NVA Subnet. This will have routes of Spoke subnet and next hop as Azure Firewall. This is required so that traffic is symmetrical. Otherwise Cisco NVA will send the traffic directly to Spoke which makes traffic asymmetrical. Because of which Azure firewall may drop the traffic.
    
    - UDR 3 – Route on Azure Firewall: This UDR is attached on Azure Firewall. It will have 0.0.0.0/0 route and next hop as Internet. So that all internet bound traffic reaching Azure Firewall goes to internet directly.


Below architecture diagram shows the traffic flow from Spoke VNET to branch and also spoke VNET to internet via Azure Firewall.

![Azure architecture diagram showing traffic flow in cisco sdwan and azure firewall](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20112024/azure-network-flow-diagram.jpg)

I hope this blog helps you deploy Cisco SDWAN in Hub and spoke model and hope it provide you clarity around the use of UDR.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }