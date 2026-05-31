locals {
  boolorgpols = ["sql.restrictAuthorizedNetworks", "compute.requireShieldedVm", "compute.disableSerialPortAccess"]
#  boolorgpols = []
  listorgpols = ["compute.restrictVpnPeerIPs", "compute.vmCanIpForward", "compute.vmExternalIpAccess", "compute.trustedImageProjects"]
#  listorgpols = []
#}

#locals {
  boolorgpols_map = { for index, boolorgpol in local.boolorgpols : "${index}" => boolorgpol }
  listorgpols_map = { for index, listorgpol in local.listorgpols : "${index}" => listorgpol }
}

module "bool_org_policy" {
  source      = "terraform-google-modules/org-policy/google"
  for_each    = local.boolorgpols_map
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "constraints/${each.value}"
  policy_type = "boolean"
  enforce     = false
}

# allow all / deny all type org policies
module "list_org_policy" {
  source      = "terraform-google-modules/org-policy/google"
  for_each    = local.listorgpols_map
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "constraints/${each.value}"
  policy_type = "list"
  enforce     = false
}

/*
module "orgpolicy" {
  source      = "github.com/kurtradecki/gcp-orgpolicies-demo"
  project_id  = "project_id"
  boolorgpols = local.boolorgpols   # boolean constraints that are enforced / not enforced
  listorgpols = local.listorgpols   # list constraints that are allow all / deny all / custom
}
*/

/*
resource "google_project_organization_policy" "sql_restrict_authorized_networks" {
  project    = var.project_id
  constraint = "sql.restrictAuthorizedNetworks"

  restore_policy {
    default = true
  }
}


resource "google_project_organization_policy" "compute_requireShieldedVm" {
  project    = var.project_id
  constraint = "constraints/compute.requireShieldedVm"

  restore_policy {
    default = false
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


resource "google_project_organization_policy" "compute_vmCanIpForward" {
  project    = var.project_id
  constraint = "constraints/compute.vmCanIpForward"

  list_policy {
    allow {
      all = true
    }
  }
}
*/