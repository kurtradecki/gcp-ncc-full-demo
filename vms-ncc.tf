# ==========================================
# 6. Test VMs
# ==========================================

# Using local blocks to iterate quickly over test VMs 
locals {
  vms = {
    "vm-vpc1-r1"   = { subnet = google_compute_subnetwork.subnet11.id, ip = "10.11.11.2", zone = "${var.region1}-a" }
    "vm-vpc1-r2"   = { subnet = google_compute_subnetwork.subnet12.id, ip = "10.12.12.2", zone = "${var.region2}-a" }
    "vm-vpc2-r1"   = { subnet = google_compute_subnetwork.subnet21.id, ip = "10.21.21.2", zone = "${var.region1}-a" }
    "vm-vpc2-r2"   = { subnet = google_compute_subnetwork.subnet22.id, ip = "10.22.22.2", zone = "${var.region2}-a" }
    "vm-vpc3-r1"   = { subnet = google_compute_subnetwork.subnet31.id, ip = "10.31.31.2", zone = "${var.region1}-a" }
    "vm-vpc3-r2"   = { subnet = google_compute_subnetwork.subnet32.id, ip = "10.32.32.2", zone = "${var.region2}-a" }
    "vm-vpc4-r1"   = { subnet = google_compute_subnetwork.subnet41.id, ip = "10.41.41.2", zone = "${var.region1}-a" }
    "vm-vpc4-r2"   = { subnet = google_compute_subnetwork.subnet42.id, ip = "10.42.42.2", zone = "${var.region2}-a" }
    "vm-vpc-dc-r1"  = { subnet = google_compute_subnetwork.subnet110.id, ip = "10.110.110.2", zone = "${var.region1}-a" }
    "vm-vpc-dc-r2"  = { subnet = google_compute_subnetwork.subnet120.id, ip = "10.120.120.2", zone = "${var.region2}-a" }
    "vm-vpc-dc2-r1" = { subnet = google_compute_subnetwork.subnet210.id, ip = "10.210.210.2", zone = "${var.region1}-a" }
    "vm-vpc-dc2-r2" = { subnet = google_compute_subnetwork.subnet220.id, ip = "10.220.220.2", zone = "${var.region2}-a" }
  }
}

resource "google_compute_instance" "test_vms" {
  for_each     = local.vms
  name         = each.key
  machine_type = "e2-micro"
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = each.value.subnet
    network_ip = each.value.ip
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata = {
    enable-oslogin = "true"
    startup-script = <<-EOT
      sudo apt-get update
      sudo apt-get install -y postgresql-client
      sudo apt-get install -y dnsutils
    EOT
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/bigquery"]
  }
  depends_on = [google_compute_router.nat_routers, google_compute_router_nat.nats]
}
