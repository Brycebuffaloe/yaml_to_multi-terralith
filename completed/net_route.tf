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