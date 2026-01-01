# Example demonstrating Terraform taint functionality
# Tainting marks a resource for recreation (destroy and recreate)
# Useful when: resource is corrupted, needs refresh, or configuration drift

# ============================================================================
# What is Tainting?
# ============================================================================
#
# Tainting a resource tells Terraform to:
# 1. Destroy the existing resource
# 2. Create a new resource with the same configuration
#
# This is useful when:
# - Resource is in a bad state and needs to be recreated
# - Resource has configuration drift that can't be fixed with update
# - You want to force a resource refresh
# - Testing resource creation/deletion workflows
# - Resource has become corrupted or unresponsive

# ============================================================================
# Method 1: terraform taint Command (Legacy - Still Works)
# ============================================================================
# Older method, but still functional
# Syntax: terraform taint <resource_address>

# Example resources that can be tainted
resource "hw_bread" "taint_example_bread" {
  kind        = "rye"
  description = "Bread for taint example - can be tainted to force recreation"
}

resource "hw_meat" "taint_example_meat" {
  kind        = "turkey"
  description = "Meat for taint example - can be tainted to force recreation"
}

resource "hw_sandwich" "taint_example_sandwich" {
  bread_id    = hw_bread.taint_example_bread.id
  meat_id     = hw_meat.taint_example_meat.id
  description = "Sandwich that can be tainted to force recreation"
}

# Taint commands (run these in terminal):
# terraform taint hw_sandwich.taint_example_sandwich
# terraform taint hw_bread.taint_example_bread
# terraform taint hw_meat.taint_example_meat

# For resources with for_each:
# terraform taint 'hw_sandwich.taint_example_sandwiches["turkey"]'
# terraform taint 'hw_sandwich.taint_example_sandwiches["ham"]'

# For resources with count:
# terraform taint hw_sandwich.taint_example_sandwiches[0]
# terraform taint hw_sandwich.taint_example_sandwiches[1]

# ============================================================================
# Method 2: terraform apply -replace (Modern - Recommended)
# ============================================================================
# Newer method (Terraform 0.15.2+), recommended over taint
# Syntax: terraform apply -replace=<resource_address>

# Modern way to taint (recommended):
# terraform apply -replace=hw_sandwich.taint_example_sandwich
# terraform apply -replace=hw_bread.taint_example_bread

# Multiple replacements in one command:
# terraform apply -replace=hw_bread.taint_example_bread -replace=hw_meat.taint_example_meat

# For resources with for_each:
# terraform apply -replace='hw_sandwich.taint_example_sandwiches["turkey"]'

# For resources with count:
# terraform apply -replace=hw_sandwich.taint_example_sandwiches[0]

# ============================================================================
# Method 3: terraform plan -replace (Preview Replacement)
# ============================================================================
# Preview what will happen when you replace a resource

# Preview replacement:
# terraform plan -replace=hw_sandwich.taint_example_sandwich
#
# Output will show:
#   # hw_sandwich.taint_example_sandwich must be replaced
#   -/+ resource "hw_sandwich" "taint_example_sandwich" {
#         ...
#       } # forces replacement

# ============================================================================
# Scenario 1: Resource in Bad State
# ============================================================================
# Resource is corrupted or unresponsive, needs to be recreated

resource "hw_sandwich" "taint_corrupted_sandwich" {
  bread_id    = hw_bread.taint_example_bread.id
  meat_id     = hw_meat.taint_example_meat.id
  description = "Sandwich that may become corrupted and need recreation"
}

# When resource is corrupted:
# Step 1: Taint the resource
#   terraform apply -replace=hw_sandwich.taint_corrupted_sandwich
#
# Step 2: Apply to recreate
#   terraform apply
#
# Result: Resource is destroyed and recreated with same configuration

# ============================================================================
# Scenario 2: Force Resource Refresh
# ============================================================================
# Force Terraform to refresh resource state, even if no changes

resource "hw_bread" "taint_refresh_bread" {
  kind        = "sourdough"
  description = "Bread that needs to be refreshed"
}

# Force refresh by tainting:
# terraform apply -replace=hw_bread.taint_refresh_bread
# terraform apply

# ============================================================================
# Scenario 3: Testing Resource Lifecycle
# ============================================================================
# Test that resources can be properly created and destroyed

resource "hw_meat" "taint_test_meat" {
  kind        = "ham"
  description = "Meat for testing lifecycle - taint to test recreation"
}

# Test workflow:
# 1. Create resource: terraform apply
# 2. Taint resource: terraform apply -replace=hw_meat.taint_test_meat
# 3. Verify recreation: terraform apply
# 4. Verify resource works correctly after recreation

# ============================================================================
# Scenario 4: Resources with Dependencies
# ============================================================================
# Tainting a resource that other resources depend on

resource "hw_bread" "taint_dependency_bread" {
  kind        = "ciabatta"
  description = "Bread that other resources depend on"
}

resource "hw_meat" "taint_dependency_meat" {
  kind        = "roast beef"
  description = "Meat that other resources depend on"
}

resource "hw_sandwich" "taint_dependent_sandwich" {
  bread_id    = hw_bread.taint_dependency_bread.id
  meat_id     = hw_meat.taint_dependency_meat.id
  description = "Sandwich that depends on bread and meat"
}

# Tainting a dependency:
# terraform apply -replace=hw_bread.taint_dependency_bread
#
# Terraform will:
# 1. Destroy dependent resources first (sandwich)
# 2. Destroy the tainted resource (bread)
# 3. Recreate bread
# 4. Recreate dependent resources (sandwich)
#
# Order matters: Dependencies are handled automatically

# ============================================================================
# Scenario 5: Tainting Multiple Resources
# ============================================================================
# Taint multiple resources at once

resource "hw_sandwich" "taint_multiple_sandwiches" {
  for_each = toset(["turkey", "ham", "roast beef"])
  bread_id = hw_bread.taint_example_bread.id
  meat_id  = hw_meat.taint_example_meat.id
  description = "Sandwich ${each.value}"
}

# Taint multiple resources:
# terraform apply \
#   -replace='hw_sandwich.taint_multiple_sandwiches["turkey"]' \
#   -replace='hw_sandwich.taint_multiple_sandwiches["ham"]' \
#   -replace='hw_sandwich.taint_multiple_sandwiches["roast beef"]'

# Or taint all instances:
# terraform apply -replace=hw_sandwich.taint_multiple_sandwiches

# ============================================================================
# Scenario 6: Untainting Resources
# ============================================================================
# Remove taint mark without applying (terraform taint only)

# If you tainted a resource but changed your mind:
# terraform untaint hw_sandwich.taint_example_sandwich
#
# Note: terraform apply -replace doesn't have an "unreplace" command
# Instead, just don't run terraform apply, or use terraform plan to preview

# ============================================================================
# Scenario 7: Tainting with Count
# ============================================================================
# Tainting resources that use count

resource "hw_sandwich" "taint_count_sandwiches" {
  count       = 3
  bread_id    = hw_bread.taint_example_bread.id
  meat_id     = hw_meat.taint_example_meat.id
  description = "Sandwich ${count.index + 1}"
}

# Taint specific indexed resource:
# terraform apply -replace=hw_sandwich.taint_count_sandwiches[0]
# terraform apply -replace=hw_sandwich.taint_count_sandwiches[1]
# terraform apply -replace=hw_sandwich.taint_count_sandwiches[2]

# ============================================================================
# Taint Workflow: Step-by-Step
# ============================================================================
#
# Step 1: Identify resource to taint
#   - Resource is corrupted, needs refresh, or testing
#   - Note the resource address
#
# Step 2: Preview replacement (optional but recommended)
#   terraform plan -replace=hw_sandwich.example
#   - Review what will be destroyed and recreated
#   - Verify this is what you want
#
# Step 3: Taint the resource
#   Option A (modern): terraform apply -replace=hw_sandwich.example
#   Option B (legacy): terraform taint hw_sandwich.example
#
# Step 4: Apply changes
#   terraform apply
#   - Resource will be destroyed and recreated
#   - Verify resource is in correct state after recreation
#
# Step 5: Verify
#   terraform plan
#   - Should show no changes (resource matches configuration)
#   - Resource should be functioning correctly

# ============================================================================
# Common Use Cases for Tainting
# ============================================================================
#
# 1. Resource Corruption
#    - Resource is in bad state
#    - Provider can't fix it with update
#    - Solution: Taint and recreate
#
# 2. Configuration Drift
#    - Resource was modified outside Terraform
#    - Terraform can't reconcile the changes
#    - Solution: Taint and recreate to match configuration
#
# 3. Testing
#    - Test resource creation/deletion
#    - Verify lifecycle hooks work
#    - Test backup/restore procedures
#
# 4. Forcing Refresh
#    - Resource state is stale
#    - Need to refresh from provider
#    - Solution: Taint to force refresh
#
# 5. Debugging
#    - Troubleshoot resource issues
#    - Test different configurations
#    - Verify provider behavior
#
# 6. Security
#    - Rotate credentials/secrets
#    - Force regeneration of sensitive data
#    - Recreate resources with new keys

# ============================================================================
# Taint vs Other Operations
# ============================================================================
#
# Taint (terraform apply -replace):
#   - Destroys and recreates resource
#   - Same configuration
#   - Use when: resource needs refresh or is corrupted
#
# Destroy and Recreate (terraform destroy + apply):
#   - Manual two-step process
#   - More control but more steps
#   - Use when: you want to review between steps
#
# Update (terraform apply with config change):
#   - Updates resource in place
#   - Configuration changed
#   - Use when: making configuration changes
#
# Refresh (terraform refresh):
#   - Updates state from provider
#   - No changes to resource
#   - Use when: state is out of sync

# ============================================================================
# Best Practices for Tainting
# ============================================================================
#
# 1. Always preview first
#    terraform plan -replace=<resource>
#    - See what will be destroyed/recreated
#    - Verify this is what you want
#
# 2. Taint during maintenance windows
#    - Resources will be temporarily unavailable
#    - Plan for downtime if needed
#    - Coordinate with team
#
# 3. Backup before tainting critical resources
#    - Export resource data if possible
#    - Backup state file
#    - Document current state
#
# 4. Use -target for complex dependencies
#    terraform apply -target=hw_sandwich.example -replace=hw_sandwich.example
#    - Focus operations on specific resources
#    - Reduce scope of changes
#
# 5. Verify after recreation
#    - Check resource is functioning
#    - Verify configuration is correct
#    - Run terraform plan to confirm no drift
#
# 6. Use modern -replace flag
#    - Prefer terraform apply -replace over terraform taint
#    - More explicit and clear
#    - Better integration with plan
#
# 7. Document taint operations
#    - Note why resource was tainted
#    - Document any issues encountered
#    - Update runbooks if needed
#
# 8. Test in non-production first
#    - Verify taint behavior
#    - Test recovery procedures
#    - Understand impact before production
#
# 9. Consider dependencies
#    - Tainting a resource may affect dependents
#    - Review dependency graph
#    - Plan for cascading effects
#
# 10. Use sparingly
#     - Taint is a workaround, not a solution
#     - Investigate root cause of issues
#     - Fix underlying problems when possible

# ============================================================================
# Example: Complete Taint Workflow
# ============================================================================
#
# Scenario: Sandwich resource is corrupted and needs recreation
#
# Step 1: Check current state
#   terraform state show hw_sandwich.taint_example_sandwich
#   # Review current resource state
#
# Step 2: Preview replacement
#   terraform plan -replace=hw_sandwich.taint_example_sandwich
#   # Review what will be destroyed and recreated
#
# Step 3: Taint the resource
#   terraform apply -replace=hw_sandwich.taint_example_sandwich
#   # Resource is marked for replacement
#
# Step 4: Apply to recreate
#   terraform apply
#   # Resource is destroyed and recreated
#
# Step 5: Verify
#   terraform plan
#   # Should show: No changes
#
# Step 6: Test resource
#   # Verify resource is functioning correctly
#   # Check that it matches expected configuration

# ============================================================================
# Taint with Modules
# ============================================================================
# Tainting resources inside modules

# If resource is in a module:
# terraform apply -replace=module.party_pack.hw_sandwich.example
#
# Syntax: module.<module_name>.<resource_type>.<resource_name>
#
# Example:
# terraform apply -replace=module.sandwich_shop.hw_sandwich.production

# ============================================================================
# Checking Taint Status
# ============================================================================
# See which resources are marked for replacement

# Run terraform plan to see tainted resources:
# terraform plan
#
# Output will show:
#   # hw_sandwich.example must be replaced
#   -/+ resource "hw_sandwich" "example" {
#         ...
#       } # forces replacement
#
# The "-/+" indicates destroy and create (replacement)

# ============================================================================
# Outputs for Tainted Resources
# ============================================================================

output "taint_example_sandwich_id" {
  description = "ID of taint example sandwich (will change after taint/recreation)"
  value       = hw_sandwich.taint_example_sandwich.id
}

output "taint_workflow_note" {
  description = "Note about taint workflow"
  value = {
    message = "Taint resources to force recreation"
    method_modern = "terraform apply -replace=<resource>"
    method_legacy = "terraform taint <resource>"
    note = "Use -replace for modern Terraform versions"
  }
}
