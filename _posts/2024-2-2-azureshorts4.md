---
title: "Application Gateway Basic vs MultiSite listener"
date: 2024-2-1 12:00:00 +500
categories: [Azure Shorts]
tags: [Azure Application Gateway]
---

I've come across instances where customer had depoyed basic listener and then tried deploying multi-site listener and saw their website/APIs were not working. While most of us go ahead with multi-site configuration, I wanted to discuss about Basic vs Multi-site listener information quickly.

* Basic Listener: It accepts all requests from any domain on ports specified in the App GW Listener. In V2 SKU, the Basic listener will be processed after the multi-site listener, unless you've created a rule and specified a higher priority for that rule.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/02022024/picture1.jpg)

* Multi-Site Listener: The Multi-site listener only accepts what is specified in the listener hostname section. It basically checks the host header of the HTTP header to validate if this FQDN is matching with the request. As the name suggests, Multi-site can be multiple sites in the same listener, or it can even be a wildcard.
    * If you have multiple listeners with the same parent domain, then specify a wildcard listener with a lower rule priority so that it can be processed later than other listeners with the same parent domain.
    * Multi-site listener would be processed first, and then the basic listener.
    * If you do not have any specific use case to use a basic listener, then avoid creating any listener with the type basic.

priority

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/02022024/picture2.jpg)

> Use listener wisely, I've seen enterprise customers because of the 100 active listeners limits have deployed multiple gateways.
there can be 200 listeners in the App GW.
> but only 100 listeners would be assoiated with the rule and can be routing traffic at the same time.
{: .prompt-tip }

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
