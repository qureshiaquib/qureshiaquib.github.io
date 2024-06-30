---
title: "How to Change Your onmicrosoft.com Domain in Entra ID"
date: 2024-6-30 12:00:00 +500
categories: [tech-blog]
tags: [Entra ID]
---

* **Scenario**: There can be many reasons why you would want to change your Entra ID domain name. A few are mentioned below:
    * At the time of subscription creation, you mapped it with Entra ID which was used for trial purposes.
    * You created a Entra ID tenant before your company name was not finalized. I have seen this occur because of a company de-merger scenario and because of migration timeline tenant and subscription creation sometime happens before name is finalized.
    * Most common: Your IT head signed up for Azure subscription and created an Entra ID test tenant without knowing this tenant will be seen everywhere when user signs in or on the Azure Portal. IT Head named it with his own name for example georgeazuredeployment.onmicrosoft.com / aquibazure.onmicrosoft.com 

Now you have decided you don’t want to stick with the old name.

* **Solution**: You can add another onmicrosoft.com domain to your existing Entra ID tenant and make that as a failback domain. The default onmicrosoft.com domain is known as the fallback domain because you can use that for other Office365 services too, like mail and teams.

You cannot remove onmicrosoft.com domain which you’ve previously added. Also any onmicrosoft domain which you add cannot be removed. You can add up to a maximum of 5 domains in your tenant.

This blog is only focused towards Azure subscription related info of Entra ID. Hence if you’ve Office365 services associated with your Entra ID along with Azure subscription then the impact of the change of domain needs to be assessed separately. I’m not covering that as part of this blog.

Assuming you only have Azure subscription attached to Entra ID. Please proceed ahead with the steps.

When you logon to Azure Portal and click on the gear icon you will see all the tenant you have access to. In this blog I’m focusing on aqquresh.onmicrosoft.com and will change this to demodoctor.onmicrosoft.com.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture1.jpg)

Adding another onmicrosoft.com domain can be done through Office 365 Admin portal.
Logon to portal.office.com -> Admin -> Setting -> Domain
you’ll see all the registered domain here.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture2.jpg)

Click on the default domain and you’ll see add onmicrosoft.com domain preview highlighted.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture3.jpg)

Before proceeding ahead with the steps, I wanted to show you the existing configuration, how it looks like. The below screenshot is of Entra ID.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture4.jpg)

You can edit properties to see the UPN and change it: Here you can see the existing domains which were associated. Please ignore doctorblognew.onmicrosoft.com as it was used previously for testing.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture5.jpg)

Now go back to your default domain and click on the add new onmicrosoft domain preview link. Below screen will be opened. And it’ll allow you to add a new domain here.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture6.jpg)

Once you’ve successfully added the domain it’ll look like the below screen.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture7.jpg)
![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture8.jpg)


Now go to the new domain which you have added and you’ll get an option to make this as failback domain. Which means default domain for all the user IDs.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture9.jpg)

Once you click and finish it’ll look like the below.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture10.jpg)

Also when you go back to any user account in the UPN drop down menu you’ll see the new domain which you’ve added. Here I see demodoctor.onmicrosoft.com

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture11.jpg)

This is how the user UI looks like once you make all the changes.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture12.jpg)

Also goto Entra ID in Azure Portal and select the default domain to your own domain which you’ve added. If you’ve some custom domain you can ignore this step.

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture13.jpg)


When you go back to setting menu in Azure portal you’ll see the new domain name:
Your users won’t realize georgeazuredeployment.onmicrosoft.com / aquibazure.onmicrosoft.com

![a](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/30062024/picture14.jpg)

This doesn't change your tenant ID so Management group hierarchy will remain the same.

Similar steps can be accomplished by adding another custom domain in your Entra ID, which doesn't end with .onmicrosoft and you own that public domain. 
But if you don’t want to do that because of other challenges then these steps will help you make relevant changes without depending on any custom domain.

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }