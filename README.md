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
Basic templates for VPCs, Subnets, Routes, and VMs are provided.  Clone or download the repo, they can be found in the "templates" folder and open them in a text editor.

There is no direct conversion of yaml to [HCL](https://github.com/hashicorp/hcl)(HashiCorp Configuration Language) that will provide you with a finished production ready formated terraform script.  In this excercise we will convert sample yaml files to hcl .  Templates are broken up by resource types up so they are easily reusable and the main terraform file is easily managed.

Templates can be created based on the need of the user.  Logical segmentation of environments or specific systems can also be used as templates for terraform script creation. The sample templates will be used to translate on prem environments to google cloud. 

### Network Yaml
Open the network.yaml file and walk through the network configuration and descriptions.
⋅⋅* There are 3 networks being created on top of a management network (10.0.0.0)
⋅⋅* There are a number of network routes defined within each of these networks.
⋅⋅* A DNS server is defined for two of the networks

Each "network:" represents a VPC in google cloud
```yaml
network: 172.16.0.0/24
network: 172.16.20.0/24
network: 172.16.30.0/24
```

Use the net_vpc.tf file and create two additional vpc's by copy and pasting the template within the file.  After copy and pasting the template twice name each resource differently.  You may follow the current format and the final result should be three vpc's named vpc1, vpc2, and vpc3.  Because this is a custom network we will be setting the "auto_create_subnetworks" to false and created them in a later step.  Save the file.
Example:
```hcl
//Create VPC
resource "google_compute_network" "vpc1" {
  name = "vpc1"
  auto_create_subnetworks = "false"
}
```

Open the net_subnet.tf file and create a subnet for each network (by copy and pasting the template within the file) with the listed IP_CIDR range in the file.  You may follow the current format and the final result should be three subnets named subnet1 placed in network:vpc1, subnet2 placed in network:vpc2, and subnet3 placed in network:vpc3. Notice the "depends_on" section... this section instructs terraform on the dependecies of the resource so there is a logical order when deploying resources.  In this example we will place the corrolating vpc for that subnet as the "depends_on" resource.  Once completed save the file.  

    NOTE: Variables will be covered later so please leave them in the terraform file for now.

Example:
```hcl
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
 networks:
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
```hcl
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
Open the vm.yaml file in the repo and review the file and notice that we are creating 3 virtual machines, each with two network interfaces.  The first machine has a dhcp network adapter which means the address is not static and is based on the avaialble address pool of the network we assign it to.  All 10. addresses will be utilizing the default subnet that exists on gcp projects. 

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
                   ip: 10.138.0.5
                   mask: 255.255.0.0
                   adapter: 'Network adapter 2'
```

Use the example in the vm.tf file to create 3 virtual machines and save the file.

Example:
```hcl
//MACHINE NAME
resource "google_compute_instance" "vm1 " {
  name         = "vm1 "
  machine_type = "n1-standard-4"
  zone         = "${var.zone}"
  depends_on   = ["google_compute_subnetwork.subnet3"]
  tags = ["terraform_deploy"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  scratch_disk {}

  network_interface {
    subnetwork = "default"
    access_config      {}
    address            = ""
  }

  network_interface {
    subnetwork         = "default"
    access_config      {}
    address            = "10.138.0.5"
  }

  can_ip_forward = true 

  metadata {}

  metadata_startup_script = ""

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write"]
  }
}
```

## Terralith_Structure
In order to manage the cloud resources without searching through one large file I have seperated them out in the .tf files focused on specific resources.  The terralith structure is a simple yet repeatable structure and approach that allows you to organize and group resources as you decide.  For this excercise we will be using the files previously created for vpc, routes, subnets, and vms (Terralith structure = logical groupings of resources or environments test/dev)

Inside the terraform folder you will also see the variables.tf file which contains the variable your terraform script utlize for region, zone, etc.  This file must be in the same directory as your terraform files.  The terraform.tfvars file is also located in this folder and contains the declared values of these variables.  This format allow you to change the region you would like to deploy your resources to by making a single change that will echo through the terraform files.  


## Deploying to GCP
For the purposes of this lab we will be creating a service account in GCP and deploying our terraform scripts with that credential. Please use the following commands to create your service account, assign it roles, and expot the key.json.

Run the following gcloud commands from a local terminal where the cloudsdk has been installed.

```
gcloud init
```
Select your account, project, and default zone

```
gcloud iam service-accounts create sa_name --display-name "my service account"
gcloud iam service-accounts list
```
Replace "sa_name" with the service account name you have in mind.  Make sure your account is returned in the list.  

```
gcloud iam service-accounts keys create ~/tfkey.json \
    --iam-account sa_name@PROJECT-ID.iam.gserviceaccount.com
```
Replace "sa_name" with the service account name you used for the previous step.  The key will be downloaded to your machine and should be placed into the same directory as the the terraform scripts (this is not suggested for production but will be utilized for this exercise, for production purposes these should be managed in a gcs bucket where the key is encrypted at rest).  Look in the terraform.tfvars file and notice the creditials variable is set to look for tfkey.json in the local directory.

```
gcloud projects add-iam-policy-binding my-project-123 \
    --member serviceAccount:my-sa-123@my-project-123.iam.gserviceaccount.com --role roles/editor
```
Replace 


## Managing Terraform within GCP 

## Deploying your scripts and script management
