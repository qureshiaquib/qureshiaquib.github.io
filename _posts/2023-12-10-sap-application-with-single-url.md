---
title: "Using Traffic Manager and Application Gateway to Access SAP Applications with Single FQDN and Different Ports"
date: 2023-12-10 12:00:00 -500
categories: [tech]
tags: [SAP on Azure,azure Application Gateway,Azure Traffic Manager]
---

In this blog, I will demonstrate how to use Traffic Manager and Application Gateway to access multiple SAP applications with a single FQDN but with different ports. 
This is a common scenario for SAP customers who have multiple SAP servers behind a web dispatcher that acts as a proxy. 
By using Traffic Manager and Application Gateway, you can achieve high availability, load balancing, and URL routing for your SAP applications.
You can also simplify the end user experience by using the same FQDN for accessing different SAP applications on different ports.

To illustrate this scenario, I will use Azure VM running Windows Server 2019 and IIS as the backend servers (assume this is web dispatcher).
One VM will host the S4 application on port 8443 and the same VM will host the EWM application on port 4443.
Both website will be reachable on the same hostname webdisp.azurequreshi.com, which is registered in DNS.
I will also use two Application Gateways, one for each region.
Finally, I will use a Traffic Manager profile to distribute the traffic across the two Application Gateways based on the priority routing method.
So, requests will only hit DC. Request to DR Application gateway will only be sent once the DC application gateway health probe is down.

So, in this scenario end user will not open the app with individual URL like s4.azurequreshi.com:8443
or ewm.azurequreshi.com:4443. they will use webdisp.azurequreshi.com:8443 and the S4 App would open.
similarly they will use webdisp.azurequreshi.com:4443 and the EWM app will be opened.

In this article I’ll share the setup of traffic manager and application gateway which will help you achieve the above scenario.
I am using dummy IIS where I am hosting website, but you can replace this with SAP Web Dispatcher in your setup and host the Web dispatcher behind application gateway.

The following diagram shows the overview of the architecture:

