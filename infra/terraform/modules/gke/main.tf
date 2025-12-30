# GKE Module for Private VPC Deployment
# Built on top of terraform-google-modules/kubernetes-engine/google

# Get current project ID from provider
data "google_client_config" "default" {}

# Get current project information
data "google_project" "current" {}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 31.0"

  project_id = data.google_project.current.project_id
  name       = var.cluster_name
  region     = var.region
  zones      = var.zones

  network           = var.network
  subnetwork        = var.subnetwork
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  # Private cluster configuration
  enable_private_endpoint = var.enable_private_endpoint
  enable_private_nodes    = true
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block

  # Master authorized networks
  master_authorized_networks = var.master_authorized_networks

  # Networking
  enable_shielded_nodes      = var.enable_shielded_nodes
  network_policy             = var.enable_network_policy
  horizontal_pod_autoscaling = var.enable_hpa
  http_load_balancing        = var.enable_http_load_balancing

  # Security
  enable_binary_authorization = var.enable_binary_authorization

  # Logging and monitoring
  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  # Cluster features
  remove_default_node_pool = true
  initial_node_count       = 1

  # Release channel
  release_channel = var.release_channel

  # Maintenance window
  maintenance_start_time = var.maintenance_start_time

  # Workload Identity
  identity_namespace = var.enable_workload_identity ? "${data.google_project.current.project_id}.svc.id.goog" : null

  # Node pools
  node_pools = var.node_pools

  node_pools_oauth_scopes = var.node_pools_oauth_scopes

  node_pools_labels = var.node_pools_labels

  node_pools_metadata = var.node_pools_metadata

  node_pools_taints = var.node_pools_taints

  node_pools_tags = var.node_pools_tags

  # Resource labels
  cluster_resource_labels = var.cluster_resource_labels
}
# Additional firewall rules for GKE
resource "google_compute_firewall" "gke_webhook_firewall" {
  count   = var.create_webhook_firewall ? 1 : 0
  name    = "${var.cluster_name}-webhook-firewall"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["8443", "9443", "15017"]
  }

  source_ranges = [var.master_ipv4_cidr_block]
  target_tags   = ["gke-${var.cluster_name}"]

  description = "Allow GKE master to access webhook pods"
}

# Service Account for Workload Identity (optional)
resource "google_service_account" "gke_workload_identity" {
  count        = var.create_workload_identity_sa ? 1 : 0
  account_id   = "${var.cluster_name}-wi-sa"
  display_name = "Workload Identity SA for ${var.cluster_name}"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  count              = var.create_workload_identity_sa ? 1 : 0
  service_account_id = google_service_account.gke_workload_identity[0].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_project.current.project_id}.svc.id.goog[${var.workload_identity_namespace}/${var.workload_identity_ksa_name}]"
  ]
}

# IAM roles for the Workload Identity service account
resource "google_project_iam_member" "workload_identity_roles" {
  for_each = var.create_workload_identity_sa ? toset(var.workload_identity_roles) : []

  project = data.google_project.current.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_workload_identity[0].email}"
}