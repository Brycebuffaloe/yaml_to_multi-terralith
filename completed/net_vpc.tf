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