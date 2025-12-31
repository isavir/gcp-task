# Production Environment
# Public VPC with Cloud Armor + External LB and Private VPC with GKE + PSC

terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7"
    }
  }
  backend "gcs" {
    bucket = "tfstate-bucket-3a12db2b"
    prefix = "/prod/terraform.tfstate"
  }
}

provider "google" {
  region = var.region
  # Project will be read from GOOGLE_PROJECT environment variable
  # or from gcloud default project configuration
}

# Get current project ID from provider
data "google_client_config" "default" {}

# Get current project information
data "google_project" "current" {}

# Public VPC with Cloud Armor and External Load Balancer
module "public_vpc" {
  source = "../../modules/networking"

  network_name = "prod-public-vpc"

  subnets = [
    {
      subnet_name           = "public-subnet-${var.region}"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = var.region
      subnet_private_access = "false"
    }
  ]

  firewall_rules = [
    {
      name      = "allow-http-https"
      direction = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]
      ranges = ["0.0.0.0/0"]
    },
    {
      name      = "allow-health-checks"
      direction = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]
      ranges      = ["130.211.0.0/22", "35.191.0.0/16"]
      target_tags = ["load-balancer"]
    }
  ]

  # External Load Balancer
  create_external_lb = true
  ssl_domains        = var.ssl_domains

  # Cloud Armor (basic rate limiting for free tier)
  create_cloud_armor   = true
  rate_limit_threshold = 100 # Reduced threshold

  # PSC endpoint to connect to private VPC
  create_psc_endpoint    = true
  psc_region             = var.region
  psc_service_attachment = google_compute_service_attachment.psc_attachment.self_link
  psc_subnet             = "public-subnet-${var.region}"
  psc_endpoint_ip        = "10.0.1.200"
}

# Private VPC with GKE and Private Service Connect
module "private_vpc" {
  source = "../../modules/networking"

  network_name = "prod-private-vpc"

  subnets = [
    {
      subnet_name           = "gke-subnet-${var.region}"
      subnet_ip             = "10.1.0.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
    },
    {
      subnet_name           = "psc-nat-subnet-${var.region}"
      subnet_ip             = "10.1.1.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      purpose               = "PRIVATE_SERVICE_CONNECT"
    }
  ]

  secondary_ranges = {
    "gke-subnet-${var.region}" = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "10.2.0.0/16"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "10.3.0.0/16"
      }
    ]
  }

  firewall_rules = [
    {
      name      = "allow-internal-private"
      direction = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
        }
      ]
      ranges = ["10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
    }
  ]

  # Cloud NAT for outbound internet access
  enable_nat = true
  nat_region = var.region

  # Remove default internet gateway for security
  delete_default_routes = false
}

# Create a simple internal load balancer for PSC target
resource "google_compute_forwarding_rule" "psc_target" {
  count                 = 1
  name                  = "psc-target-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  network               = module.private_vpc.network_name
  subnetwork            = "projects/${data.google_project.current.project_id}/regions/${var.region}/subnetworks/gke-subnet-${var.region}"
  ip_address            = "10.1.0.200"
  ip_protocol           = "TCP"
  ports                 = ["80", "443"]
  backend_service       = google_compute_region_backend_service.psc_backend[0].self_link
}

# Create a backend service for the internal load balancer
resource "google_compute_region_backend_service" "psc_backend" {
  count                 = 1
  name                  = "psc-backend-service"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  protocol              = "TCP"

  # We'll add backends later when GKE nodes are available
  health_checks = [google_compute_region_health_check.psc_health[0].self_link]
}

# Create a health check for the backend service
resource "google_compute_region_health_check" "psc_health" {
  count  = 1
  name   = "psc-health-check"
  region = var.region

  tcp_health_check {
    port = 80
  }
}

# Now create the PSC service attachment
resource "google_compute_service_attachment" "psc_attachment" {
  name                  = "prod-private-vpc-psc-attachment"
  region                = var.region
  target_service        = google_compute_forwarding_rule.psc_target[0].self_link
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = ["projects/${data.google_project.current.project_id}/regions/${var.region}/subnetworks/psc-nat-subnet-${var.region}"]
  enable_proxy_protocol = false
}

# Private GKE Cluster
module "gke" {
  source = "../../modules/gke"

  cluster_name = "prod-private-gke"
  region       = var.region

  deletion_protection = false
  
  network    = module.private_vpc.network_name
  subnetwork = "gke-subnet-${var.region}"

  ip_range_pods     = "gke-pods"
  ip_range_services = "gke-services"

  # Private cluster configuration
  enable_private_endpoint = false # Allow access from authorized networks
  master_ipv4_cidr_block  = "172.16.0.0/28"

  master_authorized_networks = [
    {
      cidr_block   = "10.1.0.0/24"
      display_name = "GKE subnet"
    },
    {
      cidr_block   = "10.0.1.0/24"
      display_name = "Public subnet (for management)"
    }
  ]

  # Security features (adjusted for free tier)
  enable_shielded_nodes       = false # Disabled for free tier
  enable_network_policy       = false # Disabled to reduce resource usage
  enable_binary_authorization = false # Disabled for free tier

  # Cluster features (free tier optimized)
  enable_hpa                 = false # Disabled to reduce complexity
  enable_vpa                 = false # Disabled for free tier
  enable_http_load_balancing = true  # Keep enabled for basic functionality

  # Workload Identity (simplified for free tier)
  enable_workload_identity    = true
  create_workload_identity_sa = false # Disabled for free tier
  # workload_identity_namespace = "default"
  # workload_identity_ksa_name  = "workload-identity-sa"
  # workload_identity_roles = [
  #   "roles/storage.objectViewer",
  #   "roles/cloudsql.client",
  #   "roles/secretmanager.secretAccessor"
  # ]

  # Production node pools (Free tier optimized)
  node_pools = [
    {
      name               = "system-pool"
      machine_type       = "e2-small" # Free tier eligible
      min_count          = 1
      max_count          = 2
      disk_size_gb       = 30
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true  # Use preemptible for cost savings
      max_pods_per_node  = 32    # Reduced for smaller nodes
      enable_secure_boot = false # Disabled for free tier
    }
  ]

  node_pools_labels = {
    all = {
      environment = "production"
      team        = "platform"
      managed-by  = "terraform"
      tier        = "free"
    }
    system-pool = {
      pool-type = "system"
    }
  }

  # Removed taints for simplicity in free tier
  node_pools_taints = {}

  cluster_resource_labels = {
    environment = "production"
    team        = "platform"
    cost-center = "engineering"
    managed-by  = "terraform"
  }

  # Maintenance window (Sunday 3 AM UTC)
  maintenance_start_time = "03:00"

  # Stable release channel for production
  release_channel = "STABLE"

  depends_on = [module.private_vpc]
}