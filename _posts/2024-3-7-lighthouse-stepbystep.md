---
title: "Azure Lighthouse for Simplified Multi-Tenant Administration"
date: 2024-3-6 12:00:00 +500
categories: [tech-blog]
tags: [Azure Lighthouse]
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

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture1.jpg)

Fill the details of the customer with name and details. Lighthouse provides two options. You can get access to specific resource group or to entire subscription. There can be scenario where a service provider is a SOC team and they would want access to Azure Sentinel resource and not entire subscription so they’ll only onboard specific resource group. 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture2.jpg)

Click on Add authorization and search for user.
You can select permanent permission or either eligible permission. If you select eligible then you the person who has got permission would need to elevate permission for specified hours only and with some approving his access elevation.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture3.jpg)

The person whom you add in the above screen doesn’t get invited to customer tenant. Also you’ll not see him in the subscription access list or management group. So this wouldn’t be a guest account.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture4.jpg)

Click on view template and then you’ll get an option to download the same. There are ways you can edit this template and also create your own template. We’ll not get into complexity in this blog post. 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture5.jpg)

### Step 2: Import the template

Once the export is done you’ll need to import the file and this activity would be done by customer whose subscription you’ll need access to.
In the global search – search for service providers and then click on service providers offers.
Click on Add offer and then add via template. 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture6.jpg)

You’ll need to upload your template file which was downloaded in step 1

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture7.jpg)

Next page would be the same custom template page which you use to deploy any other deployment template. Select the subscription you as a customer want to give access to service provider.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture8.jpg)

Click on Review and create.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture9.jpg)

These are the two objects which gets created during the deployment, registration definition and the registration assignment. These objects are checked by resource manager if your service provider user checks the directory and make any action. This is the magic behind non guest user by resource manager.
Once successfully deployed your service provider page would look like this

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture10.jpg)

You can go back to service provider tenant and check customer section. You should see customer tenant name there.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture11.jpg)

### Step 3: Validation of subscription access
You can click on the top gear icon and then see if you’re able to see customer tenant

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture12.jpg)

Also you can find the subscription in the filter list.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture13.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture14.jpg)

### Removing the access
This can be done by either service provider or customer.
If you need service provider to remove customer then it requires special role “Managed Services Registration Assignment Delete Role”

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture15.jpg)

Delete the by going to delegations

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture16.jpg)

You as a customer can also delete delegation of service provider.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/06032024/picture17.jpg)

Conclusion: I trust this guide helps you in configuring Azure Lighthouse and navigating the complexities of managing multi-tenant organizations from a single console.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }