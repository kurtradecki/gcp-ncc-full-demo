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
  name        = "ncc-hub"
  description = "ncc hub created from terraform"
  export_psc  = true
}

resource "google_network_connectivity_spoke" "nccspk_vpc1" {
  name        = "nccspk-vpc1"
  location    = "global"
  description = "ncc spoke vpc1"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpc_network {
    uri                   = google_compute_network.vpc["vpc1"].self_link
    exclude_export_ranges = []
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc2" {
  name        = "nccspk-vpc2"
  location    = "global"
  description = "ncc spoke vpc2"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpc_network {
    uri = google_compute_network.vpc["vpc2"].self_link
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc3" {
  name        = "nccspk-vpc3"
  location    = "global"
  description = "ncc spoke vpc3"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpc_network {
    uri = google_compute_network.vpc["vpc3"].self_link
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc4" {
  name        = "nccspk-vpc4"
  location    = "global"
  description = "ncc spoke vpc4"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpc_network {
    uri = google_compute_network.vpc["vpc4"].self_link
  }
}

resource "google_network_connectivity_spoke" "nccspk_vpc_transit" {
  name        = "nccspk-vpc-transit"
  location    = "global"
  description = "ncc spoke vpc-transit"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpc_network {
    uri = google_compute_network.vpc-transit.self_link
  }
}
