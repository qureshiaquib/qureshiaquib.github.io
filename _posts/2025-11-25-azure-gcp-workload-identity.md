---
title: "Authenticate Azure Workloads to GCP Using Federation"
date: 2025-11-25 01:00:00 +500
categories: [tech-blog]
tags: [Workload Identity Federation]
description: "Learn how Azure workloads can authenticate to GCP services using Workload Identity Federation. A practical guide for cross-cloud identity and secure access."
---

* **Scenario**: One of my customers was planning to host services on Azure. They have some applications which are present on GCP and some are planned to be hosted on Azure. One of the questions they had was how they could authenticate resources present on GCP from services which are deployed on Azure. They wanted to use GCP permissions along with STS.
For example, applications hosted on Azure and connecting to GCP storage bucket. How could they authenticate using GCP RBAC permissions? And similarly they have couple of different GCP services which they wanted to connect to.

* **Solution**: Workload identity federation service of google can be utilized here as the workload is hosted on Azure and service which is being accessed is present on GCP. 
Similarly, Azure also provides Workload Identity Federation which can be used when workload is hosted on GCP but services which are being accessed by GCP resources are present on Azure side.
In my scenario, the customer was also using Google IAM as their primary identity source, as all their mailboxes and identities were on Google hence utilizing the workload identity federation of google was chosen.

![Azure architecture diagram showing Azure resources accessing GCP services](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/architecture-azure-resource-accessing-gcp-services.jpg)_Download [the architecture](https://github.com/qureshiaquib/qureshiaquib.github.io/raw/main/assets/25112025/architecture-azure-resource-accessing-gcp-services.vsdx) diagram_


## Create Application in Entra ID
You’ll first need to create an application in Entra ID. We won’t go through this step-by-step; you can find the details using the link below,

[https://devtoolhub.com/creating-a-service-principal-in-azure-portal-step-by-step-guide/](https://devtoolhub.com/creating-a-service-principal-in-azure-portal-step-by-step-guide/)

![Screenshot capturing Entra app registration](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/application-entra-id.jpg)

However you’ll need to make sure you set the URI of the application, you’ll need to use this on the GCP side.

![Adding URI to Entra application step1](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/uri-in-app-registration.jpg)

![Adding URI to Entra application step2](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/adding-uri-to-application.jpg)

Assigning Managed identity to Azure resource

![Assigning a system assigned managed identity to Azure VM](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/assigning-managed-identity-to-vm.jpg)

You won’t assign any special permissions to this managed identity, this identity is created so that the VM receives the identity to request access token from the Entra ID.
## Configure Workload Identity Federation

You’ll need to ensure the required APIs are enabled on the Google project.
IAM, Resource Manager, Service Account Credentials, and Security Token Service APIs

![Registering all the required APIs on the google project](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/registering-apis.jpg)

### Create Workload Identity Pool and Provider

Create the workload identity pool

![Create workload identity pool step1](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/workload-identity-pool.jpg)

Select OpenID Connect as the provider

![Adding provider to workload identity pool](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/adding-provider-in-workload-identity-pool.jpg)

For the issuer, you’ll need to add https://sts.windows.net/yourtenantid

Replace your tenant id with your Entra tenant ID.

In the allowed audience you need to enter the URI, which you've entered in the step1
and in the attribute mapping you need to enter assertion.sub which is passed from the token. If you need to set a different value then I'll share the link at the bottom of the blog to learn more.

![Entering audience and attribute mapping in the workload identity pool](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/adding-audience-subject.jpg)

Create the workload Identity Pool

![Workload identity pool creation last step](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/configure-workload-identity-pool.jpg)

![Screen showing workload identity pool created successfully](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/workload-identity-pool-description.jpg)

## Allow your external workload to access Google cloud resources
You’ll need to grant permission to the external identity of Azure.
This has to be done on each resources once which is being access from Azure.

![Assigning workload identity pool to the storage bucket](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/grant-access-to-storage-bucket.jpg)

The principal is constructed in the following format:

```shell
principal://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/subject/SUBJECT
```

This subject refers to the Object ID of the managed identity. If you’ve select something else as subject then you’ll need to pass on that value here.

To keep it simple, since our configuration follows the standard approach then we’ll use the Object ID. Which you can copy by going to the managed identity.

## Authenticate using REST API
This method of calling the REST API and collecting the token is just an example, there are other methods via the SDK you can get the same. I’ll share the link at the bottom of the blog.

Let’s first log in to the Azure VM and then call IMDS service to get the access token from Azure.

```shell
$SubjectTokenType = "urn:ietf:params:oauth:token-type:jwt"
$SubjectToken = (Invoke-RestMethod `
  -Uri "http://169.254.169.254/metadata/identity/oauth2/token?resource=APP_ID_URI&api-version=2018-02-01" `
  -Headers @{Metadata="true"}).access_token
Write-Host $SubjectToken
```

here APP_ID_URI is the URI which you set in the step 1.

Now with this subject token you can exchange this with google STS service and get the access token which will be valid to access GCP resources where the permission was granted.

```shell
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$StsToken = (Invoke-RestMethod `
    -Method POST `
    -Uri "https://sts.googleapis.com/v1/token" `
    -ContentType "application/json" `
    -Body (@{
        "audience"           = "//iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID"
        "grantType"          = "urn:ietf:params:oauth:grant-type:token-exchange"
        "requestedTokenType" = "urn:ietf:params:oauth:token-type:access_token"
        "scope"              = "https://www.googleapis.com/auth/cloud-platform"
        "subjectTokenType"   = $SubjectTokenType
        "subjectToken"       = $SubjectToken
    } | ConvertTo-Json)).access_token
Write-Host $StsToken
```

Here, the PROJECT_NUMBER is the project that contains the workload identity\
POOL_ID : this is the workload identity pool\
PROVIDER_ID: This is the provider ID.

You can now use the command below, where we're passing the access token to access the GCP Storage Bucket.

```shell
# Replace these with your values
$BucketName = "azdoctor"

# GCS API endpoint to list objects
$Uri = "https://storage.googleapis.com/storage/v1/b/$BucketName/o"

# Make the GET request with Bearer token
$Response = Invoke-RestMethod -Uri $Uri `
    -Method Get `
    -Headers @{ Authorization = "Bearer $StsToken" }

# Output response (object listing)
$Response.items
 
Replace the $bucketName with your storage bucket name.
```

![Use REST API to access GCP resources](https://raw.githubusercontent.com/qureshiaquib/qureshiaquib.github.io/main/assets/25112025/authenticate-to-gcp-storage-bucket-rest-api.jpg)

To authenticate and call from the SDK

[https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create-cred-config](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create-cred-config)

More info on subject claims

[https://learn.microsoft.com/en-us/entra/identity-platform/access-tokens#claims-in-access-tokens](https://learn.microsoft.com/en-us/entra/identity-platform/access-tokens#claims-in-access-tokens)

[https://cloud.google.com/iam/docs/workload-identity-federation#mapping](https://cloud.google.com/iam/docs/workload-identity-federation#mapping)

[https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create-cred-config](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create-cred-config)

I hope this guide helps you in performing the cross cloud authentication, this can also be used when you're planning to build cross cloud DR where in scenarios of partial DR authentication still need to function seamlessly.

Happy Learning!

>Subscribe to my newsletter for the latest posts and summaries. Your privacy is paramount, and your email stays with us securely.
click the link to submit your email.
[https://forms.office.com/r/6ysKm4nkp4](https://forms.office.com/r/6ysKm4nkp4)
{: .prompt-tip }
