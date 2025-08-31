---
title: "Understanding Azure Cloud HSM: Key Concepts to Know"
date: 2025-6-24 12:00:00 +500
categories: [Azure Shorts]
tags: [Azure Cloud HSM]
description: "Explore Azure Cloud HSM, its high availability, key use cases, and understand the differences between Azure Cloud HSM and Azure Dedicated HSM solutions"
---

I saw readers' interest in HSM offerings from my previous blog post. You can read the blog post [here](https://www.azuredoctor.com/posts/azureshorts2/)
There is a new HSM offering from Azure known as Azure Cloud HSM, which is in preview. It will be generally available (GA) soon, and hence I thought about covering some quick tips around what it is all about.

What is the difference between Managed HSM and Azure Dedicated HSM compared to Azure Cloud HSM?

* Azure Cloud HSM uses the same HSMs as Managed HSM, Marvell LiquidSecurity HSM.

* AKV and Managed HSM would be more for SaaS and PaaS offering. Managed HSM supports encryption at rest scenarios and integrates with other Azure services. Whereas Azure Cloud HSM is for IaaS only and supports general purpose workloads.

* Azure Cloud HSM is single-tenant. It’s cryptographically isolated to each individual tenant. The isolation is enforced at the firmware level, and hence it's NIST certified with FIPS 140-3 Level 3.

* Azure Cloud HSM provides high availability and redundancy by grouping HSMs into HSM cluster and automatically synchronizing across 3 HSM instances. 

* Azure Cloud HSM is a client-server model. Microsft provide SDKs for customers to connect to their Cloud HSM through interface via PKCS11 or JCE etc. Whereas Managed HSM shares the same Rest API as AKV. Azure Cloud HSM is more similar Dedicated HSM in terms of interface methods to connect. 

* Azure Cloud HSM provides self-healing. If one instance goes down, then through attestation Microsoft replace the failed node to maintain availability. 

* In Dedicated HSM customer has to manually configure a device for High availability. It can take hours for the configuration.

* Azure Cloud HSM, Microsoft manages maintenance and patching. Customers have administrative control of their Cloud HSM, key materials and access to backups to restore operations. 

* Deployment takes 5 - 10 minutes and it's not 20+ minutes as Dedicated HSM.

* It supports symmetric and asymmetric keys. More about the keys are mentioned in below document.
[https://learn.microsoft.com/en-us/azure/cloud-hsm/service-limits](https://learn.microsoft.com/en-us/azure/cloud-hsm/service-limits)

* We should have a separate admin workstation to configure HSM than where your application is hosted. This admin workstation is where you'll configure additional user, configure roles for cloud HSM, You can shut it down and bring it on based on the requirement. Other similar best practices can be found here: [https://learn.microsoft.com/en-us/azure/cloud-hsm/secure-cloud-hsm](https://learn.microsoft.com/en-us/azure/cloud-hsm/secure-cloud-hsm)

I hope both the blog helps you in making informed decisions about HSM options on Azure Cloud.
Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }