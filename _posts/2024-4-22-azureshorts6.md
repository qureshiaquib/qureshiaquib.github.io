---
title: "Enhance your Azure Observability with Azure Workbook"
date: 2024-4-22 12:00:00 +500
categories: [Azure Shorts]
tags: [Azure Workbook]
pin: true
description: "Discover pre-built Azure workbooks for enhanced monitoring across azure services like Firewall, Defender for Cloud, and Azure Arc from public repositories"
---

This Doctor Shorts is a collection of workbooks. If you’re a partner who has deployed some solution for your customer, observability is key to your project. Workbooks can help you provide value to your customer not only by deploying the solution but also by providing monitoring capabilities. You can create your own workbook by writing ARG and KQL queries, but why reinvent the wheel when it’s already done by the PG? There are plenty of places where workbooks are available: Azure PG Github Repo, personal GitHub repos, and some are available in learn documentation, etc. All the links below will help you with JSON format workbooks, which you can import directly into your workbook and utilize them. Within less than 10 minutes, you’re up and running!

## Dashboard for Network Security: 
This will provide Dashboard and some KQL queries too for Azure Firewall, WAF and DDoS.
[https://github.com/Azure/Azure-Network-Security](https://github.com/Azure/Azure-Network-Security)

## Defender for Cloud:
This includes : Azure Security Benchmark, CSPM Dashboard, Costing related workbook etc.
[https://github.com/Azure/Microsoft-Defender-for-Cloud/tree/main/Workbooks](https://github.com/Azure/Microsoft-Defender-for-Cloud/tree/main/Workbooks)

## Azure Monitor:
This is parent location from Azure Monitor team where all the services are located and community workbooks can be hosted. Not every service would have workbooks placed but there is a placeholder named workbook in each service. I’ve found one workbook under Azure Arc services. You can go into other folders meant for specific azure service and see if workbook folder contains anything. 
[https://github.com/microsoft/AzureMonitorCommunity/tree/master/Azure%20Services/Azure%20Arc/Workbooks](https://github.com/microsoft/AzureMonitorCommunity/tree/master/Azure%20Services/Azure%20Arc/Workbooks)

## Application Insights Workbook:
Don’t go via the name of the repository, this consist of all the major service and some sample workbooks, Azure Update management, azure backup etc.
[https://github.com/microsoft/Application-Insights-Workbooks/tree/master/Workbooks](https://github.com/microsoft/Application-Insights-Workbooks/tree/master/Workbooks)

## Azure Arc:
I’ve seen lots of requirements around customer requesting workbooks for Azure Arc service. Hence there are lots of repo which I’ve collected for you folks.

### ARG queries for Azure Arc – SQL
[https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/view-databases?view=sql-server-ver16](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/view-databases?view=sql-server-ver16)

### Azure Monitor Community – Azure Arc for Servers
[https://github.com/microsoft/AzureMonitorCommunity/tree/master/Azure%20Services/Azure%20Arc/Workbooks/Azure%20Arc%20for%20Servers](https://github.com/microsoft/AzureMonitorCommunity/tree/master/Azure%20Services/Azure%20Arc/Workbooks/Azure%20Arc%20for%20Servers)

### Community Driven:
* **By Sarah Lean**:
[https://github.com/weeyin83/Azure-Arc-Windows-Linux-Dashboard](https://github.com/weeyin83/Azure-Arc-Windows-Linux-Dashboard)

* **By Cameron Battagler**:
[https://github.com/Onesuretng/Arc-enabled-SQL-Dashboards](https://github.com/Onesuretng/Arc-enabled-SQL-Dashboards)

* **By Raúl Carboneras**:

    Azure Dashboard for ARC SQL
[https://github.com/rcarboneras/sql-server-samples/tree/master/samples/features/azure-arc/dashboard](https://github.com/rcarboneras/sql-server-samples/tree/master/samples/features/azure-arc/dashboard)

    Azure Arc SQL workbook
[https://github.com/rcarboneras/sql-server-samples/tree/master/samples/features/azure-arc/workbooks](https://github.com/rcarboneras/sql-server-samples/tree/master/samples/features/azure-arc/workbooks)

* **By Elan Shudnow**:
[https://github.com/ElanShudnow/AzureCode/tree/main/Workbooks](https://github.com/ElanShudnow/AzureCode/tree/main/Workbooks)

* **By Prachi Trivedi**:
Though this blog is not just import and goto workbook but it provides good info around Arc workbook and how to utilize and create your own workbook. Written by my colleague.
[https://techcommunity.microsoft.com/t5/azure-infrastructure-blog/azure-arc-azure-monitoring-and-azure-workbooks/ba-p/4083453](https://techcommunity.microsoft.com/t5/azure-infrastructure-blog/azure-arc-azure-monitoring-and-azure-workbooks/ba-p/4083453)

I hope this will help you enhance your Azure Monitoring!
If you know more repo and community driven workbook by any person post that in the comment section :)


>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
