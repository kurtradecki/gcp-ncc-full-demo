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