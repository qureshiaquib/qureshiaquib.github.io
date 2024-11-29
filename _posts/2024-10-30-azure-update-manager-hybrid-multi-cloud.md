---
title: "Azure Update Manager: How it works for Hybrid & Multi-Cloud"
date: 2024-10-30 12:00:00 +500
categories: [tech-blog]
tags: [Azure Update Manager]
description: "Learn how Azure Update Manager works in Multi cloud and Hybrid environments. How WSUS and Repository servers are used and how AUM relies on Arc for extensions"
---

* **Scenario**: During a recent engagement one of my customers explained the challenges of managing patching and compliance reporting of their IT estate. It was a hybrid setup, and they had infrastructure spread across multiple clouds, including Azure. They had windows but a lot of their landscape was on SUSE and RedHat Linux servers. Customer wanted automated patching and reporting from central place.

* **Solution**: As the title suggests we asked them to adopt Azure Update Manager. It worked for on-premises as well as for their multi cloud estate. The customer has compliance dashboards created using Azure Monitor, which was customized based on their requirements.

## What is Azure Update Manager:
Azure Update Manager is a cloud-based solution used to schedule patches for on-premises servers and servers hosted on cloud providers like GCP, AWS, OCI, as well as Azure. Azure Update Manager itself is a cloud service, it cannot be installed as an appliance. This service is enabled by default on Azure at no additional cost. So, you don’t have to deploy this service like bastion or firewall. All the servers reports to AUM service via the Extensions.
So basically, under the hood it’s an extension installed on Azure VM or Azure Arc-Enabled VM. Yes, you heard it right. Azure Arc-Enabled VM. If you have a VM hosted outside Azure and want to use Azure Update Manager, you must enable Arc on that server first. And then AUM can be enabled as an Extension. 

![Table showing azure update manager extension name for arc vm](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31102024/table-showing-extension-name-forarc.jpg)

![Table showing azure update manager extension name for azure vm](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31102024/table-showing-extension-name-forazurevm.jpg)

Once a server is onboarded to AUM, it reports its compliance status to the AUM service, and patches can be scheduled from the AUM console present on Azure portal. Main job of Azure Update Manager is to instruct servers to download patches based on the various configuration. It won’t instruct machine where to download patches from, for example it won’t provide a repository server. Once VM/servers receive instructions from AUM to download patches, they will follow the local configuration on the machine to acquire patches. Like Windows server Update Server (WSUS) or directly over internet, or via Proxy server. The server will reach out to download patches, and once completed, it will report the latest compliance status to AUM.

## What is Arc:
Before we discuss and deep dive on the AUM, let’s discuss briefly about Arc.
Arc provides a platform to view and centrally manage all your workloads from a single pane, i.e., Azure.
It helps you deploy Azure services like Azure Monitor, Azure Update Manager, Defender, and many other solutions to on-premises servers. This is done by first installing Azure connected machine agent on every server. Once CMA is installed the machine becomes Arc-Enabled server. On which we can enable Azure solutions which we like via Extensions.


![Screenshot of Azure portal showing features supported on Arc servers](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31102024/arc-capabilities.jpg)

![Screenshot of Azure portal showing extensions supported on Arc servers](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31102024/arcextensions.jpg)

There are many extensions which can be deployed on Arc-Enabled VM. It is documented in below link.

[https://learn.microsoft.com/en-us/azure/azure-arc/servers/manage-vm-extensions#windows-extensions](https://learn.microsoft.com/en-us/azure/azure-arc/servers/manage-vm-extensions#windows-extensions)

I’ve written a blog post about certificate renewal for on-premises servers using the Arc Key Vault extension. You can find the blog below.

[https://www.azuredoctor.com/posts/arc-keyvault/](https://www.azuredoctor.com/posts/arc-keyvault/)

## How AUM works on Windows Servers:
As I mentioned previously, AUM doesn’t provide a repository server to which servers will reach out to and get patch updates, instead it’ll act as an orchestrator and inform server to download patches based on the schedule that you’ve specified. For example last day of the month, two days after patch Tuesday, weekly or monthly timeline etc. Once servers get the instructions then it’ll reach out to the WSUS repositories, or Microsoft update. Based on the configuration which is set on the machine.

I’ve seen customers having WSUS servers locally in their datacenters, as well as WSUS on Azure and other cloud providers so that Windows server doesn’t download patches directly from Microsoft Update over internet and use WSUS as local repository. But if you don’t want to rely on WSUS then you can directly whitelist Windows update URLs over proxy or firewall and servers will download latest updates accordingly.

## How AUM works on Linux:
The behaviour of AUM on linux is pretty much the same as Windows servers. AUM doesn’t provide Linux repositories but lets the system get updates from whichever repositories are configured. AUM’s job is to just trigger update based on the schedule.

AUM with Linux has multiple options. Depends on where your Linux server is hosted.

### On-premises:
If your linux servers are hosted on-premises then you’ll need to use local private repositories or public repo to download latest updates from OEM. If you’ve SUSE or RedHat servers and have license for SUSE Manager or RedHat satellite servers then these will act as a repositories and AUM will act as orchestrator for compliance check, schedule patch updates and reporting. SUSE Manager and RedHat Satellite are used for patching and these are paid version. You can use any repository server third party (3P) whichever you think is reliable and cheaper.

### Linux on Cloud:
If your Linux servers are hosted on Azure, GCP, or AWS. Especially vendors like RedHat and SUSE and if you’ve purchased the licenses from Market place or deployed it from the marketplace image then these vendors provides public cloud update infrastructure locally to that region through which servers can download latest updates. It will be a public connection outside your VNET or VPC but within the same region.

I’m providing below links to go through for their respective distributions and how they provide update infrastructure.

[https://www.suse.com/c/accessing-suse-updates-in-aws-when-do-you-need-a-private-repository/](https://www.suse.com/c/accessing-suse-updates-in-aws-when-do-you-need-a-private-repository/)

[https://www.suse.com/c/accessing-the-public-cloud-update-infrastructure-via-a-proxy/](https://www.suse.com/c/accessing-the-public-cloud-update-infrastructure-via-a-proxy/)

[https://www.suse.com/c/azure-public-cloud-update-infrastructure-101/](https://www.suse.com/c/azure-public-cloud-update-infrastructure-101/)

[https://www.suse.com/c/accessing-the-public-cloud-update-infrastructure-via-a-proxy/](https://www.suse.com/c/accessing-the-public-cloud-update-infrastructure-via-a-proxy/)

[https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-rhui?tabs=rhel7](https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-rhui?tabs=rhel7)

[https://access.redhat.com/products/red-hat-update-infrastructure](https://access.redhat.com/products/red-hat-update-infrastructure)

Below Architecture shows Azure Arc connectivity with Public endpoints and with Azure Private endpoints.
It'll also show where to place the Private Endpoints.

![Azure architecture diagram showing network architecture for arc connectivity](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31102024/arc-network-architecture.jpg)

Below architecture shows placement of WSUS and Linux Repo servers. It shows the multi-cloud setup.

![Azure architecture diagram showing network architecture for azure update manager](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31102024/azure-update-manager-architecture.jpg)
_Download [visio file](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/31102024/aum-architecture.vsdx) of this architecture_


## Cost of Azure Update Manager:
Let’s discuss the cost of the service; AUM is a cloud service. There is no appliance and you don’t have to spend on the appliance high availability etc. It’s all built into the service and you don’t have to take care of all that.
AUM for Azure Servers is free of cost. You can start leveraging AUM right away.
AUM is free when you’ve servers hosted on Azure Stack HCI on-premises.
It is chargeable for servers hosted on-premises. It is charged 5$ per server per month.
 AUM for Arc-Enabled servers is free under three conditions.
1.	If you’ve enabled Extended security updates via Arc
2.	If you’ve Defender for Servers Plan 2.
3.  Windows Server Management enabled by Azure Arc offers customers with Windows Server licenses that have active Software Assurances or Windows Server licenses that are active subscription licenses can get AUM for free.

More details about above scenarios in link below.
[https://learn.microsoft.com/en-us/azure/update-manager/update-manager-faq#are-there-scenarios-in-which-arc-enabled-server-isnt-charged-for-azure-update-manager](https://learn.microsoft.com/en-us/azure/update-manager/update-manager-faq#are-there-scenarios-in-which-arc-enabled-server-isnt-charged-for-azure-update-manager)

[https://techcommunity.microsoft.com/blog/azurearcblog/announcing-general-availability-windows-server-management-enabled-by-azure-arc/4303854](https://techcommunity.microsoft.com/blog/azurearcblog/announcing-general-availability-windows-server-management-enabled-by-azure-arc/4303854)

I hope this blog helps you deploying AUM faster and help you follow right architecture pattern.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }