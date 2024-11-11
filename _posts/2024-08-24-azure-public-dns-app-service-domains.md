---
title: "How to Purchase a Domain from Azure and Configure Public DNS"
date: 2024-08-24 12:00:00 +500
categories: [tech-blog]
tags: [Azure DNS Zone]
description: "Learn how to purchase domain from Azure and configure public DNS name server, explore Azure Public DNS Zone and App Service Domains service"
---

Today, in this blog, we’ll discuss the Public Domain and name server topics. One of the crucial topics for Administrators and Architects. Also, this is one of the key topics during Datacenter exit scenarios or during demergers and acquisitions.
Let’s first talk about Azure Public DNS Zone.

## Azure Public DNS Zone:

This is one of the DNS service in Azure's arsenal. As the name suggests, this is a DNS service for public and not for private name resolution. For Private DNS name resolution we've Private DNS Zones. So basically, if you own a public domain name from a DNS registrar like GoDaddy. and you need to manage your own name server for that domain name, then you can use the Azure Public DNS Zone service. The name server is where all the records for the domain are hosted.
By default, GoDaddy and many such domain registrars provide a name server for free.
For example, if you own a GoDaddy domain, you can check the screenshot below, which shows GoDaddy owning the name server for your domain name.

![godaddy page showing name server record](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/godaddynameserver.jpg)

There are domain registrars where records, when published, can take 24 hours to go live, excluding the DNS propagation which happens publicly. Another scenario is that many of them use email to communicate, and their support is sometimes delayed. Hence managing records during migration takes time. Also sometimes availability of name server is a challenge. If your name server is unavailable your clients won't be able to resolve IP Addresses.
You can take ownership of the name server by hosting the name server yourself. Azure Public DNS Zone is a managed service that has inbuilt high availability and provides a 100% SLA \
Yeah, that is true 100% SLA as Public DNS zone is a global service.
If you want to know the name server of any domain, you can use nslookup to find the name server records.

![Find name server records using nslookup tool](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/nameserver.jpg){: w="400" h="800" }

Name server for Azure Public DNS zone looks like below. This is just an example. You’ll get your name server record for your domain when you create the DNS Zone.

```shell
ns4-04.azure-dns.info.
ns2-04.azure-dns.net.
ns3-04.azure-dns.org.
ns4-04.azure-dns.info.
```

Microsoft.com and azure.com is also hosted on Azure Public DNS Zone.

![name server record for Azure and Microsoft](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/nameserver-azure-microsoft.jpg){: w="400" h="800" }


Once you create a Public DNS Zone, it looks like below. You can see the four name server record which is provided to you. You’ll need to use that as name server record and feed that to your DNS registrar. Once you change your name server from the default DNS registrar's NS record to Azure's NS records, the records present in your Azure Public DNS Zone would become authoritative and live.

![Overview screen which shows name server record for Azure Public DNS Zone](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/azure-public-dns-zone.jpg)

You can create records.
By going to recordsets section and create all the records.

![Host record creation in Azure Public DNS Zone](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/record-creation-in-azure-dns.jpg)


Before any name server migration to Azure Public DNS, you’ll need to ensure you have created all the records in the Azure Public DNS Zone. For example, if you have created a www.xyz.com record in your GoDaddy or other provider, you need to make sure you have created a similar A record in your Azure DNS Zone.\
Please keep in mind that creating an Azure Public DNS Zone doesn’t mean you have purchased a DNS name from a public registrar. Azure Public DNS Zone just acts as a name server for you. You’ll still need to own a public domain name from some DNS registrar like godaddy, squarespace, namecheap etc.
This brings you to another topic of purchasing a domain on Azure.

## Azure App Service Domain:

You can purchase domains directly from Azure. This will happen when you’re deploying a new website or for a new project and you don’t want to purchase domains through third party registrar.
please note, Although Microsoft is a registered registrar with ICANN, Microsoft doesn’t provide public domain directly to end customers. This is routed through godaddy.
So whenever you purchase domains from Azure App Service Domain, you pay Azure and don’t directly deal with GoDaddy in this case.

Why would you purchase from Azure and not through GoDaddy? 
No dependency on your procurement team, quick deployment of domain directly from Azure and pay to single vendor (Microsoft) could be few reasons.

![Purchasing Azure App service domain](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/appservicedomain-purchase.jpg)

![Overview screen of Azure App service domain](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/app-service-domain.jpg)

Whenever you deploy an App Service Domain, it is integrated with Azure Public DNS for hosting records. 
You can click on manage DNS records and you can find Azure DNS page.
The name server record is automatically updated with Azure DNS from the beginning

![Screenshowing DNS Zone created along with Azure App Service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24082024/app-service-domain-dns.jpg)


I hope above explainaton will help you deploy and manage public DNS more efficiently.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }