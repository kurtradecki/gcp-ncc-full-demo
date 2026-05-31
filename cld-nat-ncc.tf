# Create NATs for individual VPCs 
resource "google_compute_router" "nat_routers" {
  for_each = toset(["vpc1", "vpc2", "vpc3", "vpc4", "vpcdc"])
  name     = "cldrtr-${each.key}-nat"
  network  = google_compute_network.vpc[each.key].id
  region   = var.region1
}

resource "google_compute_router_nat" "nats" {
  for_each                           = google_compute_router.nat_routers
  name                               = "pubnatgw-${each.value.name}"
  router                             = each.value.name
  region                             = var.region1
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
