/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_network" "vpc-hub1" {
  count                           = local.deploy_nva ? 1 : 0
  name                            = "${var.vpc-prefix}nva-ncc-intrnl"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-hub1" {
  count         = local.deploy_nva ? 1 : 0
  name          = "${var.subnet1-prefix}nva-ncc-intrnl"
  ip_cidr_range = "${var.subnet1-vpc-hub1-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub1[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-hub1-spoke1" {
  count                           = local.deploy_nva ? 1 : 0
  name                            = "${var.vpc-prefix}nva-ncc-spoke1"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-hub1-spoke1" {
  count         = local.deploy_nva ? 1 : 0
  name          = "${var.subnet1-prefix}nva-ncc-spoke1"
  ip_cidr_range = "${var.spoke-first-octet}${var.spoke-hub1-second-octet}.1${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub1-spoke1[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-hub1-spoke2" {
  count                           = local.deploy_nva ? 1 : 0
  name                            = "${var.vpc-prefix}nva-ncc-spoke2"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]
}


resource "google_compute_subnetwork" "subnet1-vpc-hub1-spoke2" {
  count         = local.deploy_nva ? 1 : 0
  name          = "${var.subnet1-prefix}nva-ncc-spoke2"
  ip_cidr_range = "${var.spoke-first-octet}${var.spoke-hub1-second-octet}.2${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub1-spoke2[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-hub2" {
  count                           = local.deploy_hub2 ? 1 : 0
  name                            = "${var.vpc-prefix}nva-prng-hub"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-hub2" {
  count         = local.deploy_hub2 ? 1 : 0
  name          = "${var.subnet1-prefix}nva-prng-hub"
  ip_cidr_range = "${var.subnet1-vpc-hub2-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub2[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-hub2-spoke1" {
  count                           = local.deploy_hub2 ? 1 : 0
  name                            = "${var.vpc-prefix}nva-prng-spoke1"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-hub2-spoke1" {
  count         = local.deploy_hub2 ? 1 : 0
  name          = "${var.subnet1-prefix}nva-prng-spoke1"
  ip_cidr_range = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.1${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub2-spoke1[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-hub2-spoke2" {
  count                           = local.deploy_hub2 ? 1 : 0
  name                            = "${var.vpc-prefix}nva-prng-spoke2"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-hub2-spoke2" {
  count         = local.deploy_hub2 ? 1 : 0
  name          = "${var.subnet1-prefix}nva-prng-spoke2"
  ip_cidr_range = "${var.spoke-first-octet}${var.spoke-hub2-second-octet}.2${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-hub2-spoke2[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-transit" {
  name                            = "${var.vpc-prefix}extrnl"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-transit" {
  name          = "${var.subnet1-prefix}extrnl"
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
  count                   = local.deploy_nva ? 1 : 0
  name                    = "${var.vpc-prefix}nva-extrnl-inet"
  auto_create_subnetworks = false
  mtu                     = 1460
  routing_mode            = "GLOBAL"
  depends_on              = [time_sleep.wait_timer]

}


resource "google_compute_subnetwork" "subnet1-vpc-untrusted" {
  count         = local.deploy_nva ? 1 : 0
  name          = "${var.subnet1-prefix}nva-extrnl-inet"
  ip_cidr_range = "${var.subnet1-vpc-untrusted-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-untrusted[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_network" "vpc-management" {
  count                           = local.deploy_nva ? 1 : 0
  name                            = "${var.vpc-prefix}nva-mgmt"
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [time_sleep.wait_timer]
}


resource "google_compute_subnetwork" "subnet1-vpc-management" {
  count         = local.deploy_nva ? 1 : 0
  name          = "${var.subnet1-prefix}nva-mgmt"
  ip_cidr_range = "${var.subnet1-vpc-management-first-three-octets}${var.last-octet-and-mask}"
  region        = var.region1
  network       = google_compute_network.vpc-management[0].id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
