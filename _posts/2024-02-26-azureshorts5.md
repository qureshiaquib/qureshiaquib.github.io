---
title: "Can Reserved Instances be applied to two running VMs?"
date: 2024-2-26 12:00:00 +500
categories: [Azure Shorts]
tags: [Reserved Instance]
description: "Learn how Azure Reserved Instance (RI) benefits apply to multiple VMs at the same time or serially. know whether RI is applicable to your VM scenario"
---

## Introduction:

Recently, a few of my customers reached out asking for an explanation of RI benefits. For example, if we have one reserved instance procured and are running two VMs simultaneously, each for half a day (12 hours), they assumed that since there are two VMs, each running for 12 hours, the total would be 12 + 12 hours = 24 hours. Consequently, they questioned whether the RI benefit would apply to both VMs since they've only bought one RI.

## Clarification:

The straightforward answer is: No! RI benefits would only be applicable to one VM, and the other VM's pricing is calculated as per the PayG rate. This is because when an RI is bought, every hour a trigger checks for applicable resources. If it finds them, the PayG rate is waived off, and the RI benefit is applied. Therefore, if both VMs are running simultaneously, the trigger will apply one VM under PayG and the other under RI benefits. Once both VMs are shut down after 12 hours, for the remaining 12 hours, the trigger won’t find any resources, resulting in the utilization of the RI being only 50%.

{: .prompt-info }
>The same principle applies to savings plans as well. However, the scope of savings plans is broader, covering any type of VMs or compute resources.


>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
