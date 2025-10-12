---
title: "Connecting Hybrid and Multi-Cloud Data to Power Platform"
date: 2025-10-12 01:00:00 +500
categories: [tech-blog]
tags: [Power Platform]
description: "Discover different ways to connect hybrid and multi-cloud data including on-premises, Azure, and other clouds privately to Microsoft Power Platform and Fabric."
---

I have worked with multiple customers who were trying to implement Power BI, Fabric, Logic Apps, or other Power Platform components, where they wanted to bring on-premises data or SQL Server/flat file data into the workspace and understand how they could do this. What are the different options do we have available today to connect and import data.

The intention of this blog post is to simplify and consolidate all the approaches in a single post. We’ll not go through step-by-step installation processes for all the different types of services; instead, we’ll discuss the approaches at a high level.

Most customers use the on-premises data gateway. However, there are more options available that you can use. Let’s discuss.

## On-premises Data gateway
This is one of the oldest methods available and is mainly used when you want to bring on-premises data or connect to services hosted in the cloud. 
* Basically, you install it on a Windows client or server, manage the VM, and handle its maintenance. The recommendation is to install it with 8 vCPUs and 8 GB of memory.
You can download the gateway from the link below.
[https://www.microsoft.com/en-us/power-platform/products/power-bi/gateway](https://www.microsoft.com/en-us/power-platform/products/power-bi/gateway)
* There are two installation modes, the first is Personal Mode and the second is Standard Mode. Personal Mode is used for installing it on a client to collect data such as flat files, typically for Power BI.
* The second method is for collecting data from databases, and wide variety of data sources. This Standard Mode is used in Azure Logic Apps, Analysis Services, and the Power Platform.

More information about the On-premises Data Gateway can be found at the link below.
[https://learn.microsoft.com/en-us/data-integration/gateway/service-gateway-onprem](https://learn.microsoft.com/en-us/data-integration/gateway/service-gateway-onprem)

## VNET data gateway
VNET Data Gateway is a secure way to connect to your data sources. 
* When you deploy on-premises data gateway, it connects to the data sources privately but the outbound connection happens over internet.
It is an encrypted connection; however, customers who want private outbound connectivity can use VNET Data Gateway, which avoids public connections.
* In this setup, a managed VNET is created and hosted in Microsoft environment where a cluster of gateways are hosted. It is connected to customer VNET via network card ingestion in customer subnet. 

![Architecture showing vnet data gateway placement](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/12102025/vnet-data-gateway.jpg)

You can find the architecture here: [https://learn.microsoft.com/en-us/data-integration/vnet/data-gateway-architecture](https://learn.microsoft.com/en-us/data-integration/vnet/data-gateway-architecture)

* Instances can be scaled horizontally, currently the instance size is 2 core 8GB memory. You’ll need to understand the query type and dataset size if you plan to migrate from the on-premises data gateway to the VNET Data Gateway. In the on-premises data gateway, customers control the vCPU and memory size. In the VNET gateway, you’ll need to use a cluster of instances for parallel execution. 
* The VNET Data Gateway is currently supported only for the following use cases:
Fabric Dataflow Gen2, Fabric data pipelines, Fabric Copy Job, Fabric Mirroring, Power BI semantic models, and Power BI paginated reports. It is not supported for Power BI Dataflows and Datamarts.
* To use VNET data gateway, there are license requirements.
It is only available for P, F, and A4 or higher (A4, A5, A6, and A7) SKUs. For F SKUs, Microsoft recommends using F8 and above.
* One important aspect is that this is primarily used for ETL workloads and for short-lived API calls we've better approach available, which is VNET Integration method, We’ll discuss in the next section.
* The VNET Data Gateway can be connected to a Hub VNET, allowing it to access resources outside Azure, such as on-premises or other clouds.

## With VNET Injection.
* In the VNET Data Gateway method, the containers - the service helps in the outbound communications are hosted in Microsoft-managed environments, while in the VNET Injection method, the containers are hosted in the customer’s VNET itself.
* This is used by Power Apps, Power Automate cloud flows, Dynamics 365 apps, Copilot Studio, and all outbound connections from these services pass through the delegated subnet.
* This is used for transactional scenarios and for making API calls to the supported resources listed below.
    * Dataverse plug-ins
    * Custom connectors
    * Azure Blob Storage
    * Azure File Storage
    * Azure Key Vault
    * Azure Queues
    * Azure SQL Data Warehouse
    * HTTP with Microsoft Entra ID (preauthorized)
    * SQL Server

    You still need to rely on the VNET Data Gateway if you’re using Power BI and Power Platform Dataflows.

* In contrast to the VNET Data Gateway, where P, F, and other licenses are required, you don’t need a license to use VNET Injection. This is available for most SKUs. Users only need the basic M365 licenses mentioned here to access this service:

Few helpful links here:

[https://learn.microsoft.com/en-us/power-platform/admin/powerapps-flow-licensing-faq#azure-virtual-network-vnet](https://learn.microsoft.com/en-us/power-platform/admin/powerapps-flow-licensing-faq#azure-virtual-network-vnet)

[https://learn.microsoft.com/en-us/power-platform/admin/virtual-network-support-whitepaper](https://learn.microsoft.com/en-us/power-platform/admin/virtual-network-support-whitepaper)

It was a quick read on different methods available to integrate with power platforms. I hope you find it helpful.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
