# NETWORKING # //This may need to be 4 seperate vpcs
//Create VPC
resource "google_compute_network" "vpc1" {
  name = "vpc1"
  auto_create_subnetworks = "false"
}