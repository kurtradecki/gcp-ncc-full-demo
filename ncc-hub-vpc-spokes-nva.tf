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