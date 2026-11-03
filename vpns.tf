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

module "vpn-1" {
  source     = "github.com/kurtradecki/gcp-vpn-vpc-demo"
  project-id = var.project_id
  region1    = var.region1
#  vpc1name   = google_compute_network.vpc["vpc-routing"].name
  vpc1name   = var.one_rtg_vpc == true ? google_compute_network.vpc-transit.name : google_compute_network.vpc["vpc-routing"].name
  vpc2name   = google_compute_network.vpc["vpc-dc1"].name
  vpc1_cldrouter_custom = {
    all_subnets = true
    ip_ranges = {
      "10.0.0.0/8" = "RFC 1918 10s"
      "172.16.0.0/12" = "RFC 1918 172s"
      "192.16.0.0/16" = "RFC 1918 192s"
    }
  }
  vpc2_cldrouter_custom = {
    all_subnets = true
    ip_ranges   = {}
  }
  depends_on = [google_compute_network.vpc , google_compute_network.vpc-transit ]
}


module "vpn-2" {
  source     = "github.com/kurtradecki/gcp-vpn-vpc-demo"
  project-id = var.project_id
  region1    = var.region2
#  vpc1name   = google_compute_network.vpc["vpc-routing2"].name
  vpc1name   = var.one_rtg_vpc == true ? google_compute_network.vpc-transit.name : google_compute_network.vpc["vpc-routing2"].name
  vpc2name   = google_compute_network.vpc["vpc-dc2"].name
  vpc1_cldrouter_custom = {
    all_subnets = true
    ip_ranges = {
      "10.0.0.0/8" = "RFC 1918 10s"
      "172.16.0.0/12" = "RFC 1918 172s"
      "192.16.0.0/16" = "RFC 1918 192s"
    }
  }
  vpc2_cldrouter_custom = {
    all_subnets = true
    ip_ranges   = {}
  }
  depends_on = [google_compute_network.vpc , google_compute_network.vpc-transit ]
}
