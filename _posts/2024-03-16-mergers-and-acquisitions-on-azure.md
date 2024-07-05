---
title: "How to Handle Mergers, Acquisitions and Movements in Azure"
date: 2024-3-16 12:00:00 +500
categories: [tech-blog]
tags: [Azure Enterprise Agreement]
---

Mergers and Acquisitions are common but I’ve seen architects, sales and account teams sometimes find it difficult when we get queries about how the movement of Azure Subscription happens when both the organizations are using Azure. This can be within the same Azure AD Tenant or between Azure AD tenant move. Because couple of us sometimes are involved after subscription are in place already.

Before we delve into the different types of migration let’s have a quick recap of Microsoft Enterprise Agreement hierarchy.

When an organization purchases EA they can then create subscriptions and start their Azure resource deployment. A customer can purchase CSP through a partner which is relationship between customer and partner where CSP controls the resources and support them on the deployment and any technical issues CSP partner would create ticket on behalf of customers.

Below hierarchy is of Enterprise Agreement. First level would be enrollment, and underneath, customer can create multiple departments to segregate the deployments. Department can be one or can be many. Under department you create Accounts. Account is a container where all the subscriptions gets created. Basically you can assign an email address in the account creation process. This person owns the account. Whenever you create an account you’ll need to provide a unique email address. You cannot have two EA Accounts with the same owner.

Best practice is to provide work and school account rather than Microsoft Account. Think about when person leaves the organization.😊

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16032024/picture1.jpg)

Considering all the scenarios below, migration can be classified in two main types.

* **Non Technical Migration**: which happens in the backend with no impact to the resources present in the subscription without any downtime.
* **Technical Migration**: This involves assessment of the entire resources present in the subscription and finding whether resources are feasible to move to another subscription. each resource is assessed individually and also checking the dependency of one resource over the other.

## Scenarios:

### Move between two different EA Enrollment:
In this scenario customer has active EA enrollment and this customer has acquired another entity B who is also on Azure with active EA Enrollment. As they both are on Azure, customer A would want to take over the entity B azure deployment. Customer would want to only pay through single partner to Microsoft. Hence this need to move arises. Also, the second need can be because of Multiple Azure AD tenant and merger of resource into single Azure AD tenant so that customer can manage resources through single landing zone.

In my opinion, dividing the merger into two phases is advisable. First is movement of subscription (billing only) and second phase is merging of resources in the tenant.

#### **First phase**: 
*(type:NontechnicalMigration)*
Movement of subscription from one enrollment to another enrollment can happen in the backend. This backend move doesn’t incur any downtime for the subscription resources. You’ll need to have destination EA Account handy where the source subscription would move. Customer would need to raise a support case with MS subscription management team and provide necessary approval via email. You’ll need to inform Support engineer that tenant would remain the same.

Note: Email address which is used for the account owner used to be the tenant where the subscription would be associated. For example, if email is Aquib.qureshi@contoso.com then all the subscription which would be created under this account will be mapped to contoso.com Azure AD tenant.

Hence, you’ll need to inform the support team that you do not want resources to be moved in destination Azure AD tenant. This is important the reason is, once Azure AD tenant of a subscription changes the RBAC, Azure AD App registrations and many Azure AD dependent services in the subscription might be impacted.

You’ll think does one azure EA Enrollment can have more than one Azure AD tenant?
the answer is yes, Enrollment doesn’t have any limitations regarding tenant. One Enrollment can have multiple EA Account and each account can have their own Azure AD Tenant. (though this is not preferred as it’s not easy to manage multiple directories)
In our scenario, the Entity B has it’s own Azure AD tenant and Company A also has Azure AD tenant both residing in single Azure AD Enrollment after the movement.

Apart from the tenant, the other thing you should keep in mind is the reserved Instance that you’ve purchased in source Enrollment. If you’re transferring subscription which has RI with a currency A and your destination EA Enrollment is purchased in different currency B then the RI would be cancelled automatically as destination EA Enrollment cannot be billed in multiple currency at the same time.

#### **Second phase**:
*(type:technicalMigration)*
Merging of resources in single Azure AD tenant. This phase is executed once the billing is migrated. As mentioned, this is technical migration where each resource need to be assessed. Tenant change can be handled in many different ways. I’ll explain that in point No. 3 in detail. 

### Move subscriptions between EA Account within same EA Enrollment:
*(type:NonTechnicalMigration)*
This scenario can happen when one EA Account owner has resigned and you wanted to take over all the subscriptions and move to different EA Account. This step is easy and can be done through Azure Portal and you don’t need to raise any support case with MS.

The same Destination Azure AD tenant checkmark you'll see on the portal and you can uncheck that if you do not want to transfer subscription to destination Azure AD.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16032024/picture2.jpg)

### Move of Azure Subscription from one tenant to another:
*(type:TechnicalMigration)*
The need to change Tenant arises because of multiple reasons, first is customer had landing zone deployed with firewall, WAF and network connectivity, Azure Policy configured along with segregation of BUs in different management groups in customer A Azure deployment. As Entity B got merged the IT team of customer A would want to manage Azure resources of Entity in similar way as they manage their current Azure Deployment.  Though we shouldn’t jump to merging of resources into single Azure AD tenant directly as there are multiple ways you can coexist both the tenant and still leverage better operations. I’m highlighting few methods below.

* Having two Azure AD tenant means two different user repository. Whenever Customer A users want to manage Entity B’s Azure subscription you can invite users as guest and then provide those guest users as contributor or relevant roles so that they can manage azure resources. Recently Sync of users between two Azure AD tenant got released where you don’t have to manually invite users and this can be automated.
* You can use Azure Lighthouse to operationally manage azure deployment across two different Azure Tenant. I’ve written a blog around this topic.
* If Entity B is using Hub and spoke deployment model they can do vnet peering and leverage Customer A’s Hub network which has Firewall, WAF etc.

These are the few reasons why you shouldn’t jump to merging of Azure AD tenant and co-exist both the tenants and resources. Although not all services support multi-tenant, it depends upon the Entity B’s Azure deployment landscape and the services they use on Azure and if there is need to merge the tenant they can still proceed ahead.

Assume the decision is made to move the resources from one tenant to another.

As mentioned previously this step can be executed in multiple ways. I’ll let you decide which one you wanted to choose basis on the criticality of resources.

#### **Approach 1(Change Directory)**:
You can click on subscription and then click on “change directory”. Before you execute as mentioned previously your RBAC would reset, resources with managed identity support would be impacted, services which uses Azure AD for app registration would have an impact. So before you take this step assess all the type of resources one by one and then execute. You should have a solution to all the impacted resources before execution. 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/16032024/picture3.jpg)

Below Microsoft article outlines few of the resources which gets impacted but this doesn’t cover all the resources. 

[https://learn.microsoft.com/en-us/azure/role-based-access-controltransfer-subscription#understand-the-impact-of-transferring-a-subscription](https://learn.microsoft.com/en-us/azure/role-based-access-controltransfer-subscription#understand-the-impact-of-transferring-a-subscription)

> Not all subscription types have this change directory button enabled. If you’re using CSP subscription then this option is greyed out.
{: .prompt-tip }

I’ve seen customers create a dummy subscription and then deploy the type of resource which they wanted to test and then click on change directory to see if resources work or it fails.

#### **Approach 2 (Recreate)**:
This option is used when a customer wants to have control over the downtime. As in the previous approach you’ll need to assess and sometime create resources in dummy subscription still many a times there is less assurity and things goes wrong during migration, troubleshooting is needed during move. Hence to avoid such circumstances you can parallely re-create resources in target subscription which is binded to the target Azure AD tenant and then failover like how you do a DR. With good possibility of doing a failback.

#### **Approach 3(ASR)**:
This approach is less adopted because of many of us are unaware of this method, can only be used when we’ve large number of VM workloads. ASR can be used to replicate between two different tenant. Considering source subscription as Physical server deployments and deploying appliance in the VNET and then pushing agents to VMs hosted in Entity B’s subscription. You can replicate VMs to Customer A’s subscription. This isn’t same as ASR for Azure to Azure scenario but a workaround.

### Move Subscription from CSP to EA:
*(type:TechnicalMigration)* MS Support can’t move subscriptions in the backend, usually CSP subscription resides in different tenant which your CSP partner would have created and as tenant change is not possible in CSP hence the only option is to move resources by re-creating them or use ASR Approach 3.

### Move PAYG subscription to EA:
*(type:NonTechnicalMigration)* PAYG subscriptions where customer has purchased through credit card. This subscription can be pulled in the EA billing in the backend without any downtime. Though if you want to change the tenant then you’ll have to follow steps mentioned in previous section.

### Move MCA-Enterprise subscription to EA:
*(type:NonTechnicalMigration)*
This is uncommon approach as MCA is the future.
But you can move from MCA-Enterprise to EA enrolment by raising request with the MS Governance team. To connect with MS Governance team you'll need to reach out to your Account team. You’ll need to provide justification to governance support team and then they can execute this move. This is entirely backend move without any downtime.

These are the major types of subscriptions, I’ve covered most of the types that are common in India. I hope above content is useful and helps you in smooth migration.


Here are a few useful links from fellow colleagues:

* **Elan Shudnow**: The link below can help if you’re moving resources from one subscription to another within the same tenant. You can use Move operation in the resource group or resource mover. but to find out whether the resources support move operations, you can validate by running the PowerShell script [https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AzResourceMoveSupport](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AzResourceMoveSupport)


* **Neha Tiwari**: Below link would help when you’re doing technical migration, when you’re doing technical migration with help of resource mover or move operation in resource group what all things you should keep in mind during execution is very well documented in the below blog.
[https://techcommunity.microsoft.com/t5/azure-infrastructure-blog/detailed-csp-to-ea-migration-guidance-and-crucial-considerations/ba-p/3919364](https://techcommunity.microsoft.com/t5/azure-infrastructure-blog/detailed-csp-to-ea-migration-guidance-and-crucial-considerations/ba-p/3919364)

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }