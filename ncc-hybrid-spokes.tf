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

resource "google_network_connectivity_spoke" "nccspk_vpn" {
  name        = "nccspk-vpn1-in-vpc-transit"
  location    = var.region1
  description = "NCC hybrid spoke VPN"
  hub         = google_network_connectivity_hub.ncchub.id
/*
  linked_vpn_tunnels {
    uris = [
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-routing-remote-0",
      #      google_compute_vpn_tunnel.tunnel0_havpngw_vpc_routing.self_link,
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-routing-remote-1"
    ]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }
*/
  linked_vpn_tunnels {
    uris = ["https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-transit-vpcdc-remote-0","https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-transit-vpcdc-remote-1"]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }

  depends_on = [module.vpn-1, module.vpn-2]
}


# Link VPN Tunnels as NCC Spoke
resource "google_network_connectivity_spoke" "nccspk_vpn2" {
  name        = "nccspk-vpn2-in-vpc-transit"
  location    = var.region2
  description = "NCC hybrid spoke VPN in vpc-routing2"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpn_tunnels {
    uris = [
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region2}/vpnTunnels/vpngw-vpc-transit-vpcdc2-remote-0",
      #      google_compute_vpn_tunnel.tunnel0_havpngw_vpc_routing.self_link,
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region2}/vpnTunnels/vpngw-vpc-transit-vpcdc2-remote-1"
    ]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }
  depends_on = [module.vpn-2, module.vpn-1]
}
