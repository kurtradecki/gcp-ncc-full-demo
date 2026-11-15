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

resource "google_network_connectivity_hub" "ncchub2" {
  count           = local.deploy_nva ? 1 : 0
  name            = "nva-ncc-hub"
  description     = "ncc hub created from terraform"
  export_psc      = true
  preset_topology = "STAR"
  depends_on      = [time_sleep.wait_timer]
}


resource "google_network_connectivity_group" "ncchub2_center_group" {
  count       = local.deploy_nva ? 1 : 0
  hub         = google_network_connectivity_hub.ncchub2[0].id
  name        = "center"
  description = "ncc center group for nva-ncc-hub"

  auto_accept {
    auto_accept_projects = [var.project_id]
  }
}


resource "google_network_connectivity_group" "ncchub2_edge_group" {
  count       = local.deploy_nva ? 1 : 0
  hub         = google_network_connectivity_hub.ncchub2[0].id
  name        = "edge"
  description = "ncc edge group for nva-ncc-hub"

  auto_accept {
    auto_accept_projects = [var.project_id]
  }
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1" {
  count       = local.deploy_nva ? 1 : 0
  name        = "nccspk-vpc-nva-ncc-intrnl"
  location    = "global"
  description = "ncc spoke vpc-nva-ncc-intrnl"
  hub         = google_network_connectivity_hub.ncchub2[0].id
  group       = google_network_connectivity_group.ncchub2_center_group[0].id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1[0].self_link
    exclude_export_ranges = []
  }
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1_spoke1" {
  count       = local.deploy_nva ? 1 : 0
  name        = "nccspk-vpc-nva-ncc-spoke1"
  location    = "global"
  description = "ncc spoke vpc-nva-ncc-spoke1"
  hub         = google_network_connectivity_hub.ncchub2[0].id
  group       = google_network_connectivity_group.ncchub2_edge_group[0].id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1-spoke1[0].self_link
    exclude_export_ranges = []
  }
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1_spoke2" {
  count       = local.deploy_nva ? 1 : 0
  name        = "nccspk-vpc-nva-ncc-spoke2"
  location    = "global"
  description = "ncc spoke vpc-nva-ncc-spoke2"
  hub         = google_network_connectivity_hub.ncchub2[0].id
  group       = google_network_connectivity_group.ncchub2_edge_group[0].id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1-spoke2[0].self_link
    exclude_export_ranges = []
  }
}
