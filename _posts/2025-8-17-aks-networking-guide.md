---
title: "AKS Networking options you must know before deployment"
date: 2025-8-17 01:00:00 +500
categories: [tech-blog]
tags: [AKS]
description: "Learn how many networking options are available for AKS Cluster Node POD and application via ingress controller, this blogs talks all networking options for AKS"
---

I thought of writing a blogpost for tech professionals who want to quickly learn about networking options available for AKS. I'm not covering deployment or any of the services, just a high-level approach and options available to architects when they're starting AKS.

When you're learning AKS networking, it's easier when you segment it as control plane, node, pod and then application level. It'll help you in understanding multiple sections and categorize them.

![AKS networking approach](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/networking-approach.jpg)

## Control Plane
This is where your AKS management plane lives, where your core services live. API server, controller manager and scheduler which orchestrate your cluster. When you're using AKS this section is Microsoft managed and hosted in Microsoft hosted VNET. AKS Nodes and administrators require access to API server and hence you'll need to understand how you'll connect to it. There are multiple options.

1. Public Cluster\
API server is accessible via Public IP address. You can restrict with known source IP of your client from where you're connecting to.
As API server is hosted in Microsoft managed VNET hence it uses konnectivity tunnel to connect to your node and pod which resides in customer VNET.

    ![AKS public cluster](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/aks-public-cluster.jpg){: w="200" h="500" }

2. Private Cluster\
This uses private link and API server is accessible via internal private IP with help of private endpoint. So there will be a private endpoint deployed along with private AKS cluster. That private endpoint will be part of customer owned VNET. You can deploy Jumpbox in the VNET and then connect to the private endpoint.
It also uses konnectivity tunnel to connect API server with node and pod access.

    ![AKS private cluster](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/aks-private-cluster.jpg){: w="200" h="500" }

3. API Server VNET integration\
API server is provisioned into a delegated subnet with help of a load balancer, your nodes will connect to API server by connecting to load balancer which is exposed via private IP address. This option provides client connecting to API server publicly or privately. It uses konnectivity tunnel for pod access when using overlay.

    ![AKS VNET integration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/aks-vnet-integration.jpg){: w="200" h="500" }

There are two options for private connectivity to AKS cluster, first one is private cluster and second one VNET integration, if you want to understand difference between both the options you can refer below link. This gives you indepth study on how this gets deployed and also how it differs from one another.
[https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/public-and-private-aks-clusters-demystified/3716838](https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/public-and-private-aks-clusters-demystified/3716838)

[https://www.youtube.com/watch?v=8e8vBLZiIhQ&list=PLpbcUe4chE79sB7Jg7B4z3HytqUUEwcNE&index=61&t=772s](https://www.youtube.com/watch?v=8e8vBLZiIhQ&list=PLpbcUe4chE79sB7Jg7B4z3HytqUUEwcNE&index=61&t=772s)

## Node Networking
It is connectivity of your nodes, which are basically Azure VM, to connect each other, from Nodes to the API server and to the internet. If you know Azure Networking then this section of Node networking is easy to understand.

### VNET selection
We've option of manage VNET where AKS will manage the VNET and host the nodes, and second option of BYO scenario where AKS Nodes are hosted in customer's VNET.

### Cluster Outbound Traffic
1. Load balancer: This is the default setup, all your node pools will reach out to standard LB and then egress with public IP. There are challenges of SNAT ports exhaustion if you’re egressing with high traffic as there are SNAT ports assigned per node.
Multiple load balancer is also an option which is in preview.

    [https://learn.microsoft.com/en-us/azure/aks/use-multiple-standard-load-balancer](https://learn.microsoft.com/en-us/azure/aks/use-multiple-standard-load-balancer)

    ![AKS outbound from azure load balancer](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/cluster-outbound-ALB.jpg){: w="200" h="500" }

2. NAT gateway: NAT gateway will be deployed and associate with subnet where nodes are deployed. This works in managed VNET as well as BYO VNET, this method helps when you're facing SNAT port exhaustion.

    ![AKS egress from Azure NAT gateway](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/aks-egress-nat-gateway.jpg){: w="200" h="500" }

3. UDR: Typically, I’ve seen this in enterprises who want to control their outbound traffic through firewall. you can choose AzFW, vWAN, or 3P NGFW.

    ![Using firewall to handle outbound traffic from AKS](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/17082025/aks-cluster-udr.jpg){: w="200" h="500" }

## POD networking
This means how your POD IP address are managed.
In CNI there are two things which we need to care about, control Plane and Data plane. Control plane is basically IP address assignment and data plane is how the data moves from pods to pods or from pods to external.

Control Plane:\
Types of Azure CNI:
1. Flat Networking Model: where IP address are assigned directly from VNETs. You can connect to POD external to VNET. Node and POD both gets the IP from the VNET.
2. Overlay Networking Model: This is basically Node gets the IP from the VNET however PODs gets the IP from logically separate IP address space. PODs will be kept private however there are benefits in terms of scaling.

Data Plane:
1. Cilium Dataplane: This is also known as Azure CNI powered by Cilium, this is eBPF based dataplane and it replaces the Kubernetes IP based dataplane. Advanced Microsoft features are primarily in this space. We encourage customers to use this.
1. Azure (non-cilium) Dataplane: The Standard IP based dataplane.

### Azure CNI Overlay:

*	POD IPs come from an overlay range not part of the VNET space.
*	Highly scalable: we can have 5000 nodes and 250k PODs.
*	PODs can’t be accessed directly from outside the cluster.
*	Reuse IP address across all your cluster.

### Flat Networking Model:

1. Azure CNI POD Subnet (Dynamic)
    -	POD IPs come from same vnet as Nodes, there will be separate subnet for POD and Nodes.
    -	Supports upto 65,536 IP addresses which includes PODs + Nodes.
    -	Pods are directly accessible from outside the cluster.
    -	On-demand IP assignments, as node scale then a subset of IPs are assigned first smaller range of IP and as node scale IPs are assigned and released.

2. Azure CNI POD Subnet (Static)
    -	POD IPs come from same vnet as Nodes, there will be separate subnet for POD and Nodes.
    -	Pods are directly accessible from outside the cluster.
    -	Supports upto 1,048,544 IP addresses which includes PODs + Nodes.
    -	Static method works in a way where once the node is spun up it’ll get all the IP at once based on the max pod size assigned. So IPs won’t be assigned and released as compared to previous method.

    More info here\
    [https://learn.microsoft.com/en-us/azure/aks/concepts-network-azure-cni-pod-subnet](https://learn.microsoft.com/en-us/azure/aks/concepts-network-azure-cni-pod-subnet)

3. Azure CNI Node Subnet
    -	POD IPs comes from the same subnet where nodes resides.
    -	Pods are accessible to external network
    -	Inefficient use of VNET IP address.

There are other option of Kubenet which is going to retire and also BYO CNI which I haven't covered in this blog as mostly you'll be using above mentioned options.\
More info here:\
[https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview#use-case-comparison](https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview#use-case-comparison)

## Application Networking

1. Load Balancer Service:
    -	Utilize Kubernetes Load Balancer service to directly expose an application on a public IP or Private IP.
    -	It supports TCP and UDP traffic.
    -	Requires one unique IP: port pair per application.

2. Ingress Controllers – layer 7 load balancing.
    -	Exposes an application behind a Layer 7 reverse proxy
    -	Usable only for layer 7 traffic.
    -	Can share single public IP and port for all the FQDNs
    -	Managed Ingress Options:
        *	Istio Gateway
        *	Managed ingress-nginx through the application routing add-on
        *	Azure Application gateway for containers

### Istio Gateway
If you have been using a service mesh for managing traffic between microservices and also hosting ingress gateway for L7 functionality you can explore the Istio Gateway add-on for AKS.

*	It is Envoy based service.
*	This provides traffic management features such as rate limit circuit breaking.
*	Security: Secure ingress with mTLS.
*	Observability: It provides logs, metrics, and traces for gateway pods.

More info here:\
[https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress)

### NGINX Ingress controller – App routing add-on
*	In Cluster based
*	Basic load balancing and routing
*	Support ingress API
*	App-routing addon support
*	Managed DNS
*	Cert integration with Azure KeyVault

More info here:\
[https://learn.microsoft.com/en-us/azure/aks/concepts-network-ingress](https://learn.microsoft.com/en-us/azure/aks/concepts-network-ingress)

### Application Gateway for Containers(preview)
*	Azure-Hosted, External to the cluster.
*	It supports Gateway API.
*	WAF option is included.
*	Advanced routing features.

More info here:\
[https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview](https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview)

I would like to express my sincere thanks to [Chase Wilson](https://www.linkedin.com/in/chase-wilson/) for his collaboration.
I hope you find this blog helpful. Share the blogpost if you like it.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }