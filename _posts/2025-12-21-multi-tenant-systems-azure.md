---
title: "Azure Services and Patterns for High-Scale Multi-Tenant Systems"
date: 2025-12-21 01:00:00 +500
categories: [tech-blog]
tags: [Multi-Tenant]
description: "Explore Azure services and design patterns for building scalable multi-tenant and SaaS applications, covering networking, identity, and deployment considerations"
---
I have worked with a manufacturing automaker who was planning to build AI applications that were multi-tenant in nature.
It always amazes me how different the approaches can be, one way is to build a system directly for customers, and another is to build a platform that multiple customers can use to build and share their own systems.

For systems at this scale, it will defy many limitations which you come across on services offered by public cloud. At the same time, you need to adopt a different approach that is inherently scalable. The impact is huge. In this blog, I’ll briefly cover services that you can use while building a multi-tenant or SaaS service. I won’t dive deep into each topic, as I’ve already covered them in individual blogs that I’ve written. I’ll provide you a link to the blog which you can read at your leisure. This way, the last blog of the year becomes a pointer to multiple other blogs I’ve written. It’s a nice segue.

I’ll try to consolidate related topics into categories to make them easier to consume and better structured. For example,
* Networking
* Identity and Entra Tenant
* Deployment

Let’s explore this topic in a little more detail.
## Networking
In this section we’ll talk about how you can spin up services and connect to it cross tenant or scale your application and at the same time leverage networking feature which is provided to you.

### Azure Private Endpoint Cross Tenant
When you’re deploying any PaaS service on Azure, you can deploy its Private Endpoint in its own subscription and same tenant or cross tenant. So, in scenarios where you deploy service in a separate subscription meant for customers, you can script the deployment to create Private endpoint in your Main subscription which resides in your own tenant so that you can also access services for management and maintenance of it.
You can find more details on this in the blog post below.

[https://www.azuredoctor.com/posts/resourcesharing-with-azure-private-endpoint/](https://www.azuredoctor.com/posts/resourcesharing-with-azure-private-endpoint/)

### Azure Private Link Service Direct Connect
This is a newly introduced service that is currently in preview. If you don’t have a PaaS service but a IaaS based service and you wanted to expose it via private link service you have to deploy your VM behind a standard load balancer and then create PLS. then a PE can be created pointing to a PLS. However, the limitation was that the service had to be behind a Standard Load Balancer. Now, that limitation has been removed, you can host any private Ip address behind the PLS Direct connect. It can be the IP address which is hosted on-premises.
learn more about this from below link

[https://learn.microsoft.com/en-us/azure/private-link/configure-private-link-service-direct-connect?tabs=powershell%2Cpowershell-pe%2Cverify-powershell%2Ccleanup-powershell](https://learn.microsoft.com/en-us/azure/private-link/configure-private-link-service-direct-connect?tabs=powershell%2Cpowershell-pe%2Cverify-powershell%2Ccleanup-powershell)

### Azure Front Door
When you’re building a SaaS app or a multi-tenant service, hosting it publicly can be tricky. AFD helps you publish your application over internet. However, the major question would be how many routes, origin groups and domains need to be in place if you’ve 100s of website links. Below blogpost written earlier provides you guidance around the scale of the deployment. Learn more from the blogpost below.

[https://www.azuredoctor.com/posts/multiple-sites-azure-frontdoor/](https://www.azuredoctor.com/posts/multiple-sites-azure-frontdoor/) 

## Identity and Tenant
Identity is one of the core factors which decides how your application will be deployed and where it’ll be deployed. Since the Azure Entra tenant is where all your subscriptions are tied together. So, finding methods that enable cross-tenant authentication without sharing secrets and authorizing the services present in your customer tenants can be useful to you.

### Service Principal in Cross Tenant configuration
When you’re deploying services in your customer tenant and you wanted to authenticate to their Database or some service you can’t just ask them to create a service principal and share the secrets so that you can authenticate. Although this is one of the easiest approaches, it is riskier and does not scale well. If we create a service principal on a master tenant and then share the same with other tenants and if your customer has just assigned the same service principal with RBAC of your choice. This approach simplifies things, as you can reuse the app registration you’ve already created and the secret creation is controlled by you. Your customer would have just assigned the RBAC which you needed and no secret generation etc must be done by them. It’s seamless.
The same is explained in below blogpost.

[https://www.azuredoctor.com/posts/how-to-share-service-principals-across-entra-tenant/](https://www.azuredoctor.com/posts/how-to-share-service-principals-across-entra-tenant/)

### Workload Identity Federation
In the above scenario, you are still relying on a service principal and secrets are still generated. Do you need a secret-less method to achieve authentication and also authorization? Why don’t you explore Workload identity federation option. Currently, you can’t use WIF between two different Entra ID tenants. But who knows it’ll be true in future. But the same can be achieved if you’ve an application which is cross cloud for example GCP and Azure and you want to access buckets or services from either of the clouds. This can easily be achieved using WIF.
have a look at the step-by-step configuration mentioned in below blogpost.

[https://www.azuredoctor.com/posts/azure-gcp-workload-identity/](https://www.azuredoctor.com/posts/azure-gcp-workload-identity/)

### Azure Light House
When you’re operating in a multi-tenant environment on Azure. You would want to easily manage the resources from single console. Azure light house is exactly what you need. Little confused how to do this step by step? I’ve a walkthrough of it created long back which can help you configure it for free. You don’t have to switch the portal to manage resources across tenants. Use Azure Lighthouse.

[https://www.azuredoctor.com/posts/lighthouse-stepbystep/](https://www.azuredoctor.com/posts/lighthouse-stepbystep/)

## Deployment
Finally, once you’ve created your application and want to publish it, you would want a scalable approach. At the same time, control of your application if you’re deploying it in someone’s tenant. This topic covers exactly that.

### Azure Managed Application
Azure managed application is a way you can publish your application within your own tenant with service catalogue or you can publish it on marketplace. This is not only a way to publish; at the same time, you can govern the application. You can say I want reader access to the application whoever deploys it. Or you can say I want to only give reader access to the person who’s deploying it even though they are owner of their subscription. As it’s your IP you would want to protect sometimes and Azure Managed application can help you meet that requirement.

You can’t publish an application on Azure Marketplace unless you are enrolled in the Microsoft Partner Program and application has to be published via a different portal.
You can learn more about it here

[https://learn.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/overview)

### Azure Subscription Vending
When you’re deploying multiple instances of your application in your tenant but deploying it in multiple subscriptions so that your cost are segregated you would want to scale the deployment and keep it automated. What best can you get thinking about automation, Azure DevOps pipeline. Azure team has written subscription vending module which you can make use of and then spin up subscriptions. If you want to learn how to do this step by step please check below blog post.

[https://www.azuredoctor.com/posts/automate-subscription-with-avm/](https://www.azuredoctor.com/posts/automate-subscription-with-avm/)

What I’ve covered is simple service which you see in a single tenant environment it’s simple however the same service could be seen from a different angle and used in a highly complex environment and built to scale. While I’ve tried to cover as much topic as I know about multi tenancy and how you can scale your deployment for such scenarios there are more services and Microsoft learn team has documented it here.

[https://learn.microsoft.com/en-us/azure/architecture/guide/saas-multitenant-solution-architecture/](https://learn.microsoft.com/en-us/azure/architecture/guide/saas-multitenant-solution-architecture/)

This year was special as I've reached 50k milestones for this blog. I hope whatever i had written is helpful to you. Wish you a very Happy Christmas and a Very Happy New Year in advance and a joyful vacation.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
