---
title: "Manage Multiple Tenants in one Microsoft Customer Agreement"
date: 2025-1-25 12:00:00 +500
categories: [tech-blog]
tags: [Microsoft Customer Agreement]
description: "Learn how to manage multiple tenants in one Azure MCA, set billing profiles, and have multiple companies in single Microsoft customer agreement."
---

* **Scenario**: This blog is part 2 of [How to Manage Multiple Tenants in One Enterprise Agreement](https://www.azuredoctor.com/posts/multiple-tenants-one-enterprise-agreement/) The prior one focused on having multiple tenants in one EA; this one focuses on having multiple Entra tenants in one Microsoft customer agreement (MCA)

* **Solution**: If you’ve signed an agreement with Microsoft for Azure, you can have multiple Entra Tenants in one Microsoft Customer Agreement (MCA) it is never tied to a single tenant.

Since MCA is becoming widely adopted and multiple customers have now purchased MCA or are moving from EA to MCA, hence it is important to understand whether sharing billing with other spin-off entities is possible or not within single MCA.\
Also there can be multiple reasons why you may want a separate Entra Tenant, which I’ve discussed in part 1 of the blog.\
As MCA is new for most of us, let’s first understand how MCA is structured.

## MCA Hierarchy

First is the Billing Account: You get Billing account once you sign an agreement. Under a Billing Account, you can have multiple Billing Profiles. Billing Profile is where you get the invoices every month. Under Billing Profile you’ll have multiple invoice sections.
And based on the project or department you can have multiple invoice sections. Under invoice sections you can create multiple subscriptions.

I’ve included the diagram below from the Microsoft Learn documentation for better clarity.
Also, if you want to deep dive and find how can you use invoice section, or billing profile effectively you can refer to below blog written by Dina Fatkulbayanova
[https://www.linkedin.com/pulse/moving-from-ea-mca-what-you-should-know-dina-fatkulbayanova-jqbye/](https://www.linkedin.com/pulse/moving-from-ea-mca-what-you-should-know-dina-fatkulbayanova-jqbye/)

![Hierarchy of Microsoft Customer Agreement](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/mca-hierarchy.jpg)

![Comparison between Enterprise Agreement hierarchy and Microsoft customer agreement hierarchy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/mca-hierarchy-comparison-to-ea.jpg)


Once you logon to Cost Management + Billing and click on your Billing Account you'll see below screen similar for your billing account.

![Overview screen of MCA billing account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/billing-account-info.jpg)


## Create Entra Tenant:
You can follow the part 1 and we have a step-by-step guide to creating an Entra Tenant there.
[Create Entra Tenant](https://www.azuredoctor.com/posts/multiple-tenants-one-enterprise-agreement/#create-entra-tenant)

## Create Billing Profile
Let’s first create Billing profile for new entity in your organization.
Please note, Billing profile doesn’t define the tenant or is not associated with any tenant. We’re just creating Billing Account so that we can create invoice sections under it and then the billing is separate for the new entity

![Create Billing Profile in MCA Billing account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/Billing-profile-creation-step1.jpg)

Fill the details for your new Entity, and your new Billing profile is ready. Till now we haven't provided any permission to anyone yet on this Billing Profile.

![Step 2 of billing profile creation](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/Billing-profile-creation-step2.jpg)

## Associating Tenant to the Billing Account:

This step is new compared to the Enterprise Agreement, which did not include tenant association features. Here, in MCA we’re associating tenant directly to the Billing Account. Which lets us then invite users from that tenant. Once you click on associate tenant, only the Global Admin of the new tenant is allowed to accept the invitation for Billing account associaton. An email would be sent and that person has to accept the invitation.

Click on Associate Tenant

![Associating new additional tenant to MCA Billing Account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/billing-accociate-tenant.jpg)

Specify the Entra Tenant ID, don’t click on provisioning, as that is meant for M365. You’ll need to select Billing Management.

![Step 2 of associating new entra tenant to billing account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/billing-accociate-tenant-step2.jpg)

![Step 3 of associating new entra tenant to billing account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/billing-accociate-tenant-step3.jpg)

## Assign permission on Billing Profile:
Once you’ve associated your tenant, you can invite the user to directly manage the Billing Account, or you can specifically assign the user role on the Billing Profile.
Based on the permission required you can specify the permission (1) and select the tenant name (2), if you’ve more than one tenant you can select the specific tenant and then specify the user (3)

![Assign new user permission from new Entra tenant to MCA Billing profile](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25012025/assign-permission-on-billing-profile.jpg)

Once you’ve provided the permissions, Administrator can create subscription and it’ll be automatically be mapped to the tenant of the user, i.e new tenant. At the same time present in the same MCA billing and enjoy the benefits/discounts.

Please Note:
You can create a subscription with any tenant association, and then, by accessing the subscription settings, you can change the tenant of the subscription. This is another way to have a subscription billed in MCA/EA while maintaining a separate Entra tenant association. However, this method involves additional steps whenever a new subscription is created by the Admin. The method discussed in this blog will help you directly create subscription creators create it with the mapped tenant, thereby minimizing tenant change activities and reducing the likelihood of errors.

I hope you will be able to make better decision of managing multiple organization during your spin-off or mergers.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }