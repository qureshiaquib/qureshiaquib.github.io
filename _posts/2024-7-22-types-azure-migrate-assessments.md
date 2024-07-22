---
title: "Exploring Different Types of Azure Migrate Assessments"
date: 2024-7-21 12:00:00 +500
categories: [tech-blog]
tags: []
description: "Discover different types of Azure Migrate assessments. Learn how to utilize Azure Migrate for effective discovery, assessment and migration of various workloads"
---

I remember using Azure Site Recovery for the migration of VMs, and how Azure Migrate was later introduced as a central place offering all migration options for Azure customers. Initially, it included agentless migration and Network dependency mapping.

Over time, Azure Migrate has evolved into a full-scale tool for Azure assessment and migration, covering different types of scenarios. The Azure Migrate product team has worked extensively to centralize most of these scenarios. A new Kubernetes-based Azure Migrate appliance, recently introduced for Spring applications assessment, is an example of this effort.

Due to the numerous scenarios for discovery, assessment, and migration, I’m writing this post to show the options available today in the Azure Migrate appliance for performing assessments and migrations to Azure.

Image of it is shown below. Text based description is also copied so that you can make use of it.
![Table showing different types of assessment supported by Azure Migrate](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/22072024/types-of-assessment-supported-by-azure-migrate.jpg)

**Assessment Type**: Azure VM Discovery.\
**Description**: The Azure Migrate appliance, once configured in on-premises environments or other clouds (AWS, GCP), will discover VMs. After discovery is complete, an assessment can be created, providing output on the supportability and cost of running VMs on Azure.\
**Destination Service Name on Azure**: Azure VM\
**Does Azure Migrate support Migration to Destination Service?**: Yes\
**Link**: [Azure VM Discovery](https://learn.microsoft.com/en-us/azure/migrate/vmware/tutorial-discover-vmware?context=%2Fazure%2Fmigrate%2Fcontext%2Fvmware-context), [Hyper-V Discovery](https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-hyper-v), [Physical Discovery](https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-physical)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: Azure SQL Discovery\
**Description**: If the Azure Migrate appliance has access to a SQL server and the necessary credentials with SQL server permissions are entered, Azure Migrate also discovers SQL databases.
Based on this, an assessment can be created to show whether the databases can be migrated to Azure SQL DB or SQL Managed Instance.\
**Destination Service Name on Azure**: Azure SQL DB, SQL on Azure VM, Azure SQL MI\
**Does Azure Migrate support Migration to Destination Service?**: You’ll need to use the DMS service to migrate.\
**Link**: [Azure SQL Discovery](https://learn.microsoft.com/en-us/azure/migrate/tutorial-assess-sql)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: Azure App Service Assessments\
**Description**: Assess on-premises web applications for migration to Azure App Service. The same appliance that discovers your VMs can also discover your web apps running on them.
Azure Migrate helps you assess the following types of web apps:\
1) ASP.NET web apps running on IIS web servers\
2) Java web apps running on Tomcat servers\
**Destination Service Name on Azure**: Azure App Service, Azure App Service Container\
**Does Azure Migrate support Migration to Destination Service?**: Yes\
**Link**: [Web Apps Assessment](https://learn.microsoft.com/en-us/azure/migrate/tutorial-assess-webapps?pivots=java)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: Spring Boot applications\
**Description**: The Azure Migrate tool discovers the web apps hosted on VMs. Based on the discovery, you can create an assessment of web apps to determine if Spring Boot applications on-premises can be migrated to Azure Spring Apps.
This assessment can be carried out by the new Kubernetes-based Azure Migrate appliance. This newly introduced appliance will support more types of assessments in the future.\
**Destination Service Name on Azure**: Azure Spring Apps\
**Does Azure Migrate support Migration to Destination Service?**: No\
**Link**: [Spring Boot Applications](https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-spring-boot?tabs=K8-package%2Ccluster)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: Web Apps to Azure Kubernetes Service (AKS)\
**Description**: Web apps hosted on VMs, specifically ASP.NET and Java web apps, can be migrated to either Azure App Service or AKS. This assessment will help determine if web apps can be migrated to AKS.\
**Destination Service Name on Azure**: Azure Kubernetes Service (AKS)\
**Does Azure Migrate support Migration to Destination Service?**: Yes (using Azure Migrate: App Containerization tool)\
**Link**: [Web Apps to AKS](https://learn.microsoft.com/en-us/azure/migrate/tutorial-assess-aspnet-aks?pivots=asp-net)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: Azure VMware Solution (AVS)\
**Description**: Evaluate on-premises VMware VMs for migration to Azure VMware Solution (AVS). This assessment can be created once the Azure Migrate VMware appliance is installed on-premises for discovery.
The same appliance used for Azure VM-related assessments can be used to determine how many AVS nodes are required to host those VMs.
This can be an as-is based assessment or a performance-based assessment, providing the number of nodes and external storage (ANF/ESAN) required to meet storage needs.\
**Destination Service Name on Azure**: Azure VMware Service (AVS)\
**Does Azure Migrate support Migration to Destination Service?**: You'll need to use HCX to migrate servers to AVS.\
**Link**: [AVS Assessment](https://learn.microsoft.com/en-us/azure/migrate/vmware/tutorial-assess-vmware-azure-vmware-solution?context=%2Fazure%2Fmigrate%2Fcontext%2Fvmware-context)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: VMware Inventory (RVTools XLSX)\
**Description**: Discover servers running in your VMware environment using RVTools XLSX (preview). There is no need to set up the Azure Migrate appliance.
Export RVTools and import them into the Azure Migrate project to get the AVS sizing. This option is in preview and is mostly used in scenarios where customers don't want to install an appliance on-premises and want a quick rough sizing of their inventory.\
**Destination Service Name on Azure**: Azure VMware Service (AVS)\
**Does Azure Migrate support Migration to Destination Service?**: You'll need to use HCX to migrate servers to AVS.\
**Link**: [VMware assessment using RVTools import](https://learn.microsoft.com/en-us/azure/migrate/vmware/tutorial-import-vmware-using-rvtools-xlsx)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: SAP Systems (Preview)\
**Description**: Assess your on-premises SAP systems using the import option. This is an XLS import option where you have to provide your on-premises SAP details in a predefined template. This option is in preview.\
**Destination Service Name on Azure**: Azure VM (SAP Apps and HANA VMs)\
**Does Azure Migrate support Migration to Destination Service?**: Yes, you can migrate SAP Apps servers with Azure Migrate. For HANA, you need to use HSR to replicate the database to an Azure VM hosting HANA DB.
SAP ASCS and App servers will likely need to be recreated rather than migrated using Azure Migrate.\
**Link**: [SAP Systems Assessment](https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-sap-systems)

-----------------------------------------------------------------------------------------------------
**Assessment Type**: Azure Stack HCI (Preview)\
**Description**: There is no assessment for VMware/Hyper-V to Azure Stack HCI. However, you can use the Azure Migrate appliance to migrate to Azure Stack HCI. This option is in preview.\
**Destination Service Name on Azure**: Azure Stack HCI VMs\
**Does Azure Migrate support Migration to Destination Service?**: Yes\
**Link**: [Azure Stack HCI Migration](https://learn.microsoft.com/en-us/azure-stack/hci/migrate/migration-azure-migrate-hci-overview), [Preview Link for Azure portal - HCIMigratePPVMW](https://aka.ms/HCIMigratePPVMW)

I hope the above options will help when you perform assessments and use different services other than just opting for Azure VM.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }