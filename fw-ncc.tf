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
    src_ip_ranges = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]
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