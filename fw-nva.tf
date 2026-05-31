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

resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1"
  network   = google_compute_network.vpc-hub1.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}


resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1-spoke1" {
 name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1-spoke1"
 network   = google_compute_network.vpc-hub1-spoke1.self_link
 direction = "INGRESS"
 priority  = "500"
 allow {
   protocol = "icmp"
 }
 allow {
   protocol = "tcp"
   ports    = ["22", "80", "443", "3389"]
 }
 source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}


resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1-spoke2" {
 name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1-spoke2"
 network   = google_compute_network.vpc-hub1-spoke2.self_link
 direction = "INGRESS"
 priority  = "500"
 allow {
   protocol = "icmp"
 }
 allow {
   protocol = "tcp"
   ports    = ["22", "80", "443", "3389"]
 }
 source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}


resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2"
  network   = google_compute_network.vpc-hub2.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke1" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke1"
  network   = google_compute_network.vpc-hub2-spoke1.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke2" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke2"
  network   = google_compute_network.vpc-hub2-spoke2.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-transit" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-transit"
  network   = google_compute_network.vpc-transit.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-untrusted" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-untrusted"
  network   = google_compute_network.vpc-untrusted.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}


resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-management" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-management"
  network   = google_compute_network.vpc-management.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}
