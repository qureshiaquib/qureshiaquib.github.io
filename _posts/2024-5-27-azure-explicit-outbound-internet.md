---
title: "Azure Retires Default VM Outbound Access: How to Transition"
date: 2024-5-27 12:00:00 +500
categories: [tech-blog]
tags: [Azure Explicit Outbound Internet]
---
As you may have read the announcement regarding the retirement of the default internet access, If not please go through it here. 

[https://azure.microsoft.com/en-us/updates/default-outbound-access-for-vms-in-azure-will-be-retired-transition-to-a-new-method-of-internet-access/](https://azure.microsoft.com/en-us/updates/default-outbound-access-for-vms-in-azure-will-be-retired-transition-to-a-new-method-of-internet-access/)

So after 30th of September 2025 your default internet access on new Azure VM which you create would cease to work. Customers aware of the impact have already started transitioning to explicit outbound method to get to the internet for their workloads.
If you're still unsure about what this change entails, its impact, and the solutions you can use, this blog is for you.

* **Scenario**: You have bunch of VMs running in a VNET. You do not have any User defined route assigned to your subnet, and also you do not have any routes which sends 0.0.0.0/0 traffic to internet. In this scenario if your VMs tries to reach out to internet this is still possible. (If you do not have any internet bound block rule in your NSG) Internet on your VMs will use dynamic IPs provided by Azure. This will cease to function on 30th of September 2025 for new VMs which you create and no impact to existing VMs.

    I believe internet outbound by default without you controlling the IPs was a risky scenario anyway. Hence I recommend you to use below approach so you have consistent behaviour for outbound internet connection.

* **Solution**:
You can use below options and transition to explicit outbound internet communication instead of relying on Azure provided dynamic public IPs.

    * NAT Gateway
    * Azure Firewall / NGFW
    * Instance Level Public IP
    * Load balancer – outbound rule

## Azure NAT Gateway

This is simplest and recommended option by Microsoft. The process is to deploy a NAT gateway. NAT GW doesn’t require any VNET. You’ll need to associate this to at least one subnet so that outbound traffic from that subnet would go via the NAT gateway service. NAT gateway would have static Public IP controlled by you or even static Public IP Prefix.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27052024/picture1.jpg)


## Azure Firewall / NGFW

Another preferred option is to use the Hub and Spoke architecture pattern. Where you deploy Azure Firewall in the hub network. And all your spoke would be workload VNET acting as spoke. You’ll have a User Defined Routes in your workload VNET which point the internet traffic (0.0.0.0/0) to Azure Firewall.
For optimized cost, you can deploy Basic SKU or Standard SKU of Azure Firewall which provides cost efficiency.

Here's an example of Hub and Spoke architecture from Microsoft docs.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27052024/picture2.png)


Similarly you can have third party NGFW devices like Palo Alto, Fotigate, checkpoint etc in the Hub virtual network. These will house your firewall and point all internet outbound traffic to the firewall.
 
## Instance level public IP Address

You can assign a public IP address to a VM directly. This approach is known as instance level public IP address. which provides explicit internet outbound connection. This is mostly used by NVAs and NGFW deployment on Azure. Or you can use it for DMZ workload. Goto NIC and then ipconfig, -> Assign Public IP Address.
This option is the least preferred approach and not recommended for regular workload as having too many public IPs in your environment increases exposure risk.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27052024/picture3.jpg)


## Load balancer – outbound rule
Another approach to handle this situation is to create a standard load balancer and then create outbound rule. Note that if you only create a standard load balancer with an inbound public IP without an outbound rule, your internet will not work. You’ll need to explicitly create an outbound rule and specify the protocol and SNAT port counts for internet access to function

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/27052024/picture4.jpg)

Though you cannot use a load balancer for every workload, if you have a web server in a DMZ already associated with a Standard LB, you can use an outbound rule approach.

I hope the above approaches help you make informed decisions about your network architecture on Azure and make the necessary adjustments before the September 2025 deadline to avoid any disruptions.

Happy learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }