# Example demonstrating Terraform import functionality
# Import brings existing infrastructure under Terraform management
# Useful when: resources created manually, migrated from other tools, or adopting Terraform

# ============================================================================
# Why Import Resources?
# ============================================================================
#
# Common scenarios:
# 1. Adopting Terraform for existing infrastructure
#    - You have resources created manually or via console
#    - Want to manage them with Terraform going forward
#
# 2. Migrating from other IaC tools
#    - Moving from CloudFormation, Pulumi, etc.
#    - Need to bring resources into Terraform state
#
# 3. Recovering from lost state
#    - State file was deleted or corrupted
#    - Need to rebuild state from existing resources
#
# 4. Merging existing resources into Terraform
#    - Some resources managed manually, some by Terraform
#    - Want to consolidate management
#
# 5. Testing and learning
#    - Import resources to understand Terraform behavior
#    - Practice with real infrastructure

# ============================================================================
# Method 1: Import Blocks (Terraform 1.5+)
# ============================================================================
# Modern way to import - declare imports in configuration files
# Terraform will import during the next plan/apply

# Example: Importing an existing sandwich that was created manually
# resource "hw_sandwich" "imported_sandwich" {
#   bread_id    = hw_bread.import_bread.id
#   meat_id     = hw_meat.import_meat.id
#   description = "Sandwich imported from existing infrastructure"
# }
#
# # Import block - tells Terraform to import this resource
# import {
#   to = hw_sandwich.imported_sandwich
#   id = "sandwich-bread-rye-3-meat-turkey-6"  # Existing resource ID
# }

# Example: Importing multiple resources
# resource "hw_sandwich" "imported_sandwich_1" {
#   bread_id = hw_bread.import_bread.id
#   meat_id  = hw_meat.import_meat.id
# }
#
# resource "hw_sandwich" "imported_sandwich_2" {
#   bread_id = hw_bread.import_bread.id
#   meat_id  = hw_meat.import_meat_2.id
# }
#
# import {
#   to = hw_sandwich.imported_sandwich_1
#   id = "sandwich-bread-rye-3-meat-turkey-6"
# }
#
# import {
#   to = hw_sandwich.imported_sandwich_2
#   id = "sandwich-bread-rye-3-meat-ham-3"
# }

# ============================================================================
# Method 2: terraform import Command (Legacy but still useful)
# ============================================================================
# Command-line import - useful for one-off imports or scripting
#
# Syntax: terraform import <resource_address> <resource_id>
#
# Example commands:
# terraform import hw_sandwich.imported_sandwich sandwich-bread-rye-3-meat-turkey-6
# terraform import 'hw_sandwich.imported_sandwiches["turkey"]' sandwich-bread-rye-3-meat-turkey-6
# terraform import hw_sandwich.imported_sandwiches[0] sandwich-bread-rye-3-meat-turkey-6

# ============================================================================
# Scenario 1: Importing Existing Resources
# ============================================================================
# You have resources that exist but aren't in Terraform state

# Step 1: Create resource definition matching existing resource
resource "hw_bread" "import_bread" {
  kind        = "rye"
  description = "Bread for import example"
}

resource "hw_meat" "import_meat" {
  kind        = "turkey"
  description = "Meat for import example"
}

# Step 2: Define the resource you want to import
# This should match the existing resource's configuration
resource "hw_sandwich" "imported_example" {
  bread_id    = hw_bread.import_bread.id
  meat_id     = hw_meat.import_meat.id
  description = "This sandwich exists but needs to be imported"
}

# Step 3: Import using one of these methods:
#
# Option A: Import block (Terraform 1.5+)
# import {
#   to = hw_sandwich.imported_example
#   id = "sandwich-bread-rye-3-meat-turkey-6"  # Actual ID of existing resource
# }
#
# Option B: Command line
# terraform import hw_sandwich.imported_example sandwich-bread-rye-3-meat-turkey-6
#
# After import, run: terraform plan
# Should show: No changes (resource matches existing state)

# ============================================================================
# Scenario 2: Importing Resources with for_each
# ============================================================================
# Importing multiple resources that use for_each

# resource "hw_meat" "imported_meats" {
#   for_each = toset(["turkey", "ham", "roast beef"])
#   kind     = each.value
# }
#
# # Import each resource individually
# import {
#   to = hw_meat.imported_meats["turkey"]
#   id = "meat-turkey-6"
# }
#
# import {
#   to = hw_meat.imported_meats["ham"]
#   id = "meat-ham-3"
# }
#
# import {
#   to = hw_meat.imported_meats["roast beef"]
#   id = "meat-roast beef-10"
# }
#
# Or use command line:
# terraform import 'hw_meat.imported_meats["turkey"]' meat-turkey-6
# terraform import 'hw_meat.imported_meats["ham"]' meat-ham-3
# terraform import 'hw_meat.imported_meats["roast beef"]' meat-roast\ beef-10

# ============================================================================
# Scenario 3: Importing Resources with count
# ============================================================================
# Importing resources that use count

# resource "hw_sandwich" "imported_count_sandwiches" {
#   count       = 3
#   bread_id    = hw_bread.import_bread.id
#   meat_id     = hw_meat.import_meat.id
#   description = "Sandwich ${count.index + 1}"
# }
#
# # Import each indexed resource
# import {
#   to = hw_sandwich.imported_count_sandwiches[0]
#   id = "sandwich-bread-rye-3-meat-turkey-6"
# }
#
# import {
#   to = hw_sandwich.imported_count_sandwiches[1]
#   id = "sandwich-bread-rye-3-meat-turkey-6"
# }
#
# import {
#   to = hw_sandwich.imported_count_sandwiches[2]
#   id = "sandwich-bread-rye-3-meat-turkey-6"
# }
#
# Or use command line:
# terraform import hw_sandwich.imported_count_sandwiches[0] sandwich-bread-rye-3-meat-turkey-6
# terraform import hw_sandwich.imported_count_sandwiches[1] sandwich-bread-rye-3-meat-turkey-6
# terraform import hw_sandwich.imported_count_sandwiches[2] sandwich-bread-rye-3-meat-turkey-6

# ============================================================================
# Scenario 4: Importing and Then Refactoring
# ============================================================================
# Common workflow: Import existing resources, then refactor to better structure

# Step 1: Import existing resources as-is
# resource "hw_sandwich" "legacy_sandwich" {
#   bread_id = hw_bread.import_bread.id
#   meat_id  = hw_meat.import_meat.id
# }
#
# import {
#   to = hw_sandwich.legacy_sandwich
#   id = "sandwich-bread-rye-3-meat-turkey-6"
# }

# Step 2: After import is successful, refactor
# - Rename resources
# - Use moved blocks to track renames
# - Improve configuration structure
# - Add missing attributes

# Example: After importing, rename and improve
# resource "hw_sandwich" "refactored_sandwich" {
#   bread_id    = hw_bread.import_bread.id
#   meat_id     = hw_meat.import_meat.id
#   description = "Refactored sandwich with better configuration"
# }
#
# moved {
#   from = hw_sandwich.legacy_sandwich
#   to   = hw_sandwich.refactored_sandwich
# }

# ============================================================================
# Scenario 5: Bulk Import Workflow
# ============================================================================
# Importing many resources efficiently

# Step 1: List existing resources
# For our provider, you might query the API or check existing state
# Example: Get list of all sandwich IDs that exist

# Step 2: Generate import blocks or commands
# You can script this:
#
# #!/bin/bash
# # Example script to import multiple sandwiches
# SANDWICH_IDS=(
#   "sandwich-bread-rye-3-meat-turkey-6"
#   "sandwich-bread-wheat-5-meat-ham-3"
#   "sandwich-bread-sourdough-9-meat-roast-beef-10"
# )
#
# for i in "${!SANDWICH_IDS[@]}"; do
#   terraform import "hw_sandwich.bulk_imported[$i]" "${SANDWICH_IDS[$i]}"
# done

# Step 3: Create resource definitions matching existing resources
# resource "hw_sandwich" "bulk_imported" {
#   for_each = toset([
#     "sandwich-bread-rye-3-meat-turkey-6",
#     "sandwich-bread-wheat-5-meat-ham-3",
#     "sandwich-bread-sourdough-9-meat-roast-beef-10"
#   ])
#   bread_id = hw_bread.import_bread.id
#   meat_id  = hw_meat.import_meat.id
# }

# ============================================================================
# Import Workflow: Step-by-Step
# ============================================================================
#
# 1. Identify resources to import
#    - List existing resources (via API, console, or inventory)
#    - Note their IDs and current configuration
#
# 2. Create resource definitions
#    - Add resource blocks matching existing resources
#    - Match attributes as closely as possible
#    - Can be minimal initially (add details after import)
#
# 3. Import resources
#    - Use import blocks (Terraform 1.5+) or terraform import command
#    - Run: terraform plan (with import blocks) or terraform import (command)
#
# 4. Verify import
#    - Run: terraform plan
#    - Should show minimal or no changes
#    - If changes shown, update resource definition to match
#
# 5. Refine configuration
#    - Add missing attributes
#    - Improve resource definitions
#    - Run terraform plan again to verify
#
# 6. Remove import blocks (if used)
#    - Import blocks are only needed once
#    - Remove after successful import
#
# 7. Commit to version control
#    - Import is complete, resources now managed by Terraform

# ============================================================================
# Common Import Issues and Solutions
# ============================================================================

# Issue 1: "Resource already managed by Terraform"
# Error: resource already managed
# Solution:
#   - Resource already in state
#   - Check: terraform state list
#   - Use moved block if renaming
#   - Remove from state first if needed: terraform state rm <address>

# Issue 2: "Resource configuration doesn't match"
# Error: attributes don't match after import
# Solution:
#   - Run: terraform plan to see differences
#   - Update resource definition to match existing resource
#   - Some attributes may be computed/read-only (ignore those)

# Issue 3: "Cannot determine resource ID"
# Error: don't know how to import resource
# Solution:
#   - Check provider documentation for import format
#   - Verify resource ID format is correct
#   - Some resources require composite IDs (e.g., "resource_group/resource_name")

# Issue 4: "Import failed: resource not found"
# Error: resource doesn't exist
# Solution:
#   - Verify resource ID is correct
#   - Check resource actually exists
#   - Verify you have permissions to read the resource

# Issue 5: "Dependencies not imported"
# Error: imported resource depends on resources not in state
# Solution:
#   - Import dependencies first
#   - Import in order: dependencies before dependents
#   - Or use -target to import specific resources

# ============================================================================
# Import Best Practices
# ============================================================================
#
# 1. Import one resource at a time initially
#    - Easier to troubleshoot
#    - Verify each import works before proceeding
#
# 2. Match existing configuration closely
#    - Get current resource configuration first
#    - Match attributes in Terraform config
#    - Reduces drift after import
#
# 3. Use terraform plan after each import
#    - Verify no unexpected changes
#    - Fix configuration if changes detected
#    - Iterate until plan shows no changes
#
# 4. Import dependencies first
#    - Import resources that others depend on
#    - Example: Import bread/meat before sandwiches
#    - Prevents dependency errors
#
# 5. Use import blocks for version control
#    - Import blocks are in code (reviewable)
#    - Better for team collaboration
#    - Can be committed and shared
#
# 6. Document import process
#    - Note which resources were imported
#    - Document any manual steps
#    - Keep import IDs for reference
#
# 7. Test after import
#    - Run terraform plan to verify
#    - Test terraform apply (should be no-op)
#    - Verify resources are correctly managed
#
# 8. Remove import blocks after import
#    - Import blocks only needed once
#    - Remove after successful import
#    - Keeps configuration clean
#
# 9. Use -target for complex imports
#    - terraform import -target=hw_bread.example bread-rye-3
#    - Focuses import on specific resources
#    - Reduces scope of operations
#
# 10. Backup state before importing
#     - Copy terraform.tfstate before import
#     - Can restore if import goes wrong
#     - Especially important for production

# ============================================================================
# Example: Complete Import Workflow
# ============================================================================
#
# Scenario: You have 3 sandwiches created manually, want to manage with Terraform
#
# Step 1: List existing resources
#   - Sandwich 1: ID = "sandwich-bread-rye-3-meat-turkey-6"
#   - Sandwich 2: ID = "sandwich-bread-wheat-5-meat-ham-3"
#   - Sandwich 3: ID = "sandwich-bread-sourdough-9-meat-roast-beef-10"
#
# Step 2: Create resource definitions
#   resource "hw_sandwich" "imported_sandwiches" {
#     for_each = {
#       "sandwich-1" = { bread = "rye", meat = "turkey" }
#       "sandwich-2" = { bread = "wheat", meat = "ham" }
#       "sandwich-3" = { bread = "sourdough", meat = "roast beef" }
#     }
#     bread_id = hw_bread.import_bread.id
#     meat_id  = hw_meat.import_meat.id
#   }
#
# Step 3: Add import blocks
#   import {
#     to = hw_sandwich.imported_sandwiches["sandwich-1"]
#     id = "sandwich-bread-rye-3-meat-turkey-6"
#   }
#   import {
#     to = hw_sandwich.imported_sandwiches["sandwich-2"]
#     id = "sandwich-bread-wheat-5-meat-ham-3"
#   }
#   import {
#     to = hw_sandwich.imported_sandwiches["sandwich-3"]
#     id = "sandwich-bread-sourdough-9-meat-roast-beef-10"
#   }
#
# Step 4: Run terraform plan
#   terraform plan
#   # Terraform will show import operations
#
# Step 5: Apply imports
#   terraform apply
#   # Resources are imported into state
#
# Step 6: Verify
#   terraform plan
#   # Should show: No changes
#
# Step 7: Remove import blocks
#   # Delete import blocks (they're only needed once)
#
# Step 8: Commit
#   git add .
#   git commit -m "Import existing sandwiches into Terraform"

# ============================================================================
# Import vs Other Methods
# ============================================================================
#
# Import:
#   - Brings existing resources under Terraform management
#   - Resources already exist, just adding to state
#   - Use when: adopting Terraform for existing infrastructure
#
# Create (terraform apply):
#   - Creates new resources
#   - Resources don't exist yet
#   - Use when: building new infrastructure
#
# Moved blocks:
#   - Renames resources in Terraform state
#   - Resources already in state, just changing address
#   - Use when: refactoring Terraform configuration
#
# Import + Moved:
#   - Common pattern: Import resources, then use moved blocks to refactor
#   - Import gets resources into state
#   - Moved blocks reorganize them

# ============================================================================
# Finding Resource IDs for Import
# ============================================================================
#
# Method 1: Provider-specific commands
#   - AWS: aws ec2 describe-instances
#   - GCP: gcloud compute instances list
#   - Azure: az resource list
#
# Method 2: Cloud console/UI
#   - Navigate to resource in web console
#   - Copy resource ID from details page
#
# Method 3: Existing state files
#   - If recovering from backup
#   - Extract IDs from state file
#
# Method 4: Provider API
#   - Query provider API directly
#   - List resources and get IDs
#
# Method 5: Inventory tools
#   - Use tools like terraformer, cloudquery
#   - Generate Terraform config from existing resources

# ============================================================================
# Outputs for Imported Resources
# ============================================================================

output "imported_sandwich_id" {
  description = "ID of imported sandwich"
  value       = hw_sandwich.imported_example.id
}

output "imported_resources_summary" {
  description = "Summary of imported resources"
  value = {
    imported_count = 1
    resource_type  = "hw_sandwich"
    note          = "Resources imported and now managed by Terraform"
  }
}
