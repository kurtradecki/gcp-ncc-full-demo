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

locals {
  temp-name-variation = "2"
}


resource "google_compute_instance" "nva1" {
  count          = local.deploy_nva ? 1 : 0
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
    subnetwork = google_compute_subnetwork.subnet1-vpc-untrusted[0].self_link
    network_ip = "${var.subnet1-vpc-untrusted-first-three-octets}${var.nva1-int-address}"
    access_config {
      # ephemeral public IP
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-management[0].self_link
    network_ip = "${var.subnet1-vpc-management-first-three-octets}${var.nva1-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-transit.self_link
    network_ip = "${var.subnet1-vpc-transit-first-three-octets}${var.nva1-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1[0].self_link
    network_ip = "${var.subnet1-vpc-hub1-first-three-octets}${var.nva1-int-address}"
  }
  dynamic "network_interface" {
    for_each = local.deploy_hub2 ? [1] : []
    content {
      subnetwork = google_compute_subnetwork.subnet1-vpc-hub2[0].self_link
      network_ip = "${var.subnet1-vpc-hub2-first-three-octets}${var.nva1-int-address}"
    }
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
%{ if local.deploy_hub2 ~}
vrf definition ${var.vrf-hub2-name}
rd ${var.vrf-hub2-route-descriptor}
address-family ipv4
exit-address-family
!
%{ endif ~}
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
%{ if local.deploy_hub2 ~}
interface GigabitEthernet5
description hub 2
vrf forwarding ${var.vrf-hub2-name}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.nva1-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
ip nat inside
no shut
!
%{ endif ~}
### Global Table Routes
ip route 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1
!
# route for DCs and NCC VPC Spokes
ip route 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# route for transit - needed since transit is in a VRF
ip route ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for hub 2 - needed since hub 2 is in a VRF
ip route ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
!
### VRF management routes
# in this script, path to management interfaces is through the transit VPC peering to management VPC, thus no path to management is configured in these Network Virtual Appliances, so routing not added here
!
!
### VRF transit routes
# no default route to global table
!
# route for DCs and NCC VPC Spokes
ip route vrf ${var.vrf-transit-name} 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-transit-name} ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-transit-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
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
# route for DCs and NCC VPC Spokes
ip route vrf ${var.vrf-hub1-name} 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub1-name} ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub1-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# route for transit - needed since transit is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
%{ if local.deploy_hub2 ~}
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
!
%{ if local.deploy_hub2 ~}
### VRF hub 2 routes
# default route to global table
ip route vrf ${var.vrf-hub2-name} 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1 global
!
# route for DCs and NCC VPC Spokes
ip route vrf ${var.vrf-hub2-name} 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub2-name} ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
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
%{ endif ~}
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub1-name} overload
%{ if local.deploy_hub2 ~}
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub2-name} overload
%{ endif ~}
ip access-list standard NAT_ACL
10 permit 10.0.0.0 0.255.255.255
20 permit 10.2.0.0 0.0.255.255
30 permit 172.16.0.0 0.0.255.255
EOS
    serial-port-enable = true
  }
}



resource "google_compute_instance" "nva2" {
  count          = local.deploy_nva ? 1 : 0
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
    subnetwork = google_compute_subnetwork.subnet1-vpc-untrusted[0].self_link
    network_ip = "${var.subnet1-vpc-untrusted-first-three-octets}${var.nva2-int-address}"
    access_config {
      # ephemeral public IP
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-management[0].self_link
    network_ip = "${var.subnet1-vpc-management-first-three-octets}${var.nva2-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-transit.self_link
    network_ip = "${var.subnet1-vpc-transit-first-three-octets}${var.nva2-int-address}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1-vpc-hub1[0].self_link
    network_ip = "${var.subnet1-vpc-hub1-first-three-octets}${var.nva2-int-address}"
  }
  dynamic "network_interface" {
    for_each = local.deploy_hub2 ? [1] : []
    content {
      subnetwork = google_compute_subnetwork.subnet1-vpc-hub2[0].self_link
      network_ip = "${var.subnet1-vpc-hub2-first-three-octets}${var.nva2-int-address}"
    }
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
%{ if local.deploy_hub2 ~}
vrf definition ${var.vrf-hub2-name}
rd ${var.vrf-hub2-route-descriptor}
address-family ipv4
exit-address-family
!
%{ endif ~}
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
%{ if local.deploy_hub2 ~}
interface GigabitEthernet5
description hub 2
vrf forwarding ${var.vrf-hub2-name}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.nva2-int-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")}
ip address ${var.subnet1-vpc-hub2-first-three-octets}${var.ilb-forwarding-rule-address} ${cidrnetmask("1.1.1${var.last-octet-and-mask}")} secondary
ip nat inside
no shut
!
%{ endif ~}
### Global Table Routes
ip route 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1
!
# route for DCs and NCC VPC Spokes
ip route 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# route for transit - needed since transit is in a VRF
ip route ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for hub 2 - needed since hub 2 is in a VRF
ip route ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
!
### VRF management routes
# in this script, path to management interfaces is through the transit VPC peering to management VPC, thus no path to management is configured in these Network Virtual Appliances, so routing not added here
!
!
### VRF transit routes
# no default route to global table
!
# route for DCs and NCC VPC Spokes
ip route vrf ${var.vrf-transit-name} 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-transit-name} ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-transit-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# no route added for management since it will only be reachable through management VPC
!
# route for hub 1 - needed since hub 1 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub1-first-three-octets}.0 255.255.255.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-transit-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
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
# route for DCs and NCC VPC Spokes
ip route vrf ${var.vrf-hub1-name} 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub1-name} ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
%{ if local.deploy_hub2 ~}
# route for all spokes in hub 2 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub1-name} ${var.spoke-first-octet}${var.spoke-hub2-second-octet}.0.0 255.255.0.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# route for transit - needed since transit is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-transit-first-three-octets}.0 255.255.255.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# no route added for management since it will only be reachable through management VPC
!
%{ if local.deploy_hub2 ~}
# route for hub 2 - needed since hub 2 is in a VRF
ip route vrf ${var.vrf-hub1-name} ${var.subnet1-vpc-hub2-first-three-octets}.0 255.255.255.0 GigabitEthernet5 ${var.subnet1-vpc-hub2-first-three-octets}.1
!
%{ endif ~}
# local VRF route for load balancer health check range 1 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-1, 0)} ${cidrnetmask(var.health-check-source-ip-range-1)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
# local VRF route for load balancer health check range 2 return path traffic
ip route vrf ${var.vrf-hub1-name} ${cidrhost(var.health-check-source-ip-range-2, 0)} ${cidrnetmask(var.health-check-source-ip-range-2)} GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
!
!
%{ if local.deploy_hub2 ~}
### VRF hub 2 routes
# default route to global table
ip route vrf ${var.vrf-hub2-name} 0.0.0.0 0.0.0.0 GigabitEthernet1 ${var.subnet1-vpc-untrusted-first-three-octets}.1 global
!
# route for DCs and NCC VPC Spokes
ip route vrf ${var.vrf-hub2-name} 10.0.0.0 255.0.0.0 GigabitEthernet3 ${var.subnet1-vpc-transit-first-three-octets}.1
!
# route for all spokes in hub 1 - second octet in address represents the hub where the spokes connect
ip route vrf ${var.vrf-hub2-name} ${var.spoke-first-octet}${var.spoke-hub1-second-octet}.0.0 255.255.0.0 GigabitEthernet4 ${var.subnet1-vpc-hub1-first-three-octets}.1
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
%{ endif ~}
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub1-name} overload
%{ if local.deploy_hub2 ~}
ip nat inside source list NAT_ACL interface GigabitEthernet1 vrf ${var.vrf-hub2-name} overload
%{ endif ~}
ip access-list standard NAT_ACL
10 permit 10.0.0.0 0.255.255.255
20 permit 10.2.0.0 0.0.255.255
30 permit 172.16.0.0 0.0.255.255
EOS
    serial-port-enable = true
  }
}
