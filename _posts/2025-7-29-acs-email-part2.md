---
title: "Part2: Email with Azure Communication Service Tips & Insights"
date: 2025-7-29 01:00:00 +500
categories: [tech-blog]
tags: [ACS]
description: "Discover essential setup tips and troubleshooting insights for ACS Email communication service to optimize your production email workflow with best practices"
---

My Part 1 blog on ACS Email [here](https://www.azuredoctor.com/posts/smtprelay-with-azure-communication-service/) and on MS TechCommunity has gained a lot of attention recently, one of the causes is throttling enforced by the Exchange Online service. I’ve got you covered with step-by-step implementation guidance in [part 1](https://www.azuredoctor.com/posts/smtprelay-with-azure-communication-service/) of the blog. Since the first blog, I’ve received a lot of questions on certain topics, which led me to create part 2 of the blog. These are some common considerations you’ll need once you start using Azure Communication Service SMTP Email for production use cases.

## Authentication
### Key Authentication
ACS Email service supports multiple types of authentication, with the main categories being Key-based and Microsoft Entra ID-based authentication. The key can be found under the ACS Service, and you can use it when you authenticate via the SDK.

![Table showing authentication methods of ACS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29072025/key-acs-auth.jpg)

The method below uses Entra ID authentication, which adds an additional security layer and is preferred.

### Entra ID Auth
#### Managed Identity
Just like other Azure services you can make use of Managed identity to Authenticate to ACS. Think of it in this way, if you have App service where you have written your code or functions app, you have created managed identities for these services, and then associated and granted RBAC permissions to those identities over the ACS service. This way you don’t have to use any key or basic auth feature to authenticate ACS. Entra ID takes care of the authentication and authorization.

#### Service Principal
This is one of the widely used authentication mechanisms, as described in part1 you first create service principal in Entra ID and then assign RBAC permissions for ACS and associate them. Many who are new to Azure have asked how to create service principal.
You can follow below link.

[https://devtoolhub.com/creating-a-service-principal-in-azure-portal-step-by-step-guide/](https://devtoolhub.com/creating-a-service-principal-in-azure-portal-step-by-step-guide/)

Once service principal is created, you use the ClientID and secret to authenticate to Entra ID. This is Basic Auth and is still supported. You can use managed identity-based authentication for OAuth authentication.

## Shorter username
Currently, if you want to authenticate via Entra ID authentication, the username is lengthy. 
Username is : < Azure Communication Services Resource name>. < Entra Application ID>. < Entra Tenant ID>
I’ve received multiple cases where administrators requested shorter usernames because the legacy printer sending these emails supports only 25 characters or has a certain character limit.
You can now create an SMTP username which is shorter and associate it with the service principal (Entra App), the service principal will authenticate on behalf of the SMTP username. 

![Screen showing how to configure SMTP username in ACS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29072025/shorten-username-acs.jpg)

you can find step by step instruction here

[https://learn.microsoft.com/en-gb/azure/communication-services/quickstarts/email/send-email-smtp/smtp-authentication?tabs=built-in-role](https://learn.microsoft.com/en-gb/azure/communication-services/quickstarts/email/send-email-smtp/smtp-authentication?tabs=built-in-role)

## Add multiple sender address
I have seen common questions around adding custom domain and having multiple sender addresses in ACS. This can be easily accomplished, I’ve found that sometimes, adding more senders from the UI is greyed out, but you can add more sender email addresses through PowerShell or CLI as well. Please use below cmdlet to achieve it. 

```shell
PS C:\> New-AzEmailServiceSenderUsername -ResourceGroupName ContosoResourceProvider1 -EmailServiceName ContosoEmailServiceResource1 -DomainName contoso.com -SenderUsername test -Username test -SubscriptionId SubscriptionID
```

for step by step instructions follow below document.

[https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-multiple-senders?pivots=platform-azp](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-multiple-senders?pivots=platform-azp)

## Logs of email
Just like diagnostic logs for other Azure services, ACS provides diagnostic logs which can be configured to send to a Storage Account or Log Analytics workspace, helping you determine which emails were not delivered and bounced back.

![Screencapture of diagnostics log configuration for ACS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29072025/diagnostics-logs-acs.jpg)

You can use below KQL query 

```shell
ACSEmailStatusUpdateOperational
| where DeliveryStatus in ("Bounced", "Suppressed", "Delivered")
```

## ACS Insights
The ACS team has provided an inbuilt Email dashboard that gives excellent insights on total emails delivered, success rate, etc. Configure azure monitor via diagnostics and then this dashboard will be populated with the details.

[https://learn.microsoft.com/en-us/azure/communication-services/concepts/analytics/insights/email-insights](https://learn.microsoft.com/en-us/azure/communication-services/concepts/analytics/insights/email-insights)

![ACS Insights dashboard which is built-in](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29072025/acs-email-dashboard.jpg)

## Failure rate
This is one of the most important factor when you use ACS, as sending multiple emails and if recipient mark that email as spam or if it doesn’t get delivered then the sender reputation and IP of ACS will be throttled and put into spam. As ACS is used by multiple customers hence this failure rate for each customer is monitored and maintained by PG and CSS team. If you reach 1% or 2% failure rate then you’ll need to work with PG and provide how you’re planning to reduce it. Failure to reduce the failure rate can cause PG to throttle your ACS instance or even stop you from sending emails.
This is the main reason why we covered diagnostics in this blog, you’ll need to make sure you configure diagnostic logs and monitor the failure rate.

## IP Whitelist
I’ve received multiple cases where customers have mentioned they wanted to whitelist specific IP to connect to ACS. So only specific apps from customer environment can connect to ACS. As ACS is a PaaS service, public connectivity is the default option. Currently there is no in-built firewall like Azure SQL or other PaaS service has so we can’t whitelist IPs at service level. 
However, there is a workaround to this as network connectivity happens at two layers. The first connection happens at the authentication layer, managed by Entra ID. Afterwards, when the token is provided to the app by Entra ID, the app connects to ACS for the email sending process. You can block the 1st connection by using Conditional access policy in Entra ID.
Private Endpoint for ACS is also on the roadmap, so once this feature is available, we’ll have the capability to block connections directly via Firewall.

## Higher Email Count
Many customers have reached out after seeing the ACS service limit documentation and getting confused that it only allows a few hundred emails per hour. However, the same document mentions that you should reach out if you need to send higher email counts – ACS can easily send 2 million or more emails per hour. You can start sending emails, and if you are planning to send bulk emails in Millions then reach out to support so that they can allocate higher quota.
Please keep in mind that you should start with a lower number and gradually increase the email count. There are two benefits

1. If your domain was earlier associated with an old IP from a different service like M365 or a third-party, the receiving server will start associating the ACS IP and won’t throttle your requests. If you suddenly start sending millions of emails, the chances of your domain getting throttled by the recipient service are much higher.
2. You’ll be able to manage the failure rate of emails much more easily, as you monitor the emails and then keep reducing it. 

I'm thinking of providing you a **Bonus Tip**, mentioned below.

## Pricing calculator
I also wanted to provide pricing guidance along with these tips. ACS Email is charged based on the number and size of emails you send via the service.

![Pricing calculator snap which shows pricing of ACS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/29072025/acs-email-pricing.jpg)

You can refer to the link below to see a sample ACS sizing I’ve prepared in the Azure pricing calculator.

[https://azure.com/e/d8ca97dc3bd54f2c87acd7746e8f9622](https://azure.com/e/d8ca97dc3bd54f2c87acd7746e8f9622)

Some helpful link here:

[https://learn.microsoft.com/en-us/azure/communication-services/concepts/service-limits#email](https://learn.microsoft.com/en-us/azure/communication-services/concepts/service-limits#email)

[https://learn.microsoft.com/en-us/azure/communication-services/concepts/email/sender-reputation-managed-suppression-list#error-codes-for-soft-bounces](https://learn.microsoft.com/en-us/azure/communication-services/concepts/email/sender-reputation-managed-suppression-list#error-codes-for-soft-bounces)


I hope you found this blog helpful and along with Part 1 of the blog you implement the ACS Service seamlessly.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }