variable "public3_prefix" {
  default = "sv-public3"
}

resource "google_compute_firewall" "externalaccess" {
  name    = "externalaccess"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "30333"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["externalaccess"]
}

resource "google_compute_instance" "main" {
  name         = var.public3_prefix
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone
  tags         = ["externalaccess"]

  boot_disk {
    initialize_params {
      image = var.gcp_operating_system
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  depends_on = ["google_compute_firewall.externalaccess"]

  service_account {
    scopes = ["compute-ro"]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.public3_public_key}"
  }
}
