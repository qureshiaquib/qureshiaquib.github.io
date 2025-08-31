---
title: "How to Host Multiple Websites Using Azure Front Door"
date: 2025-8-31 01:00:00 +500
categories: [tech-blog]
tags: [Azure Front Door]
description: "Azure Front Door lets you host multiple websites with ease. Discover how you can deploy routes, rule set, rules to host multiple website behind AFD efficiently"
---

* **Scenario**: Recently I was working with one of the customers and they wanted to host multiple websites behind Azure Front Door, they were a little confused since the limits of Front Door vary. While the number of custom domains can be higher, the number of rules in a rule set is lower. Majorly they wanted to understand whether they can host multiple websites in AFD and secondly, they wanted to understand how front door is sized, whether, in the end, they would need multiple Front Door instances or if their requirements could be fulfilled with a single Front Door profile.

* **Solution**: We can host multiple websites behind a single AFD profile by using either Routes or Rule Sets. In this blog we’ll find both the approaches.

Let’s begin, Azure Front Door is a combination of multiple solutions, it consists of L7 Public Load balancer, it does geo traffic distribution, it’s a CDN and it provides WAF. I will not explain the functionalities of AFD in this blog, such as what Routes or Rule Sets are, we’ll find out how multiple websites can be hosted behind Azure Front Door.

Each customer’s requirement is different, if you have path-based routing or hosting APIs then your implementation would be different. I’ll pick one of the options I’ve seen and explain how you can make AFD work and host multiple websites.

## Option1
This option is the simplest,

![Option 1 visio diagram with afd profile and with multiple routes](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/option1-with-afd-route.jpg)_Download [architecture](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/31082025/afd-options-route-ruleset.vsdx) diagram_

* You only have to deploy one endpoint of AFD in the profile. You do have the option to host multiple endpoints in AFD; however, unless you are hitting a limitation, I recommend using a single endpoint.
* you add your custom domain in Azure Front Door, add individual host record and verify it.
* Add multiple Routes based on the number of website URL.
* Add multiple origins based on the backend web apps.

![Multiple route screenshot of azure front door](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/afd-route-screenshot.jpg)

![Route configuration of AFD](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/afd-route-snap.jpg)

![Route configuration of 2nd route](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/2nd-route-example.jpg)

![Custom domain screenshot of showing two domains added](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/custom-domain-two-domain.jpg)

![Origin 1 configuration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/origin1-details.jpg)

![Origin 2 configuration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/origin2-details.jpg)

![App1 website homepage](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/app1-website.jpg)

![App2 website homepage](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/app2-website.jpg)

## Option 2

![Visio diagram showing second option of afd with multiple rules](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/option2-with-rule-set.jpg)

* Similar to option 1, you deploy one single AFD endpoint.
* You can add a wildcard entry in custom domain or you can add individual host record.
* You need to add a single route in AFD.
* Add Multiple Origin based on the backend web app.
* You need to add a rule set, add two rules in the Rule Set that identify the request URL and then forward the request to their respective AFD origins. Based on the number of website you host, you'll need to add multiple rules.

![Route snap showing single route](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/route-snap.jpg)

![Route configuration of AFD showing rule](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/adding-rule-to-route.jpg)

![Custom domain config of wildcard domain](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/adding-wildcard-domain.jpg)

![Rule set with multiple rules](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/afd-rule-set-with-rule.jpg)

![Rules within Rule set configured with request URL](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/rule-with-request-url.jpg)

## Multi Tenant Hosting of Website

If you’re hosting a SaaS application which is multi tenant then you can refer below link which has multiple implementation type. Front Door service is used by Microsoft which hosts multiple tenants and services e.g. LinkedIn, XBOX, M365 and many more.

[https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/service/front-door](https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/service/front-door)

## How many website can I host

It’s not a straight forward answer because if you’re hosting a multi-tenant application, there are multiple options.

1. If you are relying on routes then a Single AFD profile(instance) supports max of 200 routes
2. If you’re relying on Rule Set then single profile supports 200 Routes and 100 Rules per rule set.
3. If you’re using single routes and forwarding requests to single origin group then AFD supports 500 custom domains per instance.

As you would have seen, there are many ways of implementation of your workload and hitting the limit varies depending on the implementation type you choose.

I’ve assumed Premium Instance type to give you max limit, if you’re using the Standard AFD tier, then your limits will be lower.
you can check below link for entire AFD limit

![Screenshot showing limits of Azure front door](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/frontdoor-limits.jpg)

[https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-front-door-standard-and-premium-service-limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-front-door-standard-and-premium-service-limits)

## Cost (Bonus Tip)
AFD pricing is based on four factors:
* Instance tier
* POP-to-Origin bandwidth
* POP-to-Client bandwidth
* The number of requests served by AFD.

Egress cost from the Azure region to the AFD POP is waived off. However if you’re using AFD to serve websites hosted on GCP or AWS, then egress costs from their side will apply.

Here is the sample pricing

![Screenshot showing azure pricing calculator snap of Azure front door](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/31082025/azure-pricing-calc-snap-afd.jpg)

[https://azure.com/e/a0ead11a9000456eb9627ff00b148868](https://azure.com/e/a0ead11a9000456eb9627ff00b148868)

I hope you find this blog helpful and it help you determine how to deploy Azure Front Door for your web application.
Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }