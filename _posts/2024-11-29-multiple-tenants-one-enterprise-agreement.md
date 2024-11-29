---
title: "How to Manage Multiple Tenants in One Enterprise Agreement"
date: 2024-11-29 12:00:00 +500
categories: [tech-blog]
tags: [Enterprise Agreement]
description: "Learn how to manage multiple Entra tenants under a single Azure Enterprise Agreement using enrollment accounts for streamlined billing and IT separation"
---

* **Scenario**: I’ve come across this scenario multiple times where customers had one Enterprise agreement enrollment, and they wanted to have two companies within that enrollment. These companies are part of the same parent firm, but they have distinct IT infrastructures and different policies; hence, they wanted separate Entra Tenants (Azure AD). However, they wanted to share a single enterprise agreement enrollment, which was signed through a billing partner. 

* **Solution**:Once you sign Enterprise Agreement (EA) through a billing partner it is never tied to a single Entra tenant. One EA can have multiple Enrollment accounts, associated with multiple Entra tenants.

This blog can be used by pre-sales folks who get into mergers, acquisition conversions.
Also, if you want to learn how to move subscriptions between multiple agreement types then you can refer my previous blogpost.
[https://www.azuredoctor.com/posts/mergers-and-acquisitions-on-azure/](https://www.azuredoctor.com/posts/mergers-and-acquisitions-on-azure/)

We’ll go through a scenario where a company wanted to create a separate tenant for a spin-off entity who’s IT Infra would be managed separately, however wanted to share the Azure Billing with the parent company. This could be because the 2nd entity would be part of a bigger group of company and they had negotiated good discounts and wanted to share that. 

Please note, this can also be a temporary setup. Let's assume a scenario where the spin-off entity couldn't set up a new Enterprise Agreement with a billing partner because they didn't want to reveal the name of the new entity to the billing partner and wanted to perform all the spin-off and IT infrastructure work in secrecy.

They can set up an Azure subscription in the new Entra tenant and work on the IT setup. Later, once the official name and registration task is completed, they can purchase a new Enterprise Agreement and move the subscription to the new Enterprise Enrollment under the new EA.
This can be entirely a backend movement without any redeployment of Azure services with no downtime. Please refer to the blog mentioned above for details on subscription movement.

## Create Entra Tenant
One of the misconceptions which I’ve found amongst customers is that Entra tenant can only be created once they sign a deal through partner. But in reality customer can create multiple tenants. And once tenant is created they can use the user id to create Enrollment accounts so that whenever subscriptions are created it is tied to the new Entra tenant of the user id.

let's see how this can be achieved.

First browse through portal.azure.com and search for Entra ID (Formerly Azure Active Directory)

![Entra tenant view](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/entraid-creation-step1.jpg)

After clicking on manage tenant it’ll open below window where you’ll see all the directories you’ve access too.

![Entra tenant list](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/entratenantlist.jpg)

select Entra ID and not B2C.

![Create new entra tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/entraid-creation-step2.jpg)

In this step you’ll need to specify the name of the new organization and the new Entra Tenant.

![Specifying name of entra tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/entraid-creation-step3.jpg)

goto users and create a user account in the newly created Entra Tenant.
Now that you’ve successfully created the Entra Tenant and user, you can proceed ahead with next step.

## Create Enrollment account

Under enterprise enrollment you can create multiple enrollment accounts. By default, when a subscription is created under Enrollment account it is associated to Entra ID of the enrollment account owner.

Let’s proceed and create Enrollment account. 
You should have Enterprise administrator role on the Enrollment to create one.

Logon to Azure portal and browse to cost management + Billing. And select the Enterprise enrollment. 

![Enterprise enrollment screen in cost management plus billing portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/enterprise-agreement-cost-management-billing.jpg)

Click on accounts and it’ll open all the Enrollment accounts.

![List of all the billing accounts in enterprise enrollment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/billing-accounts.jpg)

Click on add and specify the account owner email. This is your entra user id which is present in your newly created entra tenant.

![screen showing how to add enrollment account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29112024/add-enrollment-account.jpg)

Now you have two enrollment account with two different Entra Tenant. whenever you create subscriptions under Enrollment account it’ll be attached to the new entra tenant.

Enterprise Agreement will be retired soon, and customers will transition to MCA. I'll soon write a blog around how same can be achieved in MCA. And yes I've seen the same is possible in MCA-E.

I hope this blog will help you in designing the proper Enterprise Agreement and it's tenant association during a spin-off.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }