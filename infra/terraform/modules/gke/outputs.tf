output "cluster_id" {
  description = "Cluster ID"
  value       = module.gke.cluster_id
}

output "name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "type" {
  description = "Cluster type (regional / zonal)"
  value       = module.gke.type
}

output "location" {
  description = "Cluster location (region if regional cluster, zone if zonal cluster)"
  value       = module.gke.location
}

output "region" {
  description = "Cluster region"
  value       = module.gke.region
}

output "zones" {
  description = "List of zones in which the cluster resides"
  value       = module.gke.zones
}

output "endpoint" {
  description = "Cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "min_master_version" {
  description = "Minimum master kubernetes version"
  value       = module.gke.min_master_version
}

output "logging_service" {
  description = "Logging service used"
  value       = module.gke.logging_service
}

output "monitoring_service" {
  description = "Monitoring service used"
  value       = module.gke.monitoring_service
}

output "master_authorized_networks_config" {
  description = "Networks from which access to master is permitted"
  value       = module.gke.master_authorized_networks_config
}

output "master_version" {
  description = "Current master kubernetes version"
  value       = module.gke.master_version
}

output "ca_certificate" {
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "network_policy_enabled" {
  description = "Whether network policy enabled"
  value       = module.gke.network_policy_enabled
}

output "http_load_balancing_enabled" {
  description = "Whether http load balancing enabled"
  value       = module.gke.http_load_balancing_enabled
}

output "horizontal_pod_autoscaling_enabled" {
  description = "Whether horizontal pod autoscaling enabled"
  value       = module.gke.horizontal_pod_autoscaling_enabled
}

output "vertical_pod_autoscaling_enabled" {
  description = "Whether vertical pod autoscaling enabled"
  value       = module.gke.vertical_pod_autoscaling_enabled
}

# Node pools
output "node_pools_names" {
  description = "List of node pools names"
  value       = module.gke.node_pools_names
}

output "node_pools_versions" {
  description = "Node pool versions by node pool name"
  value       = module.gke.node_pools_versions
}

# Service account
output "service_account" {
  description = "The service account to default running nodes as if not overridden in `node_pools`"
  value       = module.gke.service_account
}

# Workload Identity
output "identity_namespace" {
  description = "Workload Identity namespace"
  value       = module.gke.identity_namespace
}

output "workload_identity_service_account_email" {
  description = "Email of the Workload Identity service account"
  value       = var.create_workload_identity_sa ? google_service_account.gke_workload_identity[0].email : null
}

output "workload_identity_service_account_name" {
  description = "Name of the Workload Identity service account"
  value       = var.create_workload_identity_sa ? google_service_account.gke_workload_identity[0].name : null
}

# Private cluster specific outputs
output "private_endpoint" {
  description = "Whether the master's internal IP address is used as the cluster endpoint"
  value       = var.enable_private_endpoint
}

output "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation used for the hosted master network"
  value       = var.master_ipv4_cidr_block
}