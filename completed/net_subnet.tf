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