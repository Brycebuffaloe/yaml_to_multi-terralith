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