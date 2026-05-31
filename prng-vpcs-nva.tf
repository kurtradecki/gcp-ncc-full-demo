resource "google_compute_network_peering" "peering-hub2-spoke1" {
  name                 = "peering-hub2-spoke1"
  network              = google_compute_network.vpc-hub2.self_link
  peer_network         = google_compute_network.vpc-hub2-spoke1.self_link
  export_custom_routes = true
  import_custom_routes = true
}




resource "google_compute_network_peering" "peering-spoke1-hub2" {
  name                 = "peering-spoke1-hub2"
  network              = google_compute_network.vpc-hub2-spoke1.self_link
  peer_network         = google_compute_network.vpc-hub2.self_link
  export_custom_routes = true
  import_custom_routes = true
}




resource "google_compute_network_peering" "peering-hub2-spoke2" {
  name                 = "peering-hub2-spoke2"
  network              = google_compute_network.vpc-hub2.self_link
  peer_network         = google_compute_network.vpc-hub2-spoke2.self_link
  export_custom_routes = true
  import_custom_routes = true
}




resource "google_compute_network_peering" "peering-spoke2-hub2" {
  name                 = "peering-spoke2-hub2"
  network              = google_compute_network.vpc-hub2-spoke2.self_link
  peer_network         = google_compute_network.vpc-hub2.self_link
  export_custom_routes = true
  import_custom_routes = true
}




resource "google_compute_network_peering" "peering-transit-management" {
  name                 = "peering-transit-management"
  network              = google_compute_network.vpc-transit.self_link
  peer_network         = google_compute_network.vpc-management.self_link
  export_custom_routes = true
  import_custom_routes = true
}




resource "google_compute_network_peering" "peering-management-transit" {
  name                 = "peering-management-transit"
  network              = google_compute_network.vpc-management.self_link
  peer_network         = google_compute_network.vpc-transit.self_link
  export_custom_routes = true
  import_custom_routes = true
}