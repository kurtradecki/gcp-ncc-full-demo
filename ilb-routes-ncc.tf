resource "google_compute_route" "route-from-vpc-spokes-to-ilb-transit-10" {
  for_each     = toset(local.spoke_vpcs)
  name         = "${var.default-route-to-ilb-transit-name}-in-${each.value}-10"
  dest_range   = "10.0.0.0/8"
#  network      = google_compute_network.vpc-transit.name
  network      = "projects/${var.project_id}/global/networks/${each.value}"
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit.ip_address
  priority     = 500
}


resource "google_compute_route" "route-from-vpc-spokes-to-ilb-transit-172" {
  for_each     = toset(local.spoke_vpcs)
  name         = "${var.default-route-to-ilb-transit-name}-in-${each.value}-172"
  dest_range   = "172.16.0.0/12"
#  network      = google_compute_network.vpc-transit.name
  network      = "projects/${var.project_id}/global/networks/${each.value}"
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit.ip_address
  priority     = 500
}


resource "google_compute_route" "route-from-vpc-spokes-to-ilb-transit-192" {
  for_each     = toset(local.spoke_vpcs)
  name         = "${var.default-route-to-ilb-transit-name}-in-${each.value}-192"
  dest_range   = "192.168.0.0/16"
#  network      = google_compute_network.vpc-transit.name
  network      = "projects/${var.project_id}/global/networks/${each.value}"
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit.ip_address
  priority     = 500
}
