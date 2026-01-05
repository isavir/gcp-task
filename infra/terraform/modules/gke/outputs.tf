output "cluster_id" {
  description = "Cluster ID"
  value       = var.create_private_cluster ? module.gke_private[0].cluster_id : module.gke_regular[0].cluster_id
}

output "name" {
  description = "Cluster name"
  value       = var.create_private_cluster ? module.gke_private[0].name : module.gke_regular[0].name
}

output "type" {
  description = "Cluster type (regional / zonal)"
  value       = var.create_private_cluster ? module.gke_private[0].type : module.gke_regular[0].type
}

output "location" {
  description = "Cluster location (region if regional cluster, zone if zonal cluster)"
  value       = var.create_private_cluster ? module.gke_private[0].location : module.gke_regular[0].location
}

output "region" {
  description = "Cluster region"
  value       = var.create_private_cluster ? module.gke_private[0].region : module.gke_regular[0].region
}

output "zones" {
  description = "List of zones in which the cluster resides"
  value       = var.create_private_cluster ? module.gke_private[0].zones : module.gke_regular[0].zones
}

output "endpoint" {
  description = "Cluster endpoint"
  value       = var.create_private_cluster ? module.gke_private[0].endpoint : module.gke_regular[0].endpoint
  sensitive   = true
}

output "min_master_version" {
  description = "Minimum master kubernetes version"
  value       = var.create_private_cluster ? module.gke_private[0].min_master_version : module.gke_regular[0].min_master_version
}

output "logging_service" {
  description = "Logging service used"
  value       = var.create_private_cluster ? module.gke_private[0].logging_service : module.gke_regular[0].logging_service
}

output "monitoring_service" {
  description = "Monitoring service used"
  value       = var.create_private_cluster ? module.gke_private[0].monitoring_service : module.gke_regular[0].monitoring_service
}

output "master_authorized_networks_config" {
  description = "Networks from which access to master is permitted"
  value       = var.create_private_cluster ? module.gke_private[0].master_authorized_networks_config : module.gke_regular[0].master_authorized_networks_config
}

output "master_version" {
  description = "Current master kubernetes version"
  value       = var.create_private_cluster ? module.gke_private[0].master_version : module.gke_regular[0].master_version
}

output "ca_certificate" {
  description = "Cluster ca certificate (base64 encoded)"
  value       = var.create_private_cluster ? module.gke_private[0].ca_certificate : module.gke_regular[0].ca_certificate
  sensitive   = true
}

output "network_policy_enabled" {
  description = "Whether network policy enabled"
  value       = var.create_private_cluster ? module.gke_private[0].network_policy_enabled : module.gke_regular[0].network_policy_enabled
}

output "http_load_balancing_enabled" {
  description = "Whether http load balancing enabled"
  value       = var.create_private_cluster ? module.gke_private[0].http_load_balancing_enabled : module.gke_regular[0].http_load_balancing_enabled
}

output "horizontal_pod_autoscaling_enabled" {
  description = "Whether horizontal pod autoscaling enabled"
  value       = var.create_private_cluster ? module.gke_private[0].horizontal_pod_autoscaling_enabled : module.gke_regular[0].horizontal_pod_autoscaling_enabled
}

# Node pools
output "node_pools_names" {
  description = "List of node pools names"
  value       = var.create_private_cluster ? module.gke_private[0].node_pools_names : module.gke_regular[0].node_pools_names
}

output "node_pools_versions" {
  description = "Node pool versions by node pool name"
  value       = var.create_private_cluster ? module.gke_private[0].node_pools_versions : module.gke_regular[0].node_pools_versions
}

# Service account
output "service_account" {
  description = "The service account to default running nodes as if not overridden in `node_pools`"
  value       = var.create_private_cluster ? module.gke_private[0].service_account : module.gke_regular[0].service_account
}

output "node_service_account_email" {
  description = "Email of the custom node service account"
  value       = var.node_service_account_email != "" ? var.node_service_account_email : google_service_account.gke_node_sa[0].email
}

output "node_service_account_name" {
  description = "Name of the custom node service account"
  value       = var.node_service_account_email != "" ? var.node_service_account_email : google_service_account.gke_node_sa[0].name
}

# Workload Identity
output "identity_namespace" {
  description = "Workload Identity namespace"
  value       = var.create_private_cluster ? module.gke_private[0].identity_namespace : module.gke_regular[0].identity_namespace
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