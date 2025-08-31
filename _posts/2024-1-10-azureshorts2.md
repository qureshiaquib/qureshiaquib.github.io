---
title: "Azure Key Vault vs HSM: Which one is best for you?"
date: 2024-1-10 12:00:00 +500
categories: [Azure Shorts]
tags: [Azure HSM]
description: "In this blog post Azure Doctor explains how many types of HSM are there on Azure, This will help you decide which service to use for keys and secrets"
---

This post is for customers who are trying to explore key management solutions on Azure. As there are different options Azure KeyVault Standard/Premium, Azure Managed HSM / Managed HSM pools, Dedicated HSM.
I've collected some interesting differences which you can consider during your conversation.

* With Dedicated HSM you get complete hardware control of the HSM. 
The customer has complete ownership over the HSM device and is responsible for patching and updating the firmware.
The customer will coordinate with Thales support team for these activities.

* With AKV managed HSM pool it's single tenancy service but customer doesn't get hardware control and Microsoft manages the patching & update of the device firmware.

* Only if customer need single tenancy, customer can go with dedicated or managed HSM otherwise for multi tenancy Azure Keyvault premium is a good option.

* If the requirement is of storing keys for cloud native service like Azure storage, SQL Database etc. we need to choose Azure managed HSM. Dedicated HSM is not a good choice for cloud native. It is mostly used for lift and shift applications.

* In Dedicated & managed HSM we have option for AES key, which is symmetric keys.
In Azure KV premium & Standard we have only RSA which is asymmetric keys and there is no symmetric option.

* Azure KeyVault Standard provides secrets and keys which are software protected.
Azure Keyvault Premium provides keys which are stored in HSM and are 
FIPS 140-2 Level 3 compliant.

{: .prompt-tip }
>Secrets and certificates in premium tier utilize software for storing. Only keys can be hardware protected.

This blog was written in 2024, there is a latest offering Azure Cloud HSM and I have covered that topic in my latest blog [click here to learn more](https://www.azuredoctor.com/post/azure-cloud-hsm/)

Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
