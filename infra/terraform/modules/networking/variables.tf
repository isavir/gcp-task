variable "project_id" {
  description = "The project ID to host the network in"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
}

variable "subnets" {
  description = "The list of subnets being created"
  type = list(object({
    subnet_name               = string
    subnet_ip                 = string
    subnet_region             = string
    subnet_private_access     = optional(string, "false")
    subnet_private_ipv6_access = optional(string)
    subnet_flow_logs          = optional(string, "false")
    description               = optional(string)
    purpose                   = optional(string)
    role                      = optional(string)
    stack_type                = optional(string)
    ipv6_access_type          = optional(string)
  }))
  default = []
}

variable "secondary_ranges" {
  description = "Secondary ranges that will be used in some of the subnets"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {}
}

variable "routes" {
  description = "List of routes being created in this VPC"
  type = list(object({
    name                   = string
    description            = optional(string)
    destination_range      = string
    tags                   = optional(string)
    next_hop_gateway       = optional(string)
    next_hop_instance      = optional(string)
    next_hop_instance_zone = optional(string)
    next_hop_ip            = optional(string)
    priority               = optional(number)
  }))
  default = []
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name                    = string
    description             = optional(string, null)
    direction               = optional(string, "INGRESS")
    priority                = optional(number, null)
    ranges                  = optional(list(string), null)
    source_tags             = optional(list(string), null)
    source_service_accounts = optional(list(string), null)
    target_tags             = optional(list(string), null)
    target_service_accounts = optional(list(string), null)
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), null)
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), null)
    })), [])
    log_config = optional(object({
      metadata = string
    }), null)
  }))
  default = []
}

variable "delete_default_routes" {
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  type        = bool
  default     = false
}

# Cloud NAT variables
variable "enable_nat" {
  description = "Whether to enable Cloud NAT"
  type        = bool
  default     = false
}

variable "nat_region" {
  description = "The region where the NAT gateway will be created"
  type        = string
  default     = null
}

variable "nat_router_name" {
  description = "The name of the router for NAT (if null, will create one)"
  type        = string
  default     = null
}

variable "create_nat_router" {
  description = "Whether to create a new router for NAT"
  type        = bool
  default     = true
}

variable "nat_ip_ranges_to_nat" {
  description = "How NAT should be configured per Subnetwork"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
# External Load Balancer variables
variable "create_external_lb" {
  description = "Whether to create external load balancer components"
  type        = bool
  default     = false
}

variable "ssl_domains" {
  description = "List of domains for SSL certificate"
  type        = list(string)
  default     = null
}

# Cloud Armor variables
variable "create_cloud_armor" {
  description = "Whether to create Cloud Armor security policy"
  type        = bool
  default     = false
}

variable "rate_limit_threshold" {
  description = "Rate limit threshold for Cloud Armor (requests per minute)"
  type        = number
  default     = null
}

# Private Service Connect variables
variable "create_psc_attachment" {
  description = "Whether to create PSC service attachment (for internal VPC)"
  type        = bool
  default     = false
}

variable "psc_region" {
  description = "Region for PSC components"
  type        = string
  default     = null
}

variable "psc_target_service" {
  description = "Target service for PSC attachment"
  type        = string
  default     = null
}

variable "psc_nat_subnets" {
  description = "NAT subnets for PSC attachment"
  type        = list(string)
  default     = []
}

variable "create_psc_endpoint" {
  description = "Whether to create PSC endpoint (for connecting from public VPC)"
  type        = bool
  default     = false
}

variable "psc_service_attachment" {
  description = "Service attachment to connect to via PSC"
  type        = string
  default     = null
}

variable "psc_subnet" {
  description = "Subnet for PSC endpoint"
  type        = string
  default     = null
}

variable "psc_endpoint_ip" {
  description = "IP address for PSC endpoint"
  type        = string
  default     = null
}