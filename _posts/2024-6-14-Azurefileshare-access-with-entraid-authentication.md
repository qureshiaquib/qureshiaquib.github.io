---
title: "Access Azure File from Remote sites via Entra ID join device"
date: 2024-6-14 12:00:00 +500
categories: [tech-blog]
tags: [Azure File Share]
---

* **Scenario**: I've come across a scenario where a customer had remote sites with File Servers, no Domain controller on site, and no connectivity with the Hub site where the domain controller was hosted. Users used to access the file server locally.
They used to sign in using Entra ID credentials on the devices managed through Intune.
Maintaining individual remote file servers was difficult. Additionally, having two different user IDs was not an ideal solution.

* **Challenge**: How can an Entra ID-joined device get a Kerberos token? And how would native NTFS permissions work on a File share?

* **Solution**: Azure File share supports Kerberos authentication via Entra ID. Entra ID would provide a Kerberos token to Entra ID-joined devices if users are hybrid, meaning users should be syncing from Active Directory to Entra ID via AD Connect or AD Connect Cloud Sync.

This blog discusses the services required to set this up. Configuring the Storage account with Entra ID Kerberos authentication and modifying registry settings is clearly explained in the Microsoft Learn document, so I won't repeat the configuration setup.

The link below will take you directly to the configuration details.

[https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable?tabs=azure-portal](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable?tabs=azure-portal)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14062024/Picture1.jpg)

The list of services used in the architecture is below:

* VPN gateway: For creating a site-to-site IPSec tunnel between remote sites. You can replace this with any third-party NVA which provides similar capabilities.
* Azure Firewall: Provides security and blocks unwanted traffic from the outside network.
* Azure File Share: This is the core component of the architecture, providing file share services. It alleviates many pains such as high availability of file servers, FRS/DFSR, security, and backup services. Everything is managed as a service with less overhead for the customer.
* AD Server: This is required for setting the NTFS permissions on the file share the first time.
* Domain Joined VM: This is where the Admin from an individual remote branch site would log in and set the NTFS permissions on the file share. If you have many branch sites and admins logging in simultaneously, you can use an AVD environment instead of a single VM. I'll let you decide; in this blog, I've factored in one VM to keep it simple.
* Private Endpoint: Azure File share can be accessed publicly (via QUIC), but in our case, the customer wanted to connect privately, so we've configured a private endpoint.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14062024/Picture2.jpg)

The flow of the setup is as follows:

1.	Azure Admin:
    - Creates a site-to-site tunnel with the Hub site where the domain controller is hosted and with the remote branch site.
    -	Creates all the required VNETs
    -	Configures Azure File Share and a private endpoint
    -	Configures Azure Firewall to allow traffic
    -	Promotes a Windows server to the ADC role.
    -	Configures the environment to support Kerberos authentication of AFS as mentioned in the Learn document.
    -	Sets permissions for all remote branch admins so they can delegate permissions to their users. Using groups to assign permissions on Azure File share will make the deployment clean and simple.

2.	Remote Admin:
    -	Connects to the domain-joined VM on Azure and sets permissions on Azure File share.
3.	End user:
    -	Maps the Azure File share with Entra ID credentials.

Everyday activities would only involve steps 2 and 3. The second step can be minimized by using security groups in Active Directory and assigning permissions based on groups.

Additionally, you can enable snapshot-level backup on Azure File share and also enable GRS replication if you have compliance requirements. Both activities are just a click of a button with no heavy backup and DR appliance setup.

Please note, in this blog I've mentioned hosting an additional domain controller on Azure.
In my scenario, the customer didn't want to have remote branch connectivity to Azure where the domain controller is hosted; hence, the same solution can work even if you have the domain controller hosted in Hub site and only AFS and domain-joined VMs hosted on Azure and connected to all remote branch sites.
I've added an additional domain controller as most customers have an additional domain controller on Azure, with Azure being a different Active Directory site for them.

I hope the above architecture demystifies the Azure File share with Entra ID Kerberos authentication setup.

Happy Learning!


>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }