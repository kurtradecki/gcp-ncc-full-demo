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

/*
module "vpcs" {
  source = "./modules/vpc" # Inline representation for simplicity
}
*/

# Helper local for VPC networks
locals {
  spoke_vpcs = local.deploy_ncc_spokes ? ["vpc-ncc-spoke1", "vpc-ncc-spoke2", "vpc-ncc-spoke3", "vpc-ncc-spoke4"] : []
#  other_vpcs = ["vpc-routing", "vpcdc", "vpc-routing2", "vpcdc2"]
  other_vpcs = ["vpc-dc1", "vpc-dc2"]
}

resource "google_compute_network" "vpc" {
  for_each                = toset(concat(local.spoke_vpcs, local.other_vpcs))
  name                    = each.key
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [time_sleep.wait_timer]
}

# Subnets
resource "google_compute_subnetwork" "subnet11" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet11-ncc-spoke1"
  network                  = google_compute_network.vpc["vpc-ncc-spoke1"].id
  ip_cidr_range            = "10.11.11.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet12" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet12-ncc-spoke1"
  network                  = google_compute_network.vpc["vpc-ncc-spoke1"].id
  ip_cidr_range            = "10.12.12.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet21" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet21-ncc-spoke2"
  network                  = google_compute_network.vpc["vpc-ncc-spoke2"].id
  ip_cidr_range            = "10.21.21.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet22" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet22-ncc-spoke2"
  network                  = google_compute_network.vpc["vpc-ncc-spoke2"].id
  ip_cidr_range            = "10.22.22.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet31" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet31-ncc-spoke3"
  network                  = google_compute_network.vpc["vpc-ncc-spoke3"].id
  ip_cidr_range            = "10.31.31.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet32" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet32-ncc-spoke3"
  network                  = google_compute_network.vpc["vpc-ncc-spoke3"].id
  ip_cidr_range            = "10.32.32.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet41" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet41-ncc-spoke4"
  network                  = google_compute_network.vpc["vpc-ncc-spoke4"].id
  ip_cidr_range            = "10.41.41.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet42" {
  count                    = local.deploy_ncc_spokes ? 1 : 0
  name                     = "subnet42-ncc-spoke4"
  network                  = google_compute_network.vpc["vpc-ncc-spoke4"].id
  ip_cidr_range            = "10.42.42.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

/*
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
*/

resource "google_compute_subnetwork" "subnet110" {
  name                     = "subnet-dc1-110"
  network                  = google_compute_network.vpc["vpc-dc1"].id
  ip_cidr_range            = "10.110.110.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet120" {
  name                     = "subnet-dc1-120"
  network                  = google_compute_network.vpc["vpc-dc1"].id
  ip_cidr_range            = "10.120.120.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

/*
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
*/

resource "google_compute_subnetwork" "subnet210" {
  name                     = "subnet-dc2-210"
  network                  = google_compute_network.vpc["vpc-dc2"].id
  ip_cidr_range            = "10.210.210.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet220" {
  name                     = "subnet-dc2-220"
  network                  = google_compute_network.vpc["vpc-dc2"].id
  ip_cidr_range            = "10.220.220.0/24"
  region                   = var.region2
  private_ip_google_access = true
}
