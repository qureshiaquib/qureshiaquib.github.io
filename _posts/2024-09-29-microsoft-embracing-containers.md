---
title: "How Microsoft Embraces Containers for Cloud Services"
date: 2024-09-29 12:00:00 +500
categories: [tech-blog]
tags: [containers]
description: "Learn how Microsoft uses Kubernetes and containers to power scalable, resilient cloud services across Azure and on-premises environments"
---
This blog is a little different from the previous one. In this blog, we explore how Microsoft is using Kubernetes and utilizing the benefits of K8s for hosting cloud-native applications both on Azure and on-premises. This is a different blog because we’re not going through a use case scenario or solving a technical problem based on Azure services. This provides an example of how open-source technology is being used as a platform to host and serve applications to customers. Although you’ll find many such examples from other organizations, we’ll explore how Microsoft is using this in different services.

> All the services mentioned in this blog are taken from public references, and I'm not sharing internal workings of Azure or any of Microsoft’s services.
{: .prompt-tip }

## Azure Arc Resource Bridge:

Resource bridge is a K8s management cluster installed in customer’s environment – on-premises.
This is part of Azure Arc service. Resource bridge is used as part of 

* Azure Stack HCI – Resource Bridge will help deploy VMs, Images or AVD from Azure Portal and instruct Azure Stack HCI instance to instantiate these services on-premises.
* Arc enabled VMware vSphere – RB will help start and stop VMs, add, remove, or update NICs of VMs hosted on VMware, etc., so many other tasks can be performed once you onboard vSphere to Arc services.
* Arc enabled SCVMM – RB will help perform similar start/stop operations on VMs hosted on Hyper-V and perform many other tasks.

These above services combined are part of Arc enabled Infrastructure.
Basically, the Resource Bridge is hosted on the K8s platform and supports multiple Arc services provided by Microsoft.

## Arc Enabled Kubernetes on Azure Stack HCI and Other clouds: 

Azure Stack HCI is a virtualization platform. It is based on Hyper-V, and unlike traditional Hyper-V on Windows Server, Azure Stack HCI can also host cloud services on-premises, which can be spun up from Azure. Since 23H2 version of Azure Stack HCI Arc Resource bridge is by default enabled during provisioning of ASHCI (Azure Stack HCI). Once RB is enabled, Azure Kubernetes service (AKS) can be deployed just like any other resource on-premises. This AKS enabled by Arc, can be managed from Azure Portal. 
The link below provides more information about AKS enabled by Arc.

[https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-overview](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-overview)


![Picture of Azure Stack HCI components](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29092024/azure-stack-hci-solution.png)

Once AKS is deployed on Azure Stack HCI, there are lots of cloud services which can be deployed on-premises as this AKS is arc enabled and as part of Arc services these can be deployed on-premises. Also if you’ve Kubernetes deployed on-premises or any cloud and once you connect cluster to Azure Arc then similar services mentioned below can be deployed on any cloud.

So Kubernetes becomes underline service where cloud services are deployed as PODs/containers.

[https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/overview](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/overview)

* Arc Enabled Data services:
Azure SQL Managed Instance and Azure PostgreSQL can be deployed on-premises.

[https://learn.microsoft.com/en-us/azure/azure-arc/data/overview](https://learn.microsoft.com/en-us/azure/azure-arc/data/overview)

* Azure Machine learning, App Service, Function and Logic App:
These are part of Application services and can be deployed on-premises.

[https://learn.microsoft.com/en-us/azure/app-service/overview-arc-integration](https://learn.microsoft.com/en-us/azure/app-service/overview-arc-integration)

As you can see from above examples, Arc enabled Kubernetes is being used on-premises in Stack HCI and can be enabled on any existing Kubernetes cluster deployment on-premises on bare metal or any cloud provider to provide cloud services like SQL DB, Function Apps, Logic Apps etc.
 
## AKS Edge Essentials:
It is an on-premises kubernetes implementation. This is another way of implementation where cloud services and also windows/linux containers can be deployed on Edge locations (Factory, Plants, Shopping stores and Gas stations) on AKS.
Kubernetes here is used to deploy services on-premises in a small factor like Robots, PLCs etc.
More information in below link.

[https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-edge-overview](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-edge-overview)

## Azure IoT Edge:
Azure IoT Edge brings the cloud analytics to the edge. Azure IoT Edge is a feature of Azure IoT Hub.
There are multiple components that make up IoT Edge, but mainly it consists of the IoT Edge Runtime and IoT Edge Modules. IoT Edge modules are implemented as containers. There are multiple hosts OS where this runs and can be found in below document.

[https://learn.microsoft.com/en-us/azure/iot-edge/support?view=iotedge-1.5#tier-1](https://learn.microsoft.com/en-us/azure/iot-edge/support?view=iotedge-1.5#tier-1)

Conclusion here is Microsoft is utilizing containers and open source tech for deploying services at Edge location via Azure IoT Edge which then push data to IoT Hub on Azure for further processing and reporting.

## Azure SQL Edge:
Azure SQL Edge is used in IoT and IoT Edge deployments, it runs SQL Server engine which is same for Azure SQL Database and SQL Server. Azure SQL Edge can be deployed as a single container or on a Kubernetes cluster on IoT Edge deployment.
SQL Edge is being retired, and SQL Server Express Edition is its successor. It can also be deployed as containers.

[https://learn.microsoft.com/en-us/azure/azure-sql-edge/overview](https://learn.microsoft.com/en-us/azure/azure-sql-edge/overview)

Basically, Microsoft is utilizing containers and Kubernetes to host database services on-premises, in form of Azure SQL Edge or SQL Express Edition on containers.
The SQL Engine is optimized to run on Kubernetes.

## Azure Migrate new K8s based appliance:
A new appliance type is introduced by Azure Migrate product team which is deployed as a container on a Kubernetes based appliance. Till now there used to be VMware appliance, Hyper-V and Physical Azure Migrate appliance but these were not containers. This new appliance is used for discovering spring boot apps running in on-premises.

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-spring-boot?tabs=K8-package%2Ccluster](https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-spring-boot?tabs=K8-package%2Ccluster)

## SQL Server on Containers:
I don’t need to provide any introduction about SQL Server, however since SQL Server 2017 you can run SQL Server on a Linux as a container. SUSE, RedHat and Ubuntu are supported Operating system. You can run this on Kubernetes.

[https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver16&pivots=cs1-bash](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver16&pivots=cs1-bash)

Microsoft SQL Product team has embraced containers long ago and optimized SQL Server DB engine to run on Linux and containers. Basically, they’re utilizing K8s to run its core DB Engine, and it is supported for production deployment.

## Azure PostgreSQL Database:
As mentioned in the link below, the DB engine of Azure PostgreSQL is running on Linux containers.
This service hosts thousands of customers, and the high availability and resiliency of containers are being utilized to serve customer PostgreSQL databases on Azure Cloud.

[https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview)

As you can see from above examples Cloud services requires scaling and resilience which can easily be provided by Kubernetes. Microsoft Engineering team is utilizing containers and serving their customers instead of just hosting it on a VM directly.

There are many Microsoft services that use containers in the backend. Do you know of any others? Please comment and share your knowledge!
I hope this blog helps you view these services from a new perspective. Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }