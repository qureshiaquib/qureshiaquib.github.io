---
title: "On-Prem DNS Changes for Azure Private Endpoint Deployment"
date: 2024-5-11 12:00:00 +500
categories: [tech-blog]
tags: [Azure Private Endpoint Name Resolution]
---

* **Scenario**: In a private endpoint scenario where a customer wants to connect to the private endpoint from an on-premises network, they’ll need to first resolve the FQDN to IP address. Typically, I’ve seen implementation partners create a conditional forwarder with the FQDN of the PaaS service and then point that to the private IP address of a DNS server which is hosted on Azure. Then next step is from DNS server hosted on Azure, same type of conditional forwarder point to Azure wire server IP 168.63.129.16 which helps resolve the private endpoint IP.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11052024/Picture1.jpg)

When we’ve 2-3 DNS Server in the organization, it can be easily handled.
But considering enterprises where DNS server count is more than 15 -20 and DNS servers are placed in On-premises as well as on Cloud in a multi cloud. Then you’ll face the following challenge.

* **Challenge**: In on-premises DNS server which is integrated with AD, the customer creates a DNS forwarder and points to DNS Server hosted on Azure. As there are many DNS Servers which are Windows Server Active Directory integrated thus the customer checks the box for “Store this conditional forwarder in Active Directory” So that they don't have to manually create the same conditional forwarder in all the DNS server. This makes life easier.
As soon as they do this, the DNS server on Azure will also have the same conditional forwarder, and the other forwarder which points to wire server IP would cease to function.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11052024/Picture2.jpg)

* **Solution**: There are many options to solve this conflict. As mentioned below.
If the customer opts for a Private DNS resolver, it is the most convenient approach and recommended approach by Microsoft. However, many won't choose a private DNS resolver and can save cost by choosing other options. There are manual activities involved in other options. 

### 1. Use Private DNS resolver:
One way to handle this conflict is to have Azure DNS Private resolver,
Deploy DNS Private resolver in the shared services VNET, or in separate Subnet in your identity VNET where Domain controller is hosted.
Create an inbound endpoint, create conditional forwarder for private endpoint and point it to the ADPR(Azure DNS Private resolver). Store the conditional forwarder in the active directory so even if it’s replicated to Azure hosted DNS server or on-premises it won’t break the DNS name resolution flow. All the resolution request would come to ADPR and it’ll resolve the private IP.

Some good architecture and flow diagrams are already documented here:
[https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/azure-dns-private-resolver](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/azure-dns-private-resolver)

Advantage: MS generally recommend to have ADPR because you don’t have to manage the server, it’s high availability, security etc. It’s a managed service.


### 2. Create conditional forwarder without storing it in Active Directory:
Another approach is, when you’re creating a conditional forwarder in on-premises DNS servers – do not store that in the Active Directory. Due to this, the same won’t be replicated to DNS server on Azure. Which avoids the conflicts.

However, there is a catch with this approach. If you’ve 20 domain controllers with integrated DNS then you’ll have to manually create conditional forwarder in each DNS server. You can script this via Powershell.
Please note, this needs to be done every time you create a new type of private endpoint for example if you were using blob storage and then started using SQL PaaS Database then you get a new FQDN. Same need to be created once again on each DNS server via Powershell script. Or if your organization allows you do add all well known private endpoint FQDNs beforehand all at once then you can do this.

For PowerShell script, you can use below link and the author has created a script which you can run and quickly create conditional forwarders.

[https://blog.workinghardinit.work/2022/08/09/powershell-script-to-maintain-azure-public-dns-zone-conditional-forwarders/](https://blog.workinghardinit.work/2022/08/09/powershell-script-to-maintain-azure-public-dns-zone-conditional-forwarders/)


### 3. Create a separate active directory partition:

In this solution, you'll need to create a separate Active Directory partition. Store the conditional forwarder in that partition. You’ll only need to join on-premises DNS Servers in that partition. Leaving out the DNS server hosted on Azure. Which will eventually not replicate the conditional forwarder to Azure hosted DNS Servers hence conflict won’t occur.

Please note, If you already have created conditional forwarder and then think about going with this solution, there is a bug in Active directory DNS. You’ll need to delete and re-create all your conditional forwarder in on-premises DNS Servers.

```shell
Add-DnsServerDirectoryPartition -Name "On-premises Site for private endpoint"

Register-DnsServerDirectoryPartition -Name "On-premises Site for private endpoint" -ComputerName 'ContosoDC-01
```

I hope above options help you in choosing the right name resolution strategy for your environment.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
