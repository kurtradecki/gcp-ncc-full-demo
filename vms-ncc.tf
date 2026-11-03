/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  ncc_spoke_vms = local.deploy_ncc_spokes ? {
    "vm-vpc1-r1" = { subnet = google_compute_subnetwork.subnet11[0].id, ip = "10.11.11.2", zone = "${var.region1}-c" }
    "vm-vpc1-r2" = { subnet = google_compute_subnetwork.subnet12[0].id, ip = "10.12.12.2", zone = "${var.region2}-c" }
    "vm-vpc2-r1" = { subnet = google_compute_subnetwork.subnet21[0].id, ip = "10.21.21.2", zone = "${var.region1}-c" }
    "vm-vpc2-r2" = { subnet = google_compute_subnetwork.subnet22[0].id, ip = "10.22.22.2", zone = "${var.region2}-c" }
    "vm-vpc3-r1" = { subnet = google_compute_subnetwork.subnet31[0].id, ip = "10.31.31.2", zone = "${var.region1}-c" }
    "vm-vpc3-r2" = { subnet = google_compute_subnetwork.subnet32[0].id, ip = "10.32.32.2", zone = "${var.region2}-c" }
    "vm-vpc4-r1" = { subnet = google_compute_subnetwork.subnet41[0].id, ip = "10.41.41.2", zone = "${var.region1}-c" }
    "vm-vpc4-r2" = { subnet = google_compute_subnetwork.subnet42[0].id, ip = "10.42.42.2", zone = "${var.region2}-c" }
  } : {}
  dc_vms = {
    "vm-vpc-dc-r1"  = { subnet = google_compute_subnetwork.subnet110.id, ip = "10.110.110.2", zone = "${var.region1}-c" }
    "vm-vpc-dc-r2"  = { subnet = google_compute_subnetwork.subnet120.id, ip = "10.120.120.2", zone = "${var.region2}-c" }
    "vm-vpc-dc2-r1" = { subnet = google_compute_subnetwork.subnet210.id, ip = "10.210.210.2", zone = "${var.region1}-c" }
    "vm-vpc-dc2-r2" = { subnet = google_compute_subnetwork.subnet220.id, ip = "10.220.220.2", zone = "${var.region2}-c" }
  }
  vms = merge(local.ncc_spoke_vms, local.dc_vms)
}

resource "google_compute_instance" "test_vms" {
  for_each     = local.vms
  name         = each.key
  machine_type = "e2-micro"
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
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
