# Example demonstrating Terraform backend migration
# Backend migration moves your state from one backend to another
# This is essential when: switching backends, moving to production, consolidating state

# ============================================================================
# Migration Scenario 1: Local to S3 Backend
# ============================================================================
# Most common migration: moving from local development to shared S3 backend

# STEP 1: Current state (local backend - default)
# No backend block needed - Terraform uses local by default
# State file: terraform.tfstate (in current directory)

# STEP 2: Add S3 backend configuration
# Uncomment and configure:
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"
#     key            = "hashiwich/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# STEP 3: Initialize with migration
# Run: terraform init
#
# Terraform will detect the backend change and prompt:
#   Do you want to copy existing state to the new backend?
#   Pre-existing state was found while migrating the previous "local" backend to the
#   newly configured "s3" backend. No existing state was found in the newly configured
#   "s3" backend. Do you want to copy this state to the new "s3" backend?
#
# Answer: yes
#
# Output will show:
#   Successfully configured the backend "s3"!
#   Terraform has detected that the configuration changed and has automatically
#   copied the state to the new backend.

# STEP 4: Verify migration
# Run: terraform plan
# Should show: No changes (state successfully migrated)

# STEP 5: Verify state location
# Check S3 bucket: aws s3 ls s3://my-terraform-state-bucket/hashiwich/
# Should see: terraform.tfstate

# ============================================================================
# Migration Scenario 2: S3 to Terraform Cloud
# ============================================================================
# Moving from S3 to Terraform Cloud for better collaboration features

# STEP 1: Current state (S3 backend)
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"
#     key            = "hashiwich/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# STEP 2: Update to Terraform Cloud backend
# terraform {
#   cloud {
#     organization = "my-organization"
#     workspaces {
#       name = "hashiwich-examples"
#     }
#   }
# }

# STEP 3: Authenticate with Terraform Cloud
# Run: terraform login
# This opens a browser to generate an API token

# STEP 4: Initialize with migration
# Run: terraform init
#
# Terraform will prompt:
#   Do you want to copy existing state to the new backend?
#
# Answer: yes
#
# State will be copied from S3 to Terraform Cloud

# STEP 5: Verify in Terraform Cloud UI
# Go to: https://app.terraform.io/app/my-organization/workspaces/hashiwich-examples
# Check: States tab to see migrated state

# ============================================================================
# Migration Scenario 3: S3 to Different S3 Bucket
# ============================================================================
# Moving state to a different S3 bucket (e.g., new account, region change)

# STEP 1: Current state (S3 backend - old bucket)
# terraform {
#   backend "s3" {
#     bucket         = "old-terraform-state-bucket"
#     key            = "hashiwich/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# STEP 2: Update to new S3 bucket
# terraform {
#   backend "s3" {
#     bucket         = "new-terraform-state-bucket"
#     key            = "hashiwich/terraform.tfstate"
#     region         = "us-west-2"  # Different region
#     dynamodb_table = "terraform-state-lock-new"
#     encrypt        = true
#   }
# }

# STEP 3: Initialize with migration
# Run: terraform init -migrate-state
#
# The -migrate-state flag explicitly requests migration
# Terraform will copy state from old bucket to new bucket

# STEP 4: Verify both buckets
# Old bucket: aws s3 ls s3://old-terraform-state-bucket/hashiwich/
# New bucket: aws s3 ls s3://new-terraform-state-bucket/hashiwich/
# Both should have state files (old one can be deleted after verification)

# ============================================================================
# Migration Scenario 4: Local to Local (Different Path)
# ============================================================================
# Moving state to a different local path

# STEP 1: Current state (default local)
# State file: terraform.tfstate

# STEP 2: Configure explicit local backend with new path
# terraform {
#   backend "local" {
#     path = "backups/terraform.tfstate"
#   }
# }

# STEP 3: Initialize with migration
# Run: terraform init
#
# Terraform will copy state from terraform.tfstate to backups/terraform.tfstate

# ============================================================================
# Migration Scenario 5: With Workspaces
# ============================================================================
# Migrating when using workspaces

# STEP 1: Current state (local with workspaces)
# terraform workspace new dev
# terraform workspace new staging
# terraform workspace new prod
#
# State files:
# - terraform.tfstate.d/dev/
# - terraform.tfstate.d/staging/
# - terraform.tfstate.d/prod/

# STEP 2: Configure S3 backend
# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "hashiwich/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# STEP 3: Migrate each workspace
# For each workspace:
#   terraform workspace select dev
#   terraform init -migrate-state
#
# Repeat for staging and prod

# STEP 4: Verify in S3
# aws s3 ls s3://my-terraform-state-bucket/hashiwich/ --recursive
# Should see:
#   terraform.tfstate/env:/dev/
#   terraform.tfstate/env:/staging/
#   terraform.tfstate/env:/prod/

# ============================================================================
# Migration Commands Reference
# ============================================================================

# Basic migration:
# terraform init
#   - Automatically detects backend change
#   - Prompts to migrate state
#   - Copies state to new backend

# Explicit migration:
# terraform init -migrate-state
#   - Explicitly requests state migration
#   - Useful when automatic detection doesn't work

# Reconfigure backend (without migration):
# terraform init -reconfigure
#   - Reinitializes backend configuration
#   - Does NOT migrate state
#   - Use when backend config changed but state location is same

# Force unlock (if migration fails due to lock):
# terraform force-unlock <lock-id>
#   - Use only if you're sure no other operations are running
#   - Get lock-id from error message

# ============================================================================
# Common Migration Issues and Solutions
# ============================================================================

# Issue 1: "Backend reinitialization required"
# Solution: Run terraform init -migrate-state

# Issue 2: "Error acquiring the state lock"
# Solution: 
#   - Check if another terraform operation is running
#   - Wait for it to complete
#   - If stuck, use terraform force-unlock (with caution)

# Issue 3: "Backend configuration changed"
# Solution:
#   - Run terraform init to reconfigure
#   - If state location changed, use -migrate-state

# Issue 4: "No existing state was found in the new backend"
# Solution:
#   - This is normal for first-time migration
#   - Answer "yes" to copy existing state

# Issue 5: "Pre-existing state was found in the new backend"
# Solution:
#   - New backend already has state
#   - Choose: overwrite (dangerous) or abort
#   - Better: manually verify and merge if needed

# Issue 6: Authentication errors
# Solution:
#   - Verify AWS credentials: aws sts get-caller-identity
#   - Check IAM permissions for S3 and DynamoDB
#   - For Terraform Cloud: run terraform login

# Issue 7: Bucket/table doesn't exist
# Solution:
#   - Create S3 bucket first
#   - Create DynamoDB table for locking
#   - Verify bucket/table names in backend config

# ============================================================================
# Migration Best Practices
# ============================================================================

# 1. Backup state before migration
#    cp terraform.tfstate terraform.tfstate.backup
#    Or for S3: aws s3 cp s3://bucket/key s3://bucket/key.backup

# 2. Test migration in non-production first
#    - Use a test workspace or environment
#    - Verify state is correct after migration

# 3. Coordinate with team
#    - Ensure no one is running terraform operations during migration
#    - Communicate backend change to all team members

# 4. Verify state after migration
#    terraform plan
#    Should show: No changes (if migration successful)

# 5. Update documentation
#    - Document new backend configuration
#    - Update team runbooks
#    - Update CI/CD pipelines if needed

# 6. Clean up old backend (after verification)
#    - Keep old state as backup for a period
#    - Delete old state after confirming new backend works

# 7. Use versioning/backups
#    - Enable S3 versioning before migration
#    - Keep backups of state files

# 8. Test state locking
#    - Verify locking works in new backend
#    - Test concurrent operations are prevented

# ============================================================================
# Step-by-Step Migration Checklist
# ============================================================================

# [ ] 1. Backup current state file
# [ ] 2. Verify current state is up to date (terraform plan)
# [ ] 3. Create new backend resources (S3 bucket, DynamoDB table, etc.)
# [ ] 4. Update backend configuration in terraform block
# [ ] 5. Run terraform init -migrate-state
# [ ] 6. Verify migration prompt and answer "yes"
# [ ] 7. Run terraform plan to verify state
# [ ] 8. Check new backend location for state file
# [ ] 9. Test state locking (if applicable)
# [ ] 10. Update team documentation
# [ ] 11. Coordinate team to run terraform init
# [ ] 12. Verify all team members can access new backend
# [ ] 13. Keep old state as backup for safety period
# [ ] 14. Clean up old backend resources (after safety period)

# ============================================================================
# Example: Complete Migration Workflow
# ============================================================================

# Scenario: Migrating from local to S3 backend

# 1. Current setup (local backend - no config needed)
#    State: terraform.tfstate

# 2. Create S3 resources (one-time setup)
#    aws s3 mb s3://my-terraform-state-bucket
#    aws s3api put-bucket-versioning \
#      --bucket my-terraform-state-bucket \
#      --versioning-configuration Status=Enabled
#    aws dynamodb create-table \
#      --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST

# 3. Backup current state
#    cp terraform.tfstate terraform.tfstate.backup-$(date +%Y%m%d)

# 4. Add backend configuration to terraform block
#    terraform {
#      backend "s3" {
#        bucket         = "my-terraform-state-bucket"
#        key            = "hashiwich/terraform.tfstate"
#        region         = "us-east-1"
#        dynamodb_table = "terraform-state-lock"
#        encrypt        = true
#      }
#    }

# 5. Initialize and migrate
#    terraform init
#    # Answer "yes" when prompted to migrate state

# 6. Verify
#    terraform plan
#    # Should show: No changes
#    aws s3 ls s3://my-terraform-state-bucket/hashiwich/
#    # Should see: terraform.tfstate

# 7. Test locking
#    # In terminal 1: terraform plan (should work)
#    # In terminal 2: terraform apply (should wait for lock)
#    # This verifies state locking works

# 8. Update team
#    - Share backend configuration
#    - Team members run: terraform init
#    - Verify everyone can access state

# Migration complete!
