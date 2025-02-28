---
title: "Handling Overlapping Address Spaces in AVS Without HCX"
date: 2025-2-28 12:00:00 +500
categories: [tech-blog]
tags: [Azure VMware solution HCX]
description: "Learn how to handle overlapping address spaces in Azure VMware Solution. using transit hub design and NVA. we'll have conflicting IP address on-prem & azure"
---

* **Scenario**:
One of my customers came to me with a requirement for VMware DR on Azure and they wanted to maintain overlapping addresses on both sides, DC and DR. For example, 10.10.10.10/32 would be associated to a VM in AVS, whereas the 10.0.0.0/16 segment would be present on-premises and VMs in that segment would communicate with VM hosted in AVS. There are a couple of VMs from the same segment that will be scattered between on-premises and Azure.
Additionally, they had a legacy application, and the OS was unsupported by Azure native VM.
Due to these challenges, rehosting the application on a newer version of the OS on Azure as an Azure VM was difficult.

* **Solution**:
One of the preferred solutions on Azure is to use Azure VMware Solution. AVS also supports Layer 2 stretch capability, which means port groups from on-premises VMware can be stretched to Azure VMware solution using HCX network extension appliance. However, customer’s environment was legacy and they had network address space of /16 CIDR which is a huge broadcast domain. Due to this, they couldn’t use the L2 stretch capability in the past. There was bandwidth congestion, high latency observed during L2 stretch implementation previously.
Hence customer preferred configuring /32 routes within the OS/VM/Server on DC side so that it reache its gateway, which has a /32 prefix for the resources running on another site (DR).
The challenge was: how do we achieve this on AVS? And at the same time VMs hosted on AVS should be reachable from VMs hosted on-premises with overlapping address space and a non-overlapping address space hosted on spoke Azure VNET.

* **Before we proceed, there are a few considerations**:
1.  The solution is to carefully implement transit hub design of AVS mentioned [here](https://learn.microsoft.com/en-us/azure/azure-vmware/architecture-network-design-considerations#transit-spoke-virtual-network-topology) and then using NVA within AVS. My recommendation is to thoroughly review the transit hub design, which forms the base, and then layer on the complexity of overlapping address space, resolving it via NVA within AVS.
2.  We recommend using the HCX appliance, which provides L2 stretch capability, allowing you to extend your on-premises network and achieve a similar solution. This solution in the blogpost is only designed for specific need of the customer where L2 stretch doesn’t work.

Let’s first discuss the structure of the setup on Azure.

In this picture, we have three sections: 1) Yellow demonstrates the on-premises setup , 2) Blue represents the entire Azure environment, 3) Pink is mapped to AVS, please ignore the components inside for now and we’ll deep dive later.

![overview of major components in AVS architecture](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/28022025/overview-architecture-showing-placement-of-avs.jpg)_figure1_


Requirement is mentioned in the diagram below.

![Explanation of overlapping address space requirement](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/28022025/requirement-understanding-of-overlap-address-space.jpg)_figure2_

Now, In figure1, we see an NVA positioned between VMs with overlapping IP addresses and the T1 gateway.
The reason for this is that if we attach the overlapping network directly to T1, it recognizes the subnet attached to it. And hence whenever traffic from Azure VNET or On-premises with same IP Address range passes through T0 and reaches T1 it blocks the traffic.

![Architecture diagram showing components required in overlapping IP Address between on-prem to azure vmware solution](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/28022025/avs-to-azure-vnet-connection-with-overlapping-ip.jpg)_figure3_

In figure3, we’re performing test which imitates on-premises to AVS connectivity with overlapping address space by showing Azure VM with conflicting address space. Please note, in the 2nd requirement of VM in Azure VNET connecting to AVS, there the Azure VNET won’t have overlapping address space. Because on-premises would also be connected to Azure via ExpressRoute or Site-to-Site VPN. Here the overlapping address space would be present in On-Premises and in AVS.

* **Breaking Down the Architecture Diagram**:

1.  We’ll be using UDR to instruct the VM to pass through Firewall/NVA device. 
2.  This NVA would be peered with Azure Route Server, and will advertise traffic to AVS. The routes that will be advertised is 10.10.10.204/32. This advertising route via NVA is common when you’re not using global reach design for AVS and manually advertising the routes via NVA which will attract traffic from AVS. 
3.  We’ll be placing UDR on the Gateway subnet which will instruct traffic to send the routes via Firewall/NVA. Which will make traffic symmetric.
4.  Similar to UDR on a subnet, here we’re instructing T1 to send the traffic to a overlapping VM IP via NVA place behind T1 Gateway. Here the NVA will make sure the traffic is passed through it, NVA would have incoming and outgoing network interfaces. NIC which is attached to VM network will have an IP from the same subnet range. If you’re planning to have large set of VMs behind NVA with different address range you’ll need to work on attaching new Network interface.
Please note, there is a limit to the number of NICs that can be attached to a VM in VMware. Along with that you’ll need to consider the NVA OEM and it’s limitation of max number of NIC.
5.  Once traffic reaches the VM, the outbound traffic will take the static route which is configured on that VM’s Operating system. This will instruct the VM to send the traffic back via NVA as next hop.

The network diagram below shows the traffic flow.

![Network flow of on-premise to Azure vmware solution in transit hub](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/28022025/network-flow-of-on-prem-to-avs-with-overlapping-ip.jpg)_figure4_

![End to End architecture diagram showing components required in overlapping IP Address between on-prem to avs](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/28022025/architecture-on-prem-to-azure-vmware-solution.jpg)_figure5_


In the figure 5 we’ve implemented transit hub design pattern of AVS. Where we’ve ARS present in Hub and transit Hub. Also NVA in the transit hub is BGP peered with ARS in the hub and transit Hub. This is intentionally done so that the routes advertised by AVS won’t leak to Hub Network and then to On-premises.

Similar to figure 3, in this figure 5 we’re using NVA inside AVS, traffic from FW NVA in the Hub would be sent to first to gateway present in the transit hub and then forwarded to T0 to T1, where T1 would have static route configured to send the overlapping VM traffic directly to NVA present within AVS. And NVA would forward the traffic to VM. Outbound traffic would take the same route back to maintain symmetricity.

Below diagram shows the traffic flow.

![end to end network flow from on-premises to AVS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/28022025/etoe-network-flow-of-on-prem-to-avs.jpg)_figure6_


I hope this blog post helps you design and adopt AVS.
AVS can help in quick lift and shift as well as can help you in complex scenarios.

* *Special thanks to [Shabbir Ahmed](https://www.linkedin.com/in/shabbir550/) for his collaboration, his efforts were instrumental in bringing this complex network solution to the community.*

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }