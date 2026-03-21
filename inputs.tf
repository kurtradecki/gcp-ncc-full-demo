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
