//MACHINE NAME
resource "google_compute_instance" "vm1 " {
  name         = "vm1 "
  machine_type = "n1-standard-2"
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
    subnetwork         = "subnet-1"
    access_config      {}
    address            = "172.16.0.10"
  }

  can_ip_forward = true 

  metadata {}

  metadata_startup_script = ""

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write"]
  }
}