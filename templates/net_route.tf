//Create Routes dependant on subnetwork
resource "google_compute_route" "net_route_vpc1" {
  name        = "net_route_vpc1"
  dest_range  = "0.0.0.0/0"
  network     = "vpc1"
  depends_on    = ["google_compute_subnetwork.subnet-4"]
  next_hop_ip = "172.16.0.11"
  priority    = 1000
  tags = ["route1"]
}