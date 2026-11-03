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
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpn1-in-vpc-extrnl"
  location    = var.region1
  description = "NCC hybrid spoke VPN"
  hub         = google_network_connectivity_hub.ncchub[0].id
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
    uris = ["https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-extrnl-vpc-dc1-remote-0","https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-extrnl-vpc-dc1-remote-1"]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }

  depends_on = [module.vpn-1, module.vpn-2]
}


# Link VPN Tunnels as NCC Spoke
resource "google_network_connectivity_spoke" "nccspk_vpn2" {
  count       = local.deploy_ncc_spokes ? 1 : 0
  name        = "nccspk-vpn2-in-vpc-extrnl"
  location    = var.region2
  description = "NCC hybrid spoke VPN in vpc-extrnl"
  hub         = google_network_connectivity_hub.ncchub[0].id

  linked_vpn_tunnels {
    uris = [
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region2}/vpnTunnels/vpngw-vpc-extrnl-vpc-dc2-remote-0",
      #      google_compute_vpn_tunnel.tunnel0_havpngw_vpc_routing.self_link,
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region2}/vpnTunnels/vpngw-vpc-extrnl-vpc-dc2-remote-1"
    ]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }
  depends_on = [module.vpn-2, module.vpn-1]
}
