# Example demonstrating multi-cloud infrastructure with Terraform
# This file shows how to create VPCs (Virtual Private Clouds) across AWS, GCP, and Azure
# 
# NOTE: This is a demonstration file. Uncomment and configure providers/resources
# based on which cloud platforms you have access to.

# ============================================================================
# Provider Configuration: AWS
# ============================================================================
# AWS Provider - for Amazon Web Services

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# Configure AWS provider
# provider "aws" {
#   region = "us-east-1"
#
#   # Authentication options (choose one):
#   # Option 1: Use AWS credentials file (~/.aws/credentials)
#   # Option 2: Use environment variables
#   #   export AWS_ACCESS_KEY_ID="your-access-key"
#   #   export AWS_SECRET_ACCESS_KEY="your-secret-key"
#   # Option 3: Use IAM role (if running on EC2)
#   # Option 4: Use AWS profile
#   #   profile = "my-aws-profile"
# }

# ============================================================================
# Provider Configuration: Google Cloud Platform (GCP)
# ============================================================================
# GCP Provider - for Google Cloud Platform

# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "~> 5.0"
#     }
#   }
# }

# Configure GCP provider
# provider "google" {
#   project = "my-gcp-project-id"
#   region  = "us-central1"
#
#   # Authentication options:
#   # Option 1: Use gcloud CLI authentication
#   #   gcloud auth application-default login
#   # Option 2: Use service account key file
#   #   credentials = file("path/to/service-account-key.json")
#   # Option 3: Use environment variable
#   #   export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
# }

# ============================================================================
# Provider Configuration: Azure
# ============================================================================
# Azure Provider - for Microsoft Azure

# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 3.0"
#     }
#   }
# }

# Configure Azure provider
# provider "azurerm" {
#   features {}
#
#   # Authentication options (choose one):
#   # Option 1: Use Azure CLI authentication
#   #   az login
#   # Option 2: Use service principal
#   #   subscription_id = "your-subscription-id"
#   #   client_id       = "your-client-id"
#   #   client_secret   = "your-client-secret"
#   #   tenant_id       = "your-tenant-id"
#   # Option 3: Use managed identity (if running on Azure)
# }

# ============================================================================
# AWS VPC Implementation
# ============================================================================
# AWS uses VPC (Virtual Private Cloud) for network isolation

# AWS VPC Resource
# resource "aws_vpc" "multi_cloud_aws_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#
#   tags = {
#     Name        = "multi-cloud-aws-vpc"
#     Environment = "example"
#     ManagedBy   = "terraform"
#   }
# }

# AWS Internet Gateway (for internet access)
# resource "aws_internet_gateway" "multi_cloud_aws_igw" {
#   vpc_id = aws_vpc.multi_cloud_aws_vpc.id
#
#   tags = {
#     Name = "multi-cloud-aws-igw"
#   }
# }

# AWS Subnets (public and private)
# resource "aws_subnet" "multi_cloud_aws_public_subnet" {
#   vpc_id                  = aws_vpc.multi_cloud_aws_vpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true
#
#   tags = {
#     Name = "multi-cloud-aws-public-subnet"
#     Type = "public"
#   }
# }
#
# resource "aws_subnet" "multi_cloud_aws_private_subnet" {
#   vpc_id            = aws_vpc.multi_cloud_aws_vpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "us-east-1a"
#
#   tags = {
#     Name = "multi-cloud-aws-private-subnet"
#     Type = "private"
#   }
# }

# AWS Route Table (for public subnet)
# resource "aws_route_table" "multi_cloud_aws_public_rt" {
#   vpc_id = aws_vpc.multi_cloud_aws_vpc.id
#
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.multi_cloud_aws_igw.id
#   }
#
#   tags = {
#     Name = "multi-cloud-aws-public-rt"
#   }
# }
#
# resource "aws_route_table_association" "multi_cloud_aws_public_rta" {
#   subnet_id      = aws_subnet.multi_cloud_aws_public_subnet.id
#   route_table_id = aws_route_table.multi_cloud_aws_public_rt.id
# }

# ============================================================================
# GCP VPC Implementation
# ============================================================================
# GCP uses VPC Networks (similar concept to AWS VPC)

# GCP VPC Network
# resource "google_compute_network" "multi_cloud_gcp_vpc" {
#   name                    = "multi-cloud-gcp-vpc"
#   auto_create_subnetworks = false
#   routing_mode           = "REGIONAL"
#
#   # Note: GCP VPCs are global by default, but subnets are regional
# }

# GCP Subnet (public)
# resource "google_compute_subnetwork" "multi_cloud_gcp_public_subnet" {
#   name          = "multi-cloud-gcp-public-subnet"
#   ip_cidr_range = "10.1.0.0/24"
#   region        = "us-central1"
#   network       = google_compute_network.multi_cloud_gcp_vpc.id
#
#   # Enable private Google access (for GCP services)
#   private_ip_google_access = true
# }

# GCP Subnet (private)
# resource "google_compute_subnetwork" "multi_cloud_gcp_private_subnet" {
#   name          = "multi-cloud-gcp-private-subnet"
#   ip_cidr_range = "10.1.1.0/24"
#   region        = "us-central1"
#   network       = google_compute_network.multi_cloud_gcp_vpc.id
#
#   private_ip_google_access = true
# }

# GCP Firewall Rule (for SSH access - example)
# resource "google_compute_firewall" "multi_cloud_gcp_ssh" {
#   name    = "multi-cloud-gcp-allow-ssh"
#   network = google_compute_network.multi_cloud_gcp_vpc.name
#
#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#
#   source_ranges = ["0.0.0.0/0"]  # In production, restrict this!
#   target_tags   = ["ssh"]
# }

# ============================================================================
# Azure VPC Implementation
# ============================================================================
# Azure uses Virtual Networks (VNet) - similar concept to VPC

# Azure Resource Group (required for Azure resources)
# resource "azurerm_resource_group" "multi_cloud_azure_rg" {
#   name     = "multi-cloud-azure-rg"
#   location = "East US"
#
#   tags = {
#     Environment = "example"
#     ManagedBy   = "terraform"
#   }
# }

# Azure Virtual Network (VNet)
# resource "azurerm_virtual_network" "multi_cloud_azure_vnet" {
#   name                = "multi-cloud-azure-vnet"
#   address_space       = ["10.2.0.0/16"]
#   location            = azurerm_resource_group.multi_cloud_azure_rg.location
#   resource_group_name = azurerm_resource_group.multi_cloud_azure_rg.name
#
#   tags = {
#     Name        = "multi-cloud-azure-vnet"
#     Environment = "example"
#   }
# }

# Azure Subnet (public)
# resource "azurerm_subnet" "multi_cloud_azure_public_subnet" {
#   name                 = "multi-cloud-azure-public-subnet"
#   resource_group_name  = azurerm_resource_group.multi_cloud_azure_rg.name
#   virtual_network_name = azurerm_virtual_network.multi_cloud_azure_vnet.name
#   address_prefixes     = ["10.2.1.0/24"]
# }

# Azure Subnet (private)
# resource "azurerm_subnet" "multi_cloud_azure_private_subnet" {
#   name                 = "multi-cloud-azure-private-subnet"
#   resource_group_name  = azurerm_resource_group.multi_cloud_azure_rg.name
#   virtual_network_name = azurerm_virtual_network.multi_cloud_azure_vnet.name
#   address_prefixes     = ["10.2.2.0/24"]
# }

# Azure Network Security Group (for firewall rules)
# resource "azurerm_network_security_group" "multi_cloud_azure_nsg" {
#   name                = "multi-cloud-azure-nsg"
#   location            = azurerm_resource_group.multi_cloud_azure_rg.location
#   resource_group_name = azurerm_resource_group.multi_cloud_azure_rg.name
#
#   security_rule {
#     name                       = "AllowSSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"  # In production, restrict this!
#     destination_address_prefix = "*"
#   }
#
#   tags = {
#     Environment = "example"
#   }
# }
#
# # Associate NSG with subnet
# resource "azurerm_subnet_network_security_group_association" "multi_cloud_azure_nsg_assoc" {
#   subnet_id                 = azurerm_subnet.multi_cloud_azure_public_subnet.id
#   network_security_group_id = azurerm_network_security_group.multi_cloud_azure_nsg.id
# }

# ============================================================================
# Comparison: VPC Concepts Across Clouds
# ============================================================================
# 
# Concept              | AWS                    | GCP                      | Azure
# -------------------- | ---------------------- | ------------------------ | ----------------------
# VPC/VNet             | aws_vpc                | google_compute_network   | azurerm_virtual_network
# Subnet               | aws_subnet              | google_compute_subnetwork| azurerm_subnet
# Internet Gateway     | aws_internet_gateway    | (automatic)              | (via public IP)
# Route Table          | aws_route_table         | (automatic)              | (automatic)
# Firewall/Security    | aws_security_group     | google_compute_firewall  | azurerm_network_security_group
# Availability Zones   | Explicit (us-east-1a)  | Regions (us-central1)    | Regions (East US)
# CIDR Blocks          | cidr_block              | ip_cidr_range            | address_prefixes
# Tags/Labels          | tags                    | labels                   | tags
#
# Key Differences:
# 1. AWS: Explicit route tables and internet gateways
# 2. GCP: Automatic routing, global VPCs with regional subnets
# 3. Azure: Resource groups required, network security groups for firewall rules
#
# Similarities:
# - All use CIDR blocks for IP addressing
# - All support public and private subnets
# - All have firewall/security group concepts
# - All support tags/labels for organization

# ============================================================================
# Multi-Cloud Outputs
# ============================================================================
# Outputs to demonstrate VPC information from each cloud

# AWS Outputs
# output "aws_vpc_id" {
#   description = "AWS VPC ID"
#   value       = aws_vpc.multi_cloud_aws_vpc.id
# }
#
# output "aws_vpc_cidr" {
#   description = "AWS VPC CIDR block"
#   value       = aws_vpc.multi_cloud_aws_vpc.cidr_block
# }
#
# output "aws_public_subnet_id" {
#   description = "AWS Public Subnet ID"
#   value       = aws_subnet.multi_cloud_aws_public_subnet.id
# }

# GCP Outputs
# output "gcp_vpc_id" {
#   description = "GCP VPC Network ID"
#   value       = google_compute_network.multi_cloud_gcp_vpc.id
# }
#
# output "gcp_vpc_name" {
#   description = "GCP VPC Network Name"
#   value       = google_compute_network.multi_cloud_gcp_vpc.name
# }
#
# output "gcp_public_subnet_id" {
#   description = "GCP Public Subnet ID"
#   value       = google_compute_subnetwork.multi_cloud_gcp_public_subnet.id
# }

# Azure Outputs
# output "azure_vnet_id" {
#   description = "Azure Virtual Network ID"
#   value       = azurerm_virtual_network.multi_cloud_azure_vnet.id
# }
#
# output "azure_vnet_name" {
#   description = "Azure Virtual Network Name"
#   value       = azurerm_virtual_network.multi_cloud_azure_vnet.name
# }
#
# output "azure_public_subnet_id" {
#   description = "Azure Public Subnet ID"
#   value       = azurerm_subnet.multi_cloud_azure_public_subnet.id
# }

# ============================================================================
# Multi-Cloud Best Practices
# ============================================================================
#
# 1. Use consistent naming conventions across clouds
#    - Example: multi-cloud-{cloud}-{resource-type}
#
# 2. Use consistent CIDR blocks (non-overlapping)
#    - AWS: 10.0.0.0/16
#    - GCP: 10.1.0.0/16
#    - Azure: 10.2.0.0/16
#
# 3. Use tags/labels consistently
#    - Environment, ManagedBy, Project, etc.
#
# 4. Separate provider configurations
#    - Use provider aliases if needed
#    - Use different variable files per cloud
#
# 5. Use modules for common patterns
#    - Create reusable VPC modules per cloud
#    - Share common logic where possible
#
# 6. Use workspaces or separate directories
#    - Separate state files per cloud
#    - Easier to manage and troubleshoot
#
# 7. Use remote backends per cloud
#    - AWS: S3 backend
#    - GCP: GCS backend
#    - Azure: Azure Storage backend
#
# 8. Document cloud-specific requirements
#    - Authentication methods
#    - Required permissions/roles
#    - Regional differences

# ============================================================================
# Provider Aliases for Multiple Accounts/Regions
# ============================================================================
# Use provider aliases to manage multiple accounts or regions

# AWS Provider Aliases
# provider "aws" {
#   alias  = "us_east"
#   region = "us-east-1"
# }
#
# provider "aws" {
#   alias  = "us_west"
#   region = "us-west-2"
# }
#
# # Use aliased provider
# resource "aws_vpc" "east_vpc" {
#   provider   = aws.us_east
#   cidr_block = "10.0.0.0/16"
# }
#
# resource "aws_vpc" "west_vpc" {
#   provider   = aws.us_west
#   cidr_block = "10.1.0.0/16"
# }

# ============================================================================
# Conditional Provider Usage
# ============================================================================
# Use variables to conditionally enable providers

# variable "enable_aws" {
#   description = "Enable AWS provider and resources"
#   type        = bool
#   default     = false
# }
#
# variable "enable_gcp" {
#   description = "Enable GCP provider and resources"
#   type        = bool
#   default     = false
# }
#
# variable "enable_azure" {
#   description = "Enable Azure provider and resources"
#   type        = bool
#   default     = false
# }
#
# # Conditionally create resources
# resource "aws_vpc" "conditional_vpc" {
#   count = var.enable_aws ? 1 : 0
#   # ... rest of configuration
# }

# ============================================================================
# Setup Instructions
# ============================================================================
#
# AWS Setup:
# 1. Install AWS CLI: https://aws.amazon.com/cli/
# 2. Configure credentials: aws configure
# 3. Uncomment AWS provider and resources above
# 4. Run: terraform init
# 5. Run: terraform plan
#
# GCP Setup:
# 1. Install gcloud CLI: https://cloud.google.com/sdk/docs/install
# 2. Authenticate: gcloud auth application-default login
# 3. Set project: gcloud config set project YOUR_PROJECT_ID
# 4. Uncomment GCP provider and resources above
# 5. Run: terraform init
# 6. Run: terraform plan
#
# Azure Setup:
# 1. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
# 2. Authenticate: az login
# 3. Set subscription: az account set --subscription YOUR_SUBSCRIPTION_ID
# 4. Uncomment Azure provider and resources above
# 5. Run: terraform init
# 6. Run: terraform plan
#
# Note: You need appropriate permissions/roles in each cloud to create VPCs
