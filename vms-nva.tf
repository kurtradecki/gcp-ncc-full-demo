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

resource "google_compute_instance" "vm-in-hub1-spoke1" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.vm-name-prefix}hub1-spoke1"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub1-spoke1[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1-spoke1[0].self_link
    network_ip = "${var.spoke-first-octet}${var.spoke-hub1-second-octet}.1${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}


resource "google_compute_instance" "vm-in-hub1-spoke2" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.vm-name-prefix}hub1-spoke2"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub1-spoke2[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1-spoke2[0].self_link
    network_ip = "${var.spoke-first-octet}${var.spoke-hub1-second-octet}.2${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}


resource "google_compute_instance" "vm-in-hub1" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.vm-name-prefix}hub1"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub1[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1[0].self_link
    network_ip = "${var.subnet1-vpc-hub1-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-hub2-spoke1" {
  count        = local.deploy_hub2 ? 1 : 0
  name         = "${var.vm-name-prefix}hub2-spoke1"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub2-spoke1[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2-spoke1[0].self_link
    network_ip = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.1${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-hub2-spoke2" {
  count        = local.deploy_hub2 ? 1 : 0
  name         = "${var.vm-name-prefix}hub2-spoke2"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub2-spoke2[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2-spoke2[0].self_link
    network_ip = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.2${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-hub2" {
  count        = local.deploy_hub2 ? 1 : 0
  name         = "${var.vm-name-prefix}hub2"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub2[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2[0].self_link
    network_ip = "${var.subnet1-vpc-hub2-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-transit" {
  name         = "${var.vm-name-prefix}transit"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-transit.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-transit.self_link
    network_ip = "${var.subnet1-vpc-transit-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-untrusted" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.vm-name-prefix}untrusted"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-untrusted[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-untrusted[0].self_link
    network_ip = "${var.subnet1-vpc-untrusted-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-management" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.vm-name-prefix}management"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-management[0].self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-management[0].self_link
    network_ip = "${var.subnet1-vpc-management-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}
