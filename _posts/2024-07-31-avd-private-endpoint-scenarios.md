---
title: "Azure Virtual Desktop: Private Endpoint Scenarios Explained"
date: 2024-7-31 12:00:00 +500
categories: [tech-blog]
tags: [Azure Virtual Desktop Private Endpoint]
description: "This blog covers configuring private endpoints for Azure Virtual Desktop, detailing scenarios and considerations for using public and private access"
---

* **Scenario**: As Azure Virtual Desktop can be used across multiple teams in an organization and when you’re configuring AVD in a banking environment or large enterprise, there can be multiple scenarios you’ve one team working remotely and need public internet to connect to AVD and another team connected from the head office and they should only be connected to AVD privately over ExpressRoute.

* **Solution**: Just like other managed services, private endpoint is also supported for AVD environments.
But this can be tricky at times, as mentioned in the above scenario. It’s not only the host pool in your subscription for which you’ll need to enable Private Endpoints but at the same time you’ll need to enable it for the managed components. The managed components are management plane for AVD (Broker, Gateway, Web, diagnostics, Feed) which first takes the traffic and then connection to host pool is established. Private Endpoints need to be configured for those components which don’t reside in your subscription and are managed by Microsoft.

This blog covers different Private Endpoint scenarios in Azure Virtual Desktop Environment. Multiple scenario arises when you have multiple AVD usage in a single environment/organization by different team. I’ll also cover basic Private Endpoint scenario as well.

Before we proceed with the scenarios. Let me briefly cover different types of private endpoints are there in AVD environments.

![Table showing different types of Private Endpoints in AVD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/avd-privateendpoints-table.jpg){: w="400" h="800" }


Out of the three Private Endpoints, initial feed discovery (Global) PE is created only once for the entire organization. So please don’t create multiple endpoints for initial feed discovery for every AVD workspace you deploy; we’ll only have three records and it’ll keep on updating the DNS records with the new PE which you create.\
If you have multiple workspaces, then you’ll have to just create the initial feed discovery private endpoint once for your organization, rest of your workspace can live without Initial feed discovery. More related to global PE will be covered in scenario below.

## Scenario 1: Private Endpoint for Workspace and Host Pool
This scenario applies to a single AVD use case in the organization. As the heading suggests, we’ll have to create private endpoints for the workspace and for host pools. This will ensure entire AVD traffic stays private. Traffic to host pools will take ExpressRoute or VPN S2S IPsec tunnel. including traffic that goes to management components of AVD
> Private endpoint of type global which is for initial feed discovery is only deployed once as mentioned above.
{: .prompt-tip }

![Azure architecture diagram of complete private endpoint for AVD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/end-to-end-private-endpoint.jpg)
_Download [architecture](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/31072024/avd.pptx) diagram_


## Scenario 2: Private Endpoint for Host Pool and Feed download, Initial Feed Discovery as public.
This scenario is for multiple AVD use cases in the same organization. where you’ll need to create a workspace with only private endpoint of type Feed - this is used for Feed download. And no private endpoint for initial feed discovery(Global).
As there is no initial Feed discovery private endpoint hence all the three records rdweb.wvd.microsoft.com, www.wvd.microsoft.com, client.wvd.microsoft.com uses public connectivity and you don’t have to create any DNS forwarder in the on-premises DNS zone for private record name resolution.

So, you’ll have one workspace which is private and servicing an AVD use case where users are always internal and compliance needs to be met, AVD traffic will traverse over ExpressRoute/IPSec VPN for this set of users.

And other workspace, which is public, this environment will cater to other set of users where the policy is not stringent.
So, they can continue to connect to AVD in public scenario over internet.
Host pools in both the workspace are independent of each other.

![Azure architecture diagram showing initial feed discovery as public endpoint and rest private endpoints in AVD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/initial-feed-discovery-public-endpoint.jpg)


## Scenario 3: Private Endpoint only for Host Pool, Feed download and Initial Feed Discovery is public.

This scenario is also for multiple AVD use case in the same organization. Majorly used when you have a single workspace and multiple host pool in it. Some of the host pools are configured with public access, and some you want to connect privately via private endpoint over ExpressRoute/ IPSec Tunnel. In this scenario, you’ll not deploy any of the workspace private endpoints (Initial Feed Discovery and Feed download) both will be public. And as mentioned, you’ll only deploy private endpoints for Host Pool. Also you’ll need to make sure you select the network setting appropriately.
“Enable public access for end users; use private access for session hosts” the behavior of this is end users can access the feed securely over the public internet but must use private endpoints to access session hosts.
 For host pools that need to be public, you can skip the private endpoint deployment and it’ll be entirely on public connectivity over internet.

![Azure Architecture diagram showing only host pool with private endpoints](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/host-pool-private-endpoint.jpg)

![Screenshot showing the network settings on host pools of AVD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/enable-public-access-end-users-use-private-access-session-hosts.jpg)


## Bonus Tip:
Regardless of the connectivity method you choose, you’ll need to ensure Clients can authenticate and for that we’ll need to whitelist FQDNs to outbound internet, these are required to connect to Entra ID. Entra ID cannot be hosted privately via private endpoint. Endpoints which are required to be whitelist are highlighted below. Please note, whitelisting of *.wvd.microsoft.com will only be required when you’re connecting via a public connection, you won’t need to whitelist this FQDN when you’re in a private endpoint scenario.

![Table showing FQDN to be whitelisted from client machine to internet](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/client-fqdn-whitelist.jpg)


[https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint?tabs=azure#end-user-devices](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint?tabs=azure#end-user-devices)

Similarly, from host pool, as this is a reverse connect solution hence you’ll need to whitelist certain FQDNs which are required for activation, DNS resolution, etc. in the firewall as outbound to Azure service. The same link above covers all the highlighted FQDNs mentioned below.

![Table showing FQDN to be whitelisted from host pool to internet](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31072024/hostpool-whitelist.jpg)


Special thanks to [Shabbir Ahmed](https://www.linkedin.com/in/shabbir550/) for helping in the Architecture preparation.

I hope above scenarios help you demystify the private endpoint scenarios with AVD.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }