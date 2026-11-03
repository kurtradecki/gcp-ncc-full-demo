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

resource "google_compute_route" "route-from-vpc-spokes-to-ilb-transit-10" {
  for_each     = local.deploy_ncc_spokes && local.deploy_nva ? toset(local.spoke_vpcs) : toset([])
  name         = "${var.default-route-to-ilb-transit-name}-in-${each.value}-10"
  dest_range   = "10.0.0.0/8"
#  network      = google_compute_network.vpc-transit.name
  network      = "projects/${var.project_id}/global/networks/${each.value}"
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit[0].ip_address
  priority     = 500
}


resource "google_compute_route" "route-from-vpc-spokes-to-ilb-transit-172" {
  for_each     = local.deploy_ncc_spokes && local.deploy_nva ? toset(local.spoke_vpcs) : toset([])
  name         = "${var.default-route-to-ilb-transit-name}-in-${each.value}-172"
  dest_range   = "172.16.0.0/12"
#  network      = google_compute_network.vpc-transit.name
  network      = "projects/${var.project_id}/global/networks/${each.value}"
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit[0].ip_address
  priority     = 500
}


resource "google_compute_route" "route-from-vpc-spokes-to-ilb-transit-192" {
  for_each     = local.deploy_ncc_spokes && local.deploy_nva ? toset(local.spoke_vpcs) : toset([])
  name         = "${var.default-route-to-ilb-transit-name}-in-${each.value}-192"
  dest_range   = "192.168.0.0/16"
#  network      = google_compute_network.vpc-transit.name
  network      = "projects/${var.project_id}/global/networks/${each.value}"
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit[0].ip_address
  priority     = 500
}
