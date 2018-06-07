variable "region" {}
variable "zone" {}
variable "gcp_project" {}
variable "credentials" {}
variable "compute_image" {
  description = "Image used for compute VMs."
  default     = "debian-cloud/debian-8"
}
//variable "name" {}
//variable "subnet_cidr" {}