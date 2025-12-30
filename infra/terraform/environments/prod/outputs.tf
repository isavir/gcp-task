# Public VPC Outputs
output "public_vpc_name" {
  description = "Name of the public VPC"
  value       = module.public_vpc.network_name
}

output "public_vpc_id" {
  description = "ID of the public VPC"
  value       = module.public_vpc.network_id
}

output "public_subnets" {
  description = "Public subnet information"
  value = {
    names = module.public_vpc.subnets_names
    ids   = module.public_vpc.subnets_ids
    ips   = module.public_vpc.subnets_ips
  }
}

# Private VPC Outputs
output "private_vpc_name" {
  description = "Name of the private VPC"
  value       = module.private_vpc.network_name
}

output "private_vpc_id" {
  description = "ID of the private VPC"
  value       = module.private_vpc.network_id
}

output "private_subnets" {
  description = "Private subnet information"
  value = {
    names = module.private_vpc.subnets_names
    ids   = module.private_vpc.subnets_ids
    ips   = module.private_vpc.subnets_ips
  }
}

# Load Balancer Outputs
output "external_ip" {
  description = "External IP address for the load balancer"
  value       = module.public_vpc.external_ip
}

output "cloud_armor_policy_id" {
  description = "Cloud Armor security policy ID"
  value       = module.public_vpc.cloud_armor_policy_id
}

# GKE Cluster Outputs
output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.name
}

output "gke_cluster_id" {
  description = "ID of the GKE cluster"
  value       = module.gke.cluster_id
}

output "gke_cluster_location" {
  description = "Location of the GKE cluster"
  value       = module.gke.location
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "gke_node_pools" {
  description = "GKE node pool information"
  value = {
    names    = module.gke.node_pools_names
    versions = module.gke.node_pools_versions
  }
}

output "gke_service_account" {
  description = "GKE service account email"
  value       = module.gke.service_account
}

# NAT Gateway Outputs
output "nat_name" {
  description = "NAT gateway name"
  value       = module.private_vpc.nat_name
}

output "nat_router_name" {
  description = "NAT router name"
  value       = module.private_vpc.router_name
}

# Private Service Connect Outputs
output "psc_attachment_id" {
  description = "Private Service Connect attachment ID"
  value       = module.private_vpc.psc_attachment_id
}

output "psc_endpoint_ip" {
  description = "Private Service Connect endpoint IP"
  value       = module.public_vpc.psc_endpoint_ip
}

# Connection Information
output "kubectl_connection_command" {
  description = "Command to connect to the GKE cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${data.google_client_config.default.project}"
}

output "cluster_info" {
  description = "Summary of cluster information"
  value = {
    project_id   = data.google_client_config.default.project
    region       = var.region
    cluster_name = module.gke.name
    cluster_type = module.gke.type
    node_count   = "1-2 (e2-micro, preemptible)"
    external_ip  = module.public_vpc.external_ip
    vpc_setup    = "Public VPC with Cloud Armor + Private VPC with GKE"
  }
}