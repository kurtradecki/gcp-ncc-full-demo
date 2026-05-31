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
  name        = "nva-ncc-hub"
  description = "ncc hub created from terraform"
  export_psc  = true
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1" {
  name        = "nccspk-vpc-hub1"
  location    = "global"
  description = "ncc spoke vpc-hub1"
  hub         = google_network_connectivity_hub.ncchub2.id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1.self_link
    exclude_export_ranges = []
  }
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1_spoke1" {
  name        = "nccspk-vpc-hub1-spoke1"
  location    = "global"
  description = "ncc spoke vpc-hub1-spoke1"
  hub         = google_network_connectivity_hub.ncchub2.id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1-spoke1.self_link
    exclude_export_ranges = []
  }
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1_vpc_hub1_spoke2" {
  name        = "nccspk-vpc-hub1-spoke2"
  location    = "global"
  description = "ncc spoke vpc-hub1-spoke1"
  hub         = google_network_connectivity_hub.ncchub2.id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1-spoke2.self_link
    exclude_export_ranges = []
  }
}
