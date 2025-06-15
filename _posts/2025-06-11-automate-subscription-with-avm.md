---
title: "Automate subscription creation with AVM subscription vending"
date: 2025-06-11 12:00:00 +500
categories: [tech-blog]
tags: [AVM]
description: "Learn how to automate Azure subscription creation using AVM’s Subcription Vending module with Bicep and Azure DevOps. Deploy application LZ subscription"
---
* **Scenario**: One of my customers came with a problem. The Enterprise Account owner was contacted every time a new subscription needed to be created. Additionally, he couldn’t delegate permissions for someone to create subscriptions on his behalf.
* **Challenge**: This customer had deployed landing zone using the legacy ALZ approach and hadn’t used the subscription vending module to automate subscription creation. As the LZ Subscription vending is moved to Azure Verified Module, this can be used for existing deployments or at time of fresh landing zone creation using ALZ accelerator which now uses AVM.

## AVM
Before we dive into the subscription vending module. Let’s discuss Azure Verified Module a little bit to set the context: the subscription vending module was initially an independent module, which was later integrated into AVM. AVM provides multiple such modules from Microsoft for IaC based deployments. There are many advantage of using AVM, this is Microsoft supported, and assistance is available through Microsoft support, as it is a Microsoft owned approach. We also have ALZ accelerator which uses AVM and deploy entire landing zone along with that it deploys supporting repositories and pipelines.

![AVM portal showing pattern or resources where AVM modules can be found](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/avm-pattern-portal.jpg)

* AVM: [https://azure.github.io/Azure-Verified-Modules/](https://azure.github.io/Azure-Verified-Modules/)

* ALZ accelerator: [https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/deploy-landing-zones-with-terraform#azure-landing-zone-accelerator](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/deploy-landing-zones-with-terraform#azure-landing-zone-accelerator)

## Assign permissions to Service Principal
* Subscription creator Role:

  To create subscription unattended, you’ll need to assign the Subscription Creator role to a service principal. This isn’t available through Azure Portal. You’ll need to call REST API.
  The entire process is documented below, starting from creating the service principal, retrieving the required secret, tenant, and client ID details, and finally making the REST API call. 
  
  [https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/assign-roles-azure-service-principals](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/assign-roles-azure-service-principals)

  If you prefer a simpler approach, you may use the PowerShell script developed by Sebastian. I appreciate his contribution, it saved time on writing one from scratch.
  Sebastian’s Repo: [https://github.com/SebastianClaesson/SubscriptionVendingExample/tree/main](https://github.com/SebastianClaesson/SubscriptionVendingExample/tree/main)

  Download the script by [clicking here](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/New-EnterpriseAgreementRoleAssignment.ps1)

* Validate action permission:

  Additionally, on the management group, please assign a custom role with action “Microsoft.Resources/deployments/validate/action” to the same service principal as we’ll be using Powershell to deploy the template at the management group level.

## Bicep Module for LZ Subscription Vending
AVM provides both Bicep and Terraform modules. You can build your pipeline using either approach, both of which are Microsoft supported. However, in this blog post, we’ll focus only on the Bicep approach.

![AVM portal showing lz subvending module](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/lz-sub-vending-avm-module.jpg)

The SubVending Module of AVM supports deploying Azure subscriptions and additional resources that form part of the Application Landing Zone. For example, you can configure RBAC or deploy VNETs that should be peered by default to a specific Hub VNET.
All the types of resources supported by AVM is present in the github repository mentioned below.

There are a couple of examples provided in the repository. Attaching a screenshot of the same.

![Github repo of subvending showing examples](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/github-repo-showing-sub-vending-examples.jpg)

We’ll keep it simple and deploy only the subscription as part of the module.
We need to provide the subscription name, alias, billing scope, management group ID, and tags as parameters.

```shell
targetScope = 'managementGroup'
module subVendingModule 'br/public:avm/ptn/lz/sub-vending:0.3.3' = {
  scope: managementGroup()
  params: {
    subscriptionAliasEnabled: true
    subscriptionAliasName: 'azuredoctorsubscription5'
    subscriptionBillingScope: '/providers/Microsoft.Billing/billingAccounts/xyz/enrollmentAccounts/xyz'
    subscriptionDisplayName: 'azuredoctorsubscription5'
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: 'EASubs'
    subscriptionWorkload: 'Production'
    resourceProviders: {}
    subscriptionTags: {
      environment: 'prd'
      applicationName: 'App Landing Zone'
      owner: 'Platform Team'
    }
  }
}
output newSubId string = subVendingModule.outputs.subscriptionId
```
Here you can find the Bicep LZ Subscription vending module.
[https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/lz/sub-vending](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/lz/sub-vending)

Here you can find the terraform lz Subscription vending module.
[https://github.com/Azure/terraform-azurerm-lz-vending](https://github.com/Azure/terraform-azurerm-lz-vending)

## Deploy through Powershell

You can use the following cmdlet to deploy it manually. Or you can jump to next step where we’ll deploy subscription through Azure DevOps.

```shell
New-AzManagementGroupDeployment -Name "azuredocSubVending2" -Location "francecentral" -ManagementGroupId "EASubs" -TemplateFile "main2.bicep"
```
![Powershell cmdlet showing bicep file of subvending](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/powershell-output.jpg)


## Automate through DevOps
First, create the project, then create the service connection, and start with the repository.
I’ve copied the code into the repository.

![Devops repository showing bicep registry of subvending](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/devops-repository.jpg)

We’ve created a pipeline which runs the same powershell cmdlet.

![DevOps pipeline showing bicep subvending module of AVM](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/azure-pipeline-avm.jpg)

```shell

parameters:
- name: bicepFile
  type: string

trigger: none  # manual trigger

stages:
- stage: DeploySubscription
  jobs:
  - job: Deploy
    pool:
      vmImage: 'windows-latest'  # Use Windows agent for PowerShell
    steps:
    - checkout: self

    - task: AzurePowerShell@5
      inputs:
        azureSubscription: 'azuredoctor-sub-vending'
        ScriptType: 'InlineScript'
        Inline: |
          $bicepFile = "${{ parameters.bicepFile }}"
          Write-Output "Deploying Bicep file: $bicepFile"

          # Optional: Validate if Bicep CLI is available
          bicep --version

          $templateFile = "$(System.DefaultWorkingDirectory)/bicep/$bicepFile"

          New-AzManagementGroupDeployment `
            -Name "vendingDeployment-$bicepFile" `
            -Location "eastus" `
            -ManagementGroupId "EASubs" `
            -TemplateFile $templateFile
        azurePowerShellVersion: 'LatestVersion'
        pwsh: true

```

![Photo showing kickstarting pipeline and passing repo as param](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/run-pipeline-manually.jpg)

Below screenshot shows the output of the pipeline.

![Photo showing azure powershell task from devops pipeline](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/azure-powershell-task.jpg)

![Another Photo showing azure powershell task from devops pipeline](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/azure-powershell-task2.jpg)

![Photo showing Azure EA account where all the subscriptions are present](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/11062025/azure-portal-subscription-created.jpg)

I haven’t included a pipeline with approval gates in this post, but you can configure them based on your organizational requirements.

I hope you find this helpful in automating subscription creation.

Special thanks to my friend [Darshit Shah](https://www.linkedin.com/in/darushah/) for helping me in EA lab.

Happy learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }