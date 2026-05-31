# ==========================================
# 8. Connect Routing VPC to Routing VPC
# ==========================================

resource "google_compute_network_peering" "peering-routing-vpcs-forward" {
  count                = var.route-between-routing-vpcs ? 1 : 0
  name                 = "peering-vpc-routing-to-vpc-routing2"
  network              = google_compute_network.vpc["vpc-routing"].self_link
  peer_network         = google_compute_network.vpc["vpc-routing2"].self_link
  export_custom_routes = true
  import_custom_routes = true
}


resource "google_compute_network_peering" "peering-routing-vpcs-reverse" {
  count                = var.route-between-routing-vpcs ? 1 : 0
  name                 = "peering-vpc-routing2-to-vpc-routing"
  network              = google_compute_network.vpc["vpc-routing2"].self_link
  peer_network         = google_compute_network.vpc["vpc-routing"].self_link
  export_custom_routes = true
  import_custom_routes = true
}