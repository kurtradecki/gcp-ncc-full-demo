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
  vpcs = ["vpc1", "vpc2", "vpc3", "vpc4", "vpc-routing", "vpcdc", "vpc-routing2", "vpcdc2"]
}

resource "google_compute_network" "vpc" {
  for_each                = toset(local.vpcs)
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
    uri           = google_compute_network.vpc["vpc1"].self_link
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
  region1 = var.region1
  vpc1name  = google_compute_network.vpc["vpc-routing"].name
  vpc2name  = google_compute_network.vpc["vpcdc"].name
  vpc1_cldrouter_custom = {
      all_subnets = true
      ip_ranges   = {
        "10.0.0.0/8" = "All 10s"
      }
    }
  vpc2_cldrouter_custom = {
      all_subnets = true
      ip_ranges   = {}
    }
  depends_on = [ google_compute_network.vpc ]
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
  depends_on = [ module.vpn-1 ]
}


module "vpn-2" {
  source     = "github.com/kurtradecki/gcp-vpn-vpc-demo"
  project-id = var.project_id
  region1 = var.region1
  vpc1name  = google_compute_network.vpc["vpc-routing2"].name
  vpc2name  = google_compute_network.vpc["vpcdc2"].name
  vpc1_cldrouter_custom = {
      all_subnets = true
      ip_ranges   = {
        "10.0.0.0/8" = "All 10s"
      }
    }
  vpc2_cldrouter_custom = {
      all_subnets = true
      ip_ranges   = {}
    }
  depends_on = [ google_compute_network.vpc ]
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
  depends_on = [ module.vpn-2 ]
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
    "testvm-region1-vpc1" = { subnet = google_compute_subnetwork.subnet11.id, ip = "10.11.11.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc1" = { subnet = google_compute_subnetwork.subnet12.id, ip = "10.12.12.2", zone = "${var.region2}-a" }
    "testvm-region1-vpc2" = { subnet = google_compute_subnetwork.subnet21.id, ip = "10.21.21.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc2" = { subnet = google_compute_subnetwork.subnet22.id, ip = "10.22.22.2", zone = "${var.region2}-a" }
    "testvm-region1-vpc3" = { subnet = google_compute_subnetwork.subnet31.id, ip = "10.31.31.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc3" = { subnet = google_compute_subnetwork.subnet32.id, ip = "10.32.32.2", zone = "${var.region2}-a" }
    "testvm-region1-vpc4" = { subnet = google_compute_subnetwork.subnet41.id, ip = "10.41.41.2", zone = "${var.region1}-a" }
    "testvm-region2-vpc4" = { subnet = google_compute_subnetwork.subnet42.id, ip = "10.42.42.2", zone = "${var.region2}-a" }
    "testvm-region1-vpcdc" = { subnet = google_compute_subnetwork.subnet110.id, ip = "10.110.110.2", zone = "${var.region1}-a" }
    "testvm-region2-vpcdc" = { subnet = google_compute_subnetwork.subnet120.id, ip = "10.120.120.2", zone = "${var.region2}-a" }
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
  depends_on = [ google_compute_router.nat_routers, google_compute_router_nat.nats ]
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
