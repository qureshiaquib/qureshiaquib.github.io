---
title: "How to Simplify UDR Management & Increase Route Limits"
date: 2025-3-20 12:00:00 +500
categories: [tech-blog]
tags: [AVNM]
description: "Learn how to manage UDRs in Azure Virtual Network Manager (AVNM), simplify route assignments, and increase route limits beyond the default 400 routes"
---

* **Scenario**:
One of my customers explained that they wanted to increase the route limit in UDR from 400 to 900. They reached out to the support team, but their request was denied. Additionally, I frequently hear from customers that applying UDR to multiple subnets across different subscriptions and managing routes is a difficult and error-prone task.

* **Solution**:
Recently, UDR management in Azure Virtual Network Manager (AVNM) entered preview. This will address both challenges: assigning UDRs to subnets and simplifying route management. It will also support up to 1,000 routes in the UDR, which is higher than the current limit of 400.
Although AVNM offers many benefits beyond UDR management, you can use this feature independently without managing your hub-and-spoke VNET through AVNM.

In this blog, I’ll show you how to create an AVNM instance, set up a network group, and apply route collections.
Before configuring route management, I want to show that there is no UDR assigned to the subnet, and it appears blank.

![Image showing subnet with udr](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/no-udr-on-subnet.jpg)

## Create AVNM Instance
Let’s get started. Search for AVNM and create the instance first.

![Creating AVNM instance](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/avnm-instance-creation.jpg)

Select the scope as a subscription or management group, then complete the creation step by clicking 'Review and Create'.

![selecting scope of avnm instance](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/scope-of-avnm.jpg)

## Network Group creation
Once you open the AVNM instance, click on Network groups and then create a new Network group. A network group helps you combine VNETs and subnets into a single group where specific types of routes can be applied.

![create network group in avnm](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/create-network-groups.jpg)

![Network group overview](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/network-group-overview.jpg)

Once Network group is created, you can click on Add

![Adding new VNET in the network group](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/click-add-for-vnet.jpg)

Select the subnet from the list that you want to include in the network group.
You can also automate the addition of networks to the network group via Azure Policy. This is adding VNETs dynamically.
more info about azure policy can be found [here](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-azure-policy-integration)

![Selecting VNET to add](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/select-vnet-to-add.jpg)

![VNET added to group](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/vnet-added-to-group.jpg)

Now, let’s configure routing by adding route details.

## Route configuration
![create route configuration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/create-routing-configuration.jpg)

![Routing configuration creation step 1](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/routing-configuration-step1.jpg)

We need to add rule collections here; you can add multiple.

![create rule collection](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/rule-collection.jpg)

Here, we have also selected the network group to which these rule collections will be applied.

![Add route rule](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/add-route-rule.jpg)

![Route rule](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/showing-route-rule.jpg)

![showing rule collection](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/rule-collection-step2.jpg)

## Deploy Configuration
We’ll deploy the configuration to ensure that the routing settings are applied to the network group.

![Deploy configuration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/deploy-configuration.jpg)

![Deploy route configuration step2](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/deploy-configuration-step2.jpg)

![Final deployment of routing configuration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/deployment-routing-configuration.jpg)

![Deployment status of routing configuration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/deployment-status-routing-configuration.jpg)

## Validation status
You can check whether the deployment succeeded or failed by going to the deployment blade

![Validation of deployment status](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/validate-deployment-status.jpg)

Now, let’s validate whether a UDR is assigned to the subnet. Yes, you will find a UDR with a GUID value assigned.

![Validate UDR assigned to subnet](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/validate-udr-assigned-to-subnet.jpg)

Additionally, when you search for the route table, you will find the same UDR in a managed resource group

![UDR assigned to subnet](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/udr-assigned.jpg)

When you click on the UDR, you will see the routes that were created in the routing configuration.

![validate routes in UDR](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/20032025/validate-udr-routes.jpg)

This blogpost is simple and no complex architecture is shown, however I hope blog helps you in implementing UDR management via AVNM and simplify your operational task. Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }