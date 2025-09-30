---
title: "Imitating On-Premises VMs on Azure VM for Demo Labs"
date: 2025-9-30 01:00:00 +500
categories: [Azure Shorts]
tags: [Azure Arc]
description: "Learn how to imitate on-premises VMs on Azure by disabling Azure Guest Agent and blocking IMDS, enabling quick demo and lab setups on Azure VM with less effort"
---

A quick post in Azure Shorts category.

* **Scenario**: Many times I’ve seen partners and Azure specialists wanting to create a demo environment to reproduce on-premises hosted scenarios. They struggle to imitate on-premises environments like VMware or Hyper-V–based VMs, since hosting them on Azure is difficult.
You can host Hyper-V on a Windows Server, however, the networking and switch configuration is a little difficult for folks who want to build quick POC labs. Similarly, for a VMware setup, you can host AVS and then create VMs, but the cost of AVS is high and not everyone can afford such an environment. Hosting systems on-premises is the ideal scenario, but it is not always feasible or instantly achievable.

I once came across a demo requirement for Arc. Similarly, there can be scenarios where you want to imitate on-premises VMs on an Azure VM itself.

* **Solution**: One quick and easy process I found is to disable the Windows Azure Guest Agent service and set it to disabled mode. Additionally, create Windows Firewall rules to block connections to the Instance Metadata Service.

Once you run the following commands on Azure VM. You can onboard this machine to Azure Arc and build demo labs.

```shell
Set-Service WindowsAzureGuestAgent -StartupType Disabled -Verbose
Stop-Service WindowsAzureGuestAgent -Force -Verbose
New-NetFirewallRule -Name BlockAzureIMDS -DisplayName "Block access to Azure IMDS" -Enabled True -Profile Any -Direction Outbound -Action Block -RemoteAddress 169.254.169.254
```

I hope you quickly build your POC on Azure VM.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }