---
title: "How to Configure Azure SQL Managed Instance for Beginners"
date: 2023-12-22 12:00:00 +500
categories: [tech-blog]
tags: [Azure SQL Managed Instance]
description: "This blog is for beginners who wanted to learn Azure SQL managed instance and learn how to quickly configure the service with best practices"
---

I have come across multiple instances where customer is exploring SQL PaaS instance for the first time.
Customers, due to multiple reasons choose Azure SQL Managed Instance as DB of choice. 
They are new to this PaaS offering hence they wanted quick tips to get going.
I thought of collecting few basics in a single place as a ready reckoner. 

## Redirect connection policy instead of proxy connection:

There are two modes of connectivity when we use Azure SQL, redirect and proxy.
When you connect to DB via proxy method we always connect through gateway and that act as proxy. This adds additional latency and lowers throughput. When we select redirect connection method, we skip the proxy gateway. Keep in mind we have to open additional ports 1433, and 11000-11999.

![Proxy and redirect connection type in SQL MI](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/22122023/proxy-and-redirect-connection-type.jpg)

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/connection-types-overview?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/connection-types-overview?view=azuresql)


## Maintenance Windows setting: 

Patching and upgrade of SQL MI happens in the backend with less impact to customer.

There might be times when there is a short disconnection and we don’t want that to happen during weekdays.

By default, patching window is set to 5 PM to 8 AM every day. But some customers would like to change this setting to perform the maintenance over the weekend. This update involves all the components maintenance. If you are using a redirect method of connection, then the maintenance for gateways will not impact your connection as you are already bypassing gateway.

![Maintenance window of SQL MI](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/22122023/maintenance-window-sql-mi.jpg)

[https://learn.microsoft.com/en-us/azure/azure-sql/database/maintenance-window?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/database/maintenance-window?view=azuresql)

You can be notified in advance if there is maintenance which is planned.
You can configure advance notification (currently in preview)

[https://learn.microsoft.com/en-us/azure/azure-sql/database/advance-notifications?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/database/advance-notifications?view=azuresql)

You can expect one planned update once every 35 days on average.


## Setting Alerts:

While you are running SQL MI in production you can set alerts based on the metrics which are available.
Also, if you need more metrics for alerts then you can enable diagnostics logs which sends data to Azure Log analytics. And then configure alerts based on Azure Monitor logs.

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/auditing-configureview=azuresql#set-up-auditing-for-your-server-to-event-hubs-or-azure-monitor-logs](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/auditing-configure?view=azuresql#set-up-auditing-for-your-server-to-event-hubs-or-azure-monitor-logs)

![Metrics in SQL Managed Instance](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/22122023/metrics-in-sql-mi.jpg)

You cannot get the memory here as it will always be more than 80%.
We’ve good documentation on how to determine the memory that is needed for your SQL DB.

[https://techcommunity.microsoft.com/t5/azure-sql-blog/do-you-need-more-memory-on-azure-sql-managed-instance/ba-p/563444?wt.mc_id=DP-MVP-4015656](https://techcommunity.microsoft.com/t5/azure-sql-blog/do-you-need-more-memory-on-azure-sql-managed-instance/ba-p/563444?wt.mc_id=DP-MVP-4015656)


## FOG Endpoint: 

If you have configured failover group in SQL MI, then you will get the FOG endpoint which you can use to connect to the DB. This is a listener endpoint which will remain the same even if the DB failover happens to secondary region. You should use this in your connection string instead of directly connecting to the SQL MI endpoint.
e.g. fog-name.database.windows.net

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/failover-group-configure-sql-mi?view=azuresql&tabs=azure-portal%2Cazure-powershell-manage](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/failover-group-configure-sql-mi?view=azuresql&tabs=azure-portal%2Cazure-powershell-manage)


## Lock down Azure SQL MI and prevent data exfiltration:

One way to get data out of Azure SQL MI is via the restore operation. 
Backup happens on Azure managed storage, but SQL DBA can export Copy only backup to other storage account which can be public and then can try to get the Database out of organization.

To prevent this, we can lock down SQL MI so that it can export data to specific storage account only. This setting is specified in the service endpoint policy, and you apply the service endpoint policy to the managed instance subnet.
This way you can lock down MI to specific storage account only if copy only backup is triggered it can only be sent to this storage account which you've configured.

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/service-endpoint-policies-configure?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/service-endpoint-policies-configure?view=azuresql)

Also, you can configure SQL Audit alerts.

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/auditing-configure?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/auditing-configure?view=azuresql)


## Management operations take time:

Dealing with SQL MI management operations is quite different when you compare it with other operations on Azure which is very instant. Changing a VM SKU or disk size or application gateway changes takes less time but changes to SQL MI are not instant always so you should know how much time it will take for you if you make some changes to SQL MI during production. 

Deployment of new cluster can take few hours but at the same time with new feature wave this has drastically reduced to minutes.

Management operations and respective time is mentioned in detailed in below document.

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/management-operations-overview?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/management-operations-overview?view=azuresql)


## Connection retries during transient errors:

Connection retry during any unexpected disconnection is preferred approach. This helps with better and consistent functioning of an application. Usually accomplished by an application team, but DBAs should be aware of this.

You can find sample code here.

[https://learn.microsoft.com/en-us/azure/azure-sql/database/troubleshoot-common-connectivity-issues?view=azuresql#retry-logic-for-transient-errors](https://learn.microsoft.com/en-us/azure/azure-sql/database/troubleshoot-common-connectivity-issues?view=azuresql#retry-logic-for-transient-errors)


## Test the failover of the DB:

Azure SQL MI provides cmdlets to let you initiate manual failover of the DB to the other node just to validate how your application would react in case there is a failover. This can be tested via PowerShell or cli.

[https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/high-availability-sla?view=azuresql-mi&preserve-view=true#testing-application-fault-resiliency](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/high-availability-sla?view=azuresql-mi&preserve-view=true#testing-application-fault-resiliency)


## Do we get read replica:

With Business-critical tier we get inbuilt read replica for free. So, you can connect to read replica for reporting with normal connection string applicationIntent=”Readonly” method.

In general purpose tier you can configure failover group and that way you can get read replica.

[https://learn.microsoft.com/en-us/azure/azure-sql/database/read-scale-out?view=azuresql](https://learn.microsoft.com/en-us/azure/azure-sql/database/read-scale-out?view=azuresql)


## Enable defender for Azure SQL DB: 

Enabling defender for Azure SQL MI helps you with vulnerability assessment and unusual DB access attempts to the DB. 

[https://learn.microsoft.com/en-us/azure/azure-sql/database/azure-defender-for-sql?view=azuresql#enable-microsoft-defender-for-azure-sql-database-at-the-subscription-level-from-microsoft-defender-for-cloud](https://learn.microsoft.com/en-us/azure/azure-sql/database/azure-defender-for-sql?view=azuresql#enable-microsoft-defender-for-azure-sql-database-at-the-subscription-level-from-microsoft-defender-for-cloud)

I hope this was helpful.Share the blogpost if you like it.

This would be my last blog of this year, will see you in 2024. Until then a very happy new year! :)

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
