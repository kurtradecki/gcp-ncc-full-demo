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

resource "google_compute_health_check" "hc" {
  count              = local.deploy_nva ? 1 : 0
  name               = var.health-check-name
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "80"
  }
  depends_on         = [time_sleep.wait_timer]
}


resource "google_compute_instance_group" "ig-nvas" {
  count     = local.deploy_nva ? 1 : 0
  name      = var.instance-group-name
  instances = [google_compute_instance.nva1[0].self_link, google_compute_instance.nva2[0].self_link]
  zone      = "${var.region1}-${var.zone-suffix}"
}


resource "google_compute_region_backend_service" "ilb-backend-transit" {
  count         = local.deploy_nva ? 1 : 0
  name          = var.ilb-backend-transit-name
  region        = var.region1
  health_checks = [google_compute_health_check.hc[0].id]
  protocol      = "TCP"
  network       = google_compute_network.vpc-transit.self_link
  backend {
    group          = google_compute_instance_group.ig-nvas[0].self_link
    balancing_mode = "CONNECTION"
  }
}


resource "google_compute_forwarding_rule" "ilb-forwarding-rule-transit" {
  count                 = local.deploy_nva ? 1 : 0
  name                  = var.ilb-forwarding-rule-transit-name
  region                = var.region1
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-transit[0].id
  all_ports             = true
  allow_global_access   = true  
  ip_address            = "${var.subnet1-vpc-transit-first-three-octets}${var.ilb-forwarding-rule-address}"
  network               = google_compute_network.vpc-transit.name
  subnetwork            = google_compute_subnetwork.subnet1-vpc-transit.name
}


resource "google_compute_route" "default-route-to-ilb-transit1" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.default-route-to-ilb-transit-name}1"
  dest_range   = "10.0.0.0/8"
  network      = google_compute_network.vpc-transit.name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit[0].ip_address
  priority     = 500
}


resource "google_compute_route" "default-route-to-ilb-transit2" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.default-route-to-ilb-transit-name}2"
  dest_range   = "172.16.0.0/12"
  network      = google_compute_network.vpc-transit.name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit[0].ip_address
  priority     = 500
}


resource "google_compute_route" "default-route-to-ilb-transit3" {
  count        = local.deploy_nva ? 1 : 0
  name         = "${var.default-route-to-ilb-transit-name}3"
  dest_range   = "192.168.0.0/16"
  network      = google_compute_network.vpc-transit.name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit[0].ip_address
  priority     = 500
}


resource "google_compute_region_backend_service" "ilb-backend-hub1" {
  count         = local.deploy_nva ? 1 : 0
  name          = var.ilb-backend-hub1-name
  region        = var.region1
  health_checks = [google_compute_health_check.hc[0].id]
  protocol      = "TCP"
  network       = google_compute_network.vpc-hub1[0].self_link
  backend {
    group          = google_compute_instance_group.ig-nvas[0].self_link
    balancing_mode = "CONNECTION"
  }
}


resource "google_compute_forwarding_rule" "ilb-forwarding-rule-hub1" {
  count                 = local.deploy_nva ? 1 : 0
  name                  = var.ilb-forwarding-rule-hub1-name
  region                = var.region1
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-hub1[0].id
  all_ports             = true
  allow_global_access   = true
  ip_address            = "${var.subnet1-vpc-hub1-first-three-octets}${var.ilb-forwarding-rule-address}"
  network               = google_compute_network.vpc-hub1[0].name
  subnetwork            = google_compute_subnetwork.subnet1-vpc-hub1[0].name
}


resource "google_compute_route" "default-route-to-ilb-hub1" {
  count        = local.deploy_nva ? 1 : 0
  name         = var.default-route-to-ilb-hub1-name
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc-hub1[0].name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-hub1[0].ip_address
  priority     = 500
}


resource "google_compute_region_backend_service" "ilb-backend-hub2" {
  count         = local.deploy_hub2 ? 1 : 0
  name          = var.ilb-backend-hub2-name
  region        = var.region1
  health_checks = [google_compute_health_check.hc[0].id]
  protocol      = "TCP"
  network       = google_compute_network.vpc-hub2[0].self_link
  backend {
    group          = google_compute_instance_group.ig-nvas[0].self_link
    balancing_mode = "CONNECTION"
  }
}


resource "google_compute_forwarding_rule" "ilb-forwarding-rule-hub2" {
  count                 = local.deploy_hub2 ? 1 : 0
  name                  = var.ilb-forwarding-rule-hub2-name
  region                = var.region1
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-hub2[0].id
  all_ports             = true
  allow_global_access   = true
  ip_address            = "${var.subnet1-vpc-hub2-first-three-octets}${var.ilb-forwarding-rule-address}"
  network               = google_compute_network.vpc-hub2[0].name
  subnetwork            = google_compute_subnetwork.subnet1-vpc-hub2[0].name
}


resource "google_compute_route" "default-route-to-ilb-hub2" {
  count        = local.deploy_hub2 ? 1 : 0
  name         = var.default-route-to-ilb-hub2-name
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc-hub2[0].name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-hub2[0].ip_address
  priority     = 500
}





/*
module "google_compute_route" {
  source       = "../../modules/routes" #adding local path
  project_id   = var.project_id # Replace this with your project ID in quotes
#  network_name = "default"
  for_each     = toset(concat(local.spoke_vpcs, local.other_vpcs))
  network_name = each.key

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = ["egress-inet"]
      next_hop_internet = true
    }
  ]
}
*/


locals {
  nva_ncc_spoke_vpcs = ["vpc-hub1-spoke1", "vpc-hub1-spoke2"]
}


resource "google_compute_route" "spoke_routes_to_ilb" {
  for_each     = local.deploy_nva ? toset(local.nva_ncc_spoke_vpcs) : toset([])
  name         = "${each.key}-default-route-to-ilb-in-hub1"
  dest_range   = "0.0.0.0/0"
  network      = each.key
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-hub1[0].ip_address
  priority     = 100
  depends_on   = [google_compute_network.vpc-hub1-spoke1, google_compute_network.vpc-hub1-spoke2]
}
