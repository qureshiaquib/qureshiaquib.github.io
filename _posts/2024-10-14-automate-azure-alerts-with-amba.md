---
title: "Automating Azure Alert creation with Azure Policy"
date: 2024-10-14 12:00:00 +500
categories: [tech-blog]
tags: [Azure Alerts]
description: "Learn how Azure Monitor Baseline Alert (AMBA) automates alert creation using Azure Policy, streamlining monitoring for new and existing resources in Azure"
---

* **Scenario**: Customers implement Azure Monitor for a wide variety of resources such as VMs, Disks, App Services, and SQL DBs. Once this is enabled, customers use workbooks for viewing specific scenarios. I’ve covered workbooks in one of my previous [blogs](https://www.azuredoctor.com/posts/azureshorts6/). One major challenge they face is of implementation of Alerts. This feature is one of the key capabilities of Azure Monitor, alerting when there is a threshold which gets triggered. It can range from VM CPU usage to more complex scenarios, such as capturing metrics of App Services. Alerts can be created manually. But one of the challenges which I’ve seen is, usually customers create Alerts for the resources which are deployed. What happens when you deploy new resources after the alert is created? A very specific type of alert currently covers all newly deployed resources, but not all resource types. We’ll cover that later in the blog.

* **Solution**: Azure Monitor Baseline Alert (AMBA) streamlines the creation of Azure Alerts through Azure Policy. By utilizing an Azure Policy Initiative, multiple policies within the initiative are deployed as policy definitions. These policies automatically generate alerts for any newly deployed resources. This resolves the issue of having to repeatedly create alerts manually. Many of us know Azure Policy creation is not a simple task on a wider scale. AMBA simplifies this by providing you with a templated approach.

    If you’ve tried AMBA and don’t want to deploy it for some reason, then this blog also covers how you can use Azure Policy for creating individual alerts which are available as part of AMBA. That means you can pick and choose specific alert and deploy Policy only for specific use case which you want and not all the alerts which are part of AMBA.

## Multi resource alerts:
One of the easiest approach is to create single alerts which covers multple resource automatically. for example a resource targetting resource group or subscription will be targetted to any new VMs which gets created underneath it.

You can find how to do that from below link
[https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric-multiple-time-series-single-rule#multiple-resources-multi-resource](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric-multiple-time-series-single-rule#multiple-resources-multi-resource)

However not all types of resources are supported as part of multi resource one rule configuration.
you can find list of all supported resource in below link.

[https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-types#monitor-multiple-resources-with-one-alert-rule](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-types#monitor-multiple-resources-with-one-alert-rule)

## Azure Monitor Baseline Alert:
AMBA contains standard list of alerts which is recommended by Microsoft and are included in AMBA once you deploy it, alerts are created via Azure Policy which is configured in Deploy if not exist mode(DINE). There are initiatives and under initiatives multiple Policy definitions configured for alert deployment. 
So whenever there are new resources for which Policy is configured are deployed, alerts will get created automatically.

AMBA is categorized in connectivity, Identity, Management and Landing zone. Also it has couple of packs which are IaaS, PaaS and Platform Monitoring.

## Integration of AMBA in Azure Landing Zone accelerator:
The ALZ accelerator allows you to deploy an Azure Landing Zone in a simpler way. It contains standard services that are deployed and configured based on recommendations. I’ll leave ALZ accelerator for another blog, but AMBA is integrated in the Azure Landing zone. So if you’re planning to deploy landing zones, it is fully integrated and as soon as landing zone structures are deployed it’ll also configure all the policies based on the AMBA

[https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-accelerators](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-accelerators)

![Azure portal showing Azure landing zone accelerator and Monitor and Alerts included while deploying ALZ](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/alz-accelerator-portal-showing-amba-integration.jpg)

![AMBA configuration for specific services while using Azure Landing zone accelerator](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/alz-accelerator-portal-showing-specific-services.jpg)

## Deploy independently without Azure Landing Zone:
AMBA can be deployed independently as well in brownfield or greenfield scenarios. whether the landing zone has already been deployed or not. As this is based on Azure Policy, the initiatives are assigned on the management group. It is always recommended that you follow the subscription and management group design as mentioned in the Azure landing zone document however if you do not follow the hierarchy then you can create a dummy management group and AMBA policies will be assigned there. It is mentioned in detail in below document.

[https://azure.github.io/azure-monitor-baseline-alerts/welcome/](https://azure.github.io/azure-monitor-baseline-alerts/welcome/)

[https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/deploy/Deploy-via-Azure-Portal-UI/](https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/deploy/Deploy-via-Azure-Portal-UI/)

![Link to deploy AMBA through azure portal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/amba-deployment-through-azure-portal.jpg)

![Azure portal screen showing AMBA deployment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/amba-deployment-on-azure-portal.jpg)

## Use resource centric Azure Policy for Alerts:
This method is different from standard AMBA usage. AMBA is a collection of initiatives and policies.
Policies target specific resource types. On AMBA portal you can browse specific resources and all the metric alerts which are present and then you can deploy Alert for specific resource directly by clicking on Deploy button on AMBA portal or you can copy Azure Policy code and then create Azure Policy so that it can target all the resources in your tenant, and any new resource type created in the future, alert will be created with help of Azure Policy.

![Azure Monitor baseline alert portal showing resource view of all the resources covered under AMBA](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/resource-view-of-amba.jpg)

Browse through network category and we'll select Public IP address for which we'll create azure policy.

![Browsing through the network resource category](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/selecting-network-on-amba-portal.jpg)

This is just an example of showing how many alerts are present as part of AMBA for which Policy code can be re-used.

![Alerts configured for public IP Address](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/publicip-address-metrics.jpg)

Down below on each metrics you can see Deploy, ARM, Bicep and Policy button. This will be available for most of the metris on AMBA portal.

![AMBA portal showing Deploy button and Policy button](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/alert-deployment-types.jpg)

we'll make use of Azure Policy.

![Policy code to copy and create Azure Policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/policy-code.jpg)

Let's start by creating Azure Policy.

![Azure portal showing how to create Azure policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/azure-policy-creation-screen.jpg)

Creating policy definition.Paste the policy code which was copied from AMBA portal.

![Policy creation blade](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/azure-policy-creation-screen2.jpg)

Currently i saw one error, while performing copy paste i saw double bracket in the policy code which needs to be replaced with single brackets. Otherwise you'll see error while you create policy definition.

![Replace brackets with single blakcets in Azure policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/replace-bracket-with-single-bracket.jpg)

Once definition is successfully created you'll start by assigning the policy. without assignment, policy won't take affect.

![Assigning policy after successful creation of policy definition](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/portal-showing-policy-assignment.jpg)

Select revelant details, select subscription or management group where you want to apply the Policy.

![Azure portal showing assigning azure policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/portal-showing-policy-assignment2.jpg)

"Uncheck only show parameters that need inputs or review" and modify any metrics parameters. This will be input to your alert.

![Parameters for Azure policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/parameter-for-azure-policy.jpg)

Remediation task need to be created for any resources which were created before the policy, if unchecked then only new resources will be monitored as part of policy.

![Enable remediation task when assigning policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/create-remediation-task.jpg)

Review and create the assignment.

![review and creation of azure policy assignment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/create-azure-policy.jpg)

## Exclude resources from being monitored:
As mentioned in the policy definition any resources which has specific tags with the name 'MonitorDisable' and the value 'true’. The alert will be in disabled state. 

[https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/Disabling-Policies/](https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/Disabling-Policies/)

## Remediate Existing Resource:
When an azure policy is created, any new resource will be monitored but for monitoring existing resources which were already deployed you’ll need to create a remediation task.

Opening the assignment and reviewing the remediation task shows currently it is running.

![Remediation task created in azure policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/remediation-task-in-progress.jpg)

Once all the resources are remediated, that means alerts are created for those resources then it'll be mark as completed.

![Remediation task completed](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/remediation-task-completed.jpg)

Also in each resource group wherever the alerts are created you can find this in the activity logs. which shows the DINE policy in affect.

![Policy template deploying alerts shown in activity logs](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/activity-logs-showing-policy-dine-effect.jpg)

## Sample Alerts:

Below example shows some sample alerts

![Alerts created via azure policy](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/alerts-created-by-policy.jpg)

![Azure alerts overview](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/14102024/overview-of-alerts-created.jpg)

I hope this blog helps you create Azure Policy and implement Alerts at scale.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }