# ==========================================
# 2. VPCs and Subnets
# ==========================================

/*
module "vpcs" {
  source = "./modules/vpc" # Inline representation for simplicity
}
*/

# Helper local for VPC networks
locals {
  spoke_vpcs = ["vpc1", "vpc2", "vpc3", "vpc4"]
  other_vpcs = ["vpc-routing", "vpcdc", "vpc-routing2", "vpcdc2"]
}

resource "google_compute_network" "vpc" {
  for_each                = toset(concat(local.spoke_vpcs, local.other_vpcs))
  name                    = each.key
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.apis]
}

# Subnets
resource "google_compute_subnetwork" "subnet11" {
  name                     = "subnet11"
  network                  = google_compute_network.vpc["vpc1"].id
  ip_cidr_range            = "10.11.11.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet12" {
  name                     = "subnet12"
  network                  = google_compute_network.vpc["vpc1"].id
  ip_cidr_range            = "10.12.12.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet21" {
  name                     = "subnet21"
  network                  = google_compute_network.vpc["vpc2"].id
  ip_cidr_range            = "10.21.21.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet22" {
  name                     = "subnet22"
  network                  = google_compute_network.vpc["vpc2"].id
  ip_cidr_range            = "10.22.22.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet31" {
  name                     = "subnet31"
  network                  = google_compute_network.vpc["vpc3"].id
  ip_cidr_range            = "10.31.31.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet32" {
  name                     = "subnet32"
  network                  = google_compute_network.vpc["vpc3"].id
  ip_cidr_range            = "10.32.32.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet41" {
  name                     = "subnet41"
  network                  = google_compute_network.vpc["vpc4"].id
  ip_cidr_range            = "10.41.41.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet42" {
  name                     = "subnet42"
  network                  = google_compute_network.vpc["vpc4"].id
  ip_cidr_range            = "10.42.42.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing1" {
  name                     = "subnet-routing1"
  network                  = google_compute_network.vpc["vpc-routing"].id
  ip_cidr_range            = "10.1.1.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing2" {
  name                     = "subnet-routing2"
  network                  = google_compute_network.vpc["vpc-routing"].id
  ip_cidr_range            = "10.2.2.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet110" {
  name                     = "subnet110"
  network                  = google_compute_network.vpc["vpcdc"].id
  ip_cidr_range            = "10.110.110.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet120" {
  name                     = "subnet120"
  network                  = google_compute_network.vpc["vpcdc"].id
  ip_cidr_range            = "10.120.120.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing2_1" {
  name                     = "subnet-routing2-1"
  network                  = google_compute_network.vpc["vpc-routing2"].id
  ip_cidr_range            = "10.3.3.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing2_2" {
  name                     = "subnet-routing2-2"
  network                  = google_compute_network.vpc["vpc-routing2"].id
  ip_cidr_range            = "10.4.4.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet210" {
  name                     = "subnet210"
  network                  = google_compute_network.vpc["vpcdc2"].id
  ip_cidr_range            = "10.210.210.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet220" {
  name                     = "subnet220"
  network                  = google_compute_network.vpc["vpcdc2"].id
  ip_cidr_range            = "10.220.220.0/24"
  region                   = var.region2
  private_ip_google_access = true
}