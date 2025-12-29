variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "ssl_domains" {
  description = "List of domains for SSL certificate"
  type        = list(string)
  default     = []
}