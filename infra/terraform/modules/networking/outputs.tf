output "network_name" {
  description = "The name of the VPC being created"
  value       = module.vpc.network_name
}

output "network_id" {
  description = "The ID of the VPC being created"
  value       = module.vpc.network_id
}

output "network_self_link" {
  description = "The URI of the VPC being created"
  value       = module.vpc.network_self_link
}

output "subnets_names" {
  description = "The names of the subnets being created"
  value       = module.vpc.subnets_names
}

output "subnets_ids" {
  description = "The IDs of the subnets being created"
  value       = module.vpc.subnets_ids
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created"
  value       = module.vpc.subnets_ips
}

output "subnets_self_links" {
  description = "The self-links of subnets being created"
  value       = module.vpc.subnets_self_links
}

output "subnets_regions" {
  description = "The region where the subnets will be created"
  value       = module.vpc.subnets_regions
}

output "subnets_private_access" {
  description = "Whether the subnets will have access to Google API's without a public IP"
  value       = module.vpc.subnets_private_access
}

output "subnets_flow_logs" {
  description = "Whether the subnets will have VPC flow logs enabled"
  value       = module.vpc.subnets_flow_logs
}

output "subnets_secondary_ranges" {
  description = "The secondary ranges associated with these subnets"
  value       = module.vpc.subnets_secondary_ranges
}

output "route_names" {
  description = "The route names associated with this VPC"
  value       = module.vpc.route_names
}

# Cloud NAT outputs
output "nat_name" {
  description = "Name of the Cloud NAT gateway"
  value       = var.enable_nat ? module.cloud_nat[0].name : null
}

output "router_name" {
  description = "Name of the router created for NAT"
  value       = var.enable_nat ? module.cloud_nat[0].router_name : null
}

# External Load Balancer outputs
output "external_ip" {
  description = "The external IP address for load balancer"
  value       = var.create_external_lb ? google_compute_global_address.external_ip[0].address : null
}

output "ssl_certificate_id" {
  description = "The ID of the managed SSL certificate"
  value       = var.create_external_lb && var.ssl_domains != null ? google_compute_managed_ssl_certificate.ssl_cert[0].id : null
}

# Cloud Armor outputs
output "cloud_armor_policy_id" {
  description = "The ID of the Cloud Armor security policy"
  value       = var.create_cloud_armor ? google_compute_security_policy.cloud_armor[0].id : null
}

# Private Service Connect outputs
output "psc_attachment_id" {
  description = "The ID of the PSC service attachment"
  value       = var.create_psc_attachment ? google_compute_service_attachment.psc_attachment[0].id : null
}

output "psc_endpoint_ip" {
  description = "The IP address of the PSC endpoint"
  value       = var.create_psc_endpoint ? google_compute_forwarding_rule.psc_endpoint[0].ip_address : null
}