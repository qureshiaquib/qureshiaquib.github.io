---
title: "Access services across tenant with service principal"
date: 2024-08-11 12:00:00 +500
categories: [tech-blog]
tags: [Entra ID Enterprise App]
description: "Learn how to implement cross-tenant access in Azure using Multi-Tenant Enterprise app. Simplify management of multi-tenant environments without secret sharing"
---

* **Scenario**: One of the customers reached out and said they wanted to give access to services hosted in their tenant to another provider which has got their own Entra ID tenant. They can create a service principal and provide secrets to the provider but they don’t want to perform secret management for them. As there can be multiple such providers, they wanted to find a seamless solution.

* **Solution**: An enterprise app can be created in provider’s Entra ID tenant as a multi-tenant app. And then the same app can be registered in customer’s Entra ID. Once it is registered, you can assign permissions to relevant Azure services in customer’s Entra ID tenant to service principal of the multi-tenant App. The Provider will create a secret in the Provider Tenant and then authenticate to the services present in the customer’s Entra Tenant.

![vision giving thor mjonir](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/comic.jpg)


![Azure architecture diagram showing multi tenant enterprise application](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/architecture-architecture-diagram.jpg)
_Download [architecture](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/11082024/Architecture.vsdx) diagram_


When you register an application an application object and a service principal is created in the tenant. Application objects are unique and there can be multiple service principal. One service principal in the same tenant but there can be more than one service principal in other tenant. So Application object has one to many relationships with service principal.

**Considerations**:
* This is just an architectural pattern. On the provider side, we have an application that can access services in the customer's tenant via the secrets created from the enterprise application in the provider tenant.
Based on this, you can now have a similar architecture where apps can be hosted in the provider tenant and Azure KeyVault, which hosts keys in the customer's tenant. Customers control the data as apps will be using CMK provided by customer, and customer can revoke the keys whenever they want.\
You can bring logs and data for analysis from customer tenant etc. as you know private endpoint can span multiple tenants and PaaS service’s private endpoint can be hosted in provider tenant also and hence no need to have VNET peering or IPSec Tunnel to securely transfer data from customer tenant to provider tenant. I’ve explained this in another blog post [here](https://www.azuredoctor.com/posts/resourcesharing-with-azure-private-endpoint/). So once authentication is done, you can connect to PaaS services and then build complex architectural patterns.

* On the Provider Tenant in order to authenticate you’ll need to use the secret of the multi tenant app. You can store this secret in Azure Key Vault and use Managed Identity to retrieve the secrets from AKV, and then create another authentication context with Customer’s Entra ID, but you’ll still need to rely on secrets in the end.
Federation via the Federated Identity credentials with managed service identity on the service principal created by Enterprise App is not yet supported between two Entra Tenants yet. This means you have a VM, and you assigned a user-managed service identity to the VM. And that MSI is assigned as Federated identity to the enterprise App. So you don’t rely on secrets in the process at all. This scenario is not yet possible. Exception to this is one scenario where keys are stored in customer tenant in Azure Key Vault and on the provider side you’re using a PaaS service like SQL DB or Storage Account, etc.

This is well explained in articles below.

[https://learn.microsoft.com/en-us/azure/azure-sql/database/transparent-data-encryption-byok-cross-tenant?view=azuresql#setting-up-cross-tenant-cmk](https://learn.microsoft.com/en-us/azure/azure-sql/database/transparent-data-encryption-byok-cross-tenant?view=azuresql#setting-up-cross-tenant-cmk)

[https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-cross-tenant-new-account?tabs=azure-portal](https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-cross-tenant-new-account?tabs=azure-portal)


It's a four-step process outlined below.

1.	Create the Enterprise App in the Provider Tenant.
2.	Register the Enterprise App in the customer Entra Tenant
3.	Assign permissions to relevant Azure services present in Customer Entra Tenant. Permission would be given to the Enterprise App’s service principal.
4.	Any application in Provider Tenant will then authenticate via the Customer’s Entra tenant and then access specific service. Without customer’s involvement in generating any secrets or managing it.

Create the Enterprise Application in provider Tenant. You need to make sure that when you perform app registration, the supported account type is selected as multi-tenant, as mentioned below.

![Entra ID page where enterprise app is created](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/create-multi-tenant-app-part1.jpg)
![Selecting multi tenant account type while creatig enterprise app](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/create-multi-tenant-app-part2.jpg)


Register the App in customer’s tenant. You can use portal method to create, the pattern of forming URL is as below. You’ll need to replace the customer Tenant ID with the Entra Tenant ID where you’re trying to create the application and assign the permission to azure services.

```shell
https://login.microsoftonline.com/CustomerTenantID/adminconsent?client_id=ClientID
```

![Accept and create the enterprise application in customer tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/accept-app-creation-in-customer-tenant.jpg)

Assign permissions to the relevant Azure services.

![Assign role to service principal in customer tenant](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/assign-roles-to-service-principal-part1.jpg)
![Selecting the service pricipal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11082024/assign-roles-to-service-principal-part2.jpg)


Once the above steps are accomplished, you can use Azure SDK to authenticate to the customer's tenant and then access services.

The PowerShell example below is just to validate whether authentication is working properly, and you can also fetch secrets from KeyVault, you can also replace keyvault with other services where you’ve assigned the permission.

```shell
$customertenantId = "xyz123-xyz123-xyz123-xyz123-xyz123"

#client ID & Secret of Enterprise App
$clientId = "dda216bf-xyz123-4c17-xyz123-xyz123"
$clientSecret = "--68Q~xyz123_zFN4Mv9GLiotn.IhWAKa7L"

$securePassword = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $clientId, $securePassword

#Authenticate to customer tenant
Connect-AzAccount -ServicePrincipal -TenantId $customertenantId -Credential $credential

# Define the Key Vault name
$keyVaultName = "keyvaultname"

# Get the secret from the Key Vault
$secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "secretname"

# Display the secret value
$secret.SecretValueText

# Convert the secure string to plain text
$secretValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue))

# Display the secret value
$secretValue
```

I hope above architecture pattern helps you in designing complex multi tenant application easily. This can also be used if you’re a SaaS provider and thinking of offering services on Azure. Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }

