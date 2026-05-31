# ==========================================
# 4. VPN Tunnels (Routing VPCs to DCs)
# ==========================================

module "vpn-1" {
  source     = "github.com/kurtradecki/gcp-vpn-vpc-demo"
  project-id = var.project_id
  region1    = var.region1
#  vpc1name   = google_compute_network.vpc["vpc-routing"].name
  vpc1name   = var.one_rtg_vpc == true ? google_compute_network.vpc-transit.name : google_compute_network.vpc["vpc-routing"].name
  vpc2name   = google_compute_network.vpc["vpcdc"].name
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
  vpc2name   = google_compute_network.vpc["vpcdc2"].name
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