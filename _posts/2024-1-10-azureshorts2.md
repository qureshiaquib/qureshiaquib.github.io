---
title: "Azure Shorts #2: Azure Key Vault & HSM: Which one is best for your encryption needs?"
date: 2024-1-10 12:00:00 +500
categories: [Azure Shorts]
tags: [key management solutions, Azure, Dedicated HSM, hardware control,  AKV managed HSM pool, single-tenant service, multi-tenancy, Azure Key Vault Premium, Azure managed HSM, symmetric keys, Azure KV Premium & Standard, RSA, asymmetric keys, Azure KeyVault Standard, Azure Key Vault Premium, stored in HSM, FIPS 140-2 Level 3 compliant, premium tier, hardware-protected]
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

Happy Learning!