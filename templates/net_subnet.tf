//Create Subnet dependant on vpc
resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "172.16.0.0/24"
  network       = "vpc1"
  depends_on    = ["google_compute_network.vpc1"]
  region        = "${var.region}"
}