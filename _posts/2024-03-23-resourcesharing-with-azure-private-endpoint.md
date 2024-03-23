---
title: "Enhancing Azure Connectivity: Sharing PaaS instance across customer tenants on Azure"
date: 2024-3-25 12:00:00 +500
categories: [tech-blog]
tags: [Azure Private Endpoint]
---
I’ve come across a scenario where one of my customer using Azure SQL DB wanted to share their Database with other customer who was also hosted on Azure. They were struggling to establish site-to-site connectivity so that Customer B could access Customer A’s network, enabling them to connect to the Azure SQL DB via the site-to-site tunnel. Though this can be achieved, there are better ways to connect to Azure SQL DB, or any PaaS instance for that matter, with another customer who is using Azure. This can also be used by customers who have multiple Azure AD tenants.

* **Solution**: You must be aware of private endpoints for PaaS instances. It can be configured for multiple types of service. Azure SQL DB, Storage account etc. 
You can have more than one private endpoint for any type of resource. For example, you can configure Azure SQL DB private endpoint in the Contoso network. Similarly, you can create one more private endpoint for the same resource in Fabrikam’s VNET.
When you’re configuring a PE, you’re basically bringing the PaaS service to Fabrikam’s VNET.

![a](/assets/23032024/picture1.jpg)

## There are multiple benefits to using this:

### **Private endpoints can be configured in any region**:
So, it can happen that your Azure SQL DB resides in the Azure Central India region, but you’ve created the PE in the South India region of Fabrikam's VNET.
Though this shouldn’t be done, considering latency. But this similar type of architecture of private endpoints can be leveraged for other PaaS instances where latency is not a challenge or sometimes specific PaaS service itself is not available in your region. You’ll see a lot of similar deployments when you deploy the OpenAI service.

### **No peering is required, connectivity happens in the backend**:
A common misconception is that you’ll need to peer the VNETs of Contoso and Fabrikam in order for an app residing in Fabrikam to connect to a DB in the Contoso tenant. Which is not the case. There shouldn’t be any connectivity between any of the VNET. As soon as private endpoint is created in Fabrikam and approved by Contoso you can connect to that endpoint from any of the VNETs hosted in Fabrikam as long as it has line of sight with the private endpoint IP Address. Even Fabrikam On-premises location which is connected with S2S can connect to Private Endpoint IP Address. All the connections flow through the Azure backbone and reach the actual PaaS instance without needing VNET Peering.

### **Can work cross tenant**:
As mentioned in the architecture, this private endpoint and PaaS DB relationship can work across tenants. PE can be created in any Entra ID tenant, and the actual PaaS instance can reside in any of the customer tenants. This makes PE connectivity flexible to use in broad usecases.

### **Can also be used when customer has conflicting IP Addresses**:
One of the architecture pattern with private endpoint is, Fabrikam though they have their own IP Address space and Contoso might also be using same conflicting IP schema, still Fabrikam was able to create private endpoint in their own VNET with unique IP which is limited to their own environment only. It doesn’t matter to contoso whether PE was created with the same IP Address as of Contoso VNET. So, basically, you eliminate the need for NAT and complex routing in this scenario.

PE with PaaS is just one example; I’ve seen architecture where we’ve deployed customer application with Standard LB and used that to expose it as a private Link service, assuming PE pointing to private link service can be created in any of the VNETs with conflicting IP addresses as there is no need for VNET Peering.
So this exposes your own application with PLS and PE and eliminate the need of VNET Peering and NAT if you’ve conflicting IP Address space.

I hope above scenario help you to design more complex architecture leveraging private endpoint capabilities.

Happy Learning!
