---
title: "Exploring ExpressRoute Peering Locations for Azure"
date: 2024-09-16 12:00:00 +500
categories: [tech-blog]
tags: [Azure Express Route Peering Locations]
description: "Explore the role of ExpressRoute peering locations in optimizing on-premises to Azure connectivity, covering private connectivity scenarios"
---

This blog talks about Express Route peering location and what importance it plays in connectivity when you connect from on-premises to Azure. I'll be covering majorly Express Route private connectivity scenarios.

## ExpressRoute Peering Location
This location is hosted near an Azure region. Typically, a few kilometers apart. Peering location is where Microsoft edge routers are placed. Microsoft has partnered with set of ExpessRoute providers and they’ve placed their routers in the cage present in the same facility and cross connection is done already with Microsoft Edge routers so they can serve customer traffic. Every region has at least one peering location which is near it for customer and azure region connectivity. There can be more than one.
So please keep in mind Azure regions are different than express route peering locations.
This is also known as Meet Me location.

![Azure Architecture diagram showing Express Route peering location and Azure region](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16092024/architecture-of-express-route.jpg)
_Download [architecture](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/16092024/visio.vsdx) diagram_

![Screenshot of Expres Route circuit location and peering location](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16092024/expressroute-peering-location.jpg){: w="600" h="1100" }

While creating circuit, circuit location is where your ExpressRoute gateway (ExR GW) and all your regional Azure services resides.

## ExpressRoute Peering Point to Azure Connectivity
As mentioned above, Azure services are hosted in an Azure region. To connect to on-premises through ExpressRoute (ExR), the connection passes through a peering location. One of the important aspects here is once you’re connected to one peering location you can connect to Azure services in any region. (more of standard ExR Circuit and Premium Tier down below).

![Azure architecture diagram showing one express route peering location connecting to two azure region](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16092024/peering-location-connecting-two-regions.jpg)

From on-premises once your traffic reaches ExR peering location from there to Azure region it’s all Microsoft backbone connectivity. Also there is no extra cost apart from standard network bandwidth egress charge. Even if your peering location and ExpressRoute circuit reside in different cities.
Though you can connect to multiple regions from a single peering location, you should have multiple express route circuits per region so that you’ve redundancy so that if one peering location goes down your traffic flow still works through second peering location.

Learn more about the Microsoft backbone network
[https://learn.microsoft.com/en-us/azure/networking/microsoft-global-network](https://learn.microsoft.com/en-us/azure/networking/microsoft-global-network)

## ExpressRoute Circuit Premium Add-on
By default standard ExR Circuit can connect to any VNETs in the same geopolitical region.
You can check Geopolitical boundary here

[https://learn.microsoft.com/en-us/azure/expressroute/expressroute-locations?tabs=america%2Ca-c%2Cus-government-cloud%2Ca-C#locations](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-locations?tabs=america%2Ca-c%2Cus-government-cloud%2Ca-C#locations)

one of the benefits of premium add-on of ExR Circuit is, it allows you to connect VNETs hosted in different geopolitical region to an ExR circuit present in any Azure region across Azure public regions.
For example ExR Circuit created in US can connect to VNETs which are hosted in Europe Azure regions. 

## ExpressRoute Traffic Flow
As Express Route peering location is the entrance and leaving point for traffic movement.
If you’ve created a circuit with peering point which is far away from your location then to first reach Azure region your traffic will first reach the Azure peering location and then connect to the Azure region. The return traffic will follow the same route. 
Please check below diagrams of 1 and 2 where Peering point in City 1 is closest to datacenter and peering point in city2 is far from region and datacenter. If you’ve used city2 peering location then your traffic will move through the same location which will cause latency in the communication.

![Azure architecture diagram showing network flow from local peering point in the same city](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16092024/expressRoute-traffic-flow1.jpg)

![Azure architecture diagram showing network flow from a peering point present in different city](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16092024/expressRoute-traffic-flow2.jpg)

## ExpressRoute Metro
ExR Metro is a new tier for Express Route, which is built to provide resiliency of Express Route peering location by having two connections from your WAN provider to two different ExR Peering points. These peering locations will be in the same city. Currently Express Route metro is in preview in certain regions only.

If your region doesn’t support ExpressRoute Metro you can still have two express route circuits terminating to two different peering locations to get the resiliency of the circuit.

[https://learn.microsoft.com/en-us/azure/expressroute/metro](https://learn.microsoft.com/en-us/azure/expressroute/metro)

## ExpressRoute Local circuit
As mentioned above, once an ExpressRoute circuit is created it can connect to any region within the same Geopolitical zone if it’s standard ExR Circuit, or across any Azure Public region if it’s ExR Premium Add-on enabled. However, there is another type of ExpressRoute tier called ExR Local.
This is used when you have high egress from Azure to on-premises, which makes ExR Local commercially viable because egress charges are completely free in this tier. However, it comes with higher plan of 1,2,5 & 10 Gbps.
So why are we covering ExR Local in this blog? Because once an ExR Local circuit is created, it can only connect to the region local to that peering location.

![Table showing Express Route local and it's association to Azure region](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16092024/express-route-local.jpg)

Below link shows peering point and associated region with it.
[https://learn.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers?tabs=asia%2Cn-q%2Ca-k#partners](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers?tabs=asia%2Cn-q%2Ca-k#partners)

I hope above scenario helps in deploying your express route more efficiently.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }