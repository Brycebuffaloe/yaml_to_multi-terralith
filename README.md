# Yaml_to_Multi-Terralith
Move from on prem deployment of infrastructure with yaml to a multi-terralith architecture in Google Cloud Platform.

## Status
Currently working...

## Prep
1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
2. [Create a google cloud platform account](https://cloud.google.com/free/)
3. [Install GcloudSDK](https://www.terraform.io/intro/getting-started/install.html)

## Translating Yaml into Terraform(HCL)
Basic templates for Provider, VPCs, Subnets, Routes, and VMs.  Clone or download the repo, and they can be found in the "templates" folder and open them in a text editor.

There is no direct conversion of yaml to [HCL](https://github.com/hashicorp/hcl)(HashiCorp Configuration Language) that will provide you with a finished production ready formated terraform script.  In this excercise we will convert sample yaml files to hcl .  Templates are broken by resource types up so they are easily reusable and the main terraform file is easily managed.

| Templates     | 
| ------------- |
| Provider      |
| VPC           | 
| Subnet        | 
| Routes        | 
| VM            |

Templates can be created based on the need of the user.  Logical segmentation of environments or specific systems can also be used as templates for terraform script creation. The sample templates will be used to translate on prem environments to google cloud. 

### Network Yaml
Open the network.yaml file and walk through how the network is setup.
⋅⋅* There are 3 networks being created on top of a management network (10.0.0.0)
⋅⋅* There are a number of network routes defined within each of these networks.
⋅⋅* A DNS server is defined for two of the networks

Each "network:" entry represents a VPC in google cloud
```
network: 172.16.0.0/24
network: 172.16.20.0/24
network: 172.16.30.0/24
```
Use the net_vpc template and create two additional vpc's and save the file.
Example:
```
//Create VPC
resource "google_compute_network" "vpc1" {
  name = "vpc1"
  auto_create_subnetworks = "false"
}
```
Open the net_subnet template and create a subnet for each network with the listed IP and CIDR block in the file.
Example:
```
//Create Subnet dependant on vpc
resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "172.16.0.0/24"
  network       = "m4m1"
  depends_on    = ["google_compute_network.vpc1"]
  region        = "${var.region}"
}
```
Open the net_routes template and create a subnet for each network with the listed IP and CIDR block in the file.
Example:
```
//Create Subnet dependant on vpc
resource "google_compute_subnetwork" "subnet-1" {
  name          = "sub1"
  ip_cidr_range = "172.16.0.0/24"
  network       = "vpc1"
  depends_on    = ["google_compute_network.vpc1"]
  region        = "${var.region}"
}
```

### Virtual Machine Yaml
Open the vm.yaml file in the repo and review the file and notice that we are creating 

```
VM1:
        template: 'Debian_machine'
        startOrder: 1
        networks:
            "internal":
                   type: dhcp
                   mask: 255.255.0.0
                   adapter: 'Network adapter 1'
            "control":
                   type: static
                   ip: 10.0.0.5
                   mask: 255.255.0.0
                   adapter: 'Network adapter 2'
```

## Terralith_Structure

## Deploying to GCP

## Managing Terraform within GCP 

## Deploying your scripts and script management
