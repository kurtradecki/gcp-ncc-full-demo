variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region1" {
  description = "Primary region for resources"
  type        = string
  default     = "us-central1"
}

variable "region2" {
  description = "Secondary region for resources"
  type        = string
  default     = "us-east1"
}

variable "route-between-routing-vpcs" {
  description = "VPC peering connection to allow routing between routing VPCs"
  type        = bool
  default     = true
}