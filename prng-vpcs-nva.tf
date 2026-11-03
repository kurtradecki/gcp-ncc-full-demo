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

resource "google_compute_network_peering" "peering-hub2-spoke1" {
  count                = local.deploy_hub2 ? 1 : 0
  name                 = "peering-hub2-spoke1"
  network              = google_compute_network.vpc-hub2[0].self_link
  peer_network         = google_compute_network.vpc-hub2-spoke1[0].self_link
  export_custom_routes = true
  import_custom_routes = true
}


resource "google_compute_network_peering" "peering-spoke1-hub2" {
  count                = local.deploy_hub2 ? 1 : 0
  name                 = "peering-spoke1-hub2"
  network              = google_compute_network.vpc-hub2-spoke1[0].self_link
  peer_network         = google_compute_network.vpc-hub2[0].self_link
  export_custom_routes = true
  import_custom_routes = true
}


resource "google_compute_network_peering" "peering-hub2-spoke2" {
  count                = local.deploy_hub2 ? 1 : 0
  name                 = "peering-hub2-spoke2"
  network              = google_compute_network.vpc-hub2[0].self_link
  peer_network         = google_compute_network.vpc-hub2-spoke2[0].self_link
  export_custom_routes = true
  import_custom_routes = true
}


resource "google_compute_network_peering" "peering-spoke2-hub2" {
  count                = local.deploy_hub2 ? 1 : 0
  name                 = "peering-spoke2-hub2"
  network              = google_compute_network.vpc-hub2-spoke2[0].self_link
  peer_network         = google_compute_network.vpc-hub2[0].self_link
  export_custom_routes = true
  import_custom_routes = true
}


resource "google_compute_network_peering" "peering-transit-management" {
  count                = local.deploy_nva ? 1 : 0
  name                 = "peering-transit-management"
  network              = google_compute_network.vpc-transit.self_link
  peer_network         = google_compute_network.vpc-management[0].self_link
  export_custom_routes = true
  import_custom_routes = true
}


resource "google_compute_network_peering" "peering-management-transit" {
  count                = local.deploy_nva ? 1 : 0
  name                 = "peering-management-transit"
  network              = google_compute_network.vpc-management[0].self_link
  peer_network         = google_compute_network.vpc-transit.self_link
  export_custom_routes = true
  import_custom_routes = true
}
