# Networking Module for GCP
# Supports both public (with Cloud Armor + External LB) and private (with PSC) configurations
# Built on top of terraform-google-modules/network/google

# Get current project ID from provider
data "google_client_config" "default" {}

# Get current project information
data "google_project" "current" {}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id = data.google_project.current.project_id

  network_name = var.network_name
  routing_mode = var.routing_mode

  subnets = var.subnets

  secondary_ranges = var.secondary_ranges

  routes = var.routes

  firewall_rules = var.firewall_rules

  delete_default_internet_gateway_routes = var.delete_default_routes
}

# Cloud NAT (conditional - for private subnets)
module "cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 5.0"
  count   = var.enable_nat ? 1 : 0

  project_id = data.google_project.current.project_id
  region     = var.nat_region
  router     = var.nat_router_name != null ? var.nat_router_name : "${var.network_name}-router"
  name       = "${var.network_name}-nat"

  create_router = var.create_nat_router
  network       = var.create_nat_router ? module.vpc.network_name : ""

  source_subnetwork_ip_ranges_to_nat = var.nat_ip_ranges_to_nat

  log_config_enable = true
  log_config_filter = "ERRORS_ONLY"
}

# External Load Balancer components (conditional for public VPC)
resource "google_compute_global_address" "external_ip" {
  count = var.create_external_lb ? 1 : 0
  name  = "${var.network_name}-external-ip"
}

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  count = var.create_external_lb && var.ssl_domains != null ? 1 : 0
  name  = "${var.network_name}-ssl-cert"

  managed {
    domains = var.ssl_domains
  }
}

# Cloud Armor Security Policy (for public VPC)
resource "google_compute_security_policy" "cloud_armor" {
  count = var.create_cloud_armor ? 1 : 0
  name  = "${var.network_name}-security-policy"
  project = data.google_project.current.project_id

  # Default rule
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }

  # Rate limiting rule
  dynamic "rule" {
    for_each = var.rate_limit_threshold != null ? [1] : []
    content {
      action   = "rate_based_ban"
      priority = "1000"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = ["*"]
        }
      }
      rate_limit_options {
        conform_action = "allow"
        exceed_action  = "deny(429)"
        enforce_on_key = "IP"
        ban_duration_sec = var.rate_limit_ban_duration_sec
        rate_limit_threshold {
          count        = var.rate_limit_threshold
          interval_sec = 60
        }
      }
      description = "Rate limiting rule"
    }
  }
}

# Private Service Connect components (for internal VPC)
resource "google_compute_service_attachment" "psc_attachment" {
  count  = var.create_psc_attachment ? 1 : 0
  name   = "${var.network_name}-psc-attachment"
  region = var.psc_region

  target_service        = var.psc_target_service
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = var.psc_nat_subnets
  enable_proxy_protocol = false
}

# Private Service Connect endpoint IP address (for connecting from public VPC)
resource "google_compute_address" "psc_endpoint_ip" {
  count        = var.create_psc_endpoint ? 1 : 0
  name         = "${var.network_name}-psc-endpoint-ip"
  region       = var.psc_region
  subnetwork   = "projects/${data.google_project.current.project_id}/regions/${var.psc_region}/subnetworks/${var.psc_subnet}"
  address_type = "INTERNAL"
  address      = var.psc_endpoint_ip
}

# Private Service Connect endpoint (for connecting from public VPC)
resource "google_compute_forwarding_rule" "psc_endpoint" {
  count  = var.create_psc_endpoint ? 1 : 0
  name   = "${var.network_name}-psc-endpoint"
  region = var.psc_region

  target      = var.psc_service_attachment
  network     = module.vpc.network_name
  subnetwork  = "projects/${data.google_project.current.project_id}/regions/${var.psc_region}/subnetworks/${var.psc_subnet}"
  ip_address  = var.create_psc_endpoint ? google_compute_address.psc_endpoint_ip[0].address : null
}