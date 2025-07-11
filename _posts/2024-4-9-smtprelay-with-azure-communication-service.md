---
title: "Send emails via SMTP relay with Azure Communication Service"
date: 2024-4-09 12:00:00 +500
categories: [tech-blog]
tags: [Azure Communication Service]
description: "Learn how to set up SMTP relay using Azure Communication Service for seamless email sending from Azure-hosted applications without modifying code"
---

We’ve come across multiple cases where customers want to send emails from Applications migrated to Azure through some kind of SMTP service. Though we’ve seen customers opting for O365 for SMTP relay, this can create issues due to throttling limitations in Office Service.
Also, managing mailbox and license assignment on Office 365 console is a different story; customers would want to have seamless SMTP relay service experience from single console on Azure.

Though Azure Communication service supports sending emails outbound but currently it requires you to integrate it via the ACS SDK that Microsoft provide. In scenarios where you don't want to modify code and just change the pointing of your SMTP server to Azure, you can now use ACS - SMTP relay built into Email communication service.

Azure Communication Service supports different types of notifications, SMTP relay in ACS got GA last month and this blog post is simple step by step instructions of how you can quickly test the service and then migrate from Sendgrid or another service you’re using to native ACS – Email communication service for better operational experience and support.

High level steps are as follows:\
[1. Create Azure Communication Service Account](#1-create-azure-communication-service-account)\
[2. Create Email communication service](#2-create-email-communication-service)\
[3. Add a custom domain to ECS](#3-add-a-custom-domain-to-ecs)\
[4. Attach custom domain to ACS Account](#4-attach-custom-domain-to-acs-account)\
[5. Create and Assign custom RBAC Role for Authentication](#5-create-and-assign-custom-rbac-role-for-authentication)\
[6. Test SMTP Relay via Powershell](#6-test-smtp-relay-via-powershell)

## 1. Create Azure Communication Service Account
First step you’ll need to do is to create an ACS account. This is a parent service which has multiple notification services inside it(Chat,SMS, Email etc). Email communications service is one of them.

![Create communication service account](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/create-communication-service-account.jpg)

## 2. Create Email communication service
We’ll have to create ECS which is the actual service that holds configuration details.

![Create email communication service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/create-email-communication-service.jpg)

## 3. Add a custom domain to ECS
ECS provides Azure managed domain which look like this “GUID.azurecomm.net” this provides limited volume of email hence using custom domain is preferred.
Once you add a custom domain, the UI provides you with TXT record which you’ll need to create in your Name server. This would take 15 minutes to verify the domain

![Add custom domain to email communication service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/add-custom-domain-email-communication-service.jpg)
![Verify custom domain](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/verify-custom-domain.jpg)

Once domain is verified the screen looks like this, you’ll have to create SPF and DKIM records so that your email doesn’t land in junk and ownership is maintained.

![Verify SPF and DKIM records for email communication](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/verify-spf-dkim-records.jpg)

Once all the records are created the screen would look like this, please ignore the azure managed domain. You can only have custom domain in the account and doesn’t have to add Azure Domain explicitly.

![Screen showing all records verified successfully](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/screen-all-records-verified.jpg)

## 4. Attach custom domain to ACS Account
Once email is validated we’ll need to attach ECS to ACS.

![Connect Email communication service to Azure communication service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/connect-ecs-acs.jpg)

## 5. Create and Assign custom RBAC Role for Authentication
We’ll be using 587 port to send email which is authenticated SMTP. For authentication we have Entra ID authentication.
Create a service principal by going to Entra ID – App registration page. Register the app and create a client secret. Note down Client ID, Tenant ID and Secret value. This will be used in next stage for authentication.
We’ll need to create a custom RBAC role which has permission to send email.
We’ll clone reader role.

![Assigning RBAC to service principal for authentication](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/assign-rbac-service-principal-authentication.jpg)

And we’ll be adding two actions which is present in Azure Communication service resource provider.

![Actions to be added in the RBAC](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/actions-added-rbac.jpg)

Once the Role is created we’ll need to assign this to service principal

![Assign the role to service principal](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/assign-role-service-principal.jpg)
![Selecting service principal in RBAC](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/selecting-service-principal-rbac.jpg)

## 6. Test SMTP Relay via Powershell
That’s all, now you’ll need to find out the sender email. Which is default DoNotReply@domain.com

![Find the sender email used by email communication service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/find-sender-email-ecs.jpg)
![Step2 of finding sender smtp address](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/find-sender-smtp-address.jpg)

> You can add custom sender usernames, click the link to see how to achieve this.
[Multiple sender address](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-multiple-senders?pivots=platform-azp#create-multiple-sender-usernames)
{: .prompt-tip }

You’ll need credentials to authenticate to the service. 

* Username is \< Azure Communication Services Resource name>. \< Entra Application ID>. \< Entra Tenant ID>
* Password is the client secret which you’ve generated.
* Port that we’ll need to use is 587
* SMTP server address is smtp.azurecomm.net

Now you can use any third party application to send email via the above parameters. To showcase we can use powershell with the same parameters to send emails.

![Powershell cmdlets for test email](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/powershell-cmdlets-test-email.jpg)
![Test email received from Azure communication service](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/09042024/test-email-received-azure-communication-service.jpg)

Conclusion: I trust this guide helps you in configuring SMTP relay and send emails from your custom or third party application without any change to the application/code.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }