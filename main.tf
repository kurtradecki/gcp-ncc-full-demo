/*
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.4"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.4"
    }
  }
}
*/

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# ==========================================
# 1. APIs & Org Policies
# ==========================================

locals {
  services = [
    "cloudresourcemanager.googleapis.com",
    "bigquery.googleapis.com",
    "cloudquotas.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "networkconnectivity.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each           = toset(local.services)
  service            = each.key
  disable_on_destroy = false
}

resource "google_project_organization_policy" "sql_restrict_authorized_networks" {
  project    = var.project_id
  constraint = "sql.restrictAuthorizedNetworks"

  restore_policy {
    default = true
  }
}

resource "google_project_organization_policy" "compute_restrict_vpn_peer_ips" {
  project    = var.project_id
  constraint = "constraints/compute.restrictVpnPeerIPs"

  list_policy {
    allow {
      all = true
    }
  }
}

# ==========================================
# 2. VPCs and Subnets
# ==========================================

/*
module "vpcs" {
  source = "./modules/vpc" # Inline representation for simplicity
}
*/

# Helper local for VPC networks
locals {
  spoke_vpcs = ["vpc1", "vpc2", "vpc3", "vpc4"]
  other_vpcs = ["vpc-routing", "vpcdc", "vpc-routing2", "vpcdc2"]
}

resource "google_compute_network" "vpc" {
  for_each                = toset(concat(local.spoke_vpcs, local.other_vpcs))
  name                    = each.key
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.apis]
}

# Subnets
resource "google_compute_subnetwork" "subnet11" {
  name                     = "subnet11"
  network                  = google_compute_network.vpc["vpc1"].id
  ip_cidr_range            = "10.11.11.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet12" {
  name                     = "subnet12"
  network                  = google_compute_network.vpc["vpc1"].id
  ip_cidr_range            = "10.12.12.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet21" {
  name                     = "subnet21"
  network                  = google_compute_network.vpc["vpc2"].id
  ip_cidr_range            = "10.21.21.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet22" {
  name                     = "subnet22"
  network                  = google_compute_network.vpc["vpc2"].id
  ip_cidr_range            = "10.22.22.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet31" {
  name                     = "subnet31"
  network                  = google_compute_network.vpc["vpc3"].id
  ip_cidr_range            = "10.31.31.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet32" {
  name                     = "subnet32"
  network                  = google_compute_network.vpc["vpc3"].id
  ip_cidr_range            = "10.32.32.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet41" {
  name                     = "subnet41"
  network                  = google_compute_network.vpc["vpc4"].id
  ip_cidr_range            = "10.41.41.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet42" {
  name                     = "subnet42"
  network                  = google_compute_network.vpc["vpc4"].id
  ip_cidr_range            = "10.42.42.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing1" {
  name                     = "subnet-routing1"
  network                  = google_compute_network.vpc["vpc-routing"].id
  ip_cidr_range            = "10.1.1.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing2" {
  name                     = "subnet-routing2"
  network                  = google_compute_network.vpc["vpc-routing"].id
  ip_cidr_range            = "10.2.2.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet110" {
  name                     = "subnet110"
  network                  = google_compute_network.vpc["vpcdc"].id
  ip_cidr_range            = "10.110.110.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet120" {
  name                     = "subnet120"
  network                  = google_compute_network.vpc["vpcdc"].id
  ip_cidr_range            = "10.120.120.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing2_1" {
  name                     = "subnet-routing2-1"
  network                  = google_compute_network.vpc["vpc-routing2"].id
  ip_cidr_range            = "10.3.3.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_routing2_2" {
  name                     = "subnet-routing2-2"
  network                  = google_compute_network.vpc["vpc-routing2"].id
  ip_cidr_range            = "10.4.4.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet210" {
  name                     = "subnet210"
  network                  = google_compute_network.vpc["vpcdc2"].id
  ip_cidr_range            = "10.210.210.0/24"
  region                   = var.region1
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet220" {
  name                     = "subnet220"
  network                  = google_compute_network.vpc["vpcdc2"].id
  ip_cidr_range            = "10.220.220.0/24"
  region                   = var.region2
  private_ip_google_access = true
}

# ==========================================
# 3. NCC Hub and Spokes
# ==========================================

resource "google_network_connectivity_hub" "ncchub" {
  name        = "ncchub"
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

# ==========================================
# 4. VPN Tunnels (Routing VPCs to DCs)
# ==========================================

module "vpn-1" {
  source     = "github.com/kurtradecki/gcp-vpn-vpc-demo"
  project-id = var.project_id
  region1    = var.region1
  vpc1name   = google_compute_network.vpc["vpc-routing"].name
  vpc2name   = google_compute_network.vpc["vpcdc"].name
  vpc1_cldrouter_custom = {
    all_subnets = true
    ip_ranges = {
      "10.0.0.0/8" = "All 10s"
    }
  }
  vpc2_cldrouter_custom = {
    all_subnets = true
    ip_ranges   = {}
  }
  depends_on = [google_compute_network.vpc]
}

# Link VPN Tunnels as NCC Spoke
resource "google_network_connectivity_spoke" "nccspk_vpn_vpc_routing" {
  name        = "nccspk-vpn-in-vpc-routing"
  location    = var.region1
  description = "NCC hybrid spoke VPN"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpn_tunnels {
    uris = [
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-routing-remote-0",
      #      google_compute_vpn_tunnel.tunnel0_havpngw_vpc_routing.self_link,
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-routing-remote-1"
    ]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }
  depends_on = [module.vpn-1]
}


module "vpn-2" {
  source     = "github.com/kurtradecki/gcp-vpn-vpc-demo"
  project-id = var.project_id
  region1    = var.region1
  vpc1name   = google_compute_network.vpc["vpc-routing2"].name
  vpc2name   = google_compute_network.vpc["vpcdc2"].name
  vpc1_cldrouter_custom = {
    all_subnets = true
    ip_ranges = {
      "10.0.0.0/8" = "All 10s"
    }
  }
  vpc2_cldrouter_custom = {
    all_subnets = true
    ip_ranges   = {}
  }
  depends_on = [google_compute_network.vpc]
}

# Link VPN Tunnels as NCC Spoke
resource "google_network_connectivity_spoke" "nccspk_vpn_vpc_routing2" {
  name        = "nccspk-vpn-in-vpc-routing2"
  location    = var.region1
  description = "NCC hybrid spoke VPN in vpc-routing2"
  hub         = google_network_connectivity_hub.ncchub.id

  linked_vpn_tunnels {
    uris = [
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-routing2-remote-0",
      #      google_compute_vpn_tunnel.tunnel0_havpngw_vpc_routing.self_link,
      "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region1}/vpnTunnels/vpngw-vpc-routing2-remote-1"
    ]
    site_to_site_data_transfer = false
    #    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }
  depends_on = [module.vpn-2]
}




# ==========================================
# 5. Global Firewall Policy
# ==========================================

resource "google_compute_network_firewall_policy" "fw_policy" {
  name        = "fw-policy"
  description = "Global network firewall policy"
}

resource "google_compute_network_firewall_policy_rule" "allow_iap_range" {
  firewall_policy = google_compute_network_firewall_policy.fw_policy.name
  rule_name       = "allow-iap-range"
  description     = "Allow traffic from IAP range"
  priority        = 100
  direction       = "INGRESS"
  action          = "allow"
  match {
    src_ip_ranges = ["35.235.240.0/20"]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "allow_internal" {
  firewall_policy = google_compute_network_firewall_policy.fw_policy.name
  rule_name       = "allow-internal-vms"
  description     = "Allow VMs to reach each other"
  priority        = 200
  direction       = "INGRESS"
  action          = "allow"
  match {
    src_ip_ranges = ["10.0.0.0/8"]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

# Associates the firewall policy to the VPCs 
resource "google_compute_network_firewall_policy_association" "fw_vpc_assoc" {
  for_each          = toset(["vpc1", "vpc2", "vpc3", "vpc4", "vpcdc", "vpcdc2"])
  name              = "assoc-${each.key}"
  firewall_policy   = google_compute_network_firewall_policy.fw_policy.id
  attachment_target = google_compute_network.vpc[each.key].id
}

# ==========================================
# 6. Test VMs
# ==========================================

# Using local blocks to iterate quickly over test VMs 
locals {
  vms = {
    "testvm-region1-vpc1"   = { subnet = google_compute_subnetwork.subnet11.id, ip = "10.11.11.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc1"   = { subnet = google_compute_subnetwork.subnet12.id, ip = "10.12.12.2", zone = "${var.region2}-a" }
    "testvm-region1-vpc2"   = { subnet = google_compute_subnetwork.subnet21.id, ip = "10.21.21.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc2"   = { subnet = google_compute_subnetwork.subnet22.id, ip = "10.22.22.2", zone = "${var.region2}-a" }
    "testvm-region1-vpc3"   = { subnet = google_compute_subnetwork.subnet31.id, ip = "10.31.31.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc3"   = { subnet = google_compute_subnetwork.subnet32.id, ip = "10.32.32.2", zone = "${var.region2}-a" }
    "testvm-region1-vpc4"   = { subnet = google_compute_subnetwork.subnet41.id, ip = "10.41.41.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc4"   = { subnet = google_compute_subnetwork.subnet42.id, ip = "10.42.42.2", zone = "${var.region2}-a" }
    "testvm-region1-vpcdc"  = { subnet = google_compute_subnetwork.subnet110.id, ip = "10.110.110.2", zone = "${var.region1}-a" }
    "testvm-region2-vpcdc"  = { subnet = google_compute_subnetwork.subnet120.id, ip = "10.120.120.2", zone = "${var.region2}-a" }
    "testvm-region1-vpcdc2" = { subnet = google_compute_subnetwork.subnet210.id, ip = "10.210.210.2", zone = "${var.region1}-a" }
    "testvm-region2-vpcdc2" = { subnet = google_compute_subnetwork.subnet220.id, ip = "10.220.220.2", zone = "${var.region2}-a" }
  }
}

resource "google_compute_instance" "test_vms" {
  for_each     = local.vms
  name         = each.key
  machine_type = "e2-micro"
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = each.value.subnet
    network_ip = each.value.ip
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata = {
    enable-oslogin = "true"
    startup-script = <<-EOT
      sudo apt-get update
      sudo apt-get install -y postgresql-client
      sudo apt-get install -y dnsutils
    EOT
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/bigquery"]
  }
  depends_on = [google_compute_router.nat_routers, google_compute_router_nat.nats]
}

# ==========================================
# 7. Cloud NAT (Outbound VM Traffic)
# ==========================================

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

# ==========================================
# 9. NVA & attached VPCs, subnets, VMs, FW rules, etc
# ==========================================

resource "google_compute_network" "vpc-hub1" {
  name                            = "${var.vpc-prefix}hub1"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}




resource "google_compute_subnetwork" "subnet1-vpc-hub1" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-hub1.name}"
  ip_cidr_range = "${var.subnet1-vpc-hub1-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub1.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




resource "google_compute_network" "vpc-hub2" {
  name                            = "${var.vpc-prefix}hub2"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}




resource "google_compute_subnetwork" "subnet1-vpc-hub2" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-hub2.name}"
  ip_cidr_range = "${var.subnet1-vpc-hub2-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub2.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




resource "google_compute_network" "vpc-hub2-spoke1" {
  name                            = "${google_compute_network.vpc-hub2.name}-spoke1"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}




resource "google_compute_subnetwork" "subnet1-vpc-hub2-spoke1" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-hub2-spoke1.name}"
  ip_cidr_range = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.1${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub2-spoke1.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




resource "google_compute_network" "vpc-hub2-spoke2" {
  name                            = "${google_compute_network.vpc-hub2.name}-spoke2"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}




resource "google_compute_subnetwork" "subnet1-vpc-hub2-spoke2" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-hub2-spoke2.name}"
  ip_cidr_range = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.2${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub2-spoke2.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




resource "google_compute_network" "vpc-transit" {
  name                            = "${var.vpc-prefix}transit"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}




resource "google_compute_subnetwork" "subnet1-vpc-transit" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-transit.name}"
  ip_cidr_range = "${var.subnet1-vpc-transit-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-transit.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




resource "google_compute_network" "vpc-untrusted" {
  name                    = "${var.vpc-prefix}untrusted"
  auto_create_subnetworks = false
  mtu                     = 1460
  routing_mode            = "GLOBAL"
}




resource "google_compute_subnetwork" "subnet1-vpc-untrusted" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-untrusted.name}"
  ip_cidr_range = "${var.subnet1-vpc-untrusted-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-untrusted.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




resource "google_compute_network" "vpc-management" {
  name                            = "${var.vpc-prefix}management"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}




resource "google_compute_subnetwork" "subnet1-vpc-management" {
  name          = "${var.subnet1-prefix}${google_compute_network.vpc-management.name}"
  ip_cidr_range = "${var.subnet1-vpc-management-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-management.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}




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




resource "google_compute_instance" "vm-in-hub1" {
  name         = "${var.vm-name-prefix}hub1"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub1.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1.self_link
    network_ip = "${var.subnet1-vpc-hub1-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-hub2-spoke1" {
  name         = "${var.vm-name-prefix}hub2-spoke1"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub2-spoke1.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2-spoke1.self_link
    network_ip = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.1${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-hub2-spoke2" {
  name         = "${var.vm-name-prefix}hub2-spoke2"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub2-spoke2.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2-spoke2.self_link
    network_ip = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.2${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-hub2" {
  name         = "${var.vm-name-prefix}hub2"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-hub2.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2.self_link
    network_ip = "${var.subnet1-vpc-hub2-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-transit" {
  name         = "${var.vm-name-prefix}transit"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-transit.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-transit.self_link
    network_ip = "${var.subnet1-vpc-transit-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-untrusted" {
  name         = "${var.vm-name-prefix}untrusted"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-untrusted.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-untrusted.self_link
    network_ip = "${var.subnet1-vpc-untrusted-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_instance" "vm-in-management" {
  name         = "${var.vm-name-prefix}management"
  machine_type = var.vm-machine-type
  zone         = "${var.region1}-${var.zone-suffix}"
  tags         = ["test-instance"]
  network_interface {
    network    = google_compute_network.vpc-management.self_link
    subnetwork = google_compute_subnetwork.subnet1-vpc-management.self_link
    network_ip = "${var.subnet1-vpc-management-first-three-octets}${var.test-vm-int-address}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "label"
      }
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub1"
  network   = google_compute_network.vpc-hub1.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2"
  network   = google_compute_network.vpc-hub2.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke1" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke1"
  network   = google_compute_network.vpc-hub2-spoke1.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke2" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-hub2-spoke2"
  network   = google_compute_network.vpc-hub2-spoke2.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-transit" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-transit"
  network   = google_compute_network.vpc-transit.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}




resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-untrusted" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-untrusted"
  network   = google_compute_network.vpc-untrusted.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}


resource "google_compute_firewall" "allow-ssh-rdp-icmp-http-https-from-private-vpc-management" {
  name      = "allow-ssh-rdp-icmp-http-https-from-private-vpc-management"
  network   = google_compute_network.vpc-management.self_link
  direction = "INGRESS"
  priority  = "500"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = setunion(var.fw-rule-source-ranges, toset([var.health-check-source-ip-range-1, var.health-check-source-ip-range-2]))
}



locals {
  temp-name-variation = "2"
}


resource "google_compute_instance" "nva1" {
#  name           = "nva1-${local.temp-name-variation}"
  name           = "nva1"
  machine_type   = "n1-standard-8"
  zone           = "${var.region1}-${var.zone-suffix}"
  can_ip_forward = true
  boot_disk {
    initialize_params {
      image = "cisco-public/csr1000v1721r-byol"
      type  = "pd-ssd"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-untrusted.self_link
    network_ip = "${var.subnet1-vpc-untrusted-first-three-octets}${var.nva1-int-address}"
    access_config {
      # ephemeral public IP
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-management.self_link
    network_ip = "${var.subnet1-vpc-management-first-three-octets}${var.nva1-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-transit.self_link
    network_ip = "${var.subnet1-vpc-transit-first-three-octets}${var.nva1-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1.self_link
    network_ip = "${var.subnet1-vpc-hub1-first-three-octets}${var.nva1-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2.self_link
    network_ip = "${var.subnet1-vpc-hub2-first-three-octets}${var.nva1-int-address}"
  }
  metadata = {
    # Note: the "1.1.1" in the cidrnetmask function is a placeholder, ie doesn't matter, only the mask matters) 
    startup-script     = <<EOS
Section: IOS configuration
username ${var.admin-name} privilege 15 secret 9 ${var.admin-secret-password}
!
vrf definition ${var.vrf-transit-name}
rd ${var.vrf-transit-route-descriptor}
address-family ipv4
exit-address-family
!
vrf definition ${var.vrf-management-name}
rd ${var.vrf-management-route-descriptor}
address-family ipv4
exit-address-family
!
vrf definition ${var.vrf-hub1-name}
rd ${var.vrf-hub1-route-descriptor}
address-family ipv4
exit-address-family
!
vrf definition ${var.vrf-hub2-name}
rd ${var.vrf-hub2-route-descriptor}
address-family ipv4
exit-address-family
!
interface GigabitEthernet1
description VPC untrusted - no secondary address for LB configured - not needed on GigabitEthernet1 / VM nic0
ip address ${var.subnet1-vpc-untrusted-first-three-octets}${var.nva1-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip nat outside
!
interface GigabitEthernet2
description VPC management - no secondary address for ILB and no NAT configured
vrf forwarding ${var.vrf-management-name}
ip address ${var.subnet1-vpc-management-first-three-octets}${var.nva1-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
no shut
!
interface GigabitEthernet3
description transit - no NAT configured
vrf forwarding ${var.vrf-transit-name}
ip address ${var.subnet1-vpc-transit-first-three-octets}${var.nva1-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-transit-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
no shut
!
interface GigabitEthernet4
description hub 1
vrf forwarding ${var.vrf-hub1-name}
ip address ${var.subnet1-vpc-hub1-first-three-octets}${var.nva1-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-hub1-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
ip nat inside
no shut
!
interface GigabitEthernet5
description hub 2
vrf forwarding ${var.vrf-hub2-name}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.nva1-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
ip nat inside
no shut
!
### Global Table Routes
ip route 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# route for transit - needed since transit is in a VRF
ip route ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for hub 2 - needed since hub 2 is in a VRF
ip route ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
!
### VRF management routes
# in this script, path to management interfaces is through the transit VPC peering to management VPC, thus no path to management is configured in these Network Virtual Appliances, so routing not added here
!
!
### VRF transit routes
# no default route to global table
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route vrf ${var.vrf-transit-name} 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-transit-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-transit-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-transit-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
!
### VRF hub 1 routes
# default route to global table
ip route vrf ${var.vrf-hub1-name} 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1 global
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route vrf ${var.vrf-hub1-name} 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub1-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# route for transit - needed since transit is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
!
### VRF hub 2 routes
# default route to global table
ip route vrf ${var.vrf-hub2-name} 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1 global
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route vrf ${var.vrf-hub2-name} 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub2-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# route for transit - needed since transit is in a VRF
ip route vrf ${var.vrf-hub2-name} ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route vrf ${var.vrf-hub2-name} ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-hub2-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-hub2-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
!
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub1-name} overload
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub2-name} overload
ip access-list standard NAT_ACL
10 permit 10.0.0.0 0.255.255.255
20 permit 10.2.0.0 0.0.255.255
30 permit 172.16.0.0 0.0.255.255
EOS
    serial-port-enable = true
  }
}



resource "google_compute_instance" "nva2" {
#  name           = "nva2-${local.temp-name-variation}"
  name           = "nva2"
  machine_type   = "n1-standard-8"
  zone           = "${var.region1}-${var.zone-suffix}"
  can_ip_forward = true
  boot_disk {
    initialize_params {
      image = "cisco-public/csr1000v1721r-byol"
      type  = "pd-ssd"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-untrusted.self_link
    network_ip = "${var.subnet1-vpc-untrusted-first-three-octets}${var.nva2-int-address}"
    access_config {
      # ephemeral public IP
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-management.self_link
    network_ip = "${var.subnet1-vpc-management-first-three-octets}${var.nva2-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-transit.self_link
    network_ip = "${var.subnet1-vpc-transit-first-three-octets}${var.nva2-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1.self_link
    network_ip = "${var.subnet1-vpc-hub1-first-three-octets}${var.nva2-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub2.self_link
    network_ip = "${var.subnet1-vpc-hub2-first-three-octets}${var.nva2-int-address}"
  }
  metadata = {
    # Note: the "1.1.1" in the cidrnetmask function is a placeholder, ie doesn't matter, only the mask matters) 
    startup-script     = <<EOS
Section: IOS configuration
username ${var.admin-name} privilege 15 secret 9 ${var.admin-secret-password}
!
vrf definition ${var.vrf-transit-name}
rd ${var.vrf-transit-route-descriptor}
address-family ipv4
exit-address-family
!
vrf definition ${var.vrf-management-name}
rd ${var.vrf-management-route-descriptor}
address-family ipv4
exit-address-family
!
vrf definition ${var.vrf-hub1-name}
rd ${var.vrf-hub1-route-descriptor}
address-family ipv4
exit-address-family
!
vrf definition ${var.vrf-hub2-name}
rd ${var.vrf-hub2-route-descriptor}
address-family ipv4
exit-address-family
!
interface GigabitEthernet1
description VPC untrusted - no secondary address for LB configured - not needed on GigabitEthernet1 / VM nic0
ip address ${var.subnet1-vpc-untrusted-first-three-octets}${var.nva2-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip nat outside
!
interface GigabitEthernet2
description VPC management - no secondary address for ILB and no NAT configured
vrf forwarding ${var.vrf-management-name}
ip address ${var.subnet1-vpc-management-first-three-octets}${var.nva2-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
no shut
!
interface GigabitEthernet3
description transit - no NAT configured
vrf forwarding ${var.vrf-transit-name}
ip address ${var.subnet1-vpc-transit-first-three-octets}${var.nva2-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-transit-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
no shut
!
interface GigabitEthernet4
description hub 1
vrf forwarding ${var.vrf-hub1-name}
ip address ${var.subnet1-vpc-hub1-first-three-octets}${var.nva2-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-hub1-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
ip nat inside
no shut
!
interface GigabitEthernet5
description hub 2
vrf forwarding ${var.vrf-hub2-name}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.nva2-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
ip nat inside
no shut
!
### Global Table Routes
ip route 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# route for transit - needed since transit is in a VRF
ip route ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for hub 2 - needed since hub 2 is in a VRF
ip route ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
!
### VRF management routes
# in this script, path to management interfaces is through the transit VPC peering to management VPC, thus no path to management is configured in these Network Virtual Appliances, so routing not added here
!
!
### VRF transit routes
# no default route to global table
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route vrf ${var.vrf-transit-name} 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-transit-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-transit-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-transit-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
!
### VRF hub 1 routes
# default route to global table
ip route vrf ${var.vrf-hub1-name} 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1 global
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route vrf ${var.vrf-hub1-name} 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub1-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# route for transit - needed since transit is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
!
### VRF hub 2 routes
# default route to global table
ip route vrf ${var.vrf-hub2-name} 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1 global
!
# route for all spokes in hub 1 - all 10 addresses other than hub 2's 10 addresses 
ip route vrf ${var.vrf-hub2-name} 10.0.0.0 255.0.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub2-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# route for transit - needed since transit is in a VRF
ip route vrf ${var.vrf-hub2-name} ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route vrf ${var.vrf-hub2-name} ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-hub2-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-hub2-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
!
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub1-name} overload
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub2-name} overload
ip access-list standard NAT_ACL
10 permit 10.0.0.0 0.255.255.255
20 permit 10.2.0.0 0.0.255.255
30 permit 172.16.0.0 0.0.255.255
EOS
    serial-port-enable = true
  }
}


resource "google_compute_health_check" "hc" {
  name               = var.health-check-name
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "80"
  }
}


resource "google_compute_instance_group" "ig-nvas" {
  name      = var.instance-group-name
  instances = [google_compute_instance.nva1.id, google_compute_instance.nva2.id]
  zone      = "${var.region1}-${var.zone-suffix}"
}


resource "google_compute_region_backend_service" "ilb-backend-transit" {
  name          = var.ilb-backend-transit-name
  region        = var.region1
  health_checks = [google_compute_health_check.hc.id]
  protocol      = "TCP"
  network       = google_compute_network.vpc-transit.self_link
  backend {
    group          = google_compute_instance_group.ig-nvas.self_link
    balancing_mode = "CONNECTION"
  }
}


resource "google_compute_forwarding_rule" "ilb-forwarding-rule-transit" {
  name                  = var.ilb-forwarding-rule-transit-name
  region                = var.region1
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-transit.id
  all_ports             = true
  ip_address            = "${var.subnet1-vpc-transit-first-three-octets}${var.ilb-forwarding-rule-address}"
  network               = google_compute_network.vpc-transit.name
  subnetwork            = google_compute_subnetwork.subnet1-vpc-transit.name
}


resource "google_compute_route" "default-route-to-ilb-transit" {
  name         = var.default-route-to-ilb-transit-name
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc-transit.name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-transit.ip_address
  priority     = 500
}


resource "google_compute_region_backend_service" "ilb-backend-hub1" {
  name          = var.ilb-backend-hub1-name
  region        = var.region1
  health_checks = [google_compute_health_check.hc.id]
  protocol      = "TCP"
  network       = google_compute_network.vpc-hub1.self_link
  backend {
    group          = google_compute_instance_group.ig-nvas.self_link
    balancing_mode = "CONNECTION"
  }
}


resource "google_compute_forwarding_rule" "ilb-forwarding-rule-hub1" {
  name                  = var.ilb-forwarding-rule-hub1-name
  region                = var.region1
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-hub1.id
  all_ports             = true
  ip_address            = "${var.subnet1-vpc-hub1-first-three-octets}${var.ilb-forwarding-rule-address}"
  network               = google_compute_network.vpc-hub1.name
  subnetwork            = google_compute_subnetwork.subnet1-vpc-hub1.name
}


resource "google_compute_route" "default-route-to-ilb-hub1" {
  name         = var.default-route-to-ilb-hub1-name
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc-hub1.name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-hub1.ip_address
  priority     = 500
}


resource "google_compute_region_backend_service" "ilb-backend-hub2" {
  name          = var.ilb-backend-hub2-name
  region        = var.region1
  health_checks = [google_compute_health_check.hc.id]
  protocol      = "TCP"
  network       = google_compute_network.vpc-hub2.self_link
  backend {
    group          = google_compute_instance_group.ig-nvas.self_link
    balancing_mode = "CONNECTION"
  }
}


resource "google_compute_forwarding_rule" "ilb-forwarding-rule-hub2" {
  name                  = var.ilb-forwarding-rule-hub2-name
  region                = var.region1
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-hub2.id
  all_ports             = true
  ip_address            = "${var.subnet1-vpc-hub2-first-three-octets}${var.ilb-forwarding-rule-address}"
  network               = google_compute_network.vpc-hub2.name
  subnetwork            = google_compute_subnetwork.subnet1-vpc-hub2.name
}


resource "google_compute_route" "default-route-to-ilb-hub2" {
  name         = var.default-route-to-ilb-hub2-name
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc-hub2.name
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-hub2.ip_address
  priority     = 500
}


resource "google_network_connectivity_spoke" "nccspk_vpc_hub1" {
  name        = "nccspk-vpc-hub1"
  location    = "global"
  description = "ncc spoke vpc-hub1"
  hub         = google_network_connectivity_hub.ncchub.id
  
  linked_vpc_network {
    uri           = google_compute_network.vpc-hub1.self_link
    exclude_export_ranges = []
  }
}


/*
module "google_compute_route" {
  source       = "../../modules/routes" #adding local path
  project_id   = var.project_id # Replace this with your project ID in quotes
#  network_name = "default"
  for_each     = toset(concat(local.spoke_vpcs, local.other_vpcs))
  network_name = each.key

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = ["egress-inet"]
      next_hop_internet = true
    }
  ]
}
*/

resource "google_compute_route" "spoke_routes_to_ilb" {
  for_each     = toset(local.spoke_vpcs)
  name         = "${each.key}-default-route-to-ilb-in-hub1"
  dest_range   = "0.0.0.0/0"
  network      = each.key
  next_hop_ilb = google_compute_forwarding_rule.ilb-forwarding-rule-hub1.ip_address
  priority     = 100
}