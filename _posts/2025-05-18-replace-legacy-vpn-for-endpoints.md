---
title: "Replace legacy VPN within an hour for your endpoints"
date: 2025-5-18 12:00:00 +500
categories: [tech-blog]
tags: [Entra Private Access]
description: "Replace legacy VPN, including SSL and P2S, and connect to Azure Private Endpoints with Entra Private Access for secure, modern, and scalable connectivity"
---
I was away for a few weeks due to health reasons, but now that I'm back, I wanted to dive into a topic focused on Entra ID.

* **Scenario**:
One of my customers reached out to me and explained they wanted to have alternative approach to their SSL VPN which they use. They wanted modern way to access resources present in private network, more of the ZTNA based approach and more simple to scale.

* **Solution**:
One option is to use the SSL VPN or Point-to-Site connectivity provided by vWAN or VPN Gateway. However, we'll focus on Entra Private Access, the latest offering from Microsoft, included as part of the Microsoft Security Service Edge (SSE) solution.

We’ll focus only on Entra Private Access, which lets you connect to private resources on Azure or on-premises from your endpoints while they are on a public network. We’ll cover Entra Internet Access later.

## Pre-Requisite
There are certain pre-requisites that need to be followed.

* License: Microsoft Entra ID P1
* License: Microsoft Entra Suite or Standalone Entra Private Access
* RBAC: Global Secure Access Administrator and Application Administrator
* Connector Server: A windows server which has internet outbound connectivity. This server connects to Entra    Private Access services and proxies the connections to resources that are connected via private endpoints. All connections pass through this server.
* A Windows 10 client to test connectivity to the server or some Azure private endpoint services. This client must be Entra ID joined or Hybrid joined.

## License
Assign relevant license to the user:

![Assigning Entra ID P1 license to user](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/license-assignment.jpg)

Enable Private Access Profile under traffic forwarding.

![Enable private access](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/enable-private-access.jpg)

## Private Access Connector Installation

Download the private access connector [click here](https://download.msappproxy.net/subscription/d3c8b69d-6bf7-42be-a529-3fe9c2e70c90/connector/download)

![Download private access connector](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/download-private-access-connector.jpg)

Install it on the windows server. There can be many connector appliances based on the application you're publishing via Entra private access.

![Installing Private Access Connector](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/private-access-connector-installation.jpg)

Once installation is completed you can validate the connector by checking on the Entra portal.

![Validate private access connector status](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/validate-private-access-connector.jpg)

## Enterprise Application creation

For all the applications you want users to access, you'll need to either create applications or add their IPs to Quick Access. Quick access app is kind of default setting for all the users who connect via private access. However it is always better for better management and segregation you create applications. Here, the application we're referring to is an Enterprise Application, which you may be familiar if you're managing Entra ID.

![Enterprise application creation](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/enterprise-application.jpg)

![Add application IP segment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/add-application-ip-segment.jpg)

Specify the IP address of the server or application and the required port numbers. For example, if users need to take RDP or access a web application hosted on the server, you should include ports like 3389 and 443.

![Validate the application and network segment](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/validate-application-segment.jpg)

## Installation of GSA Client

[https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Clients.ReactView](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Clients.ReactView)
Download the client from the above link and install it on the endpoint. You can also use Intune to push the agent for automated deployment.
For this test, we'll proceed with manual installation.

![Install GSA client](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/install-gsa-client.jpg)

We’ll have to assign this application to the user so that the Private Access rules for this application are associated with this user.

![Associate user to application](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/associate-user-application.jpg)

![Validate the application setting ](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/validate-application-segment-step2.jpg)

## Testing
All the configuration is done, now whenever there is a traffic which matches the IP address or FQDN of the application and if user is associated to that application, then automatically those connection will be proxied via the GSA client to the connector. And from the connector to the actual application.

Rest of the connection which doesn't matches the application network segment would take normal internet path from your desktop/endpoint.

## Diagnosis

Now let’s goto the setting of client and see the traffic.

![Advance diagnostics of GSA client](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/diagnostic-gsa-client.jpg)

![Traffic validation](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/traffic-validation-gsa.jpg)

You can also check whether the traffic is being sent via the GSA client through Policy tester.

![Policy tester in GSA Client](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/policy-tester-gsa-client.jpg)

![Validate traffic getting tunneled](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/validate-traffic-getting-tunneled.jpg)

I’ve done similar testing to connect to Azure SQL Database from the client/endpoint securely.

Create an application for Azure SQL DB server

![Create new application for Azure SQL Database](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/create-application-private-access.jpg)

Specify the FQDN and port

![Specify network setting for Azure SQL DB to connect via private access](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/sql-db-port-for-private-access.jpg)

Make sure you’ve disabled public connectivity of database

![Ensure public access on Azure SQL DB is disabled](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/public-access-disable-azure-sql-db.jpg)

To validate whether traffic is truly passing through the GSA client, you can enable the traffic collector.

![Check connectivity of SSMS through diagnostics setting of GSA client](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/18052025/check-connectivity-ssms-and-diagnostic.jpg)

I hope you found this blog useful and that it helps you in setting up Entra Private Access.

Happy learning

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }