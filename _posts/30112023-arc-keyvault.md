---
title: "Simplify certificate management of on-premises IIS server with Azure Arc and Azure Key Vault VM extension"
date: 2023-11-22
categories: [Tech]
tags: [azure keyvault vault, azure arc, hybrid, server, azure, on-premises ]
---

One common question which I’ve come across is certificate management for web servers. Usually when servers are hosted on Azure there are ways like storing certificates and secrets in Azure Key vault is a viable solution. I’ve come across customers who’re running servers in hybrid and few servers would still remain on-premises because of dependencies. For these web servers managing certificates is a costly affair. Common practice which I’ve seen is admin sharing the certificate with application team on some file share. This creates few problems
