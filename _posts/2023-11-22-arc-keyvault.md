---
title: "Simplify certificate management of on-premises IIS server with Azure Arc and Azure Key Vault VM extension"
date: 2023-11-22 12:00:00 -500
categories: [tech-blog]
tags: [Azure Arc]
---

One common question which I’ve come across is certificate management for web servers. Usually when servers are hosted on Azure there are ways like storing certificates and secrets in Azure Key vault is a viable solution. I’ve come across customers who’re running servers in hybrid and few servers would still remain on-premises because of dependencies. For these web servers managing certificates is a costly affair. Common practice which I’ve seen is admin sharing the certificate with application team on some file share. This creates few problems

1.	Storing the certificate in file share or on email.
2.	Based on the number of application team a lot of team gets access to certificates.
3.	Manually applying updated certificates once the expiry is near also finding which all servers this certificate is being used is a pain if you’ve a big environment with lots of web service. 

One better way to handle this scenario is to Store certificate in Azure Key vault centrally and Arc Enable the web server. One last step which will do the magic is Azure Key vault VM Extension. Which can be enabled on Arc Server as extension. 

#### This setup provides the advantages below.

1.	All the certificates are stored centrally in Azure Key Vault which is protected.
2.	No application team has got manual access to certificates, on-prem server will pull the certificate based on the managed identity   assigned via Azure Arc.
3.	Once the cert expiry is near Admin/app team need to just goto Azure Key Vault and update the certificate with the latest version. Azure Key vault VM Extension will pull the latest certificate and apply the same to the website.

```shell
$Settings = @{
  secretsManagementSettings = @{
    observedCertificates = @(
      "https://keyvaultname.vault.azure.net/secrets/certificatename"
      # Add more here in a comma separated list
    )
    certificateStoreLocation = "LocalMachine"
    certificateStoreName = "My"
    pollingIntervalInS = "3600" # every hour
  }
  authenticationSettings = @{
    # Don't change this line, it's required for Arc enabled servers
    msiEndpoint = "http://localhost:40342/metadata/identity"

    }
}
$ResourceGroup = "ARC_SERVER_RG_NAME"
$ArcMachineName = "ARC_SERVER_NAME"
$Location = "ARC_SERVER_LOCATION (e.g. eastus2)"

New-AzConnectedMachineExtension -ResourceGroupName $ResourceGroup -MachineName $ArcMachineName -Name "KeyVaultForWindows" -Location $Location -Publisher "Microsoft.Azure.KeyVault" -ExtensionType "KeyVaultForWindows" -Setting (ConvertTo-Json $Settings)
```
For auto renewal of certificate, we’ll need to enable IIS Rebind.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30112023/Picture1.jpg)

This is how Arc VM Extension looks like when it’s enabled.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30112023/Picture2.jpg)

Assigning permission to Arc server to fetch the certificate from keyvault.
You can use access policy on Keyvault as well, it’s supported.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30112023/Picture3.jpg)

Versions of the certificate can be uploaded from keyvault certificate blade and looks like below.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30112023/Picture4.jpg)

If you’re renewing certificates and wanted to see if certificates are getting pulled down properly or not you can check error logs located here.
C:\ProgramData\Guestconfig\extension_logs\Microsoft.Azure.Keyvault.keyvaultforwindows

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30112023/Picture5.jpg)

If you’re running Azure VM similar thing can be achieved
[click here](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-windows)

Cert Rebind in IIS
[click here](https://learn.microsoft.com/en-us/iis/get-started/whats-new-in-iis-85/certificate-rebind-in-iis85)

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
