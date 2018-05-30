# Yaml_to_Multi-Terralith
Move from on prem deployment of infrastructure with yaml to a multi-terralith architecture in Google Cloud Platform.

## Status
Currently working...

## Prep
1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
2. [Create a google cloud platform account](https://cloud.google.com/free/)
3. [Install GcloudSDK](https://www.terraform.io/intro/getting-started/install.html)
4. Clone or download the repo

## Translating Yaml into Terraform(HCL)
Basic templates for Provider, VPCs, Subnets, Routes, and VMs are provided.  Clone or download the repo, they can be found in the "templates" folder and open them in a text editor.

There is no direct conversion of yaml to [HCL](https://github.com/hashicorp/hcl)(HashiCorp Configuration Language) that will provide you with a finished production ready formated terraform script.  In this excercise we will convert sample yaml files to hcl .  Templates are broken up by resource types up so they are easily reusable and the main terraform file is easily managed.

Templates can be created based on the need of the user.  Logical segmentation of environments or specific systems can also be used as templates for terraform script creation. The sample templates will be used to translate on prem environments to google cloud. 

### Network Yaml
Open the network.yaml file and walk through the network configuration and descriptions.
⋅⋅* There are 3 networks being created on top of a management network (10.0.0.0)
⋅⋅* There are a number of network routes defined within each of these networks.
⋅⋅* A DNS server is defined for two of the networks

Each "network:" represents a VPC in google cloud
```
network: 172.16.0.0/24
network: 172.16.20.0/24
network: 172.16.30.0/24
```

Use the net_vpc.tf file and create two additional vpc's by copy and pasting the template within the file.  After copy and pasting the template twice name each resource differently.  You may follow the current format and the final result should be three vpc's named vpc1, vpc2, and vpc3.  Because this is a custom network we will be setting the "auto_create_subnetworks" to false and created them in a later step.  Save the file.
Example:
```terraform
//Create VPC
resource "google_compute_network" "vpc1" {
  name = "vpc1"
  auto_create_subnetworks = "false"
}
```

Open the net_subnet.tf file and create a subnet for each network (by copy and pasting the template within the file) with the listed IP_CIDR range in the file.  You may follow the current format and the final result should be three subnets named subnet1 placed in network:vpc1, subnet2 placed in network:vpc2, and subnet3 placed in network:vpc3. Notice the "depends_on" section... this section instructs terraform on the dependecies of the resource so there is a logical order when deploying resources.  In this example we will place the corrolating vpc for that subnet as the "depends_on" resource.  Once completed save the file.  

    NOTE: Variables will be covered later so please leave them in the terraform file for now.

Example:
```terraform
//Create Subnet dependant on vpc
resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "172.16.0.0/24"
  network       = "vpc1"
  depends_on    = ["google_compute_network.vpc1"]
  region        = "${var.region}"
}
```

Open the net_routes.tf file and create the routes within each "network" (these are the subnets you just created) listed in the network.yaml file.  The routes are listed below the network and labeled as routes with a "dest" and "gateway".  
Example:
```yaml
  - network: 172.16.0.0/24
    routes:
      - dest: 0.0.0.0/0
        gateway: 172.16.0.11
      - dest: 172.16.10.0/24
        gateway: 172.16.0.10
      - dest: 172.16.20.0/24
        gateway: 172.16.0.10
      - dest: 172.16.30.0/24
        gateway: 172.16.0.10
```

The template below creates the first route (dest: 0.0.0.0/0 => gateway: 172.16.0.11) in subnet1 located in vpc1.  Each route will be a seperate resource.  Vpc1>subnet1 should have four route resources, vpc2>subnet2 should have 1 route resource, and vpc3>subnet3 should have 1 route resource.  The "gateway" address will be placed into the "next_hop_ip" section.  Once completed save the file.
```terraform
//Create Routes dependant on subnetwork
resource "google_compute_route" "net_route_vpc1" {
  name        = "net_route_vpc1"
  dest_range  = "0.0.0.0/0"
  network     = "vpc1"
  depends_on    = ["google_compute_subnetwork.subnet1"]
  next_hop_ip = "172.16.0.11"
  priority    = 1000
  tags = ["route1"]
}
```

### Virtual Machine Yaml
Open the vm.yaml file in the repo and review the file and notice that we are creating 3 virtual machines, each with two network interfaces.  

```yaml
//Create a virtual machine
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
