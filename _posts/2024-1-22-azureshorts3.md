---
title: "How to Improve Azure VM Performance: Managing Disk IOPS"
date: 2024-1-22 12:00:00 +500
categories: [Azure Shorts]
tags: [Azure Disk]
description: "Discover how Azure VM and disk SKUs affect performance limits. Learn to monitor and optimize IOPS, throughput, and prevent workload slowdowns effectively"
---

I've come across multiple scenarios where VM workload was running slow and upon raising support case it highlighted that VM is blocking disk to reach higher IOPS and Throughput.
As you know every disk has different throughput/IOPS limits based on the SKU and tier you choose. Similarly every Azure VM has got capping limit which can be checked from Azure VM SKU documentation.

Even though you've got disk with higher IOPS and throughput but with smaller VM SKU which has lower limit can actually limit workload and disk to reach those high numbers which then impact your workload.
So you need to plan the workload accordingly by assessing your IOPS/Throughput need not only CPU/Memory.
This usually happens if you've spiky workload like DB server.

Now, in order to keep track whether your VM is throttling the disk IOPS and Throughput you can check few metrics which are available at VM level. We don't have to rely on MS Support for this.

Goto VM Blade and then click on Metrics 

## VM capping metrics 
* VM Cached IOPS consumed Percentage
* VM Cached Bandwidth consumed Percentage
* VM Uncached IOPS consumed Percentage
* VM Uncached Bandwidth Consumed Percentage

> Bandwidth here is throughput
{: .prompt-tip }

If the chart shows limits which is close to 100% that means you're likely hitting those limits and you'll need to upgrade the VM SKU so that you get higher IOPS/Throughput.

As previously mentioned a disk can also throttle your IOPS/Throughput based on the SKU you've choosen.
This is especially for premium SSD v1 type disk. As v2 IOPS can be scaled separately than the disk space.

## Disk capping metrics 
* Data Disk IOPS consumed Percentage
* Data Disk Bandwidth Consumed Percentage

Happy Learning!

>Subscribe to my biweekly newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
