---
title: "Inject static routes in ExpressRoute with dummy VNET or ARS"
date: 2025-5-30 12:00:00 +500
categories: [tech-blog]
tags: [Advertise Routes]
description: "Learn how to inject static routes from Azure to on-premises via ExpressRoute using the dummy VNET approach with UDR and NVA integration techniques"
---

* **Scenario**:
One of my customers had a brownfield deployment in Azure and they were transitioning one of their entities to SD-WAN from MPLS. SD-WAN appliances were deployed in the Hub VNET on Azure. All the branch sites were connected to on-premises and Azure via their MPLS which they wanted to replace with SD-WAN.
However branch site connectivity to other entities hosted on-premises would still connect via Express Route.

    So essentially the flow is Branch Site -> Azure SD-WAN -> via Express Route -> on-premises (other entities). 

* **Challenge**:
The challenge which they were facing was how to advertise or inject branch site routes to on-premises from Azure over Express Route. As ExpressRoute is BGP enabled we can’t push static routes from Azure.

* **Solution**:
Before we discuss the solution, let’s understand the scenario. Customer had a complex Hub network design where a lot of entities were connected via individual ExpressRoutes. They had Application Gateway, NAT gateway and Third party NGFW deployed in connectivity subscription. Due to these complexities, they didn’t want to move to a new vWAN based architecture or even implement Azure Route Server yet because they were in middle of the SD-WAN migration.\
Now that we have discussed why we can't convert the requirement to vWAN or more innovative architecture approach, let's discuss the solution.

    * Solution A: use a dummy VNET design. It is sometimes referred to as a Ghost VNET or advertising VNET. (use it cautiously)
    * Solution B: use Azure Route Server (Recommended)

    Let’s discuss each solution and how it’ll work.

## Solution A
* Task 1 : As the name suggests, you’ll need to create a VNET. The address space of that VNET will be the one which you want to advertise on-premises via Express Route. We create VNET on Azure and peer the same with Hub VNET where ExR Gateway resides which basically advertises the routes to on-premises. The key point here is that we will not create any subnet in that dummy VNET or host any VMs. We’ll just keep it as it is. Make sure you enable "Use Remote Gateway" in the VNET peering from spoke side.
* Task 2: We’ll need to attach a UDR to the gateway subnet and add routes which correspond to address space present in the dummy VNET, next hop for these routes would be the load balancer IP which has SD-WAN NVA in the backend pool. Now as soon as traffic from on-premises traverses ExpressRoute and reaches the ExpressRoute gateway, the gateway redirects the traffic to SD-WAN instead of sending it to dummy VNET.

Similarly, if you’ve any VMs present in spoke VNET and wanted to reach out to SD-WAN then you can have similar UDR which directs traffic to SD-WAN Load balancer IP.

![Azure architecture diagram showing dummy vnet to inject routes into the VNET](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30052025/inject-static-routes-dummy-vnet.jpg)_Download [visio file](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/30052025/inject-static-routes.vsdx) of this architecture_

## Solution B
Solution A, which we have discussed previously, is legacy option which we’ve been using for a while. Now as we’ve Azure Route server service present this architecture is the recommended approach. We’ll be using ARS in this and perform BGP peering between SD-WAN NVA and ARS. Once BGP is up, you can publish branch site routes over the BGP connection which will be learned by the ARS. Along with that, enable Branch to Branch option in Azure Route server which lets ARS exchange routes with VPN or Express Route gateway. Once this setting is enabled all the routes advertised by SD-WAN NVA will be advertised over ExpressRoute.

![Azure architecture diagram showing ARS connected with NVA](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30052025/inject-static-routes-ars.jpg)

I hope the scenario helps you understand the options at hand to inject or advertise routes from Azure when using ExpressRoute or BGP VPN gateway where static routes can't be pushed. Share the blogpost if you like it.

Happy learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }