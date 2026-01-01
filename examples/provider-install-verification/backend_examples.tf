# Example demonstrating various Terraform backend configurations
# Backends determine where Terraform stores its state file
# 
# NOTE: These are commented examples showing different backend types
# Uncomment and configure the backend you want to use

# ============================================================================
# Default: Local Backend (No configuration needed)
# ============================================================================
# By default, Terraform uses a local backend that stores state in:
# - terraform.tfstate (in the working directory)
# - terraform.tfstate.backup (backup of previous state)
#
# This is fine for:
# - Personal projects
# - Learning and development
# - Single-user scenarios
#
# NOT recommended for:
# - Team collaboration (no state locking)
# - Production environments (no redundancy)
# - CI/CD pipelines (state not shared)

# To explicitly use local backend (optional):
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }

# ============================================================================
# Backend Type 1: S3 Backend (AWS)
# ============================================================================
# Most common production backend for AWS environments
# Requires: S3 bucket, DynamoDB table (for state locking), IAM permissions

# terraform {
#   backend "s3" {
#     # Required: S3 bucket name
#     bucket = "my-terraform-state-bucket"
#
#     # Required: Key (path) where state file will be stored
#     key = "hashiwich/terraform.tfstate"
#
#     # Optional: AWS region
#     region = "us-east-1"
#
#     # Optional: DynamoDB table for state locking
#     # Prevents concurrent modifications
#     dynamodb_table = "terraform-state-lock"
#
#     # Optional: Enable server-side encryption
#     encrypt = true
#
#     # Optional: AWS profile to use
#     # profile = "my-aws-profile"
#
#     # Optional: Access key and secret (not recommended - use IAM roles or profiles)
#     # access_key = "AKIAIOSFODNN7EXAMPLE"
#     # secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
#   }
# }

# Setup requirements:
# 1. Create S3 bucket: aws s3 mb s3://my-terraform-state-bucket
# 2. Enable versioning: aws s3api put-bucket-versioning --bucket my-terraform-state-bucket --versioning-configuration Status=Enabled
# 3. Create DynamoDB table for locking:
#    aws dynamodb create-table \
#      --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST
# 4. Configure IAM permissions (read/write to S3, read/write to DynamoDB)

# ============================================================================
# Backend Type 2: Terraform Cloud Backend
# ============================================================================
# Cloud-hosted backend with free tier available
# Good for: Teams, remote execution, state management
# Sign up at: https://app.terraform.io

# terraform {
#   cloud {
#     organization = "my-organization"
#
#     workspaces {
#       name = "hashiwich-examples"
#     }
#   }
# }

# Alternative: Using workspaces with tags
# terraform {
#   cloud {
#     organization = "my-organization"
#
#     workspaces {
#       tags = ["examples", "hashiwich"]
#     }
#   }
# }

# Setup requirements:
# 1. Create account at https://app.terraform.io
# 2. Create an organization
# 3. Create a workspace (or use tags)
# 4. Run: terraform login (to authenticate)
# 5. Run: terraform init

# ============================================================================
# Backend Type 3: Azure Storage Backend
# ============================================================================
# For Azure environments

# terraform {
#   backend "azurerm" {
#     # Required: Storage account name
#     storage_account_name = "mystorageaccount"
#
#     # Required: Container name
#     container_name = "tfstate"
#
#     # Required: Key (path) where state file will be stored
#     key = "hashiwich/terraform.tfstate"
#
#     # Optional: Resource group name
#     resource_group_name = "my-resource-group"
#
#     # Optional: Enable state locking (requires storage account)
#     # Uses blob lease for locking
#   }
# }

# Setup requirements:
# 1. Create storage account: az storage account create --name mystorageaccount --resource-group my-resource-group
# 2. Create container: az storage container create --name tfstate --account-name mystorageaccount
# 3. Configure authentication (service principal, managed identity, or access key)

# ============================================================================
# Backend Type 4: Google Cloud Storage (GCS) Backend
# ============================================================================
# For GCP environments

# terraform {
#   backend "gcs" {
#     # Required: GCS bucket name
#     bucket = "my-terraform-state-bucket"
#
#     # Required: Key (path) where state file will be stored
#     key = "hashiwich/terraform.tfstate"
#
#     # Optional: Enable state locking
#     # Uses Cloud Storage object versioning
#   }
# }

# Setup requirements:
# 1. Create GCS bucket: gsutil mb gs://my-terraform-state-bucket
# 2. Enable versioning: gsutil versioning set on gs://my-terraform-state-bucket
# 3. Configure authentication (service account or user credentials)

# ============================================================================
# Backend Type 5: HashiCorp Consul Backend
# ============================================================================
# For organizations using Consul

# terraform {
#   backend "consul" {
#     # Required: Consul address
#     address = "demo.consul.io:8500"
#
#     # Required: Path where state will be stored
#     path = "hashiwich/terraform.tfstate"
#
#     # Optional: Datacenter
#     datacenter = "dc1"
#
#     # Optional: Access token
#     # access_token = "your-consul-token"
#   }
# }

# ============================================================================
# Backend Type 6: HTTP Backend
# ============================================================================
# For custom HTTP-based state storage
# Requires: HTTP endpoint that supports GET, POST, DELETE, LOCK, UNLOCK

# terraform {
#   backend "http" {
#     address = "https://api.example.com/terraform/state"
#
#     # Optional: Lock address (if different from state address)
#     lock_address = "https://api.example.com/terraform/lock"
#
#     # Optional: Unlock address (if different from state address)
#     unlock_address = "https://api.example.com/terraform/unlock"
#
#     # Optional: Username for basic auth
#     username = "terraform"
#
#     # Optional: Password for basic auth
#     password = "secret-password"
#
#     # Optional: Skip certificate verification (not recommended for production)
#     # skip_cert_verification = true
#   }
# }

# ============================================================================
# Backend Type 7: Remote Backend (Legacy)
# ============================================================================
# Legacy backend for Terraform Enterprise (pre-0.12)
# Note: Use "cloud" backend for Terraform Cloud instead

# terraform {
#   backend "remote" {
#     organization = "my-organization"
#     workspaces {
#       name = "hashiwich-examples"
#     }
#   }
# }

# ============================================================================
# Backend Configuration: Partial Configuration
# ============================================================================
# Sometimes you want to provide backend config at init time instead of in code
# Useful for: Different configs per environment, avoiding secrets in code

# terraform {
#   backend "s3" {
#     # Only specify backend type, provide config via:
#     # - Command line: terraform init -backend-config="bucket=my-bucket"
#     # - Config file: terraform init -backend-config=backend.hcl
#     # - Environment variables: TF_CLI_ARGS_init="-backend-config=..."
#   }
# }

# Example backend.hcl file:
# bucket         = "my-terraform-state-bucket"
# key            = "hashiwich/terraform.tfstate"
# region         = "us-east-1"
# dynamodb_table = "terraform-state-lock"
# encrypt        = true

# Initialize with: terraform init -backend-config=backend.hcl

# ============================================================================
# Backend Configuration: Workspaces
# ============================================================================
# Workspaces allow multiple state files in the same backend
# Useful for: Environments (dev, staging, prod), feature branches

# Example: Using workspaces with S3 backend
# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "hashiwich/terraform.tfstate"  # Workspace name appended automatically
#     region = "us-east-1"
#   }
# }

# Workspace commands:
# terraform workspace new dev      # Create new workspace
# terraform workspace select dev  # Switch to workspace
# terraform workspace list        # List all workspaces
# terraform workspace show        # Show current workspace

# With workspaces, state files are stored as:
# - hashiwich/terraform.tfstate/env:/dev/
# - hashiwich/terraform.tfstate/env:/staging/
# - hashiwich/terraform.tfstate/env:/prod/

# ============================================================================
# Backend Configuration: State Locking
# ============================================================================
# State locking prevents concurrent modifications
# Critical for: Team collaboration, CI/CD pipelines

# Backends that support locking:
# - S3: Uses DynamoDB table
# - Azure: Uses blob lease
# - GCS: Uses object versioning
# - Terraform Cloud: Built-in locking
# - Consul: Built-in locking
# - Local: NO LOCKING (not safe for teams)

# Example error when lock is held:
# Error: Error acquiring the state lock
# Lock Info:
#   ID:        12345678-1234-1234-1234-123456789abc
#   Path:      my-terraform-state-bucket/hashiwich/terraform.tfstate
#   Operation: OperationTypePlan
#   Who:       user@example.com
#   Version:   1.4.0
#   Created:   2024-01-01 12:00:00 +0000 UTC
#   Info:      Locked by another operation

# To force unlock (use with caution):
# terraform force-unlock 12345678-1234-1234-1234-123456789abc

# ============================================================================
# Best Practices
# ============================================================================
# 1. Always use remote backends for production
# 2. Enable state locking (prevents concurrent modifications)
# 3. Enable encryption at rest
# 4. Enable versioning (S3, GCS) or backups
# 5. Use workspaces for environment separation
# 6. Never commit state files to version control
# 7. Use partial configuration for sensitive values
# 8. Regularly backup state files
# 9. Use least-privilege IAM/access policies
# 10. Monitor state file size (large states can be slow)

# ============================================================================
# Current Configuration
# ============================================================================
# This example directory uses the default local backend
# State is stored in: terraform.tfstate (in this directory)
#
# To switch to a remote backend:
# 1. Uncomment and configure one of the backend blocks above
# 2. Run: terraform init
# 3. Terraform will prompt to migrate existing state
# 4. Confirm migration
# 5. State will be moved to the new backend
