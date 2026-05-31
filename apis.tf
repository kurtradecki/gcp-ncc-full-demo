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
    "servicenetworking.googleapis.com",
    "networkmanagement.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each           = toset(local.services)
  service            = each.key
  disable_on_destroy = false
}
