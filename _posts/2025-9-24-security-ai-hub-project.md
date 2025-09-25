---
title: "How to Secure Azure AI Foundry Hub Project Connectivity"
date: 2025-9-24 01:00:00 +500
categories: [tech-blog]
tags: [Azure AI Foundry]
description: "Learn how to secure connectivity in Azure AI Foundry Hub Projects with private endpoints, hub-spoke networks, and additional PaaS service network controls"
---

* **Scenario**:
I found that a lot of customers have started deploying AI models in Azure AI foundry and they’re deploying them with endpoints set to public. When it comes to Private Endpoint deployment in AI foundry, the configurations can be tricky as there are multiple Private endpoints that will get created. If you’re using a hub-based approach, then this blog is for you.
We’ll explain how the Private Endpoints (PE) of the AI Foundry service are created in the managed VNET.
How you’ll need to create that in customer VNET, along with that PE for additional services need to be created in customer VNET and so on.

AI Foundry project-based deployment is different from hub-based deployment.
Please note, Microsoft recommends choosing an AI Foundry project instead of a hub-based project, however there are some features which are only available in Hub based project.
If you want to learn the difference between the two options, you can check the article below.

[https://learn.microsoft.com/en-us/azure/ai-foundry/what-is-azure-ai-foundry#which-type-of-project-do-i-need](https://learn.microsoft.com/en-us/azure/ai-foundry/what-is-azure-ai-foundry#which-type-of-project-do-i-need)

Let’s proceed assuming you’ve done your assessment and selected AI Foundry Hub based project.

## Services Placement

![Image showing blocks level diagram of AI foundry hub and additional services placement](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/service-placement-in-ai-foundry.jpg)

Before we discuss all the private endpoints, let’s first look at where the services will be placed.
1. This is the on-premises workload which will access the AI Model present in AI Foundry or connect to Applications hosted on Azure which will then talk to models hosted in AI Foundry.
2. Customer HUB VNET is where all the connectivity related components will be deployed like Express Route/ VPN gateway, private endpoint, firewall etc.
3. This is the spoke subscription where your PaaS services will be hosted, these PaaS services are often dependent services like AI search service, blob storage which are required for your application along with AI Foundry. Private endpoints of these services will be deployed in Hub VNET so that on-premises can talk to these services. In an enterprise environment, these private endpoints will be hosted in the VNETs of the spoke subscription in a separate subnet, not in the hub. We’ve simplified and shown the PEs in the Hub VNET. 
4. This is where all the additional services which get deployed along with AI Hub project, will be hosted.
5. This is where your AI Foundry managed VNET will be hosted. Serverless, prompt flow and managed endpoints will be hosted.

## Additional services part of AI Foundry

As mentioned in the 4th point above, when you deploy a hub-based project, additional PaaS services will also be deployed.

AI services will be created
![AI foundry hub deployment and showing first additional service which is added](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/additional-services.jpg)

Container registry, blob storage and key vault is created.
![AI foundry hub deployment and showing couple of more additional service part of the deployment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/additional-services-storage.jpg)

This screenshot shows all the services which get deployed as part of AI hub based project.
![Screenshot showing additional services which are deployed as part of AI hub deployment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/additional-services-deployed.jpg)

## Connectivity Method for AI Foundry

We’ll be deploying the AI Hub service in private mode which is “Allow only approved outbound” and public connectivity will be disabled. This will ensure that you can only access the AI Foundry portal through a connected network and not publicly. Along with that any outbound connectivity needs to be explicitly allowed in the outbound rules. In the backend an Azure firewall will be deployed which will enable this functionality of allow and deny.

Making sure your public connectivity is disabled for the workspace.
![Public connectivity to AI foundry hub is disabled](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/public-disabled-ai-foundry.jpg)

private endpoint is deployed in customer vnet and also a PE is created in managed VNET. The one with _sys is for managed VNET.
![private endpoint deployed for ai foundry hub](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/private-endpoint-ai-foundry.jpg)

Validating the network setting of "Allow only approved outbound" is selected for workspace.
![Workspace setting of AI foundry hub based project seleted as allow only approved outbound](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/allow-only-approved-outbound.jpg)

## Private Endpoint Scenarios

![Azure architecture diagram showing private endpoint of AI foundry hub and customer PaaS service in customer own VNET](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/ai-hub-pe-customer-vnet.jpg)

### **PE for AI foundry and additional PaaS services in customer VNET**
This architecture shows two scenarios of private endpoints, first scenario is PE of search service, storage account or PaaS services which are deployed in customer’s environment that is required by the application. PE will get deployed in the HUB VNET in a subnet. This is typical scenario which you must be using PaaS service and it's private endpoint.

The second scenario is of PE that is created for the AI Hub itself and for additional PaaS services deployed as part of the AI Foundry Hub project. These are AI Search, keyvault, container registry. AI Hub private endpoint is required without which you cannot connect to AI Foundry portal.

### **PE for additional services and customer PaaS services in managed VNET**

![Azure architecture diagram showing private endpoints of AI foundry hub and additional paas services in the managed vnet](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/pe-ai-foundry-managed-vnet.jpg)

This section is of PE which gets deployed in the managed VNET and it gets deployed as part of AI Hub project. A managed hub is where all your PE will get created along with Agent, serverless or compute instances.

Whenever your compute instance in the AI Foundry wants to connect to additional PaaS services securely it’ll connect to private endpoint present in the managed VNET and hence for container registry, AI services, blob and key vault individual PE are deployed in the managed VNET itself. This is created automatically as soon as managed VNET is provisioned.

This image shows the _Sys private endpoint which are created automatially.
![Image of private endpoint which gets created automatically and in inactive state](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/pe-managed-vnet.jpg)

you’ll see this as inactive, the reason is while deploying the AI Hub, managed VNET is not deployed, it’ll only get triggered once compute instance is deployed or if you have instructed during the deployment to provision the managed VNET. This is to save the cost of Private endpoints and also the firewall resource. These PE are automatically created and you don’t have to manually create it.

Second scenario is of PE for customer deployed PaaS services, these PE are also created in managed VNET, for compute or serverless instances which need to communicate with PaaS services privately, a PE is required. Creation is not automatic and need to be created manually. Depending upon the services which you've deployed in your spoke subscription and based on the project you'll need to create private endpoint of those in managed VNET. Below are the steps to create it.

Adding a new connection from AI foundry portal.
![Adding connection in AI foundry hub](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/create-new-connection.jpg)

Searching for desired service for which you need to make connection, here we're searching for ai search
![Adding Azure AI search from the selection](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/connection-ai-search.jpg)

Enter the name of the service which you want to add.
![Searching and adding the specific search service instance](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/ai-search-service-addition.jpg)

I have observed, for couple of service private endpoint is created automatically if managed vnet is provisioned already. However in my scenario it is not provisioned hence creating a PE manually.
![Adding the search service pe in managed vnet](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/new-pe-search-services.jpg)

Validate private endpoint is created successfully.
![Private endpoint is visible in the search service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/new-pe-search-services-approve.jpg)

AI foundry hub showing outbound rules, PE is created.
![Created outbound rule for ai foundry hub project](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/created-pe-managed-vnet.jpg)

## Outbound connectivity from AI Hub to on-premises resources

As AI Hub compute resources are in managed VNET, you cannot directly peer that with HUB vnet to reach on-premises. There is no such option. One way is to create application gateway in Hub VNET and put on-premises resource IP address in the backend pool of the application gateway, and create private endpoint of this application gateway in the managed VNET. This way compute instance in AI Hub project can connect to on-premises resources.

![Application gateway private endpoint for ai foundry hub to connect to on-premises](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/ai-hub-to-on-premise.jpg)

please check below article to know more
[https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/access-on-premises-resources](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/access-on-premises-resources)

## Securing Additional PaaS services
The services which are deployed as part of the AI Hub accepts public connections, if you have selected the option of “Approved Only outbound” that is only for AI Hub resource and not for all the additional services which are deployed as part of AI Foundry. Hence you need to ensure each individual service is not publicly exposed. Along with that you need to make sure to check the option to allow trusted Microsoft services.

Making sure public connectivity to container registry is disabled.
![Disabling public connectivity to container registry](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/container-registry-disable-public.jpg)

Making sure public connectivity to AKV is disabled.
![Disabling public connectivity to azure key vault](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/key-vault-disable-public.jpg)

Making sure public connectiivty to blob storage is disabled.
![Disabling public connectivity to blob storage](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/blob-storage-disable-public.jpg)

## Inactive PE
During initial deployment if you’ve not selected to provision the managed VNET, hence you’ll see that the PEs are inactive because the VNET and firewall aren't deployed. Best approach is to select the checbox during the deployment itself.

This is where you can select "provision managed vnet" during AI foundry hub project.
![Selecting the provisioned managed vnet checkbox for managed vnet deployment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/24092025/provisioned-managed-vnet.jpg)

You can deploy it manually after the AI Hub is provisioned through CLI.

[https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/configure-managed-network?tabs=azure-cli#manually-provision-a-managed-vnet](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/configure-managed-network?tabs=azure-cli#manually-provision-a-managed-vnet)

I hope you deploy your AI Foundry Hub Project securely.
Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }