# Yaml_to_Multi-Terralith
Move from on prem deployment of infrastructure with yaml to a multi-terralith architecture in Google Cloud Platform.

## Status
Currently working...

## Prep
1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
2. [Create a google cloud platform account](https://cloud.google.com/free/)
3. [Install GcloudSDK](https://www.terraform.io/intro/getting-started/install.html)

## Translating Yaml into Terraform(HCL)
Basic templates for Provider, VPCs, Subnets, Routes, and VM or in the repo.  Clone or download the repo and they can be found in the "templates" folder and open them in a text editor.

There is no direct conversion of yaml to [HCL](https://github.com/hashicorp/hcl)(HashiCorp Configuration Language) that will provide you with a finished production ready formated terraform script.  In this excercise we will convert sample yaml files to hcl .  Templates are broken by resource types up so they are easily reusable and the main terraform file is easily managed.

| Templates     | 
| ------------- |
| Provider      |
| VPC           | 
| Subnet        | 
| Routes        | 
| VM            |

Templates can be created based on the need of the user.  Logical segmentation of environments or specific systems can also be used as templates for terraform script creation.  

### Network Yaml

### Virtual Machine Yaml


## Terralith_Structure

## Deploying to GCP

## Managing Terraform within GCP 

## Deploying your scripts and script management
