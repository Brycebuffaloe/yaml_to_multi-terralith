# Yaml_to_Multi-Terralith
Move from on prem deployment of infrastructure with yaml to a multi-terralith architecture in Google Cloud Platform.

## Status
Currently working...

## Prep
1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
2. [Create a google cloud platform account](https://cloud.google.com/free/)
3. [Install GcloudSDK](https://www.terraform.io/intro/getting-started/install.html)
4. [Enable GCP APIs](https://support.google.com/cloud/answer/6158841?hl=en)
    a. Enable Compute Engine API, 
5. Clone or download the repo

## Translating Yaml into Terraform(HCL)
Basic templates for VPCs, Subnets, Routes, and VMs are provided.  Clone or download the repo, they can be found in the "templates" folder and open them in a text editor.

There is no direct conversion of yaml to [HCL](https://github.com/hashicorp/hcl)(HashiCorp Configuration Language) that will provide you with a finished production ready formated terraform script.  In this excercise we will convert sample yaml files to hcl .  Templates are broken up by resource types up so they are easily reusable and the main terraform file is easily managed.

Templates can be created based on the need of the user.  Logical segmentation of environments or specific systems can also be used as templates for terraform script creation. The sample templates will be used to translate on prem environments to google cloud. 

### Network Yaml
Open the network.yaml file and walk through the network configuration and descriptions.  There are 3 networks being created on top of a management network (10.0.0.0).  There are a number of network routes defined within each of these networks. 

Each "network:" represents a VPC in google cloud
```yaml
network: 172.16.0.0/24
network: 172.16.20.0/24
network: 172.16.30.0/24
```

Use the net_vpc.tf file and create two additional vpc's by copy and pasting the template within the file.  After copy and pasting the template twice name each resource differently.  You may follow the current format and the final result should be three vpc's named vpc1, vpc2, and vpc3.  Because this is a custom network we will be setting the "auto_create_subnetworks" to false and created them in a later step.  Save the file.
Result:
```hcl
//Create VPC
resource "google_compute_network" "vpc1" {
  name = "vpc1"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "vpc2" {
  name = "vpc2"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "vpc3" {
  name = "vpc3"
  auto_create_subnetworks = "false"
}
```

Open the net_subnet.tf file and create a subnet for each network (by copy and pasting the template within the file) with the listed IP_CIDR range in the network.yaml file as "network:{ip_cidr_range}".  You may follow the current format and the final result should be three subnets named subnet1 placed in network:vpc1, subnet2 placed in network:vpc2, and subnet3 placed in network:vpc3. Notice the "depends_on" section... this section instructs terraform on the dependecies of the resource so there is a logical order when deploying resources.  In this example we will place the corrolating vpc for that subnet as the "depends_on" resource.  Once completed save the file.  

    NOTE: Variables will be covered later so please leave them in the terraform file for now.

Result:
```hcl
//Create Subnet dependant on vpc
resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "172.16.0.0/24"
  network       = "vpc1"
  depends_on    = ["google_compute_network.vpc1"]
  region        = "${var.region}"
}
resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "172.16.20.0/24"
  network       = "vpc2"
  depends_on    = ["google_compute_network.vpc2"]
  region        = "${var.region}"
}
resource "google_compute_subnetwork" "subnet3" {
  name          = "subnet3"
  ip_cidr_range = "172.16.30.0/24"
  network       = "vpc3"
  depends_on    = ["google_compute_network.vpc3"]
  region        = "${var.region}"
}
```

Open the net_routes.tf file and create the routes within each "subnetwork" (these are the subnets you just created) listed in the network.yaml file.  The routes are listed below the network and labeled as routes with a "dest" and "gateway".  
Example from network.yaml:
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

The template below creates the first route (dest: 0.0.0.0/0 => gateway: 172.16.0.11) in subnet1 located in vpc1.  Each route will be a seperate resource.  Vpc1 containing subnet1 should have two route resources, vpc2 containing subnet2 should have one route resource, and vpc3 containing subnet3 should have one route resource.  The "gateway" address will be placed into the "next_hop_ip" section.  Each resource will need to be named uniquely on the resource line and the name line.  Once completed save the file.

Result:
```hcl
//Create Routes dependant on subnetwork
resource "google_compute_route" "net_route_vpc1-1" {
  name        = "route1"
  dest_range  = "0.0.0.0/0"
  network     = "vpc1"
  depends_on    = ["google_compute_subnetwork.subnet1"]
  next_hop_ip = "172.16.0.11"
  priority    = 1000
  tags = []
}
resource "google_compute_route" "net_route_vpc1-2" {
  name        = "route1-2"
  dest_range  = "172.16.10.0/24"
  network     = "vpc1"
  depends_on    = ["google_compute_subnetwork.subnet1"]
  next_hop_ip = "172.16.0.10"
  priority    = 1000
  tags = []
}
resource "google_compute_route" "net_route_vpc2" {
  name        = "route2"
  dest_range  = "0.0.0.0/0"
  network     = "vpc2"
  depends_on    = ["google_compute_subnetwork.subnet2"]
  next_hop_ip = "172.16.20.25"
  priority    = 1000
  tags = []
}
resource "google_compute_route" "net_route_vpc3" {
  name        = "route3"
  dest_range  = "0.0.0.0/0"
  network     = "vpc3"
  depends_on    = ["google_compute_subnetwork.subnet3"]
  next_hop_ip = "172.16.30.25"
  priority    = 1000
  tags = []
}
```

### Virtual Machine Yaml
Open the vm.yaml file in the repo and review the file and notice that we are creating 3 virtual machines, all of the vms have two network interfaces. All 10.138 addresses will be utilizing the "default" subnet that exists on all gcp projects within the west region. Make sure to map the ip in the yaml to a corrolating subnet with an IP that exisits within that range under the "network interface" section of the vm.tf file.  The template as it suggests is a debian instance and we will be using a default google cloud image for debian.

Example:
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

Use the example in the vm.tf file to create 3 virtual machines and save the file.   Each resource will need to be named uniquely on the resource line and the name line.  We will be using the n1-standard-2 machine type which support 2 network interfaces.  Each vm should depend on a corrolating subnet from its network interfaces.  For now the service account section should remain unchanged.  This is a later step when decided what this machines will have access to within google cloud.  Notice the use of a variable in the zone section.  Once completed save the file.

Result:
```hcl
//MACHINE NAME
resource "google_compute_instance" "vm1" {
  name         = "vm1"
  machine_type = "n1-standard-2"
  zone         = "${var.zone}"
  depends_on   = ["google_compute_subnetwork.subnet1"]
  tags = []

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  //scratch_disk {}

    network_interface {
    subnetwork         = "default"
    access_config      {}
    address            = "10.138.0.5"
  }

    network_interface {
    subnetwork         = "subnet1"
    access_config      {}
    address            = "172.16.0.11"
  }

  can_ip_forward = true 

  metadata {}

  metadata_startup_script = ""

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write"]
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "n1-standard-2"
  zone         = "${var.zone}"
  depends_on   = ["google_compute_subnetwork.subnet2"]
  tags = []

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  //scratch_disk {}

  network_interface {
    subnetwork         = "default"
    access_config      {}
    address            = "10.138.0.13"
  }

    network_interface {
    subnetwork         = "subnet2"
    access_config      {}
    address            = "172.16.20.11"
  }

  can_ip_forward = true 

  metadata {}

  metadata_startup_script = ""

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write"]
  }
}

resource "google_compute_instance" "vm3" {
  name         = "vm3"
  machine_type = "n1-standard-2"
  zone         = "${var.zone}"
  depends_on   = ["google_compute_subnetwork.subnet3"]
  tags = []

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  //scratch_disk {}

  network_interface {
    subnetwork         = "default"
    access_config      {}
    address            = "10.138.0.39"
  }

    network_interface {
    subnetwork         = "subnet3"
    access_config      {}
    address            = "172.16.30.10"
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
In order to manage the cloud resources without searching through one large file I have seperated them out in the .tf files focused on specific resources.  The terralith structure is a simple yet repeatable structure and approach that allows you to organize and group resources as you decide.  For this excercise we will be using the files previously created in the previous sections for vpc, routes, subnets, and vms (Terralith structure = logical groupings of resources or environments test/dev/prod)

Inside the terraform folder you will also see the variables.tf file which contains the variables your terraform script utlizes for region, zone, etc.  This file must be in the same directory as your terraform files. If you would like to add variables to your terraform script this is where you would declare them.  Please review this file but do not change for this exercise.

The terraform.tfvars file is also located in this folder and contains the set values of these variables.  This format allows you to change the region, zone, image, or ect you would like to deploy your resources with or to by making a single change that will echo through the terraform files.  There are default values inside of this file, please review this file and add your pre-req created google cloud project name to the "gcp_project" line.

```
region      = "us-west1"
gcp_project = "{insert name here}"
credentials = "tfkey.json"
```

## Deploying to GCP
For the purposes of this lab we will be creating a service account in GCP and deploying our terraform scripts with that credential. Please use the following commands to create your service account, assign it roles, and expot the tfkey.json.

Run the following gcloud commands from a local terminal where the cloudsdk has been installed.

```
gcloud init
```
Select your account, project, and default zone

```
gcloud iam service-accounts create sa_name --display-name "sa_name"
gcloud iam service-accounts list
```
Replace "sa_name" and with the service account name you have in mind.  Make sure your account is returned in the list.  

```
gcloud iam service-accounts keys create ~/tfkey.json \
    --iam-account sa_name@pj_name.iam.gserviceaccount.com
```
Replace "sa_name" with the service account name you used for the previous step and replace "pj_name" with your gcp project name.  The key will be downloaded to your machine and should be moved into the same directory as the the terraform scripts (templates folder) (this is not suggested for production but will be utilized for this exercise, for production purposes these should be managed in a gcs bucket where the key is encrypted at rest).  Look in the terraform.tfvars file and notice the creditials variable is set to look for tfkey.json in the local directory.

```
gcloud projects add-iam-policy-binding pj_name \
    --member serviceAccount:sn_name@pj_name.iam.gserviceaccount.com --role roles/editor
``` 
Replace "sa_name" with the service account name you used for the previous step and replace "pj_name" with your gcp project name.  We are granting the service account right to be a project editor so it can deploy resources.  These role can be more well defined for production if you would like restrict what can be deployed for security reasons.  For example there may be no need for a service account to deploy a kubernetes cluster so we can grant roles for vm's and network to secure that and restrict the account.  


## Deploying your scripts and script management

Once you have your terraform files and json key in the same directory (templates folder) we can deploy the scripted infrastructure to google cloud.  

Open a terminal window and cd to the directory the terraform files (templates folder) are located in and issue the following commands.

1.  initalize terraform to grab the correct plugins:
```
terraform init
```

2.  Validate you file and look for syntax errors:
```
terraform validate
```

3.  Preview the Terraform changes:
```
terraform plan
```
The result should be:
```
Plan: 13 to add, 0 to change, 0 to destroy.
```
Note:  Correct any errors that present themselves before proceeding

4.  Deploy the Terraform scripts:
```
terraform apply
```

Note: You will need to confirm with yes.

5.  If all goes well you should see:
```
Apply complete! Resources:  13 added,  0 changed,  0 destroyed.
```

## Confirm Deployment
1. [Log into google cloud console](https://console.cloud.google.com/)
2. Navigate through the left side drop down to "Networks VPC" and confirm your 3 vpc's have been created.
   a. Within each vpc look at the routes you created as well.
3. Navigate through the left side drop down to "Compute Engine" and confirm your 3 vm's have been created.
4. Your terraform deployment is successful if you have found all of these resources.

##  Destroy Resources with Terraform
```
terraform destroy
```
Note: You will need to confirm with yes.
