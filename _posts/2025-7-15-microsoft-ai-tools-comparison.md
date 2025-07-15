---
title: "Types of Microsoft Copilot and AI Solutions for IT Pros"
date: 2025-7-15 01:00:00 +500
categories: [tech-blog]
tags: [copilot]
description: "Explore and compare Microsoft’s AI tools like Copilot, Azure AI Foundry, GitHub Copilot, M365 Agent SDK to understand their purpose, scope, and use cases"
---

Recently, few of my customers wanted to understand which tools they can use to build AI Agents or tools provided by Microsoft which can help them accelerate their AI journey. Also as all the applications will have some flavour of AI to make things simpler for end users, i didn't want to cover all of the Microsoft tools like Copilot in Word, PowerPoint or Copilot for Azure etc because these are just wrappers. Hence i thought of covering major tools which are offerred by Microsoft in AI space. Also I'm not planning to deep dive on these topic in very depth, these are just high level information which you can use and then later learn these tool in depth.

![Video showing man putting sauce everywhere](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/companies-putting-ai-everywhere.mp4)

## Azure AI foundry
Formerly known as Azure AI Studio this is single place to find all the models which you want to deploy on Azure; it can be any model from hugging face or any open-source Model. Once model is added you can experiment with these models in the playground option. You can add Azure AI search if you’ve existing index. Or you can ground it using data present on SharePoint or the web.
Metrics dashboard helps you in finding the output of your model. It helps you with providing charts on data like Relevance, Groundedness and Fluency.

You can fine-tune the model by providing location of the files. All these are within AI Foundry control.
This has been well developed by the Microsoft Core AI team. You can find everything related to AI centrally in one single place.

![AI foundry showing all the AI models](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/AzureAIfoundry-console.jpg)


## Microsoft copilot
This is the most commonly used AI product, provided by Microsoft AI team as this is categorized as consumer use.
Copilot was initially started as Bing Chat when it was earlier in preview and now, we’ve a complete dedicated site: [https://copilot.microsoft.com](https://copilot.microsoft.com)

![Copilot Web page](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-web.jpg)

You can get Copilot results on the Bing page too.
![Copilot showing web and work section for internal and external search](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-for-work.jpg)

Similarly, Copilot is integrated into M365 you can have Web search or work related search from M365 portal now.
Along with that Researcher and analyst agents are available to do deep research. Providing AI based result is one use case, as we've integration of M365 you can publish agents which will be available for end users to use. Many organizations have developed their agents and hosted in M365 Agent Store.

![Agent store in M365 containing agents](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-for-work-agent-store.jpg)

## Windows AI Foundry
Not all models need cloud scale. Due to compliance, you might want to run models locally. Along with that If you want to optimize cost, you might prefer running models locally.
Power-efficient NPUs, which will continue to be released by OEMs and hence Windows AI foundry is introduced to help you in this space.

![chart showing Windows ML](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/windowsaifoundry.jpg)

Windows AI API and Windows AI Foundry are built on Windows ML. It is powered by ONNX runtime. 
To get started, you can download the AI Dev Gallery from windows store. Currently it is in preview.

![AI dev gallery showing models](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/ai-dev-gallery.jpg)

Windows AI API will help you implement AI in your Apps and utilize the inbuilt APIs provided by Windows ML. Multiple functionalities are exposed through the API. Models are also optimized to run locally.

You can get more info from below link\
[https://developer.microsoft.com/en-us/windows/ai/](https://developer.microsoft.com/en-us/windows/ai/)\
[https://learn.microsoft.com/en-us/windows/ai/apis/](https://learn.microsoft.com/en-us/windows/ai/apis/)\
[https://learn.microsoft.com/en-us/windows/ai/foundry-local/get-started](https://learn.microsoft.com/en-us/windows/ai/foundry-local/get-started)\
[https://learn.microsoft.com/en-us/windows/ai/new-windows-ml/overview](https://learn.microsoft.com/en-us/windows/ai/new-windows-ml/overview)

## GitHub Copilot
GitHub Copilot originally coined the term Copilot and it was the first AI which was released by Microsoft amongst the ones we are discussing in this blog. This is easy to guess, Github copilot provides code completion and suggestion related to code which you're typing in your IDE, it can be any IDE.

Below screen shows whenever you type, the code suggestion provided by copilot.

![UI showing github copilot code completion](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/github-copilot-code-completion.jpg)

There are two ways to access Github Copilot Chat, one from the website another from IDE itself.

![Github copilot chat](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/github-copilot-copilot-chat.jpg)

![Github copilot chat UI](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/github-copilot-copilot-chat2.jpg)


You can have GitHub Copilot for free. With this free version you will get 50 agent mode or chat requests per month and 2,000 code completions per month.

![Price of github copilot](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/github-copilot-copilot-price.jpg)

## Teams AI library v2 & Microsoft 365 Agent SDK

This section majorly covers SDKs and framework provided by Microsoft which helps developers to build AI centric agent/bot and publish in Teams,Copilot or integrate the same in your own web application.

There are many ways to publish agents in teams, if you’ve searched on Bing, you may have seen Microsoft Bot Framework, Teams AL Library v2 and M365 Agent SDK. Wanted to know which SDK to use? Please check the image below. Which I have copied from Microsoft documentation. [Click here](https://learn.microsoft.com/en-us/microsoftteams/platform/bots/build-a-bot)
Hence I am not covering all these SDKs or framework in separate section in this blog and putting everything into this section.

![types of bot deployment options](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/bot-deployment-types.jpg)

### Teams AI Library v2
It is a framework which is teams centric, it will help you build Bots or Agents which can integrate with OpenAI or Azure OpenAI service. Bot framework SDK is an alternative method, however teams AI Library v2 provides you with single SDK to integrate with Microsoft Graph, Bot and Adaptive cards. Instead of developers figuring out multiple SDKs to integrate and depend on, you can now rely on Teams AI Library v2. Also, this preview version integrates with MCP and A2A if you have agents that interact with users or other agents.

![Website showing teams AI library v2](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/teams-ai-library-v2.jpg)

More info here:\
[https://microsoft.github.io/teams-ai/welcome/](https://microsoft.github.io/teams-ai/welcome/)\
[https://github.com/microsoft/teams-ai](https://github.com/microsoft/teams-ai)\
[https://devblogs.microsoft.com/microsoft365dev/announcing-the-updated-teams-ai-library-and-mcp-support/](https://devblogs.microsoft.com/microsoft365dev/announcing-the-updated-teams-ai-library-and-mcp-support/)


### Microsoft 365 Agent SDK
This is an evolution of Azure Bot framework SDK. It was announced in Ignite last year and went to GA this build 2025. 
M365 Agent toolkit will give you full control over the chatbot customization. Whether your AI model is hosted in AI foundry or outside, whether your orchestrator is semantic kernel or lang chain. You can customize your agent and build your own multi agent through this SDK. Single SDK will be used to publish agent in teams, copilot studio, web chat.

More info can be found in below link.\
[https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/choose-agent-solution](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/choose-agent-solution)\
[https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp)

## Copilot Studio
If you ever worked on Power Virtual Agent, it was rebranded and merged into Copilot Studio. Now as you know major focus is on AI. However, this is not just an RPA, Copilot Studio is more than that. You can build agents and while building you can assign tasks in natural language. Want to know more about what an agent is, [click here](https://learn.microsoft.com/en-us/microsoft-copilot-studio/fundamentals-what-is-copilot-studio#what-is-an-agent)

Earlier we used to do [topics](https://learn.microsoft.com/en-us/microsoft-copilot-studio/fundamentals-what-is-copilot-studio#what-is-an-agent), now we do agents and use natural language to build an agent.

Copilot Studio caters to multiple user personas:

1. Copilot Studio is very well integrated in M365 Copilot to build Agents with natural language via Agent Builder so that a normal M365 user can also create an agent and transform his work.

2. Along with that Copilot Studio can be used to create autonomous agents through Low Code platform which is Copilot Studio console.

3. Copilot Studio can be used to create agents by a developer using pro code tools like Visual studio or GitHub.

Now, whenever you create an agent, you can connect the agent to visual studio code and modify the agent through developer tools.

![Visual studio code showing copilot studio extension](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-studio-copilot-extension1.jpg)

![visual studio code showing agent code of copilot studio](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-studio-copilot-agent-code.jpg)

Agents can connect with another agent which is built in Copilot Studio or Azure AI foundry and get information from connected agents. You do not have to worry about A2A or MCP. Microsoft copilot studio will take care of that and you just have to add agent in the copilot agents UI and you're done.

![Page showing AI model options in copilot studio](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-studio-agent-rag-capability-model.jpg)

You can modify the model, and tweak the settings so you get low code platform but with customization capabilities.

![connect copilot studio agent to another agent](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/15072025/copilot-studio-agent-connectivity.jpg)

## Security Copilot

Security Copilot is Microsoft Gen AI tool which will help you in analyzing and going through security incidents in much easier way. This isn't a tool which will help you generate agent or bots however this will help you tremendously in analyzing security issues in your organization. 

It contains multiple plug-ins which helps to connect to multiple data sources like Defender XDR, Sentinel, Azure Firewall, WAF, Intune and also non-Microsoft solution.
It doesn’t store all these data centrally, it just connect to multiple solutions through API calls.

There are two ways to access Copilot for Security.\
Embedded: This is embedded in all the solutions and your security team can click on incidents, endpoints, etc., to analyze or make a sense of the incidents that have occurred or to request more information. Which makes a session in the security of copilot and provide you a response. You don't have to open any other console.

Copilot for security home page: In this console you can interact with prompts and make use of prompt book to have multiple prompts collaborate with previous prompts to achieve an outcome.

More info here:\
[https://learn.microsoft.com/en-us/copilot/security/experiences-security-copilot](https://learn.microsoft.com/en-us/copilot/security/experiences-security-copilot)

I hope you found this blog helpful and it gives you a headstart to choose correct solution.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }