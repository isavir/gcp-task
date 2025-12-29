# GCP Networking Module

This module creates a VPC network in Google Cloud Platform with support for both public and private configurations. It's built on top of the `terraform-google-modules/network/google` module for reliability and best practices.

## Features

- **VPC Network**: Creates a custom VPC with configurable subnets
- **Cloud NAT**: Optional NAT gateway for private subnet internet access
- **External Load Balancer**: Global IP and SSL certificates for public access
- **Cloud Armor**: Security policies with rate limiting for DDoS protection
- **Private Service Connect**: Service attachment and endpoint for private connectivity

## Usage Examples

### Public VPC with Cloud Armor and External Load Balancer

```hcl
module "public_vpc" {
  source = "./modules/networking"

  project_id   = "my-project"
  network_name = "public-vpc"

  subnets = [
    {
      subnet_name           = "public-subnet"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = "us-central1"
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
    }
  ]

  # External Load Balancer
  create_external_lb = true
  ssl_domains        = ["example.com", "www.example.com"]

  # Cloud Armor
  create_cloud_armor     = true
  rate_limit_threshold   = 100
}
```

### Private VPC with GKE and Private Service Connect

```hcl
module "private_vpc" {
  source = "./modules/networking"

  project_id   = "my-project"
  network_name = "private-vpc"

  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.1.0.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    gke-subnet = [
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

  # Cloud NAT for internet access
  enable_nat = true
  nat_region = "us-central1"

  # Private Service Connect
  create_psc_attachment = true
  psc_region           = "us-central1"
  psc_target_service   = "projects/my-project/regions/us-central1/serviceAttachments/my-service"
  psc_nat_subnets      = ["projects/my-project/regions/us-central1/subnetworks/psc-nat"]

  delete_default_routes = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| google | >= 5.0, < 7 |

## Providers

| Name | Version |
|------|---------|
| google | >= 5.0, < 7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | terraform-google-modules/network/google | ~> 9.0 |
| cloud_nat | terraform-google-modules/cloud-nat/google | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The project ID to host the network in | `string` | n/a | yes |
| network_name | The name of the VPC network | `string` | n/a | yes |
| subnets | The list of subnets being created | `list(object)` | `[]` | no |
| create_external_lb | Whether to create external load balancer components | `bool` | `false` | no |
| create_cloud_armor | Whether to create Cloud Armor security policy | `bool` | `false` | no |
| create_psc_attachment | Whether to create PSC service attachment | `bool` | `false` | no |
| enable_nat | Whether to enable Cloud NAT | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| network_name | The name of the VPC being created |
| network_id | The ID of the VPC being created |
| subnets_names | The names of the subnets being created |
| external_ip | The external IP address for load balancer |
| cloud_armor_policy_id | The ID of the Cloud Armor security policy |