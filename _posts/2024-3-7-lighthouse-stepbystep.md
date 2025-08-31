---
title: "Azure Lighthouse for Simplified Multi-Tenant Administration"
date: 2024-3-6 12:00:00 +500
categories: [tech-blog]
tags: [Azure Lighthouse]
description: "Discover Azure Lighthouse for managing multiple Azure AD tenants from a unified portal. Learn how to set up Azure Lighthouse for easy subscription management"
---

One of my customer asked, we’ve multiple Azure AD Tenants in our Enterprise enrollments and subscriptions associated with those. We wanted a simpler way to manage subscription from single Azure Portal and doesn’t want to switch between different directories to see the resources.
I’ve seen Azure Partners utilizing this and few of partners are unaware of Azure Lighthouse as a solution. The same solution can be used by Azure customers who have multiple Azure AD tenants in their environment. All of below can be accomplished with no additional cost, yes Azure LightHouse is free.

Having multiple tenants can be because of multiple reasons. 

* It can be because of a group company managing Azure for multiple child firms who wanted to have separate Azure AD tenant for them.
* Because of multiple mergers and acquisitions they’ve got multiple tenants.
* Multiple Azure AD tenant got created by different EA Account owners unknowingly. ;) this happens a lot and I’ll share some good example about mergers and acquisitions in future blog post.

This blog post would be a simple step by step guide of setting up light house and how does it really looks once you onboard a customer.
### Step1: Export template through Azure Portal

In this step you as a service provider would create a template. This template will be consumed by your customer whose subscription you’ll be managing.\
Launch Azure Portal in the global search, search for my customers.\
You’ll see below screen and an option to create ARM template.

![Azure Lighthouse landing page](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/azure-lighthouse-landing-page.jpg)

Fill the details of the customer with name and details. Lighthouse provides two options. You can get access to specific resource group or to entire subscription. There can be scenario where a service provider is a SOC team and they would want access to Azure Sentinel resource and not entire subscription so they’ll only onboard specific resource group. 

![ARM template creation for Azure Lighthouse](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/arm-template-creation-azure-lighthouse.jpg)

Click on Add authorization and search for user.
You can select permanent permission or either eligible permission. If you select eligible then you the person who has got permission would need to elevate permission for specified hours only and with some approving his access elevation.

![Providing access to User](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/providing-access-to-user.jpg)

The person whom you add in the above screen doesn’t get invited to customer tenant. Also you’ll not see him in the subscription access list or management group. So this wouldn’t be a guest account.

![Selecting the permission for the user](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/selecting-permission-for-user.jpg)

Click on view template and then you’ll get an option to download the same. There are ways you can edit this template and also create your own template. We’ll not get into complexity in this blog post. 

![ARM template for Azure Lighthouse](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/arm-template-azure-lighthouse.jpg)

### Step 2: Import the template

Once the export is done you’ll need to import the file and this activity would be done by customer whose subscription you’ll need access to.
In the global search – search for service providers and then click on service providers offers.
Click on Add offer and then add via template. 

![Add the template](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/add-template.jpg)

You’ll need to upload your template file which was downloaded in step 1

![Importing the template](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/importing-template.jpg)

Next page would be the same custom template page which you use to deploy any other deployment template. Select the subscription you as a customer want to give access to service provider.

![ARM template deployment in customer tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/arm-template-deployment-customer-tenant.jpg)

Click on Review and create.

![Deployment undergoing for Azure Lighthouse](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/deployment-undergoing-azure-lighthouse.jpg)

These are the two objects which gets created during the deployment, registration definition and the registration assignment. These objects are checked by resource manager if your service provider user checks the directory and make any action. This is the magic behind non guest user by resource manager.
Once successfully deployed your service provider page would look like this

![Service provider on Azure portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/service-provider-azure-portal.jpg)

You can go back to service provider tenant and check customer section. You should see customer tenant name there.

![Customer section on Azure portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/customer-section-azure-portal.jpg)

### Step 3: Validation of subscription access
You can click on the top gear icon and then see if you’re able to see customer tenant

![All the tenant in one portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/tenant-one-portal.jpg)

Also you can find the subscription in the filter list.

![Subscription filter list](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/subscription-filter-list.jpg)

![VMs from multiple tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/vms-multiple-tenant.jpg)

### Removing the access
This can be done by either service provider or customer.
If you need service provider to remove customer then it requires special role “Managed Services Registration Assignment Delete Role”

![Delegate remove permissions for Azure Lighthouse](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/delegate-remove-permissions-azure-lighthouse.jpg)

Delete the by going to delegations

![Deletion the light house permission from customer portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/delete-light-house-permission-customer-portal.jpg)

You as a customer can also delete delegation of service provider.

![Deletion from service provider portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/delete-service-provider-portal.jpg)

Conclusion: I trust this guide helps you in configuring Azure Lighthouse and navigating the complexities of managing multi-tenant organizations from a single console.

Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }