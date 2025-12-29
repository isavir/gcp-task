variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "zones" {
  description = "The zones to host the cluster in (optional if regional cluster is desired)"
  type        = list(string)
  default     = []
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
  type        = string
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
  type        = string
}

# Private cluster configuration
variable "enable_private_endpoint" {
  description = "Whether the master's internal IP address is used as the cluster endpoint"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# Security features
variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes features on all nodes in this cluster"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy addon"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable BinAuthZ Admission controller"
  type        = bool
  default     = false
}

variable "enable_pod_security_policy" {
  description = "Enable PodSecurityPolicy controller"
  type        = bool
  default     = false
}

# Cluster features
variable "enable_hpa" {
  description = "Enable horizontal pod autoscaling addon"
  type        = bool
  default     = true
}

variable "enable_vpa" {
  description = "Enable vertical pod autoscaling addon"
  type        = bool
  default     = false
}

variable "enable_http_load_balancing" {
  description = "Enable httpload balancer addon"
  type        = bool
  default     = true
}

# Logging and monitoring
variable "logging_service" {
  description = "The logging service that the cluster should write logs to"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "The monitoring service that the cluster should write metrics to"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

# Release channel
variable "release_channel" {
  description = "The release channel of this cluster"
  type        = string
  default     = "STABLE"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE", "UNSPECIFIED"], var.release_channel)
    error_message = "Release channel must be one of: RAPID, REGULAR, STABLE, UNSPECIFIED."
  }
}

# Maintenance
variable "maintenance_start_time" {
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  type        = string
  default     = "05:00"
}

# Workload Identity
variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

# Node pools configuration
variable "node_pools" {
  description = "List of maps containing node pools"
  type = list(object({
    name                      = string
    machine_type             = optional(string, "e2-medium")
    node_locations           = optional(string, "")
    min_count                = optional(number, 1)
    max_count                = optional(number, 100)
    local_ssd_count          = optional(number, 0)
    spot                     = optional(bool, false)
    disk_size_gb             = optional(number, 100)
    disk_type                = optional(string, "pd-standard")
    image_type               = optional(string, "COS_CONTAINERD")
    enable_gcfs              = optional(bool, false)
    enable_gvnic             = optional(bool, false)
    auto_repair              = optional(bool, true)
    auto_upgrade             = optional(bool, true)
    preemptible              = optional(bool, false)
    initial_node_count       = optional(number, 0)
    accelerator_count        = optional(number, 0)
    accelerator_type         = optional(string, "")
    gpu_partition_size       = optional(string, "")
    max_pods_per_node        = optional(number, 110)
    enable_secure_boot       = optional(bool, false)
    enable_integrity_monitoring = optional(bool, true)
  }))
  default = [
    {
      name         = "default-node-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 3
      disk_size_gb = 100
      disk_type    = "pd-standard"
      image_type   = "COS_CONTAINERD"
      auto_repair  = true
      auto_upgrade = true
      preemptible  = false
    }
  ]
}

variable "node_pools_oauth_scopes" {
  description = "Map of lists containing node oauth scopes by node-pool name"
  type        = map(list(string))
  default = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }
}

variable "node_pools_labels" {
  description = "Map of maps containing node labels by node-pool name"
  type        = map(map(string))
  default = {
    all = {}
  }
}

variable "node_pools_metadata" {
  description = "Map of maps containing node metadata by node-pool name"
  type        = map(map(string))
  default = {
    all = {
      disable-legacy-endpoints = "true"
    }
  }
}

variable "node_pools_taints" {
  description = "Map of lists containing node taints by node-pool name"
  type        = map(list(object({
    key    = string
    value  = string
    effect = string
  })))
  default = {
    all = []
  }
}

variable "node_pools_tags" {
  description = "Map of lists containing node network tags by node-pool name"
  type        = map(list(string))
  default = {
    all = []
  }
}

# Resource labels
variable "cluster_resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  type        = map(string)
  default     = {}
}

# Additional firewall rules
variable "create_webhook_firewall" {
  description = "Create firewall rule for webhooks"
  type        = bool
  default     = true
}

# Workload Identity Service Account
variable "create_workload_identity_sa" {
  description = "Create a service account for Workload Identity"
  type        = bool
  default     = false
}

variable "workload_identity_namespace" {
  description = "Kubernetes namespace for Workload Identity"
  type        = string
  default     = "default"
}

variable "workload_identity_ksa_name" {
  description = "Kubernetes service account name for Workload Identity"
  type        = string
  default     = "workload-identity-sa"
}

variable "workload_identity_roles" {
  description = "List of IAM roles to assign to the Workload Identity service account"
  type        = list(string)
  default     = []
}