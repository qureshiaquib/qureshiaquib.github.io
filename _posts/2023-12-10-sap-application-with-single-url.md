---
title: "Use Traffic Manager and App Gateway to access multiple SAP Apps"
date: 2023-12-9 12:00:00 -500
categories: [tech-blog]
tags: [SAP on Azure]
description: "you can host multiple SAP application on different port but expose it centrally through Traffic manager and azure application gateway"
---

In this blog, I will demonstrate how to use Traffic Manager and Application Gateway to access multiple SAP applications with a single FQDN but with different ports. 
This is a common scenario for SAP customers who have multiple SAP servers behind a web dispatcher that acts as a proxy. 
By using Traffic Manager and Application Gateway, you can achieve high availability, load balancing, and URL routing for your SAP applications.
You can also simplify the end user experience by using the same FQDN for accessing different SAP applications on different ports.
In addition in the event of a disaster, or a DR Drill, users should seemlessly be redirected to the DR region without any manual intervention.

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
I am using dummy IIS server where I have hosted my website, but you can replace this with SAP Web Dispatcher in your setup and host the Web dispatcher behind application gateway.

The following diagram shows the overview of the architecture:

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture1.jpg)


So, let us start with the actual server which is hosting the website.
Below are the bindings in IIS. This is just a demo setup of the website. Actual SAP App would be different. The intention here is to highlight the website that is hosted on 4443 on a hostname which is s4.azurequreshi.com

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture2.jpg)

Similarly, the screenshot below shows another website. The same can be hosted on a separate webserver as well.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture3.jpg)

## Application Gateway Settings: 
### Let us check the frontend IP of the application gateway.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture4.jpg)

### Now let us look at the listener settings.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture5.jpg)

Simple multi site listener in application gateway for both the websites. The difference between both the listeners is the ports. 8443 and 4443.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture6.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture7.jpg)

### Now backend setting

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture8.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture9.jpg)

The only change is the hostname I am translating to s4.azurequreshi.com instead of webdisp.azurequreshi.com as my website in the back end hosted on s4.azurequreshi.com.

### Same setting can be seen for the 2nd http setting.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture10.jpg)

### Here is how the health probe looks like.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture11.jpg)

### Now the rule configuration. No tweak very simple basic rules.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture12.jpg)

### And the backend setting.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture13.jpg)

I have kept only the single IP as of now, but you can have two backend pools for two different websites. One pool for S4 and Another for EWM. Also, you can associate the backend pool with their respective rules in application gateway.

Till here if you have followed, you can open the website with application gateway URL, and it will redirect to their respective websites once you do hostname entry on your desktop.
Point hostname webdisp.azurequreshi.com to Application gateway IP for testing.

You will need to replicate the Application gateway setting and website configuration for south India.
Web server can be shutdown, or you can replicate it via Azure Site Recovery.

Once the above settings are done you may proceed with Traffic manager configuration.

## Traffic Manager
As this is an active passive DR hence, we will need to configure priority-based routing in traffic manager. 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture14.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture15.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture16.jpg)

### A look at the health probe of the traffic manager.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture17.jpg)


With this setting traffic manager will only send the traffic to DC – central India. Once the endpoint becomes degraded then the traffic manager will provide DR IP Address to clients.

Last step is to set the CNAME of your URL to traffic manager.
When you do nslookup you’ll find 

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture18.jpg)

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture19.jpg)

## Result
This is how the website would open, this is not specific screenshot of SAP S4 and EWM but this app gateway and traffic manager setting would be same.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture20.jpg)


![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/10122023/Picture21.jpg)

Thanks Nishant Roy for reviewing the work and sharing the requirement which was the inspiration for writing this blog post.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
