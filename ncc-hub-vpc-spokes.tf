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

resource "google_network_connectivity_hub" "ncchub" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "ncc-hub"
  description = "ncc hub created from terraform"
  export_psc  = true
  depends_on  = [time_sleep.wait_timer]
}

resource "google_network_connectivity_spoke" "nccspk_vpc1" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpc-ncc-spoke1"
  location    = "global"
  description = "ncc spoke vpc-ncc-spoke1"
  hub         = google_network_connectivity_hub.ncchub[0].id

  linked_vpc_network {
    uri                   = google_compute_network.vpc["vpc-ncc-spoke1"].self_link
    exclude_export_ranges = []
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc2" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpc-ncc-spoke2"
  location    = "global"
  description = "ncc spoke vpc-ncc-spoke2"
  hub         = google_network_connectivity_hub.ncchub[0].id

  linked_vpc_network {
    uri = google_compute_network.vpc["vpc-ncc-spoke2"].self_link
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc3" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpc-ncc-spoke3"
  location    = "global"
  description = "ncc spoke vpc-ncc-spoke3"
  hub         = google_network_connectivity_hub.ncchub[0].id

  linked_vpc_network {
    uri = google_compute_network.vpc["vpc-ncc-spoke3"].self_link
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc4" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpc-ncc-spoke4"
  location    = "global"
  description = "ncc spoke vpc-ncc-spoke4"
  hub         = google_network_connectivity_hub.ncchub[0].id

  linked_vpc_network {
    uri = google_compute_network.vpc["vpc-ncc-spoke4"].self_link
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc_transit" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpc-extrnl"
  location    = "global"
  description = "ncc spoke vpc-extrnl"
  hub         = google_network_connectivity_hub.ncchub[0].id

  linked_vpc_network {
    uri = google_compute_network.vpc-transit.self_link
  }
}
