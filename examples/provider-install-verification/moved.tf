# Example demonstrating moved blocks in Terraform
# Moved blocks tell Terraform that a resource has been renamed or moved
# without destroying and recreating it. This is essential for refactoring.

# ============================================================================
# Scenario 1: Simple resource rename
# ============================================================================
# Use case: You renamed a resource and want Terraform to recognize it's the same
# Example: Renamed "old_sandwich" to "new_sandwich"

resource "hw_bread" "moved_old_bread" {
  kind        = "rye"
  description = "Bread that will be renamed"
}

resource "hw_meat" "moved_old_meat" {
  kind        = "turkey"
  description = "Meat that will be renamed"
}

# Original resource name (if this already exists in state)
# After adding the moved block below, you can rename this to "moved_new_sandwich"
resource "hw_sandwich" "moved_old_sandwich" {
  bread_id    = hw_bread.moved_old_bread.id
  meat_id     = hw_meat.moved_old_meat.id
  description = "Old sandwich name - will be moved to new name"
}

# Moved block: Tell Terraform this resource was renamed
# Uncomment this and rename the resource above to see it in action
# moved {
#   from = hw_sandwich.moved_old_sandwich
#   to   = hw_sandwich.moved_new_sandwich
# }

# After applying the moved block, you would rename to:
# resource "hw_sandwich" "moved_new_sandwich" {
#   bread_id    = hw_bread.moved_old_bread.id
#   meat_id     = hw_meat.moved_old_meat.id
#   description = "New sandwich name - same resource, just renamed"
# }

# ============================================================================
# Scenario 2: Moving from count to for_each
# ============================================================================
# Use case: Refactoring from count to for_each for better control
# Example: Moving indexed resources to keyed resources

resource "hw_bread" "moved_count_bread" {
  count       = 2
  kind        = count.index == 0 ? "rye" : "wheat"
  description = "Bread ${count.index + 1} for count example"
}

resource "hw_meat" "moved_count_meat" {
  count       = 2
  kind        = count.index == 0 ? "turkey" : "ham"
  description = "Meat ${count.index + 1} for count example"
}

resource "hw_sandwich" "moved_count_sandwich" {
  count       = 2
  bread_id    = hw_bread.moved_count_bread[count.index].id
  meat_id     = hw_meat.moved_count_meat[count.index].id
  description = "Sandwich ${count.index + 1} - using count"
}

# Moved blocks: Moving from count[0] and count[1] to for_each with specific keys
# Uncomment these to move from count to for_each:
# moved {
#   from = hw_sandwich.moved_count_sandwich[0]
#   to   = hw_sandwich.moved_for_each_sandwich["sandwich_1"]
# }
#
# moved {
#   from = hw_sandwich.moved_count_sandwich[1]
#   to   = hw_sandwich.moved_for_each_sandwich["sandwich_2"]
# }

# After applying moved blocks, you would create:
# resource "hw_sandwich" "moved_for_each_sandwich" {
#   for_each = {
#     sandwich_1 = {
#       bread = "rye"
#       meat  = "turkey"
#     }
#     sandwich_2 = {
#       bread = "wheat"
#       meat  = "ham"
#     }
#   }
#   bread_id    = hw_bread.moved_count_bread[each.value.bread == "rye" ? 0 : 1].id
#   meat_id     = hw_meat.moved_count_meat[each.value.meat == "turkey" ? 0 : 1].id
#   description = "Sandwich ${each.key} - using for_each"
# }

# ============================================================================
# Scenario 3: Renaming keys in for_each
# ============================================================================
# Use case: Changing the key names in a for_each map
# Example: Changing from descriptive keys to ID-based keys

resource "hw_bread" "moved_for_each_bread" {
  for_each = {
    bread_1 = "ciabatta"
    bread_2 = "baguette"
  }
  kind        = each.value
  description = "Bread ${each.key}"
}

resource "hw_meat" "moved_for_each_meat" {
  for_each = {
    meat_1 = "turkey"
    meat_2 = "roast beef"
  }
  kind        = each.value
  description = "Meat ${each.key}"
}

resource "hw_sandwich" "moved_for_each_sandwich" {
  for_each = {
    old_key_1 = {
      bread = "bread_1"
      meat  = "meat_1"
    }
    old_key_2 = {
      bread = "bread_2"
      meat  = "meat_2"
    }
  }
  bread_id    = hw_bread.moved_for_each_bread[each.value.bread].id
  meat_id     = hw_meat.moved_for_each_meat[each.value.meat].id
  description = "Sandwich with old key: ${each.key}"
}

# Moved blocks: Moving from old keys to new keys in for_each
# Uncomment these to rename the keys:
# moved {
#   from = hw_sandwich.moved_for_each_sandwich["old_key_1"]
#   to   = hw_sandwich.moved_for_each_sandwich["new_key_1"]
# }
#
# moved {
#   from = hw_sandwich.moved_for_each_sandwich["old_key_2"]
#   to   = hw_sandwich.moved_for_each_sandwich["new_key_2"]
# }

# After applying, update the for_each map keys:
# resource "hw_sandwich" "moved_for_each_sandwich" {
#   for_each = {
#     new_key_1 = { ... }  # same values, new key
#     new_key_2 = { ... }  # same values, new key
#   }
#   ...
# }

# ============================================================================
# Scenario 4: Demonstrating the moved block workflow
# ============================================================================
# This example shows the proper workflow for using moved blocks

resource "hw_bread" "moved_demo_bread" {
  kind        = "sourdough"
  description = "Bread for move demonstration"
}

resource "hw_meat" "moved_demo_meat" {
  kind        = "ham"
  description = "Meat for move demonstration"
}

# STEP 1: Original resource (if this exists in your state)
# If you have a resource named "moved_demo_original" in your state,
# you would add the moved block below and then rename this resource

# Original resource (commented out to show the workflow)
# resource "hw_sandwich" "moved_demo_original" {
#   bread_id    = hw_bread.moved_demo_bread.id
#   meat_id     = hw_meat.moved_demo_meat.id
#   description = "Original sandwich - this will be moved"
# }

# STEP 2: Add the moved block (uncomment when ready to test)
# moved {
#   from = hw_sandwich.moved_demo_original
#   to   = hw_sandwich.moved_demo_renamed
# }

# STEP 3: The "new" resource (after the move)
# After applying the moved block, this is the resource that will exist
resource "hw_sandwich" "moved_demo_renamed" {
  bread_id    = hw_bread.moved_demo_bread.id
  meat_id     = hw_meat.moved_demo_meat.id
  description = "Renamed sandwich - moved from moved_demo_original"
}

# Workflow to test this:
# 1. Uncomment the "moved_demo_original" resource above
# 2. Run terraform apply to create it
# 3. Comment out "moved_demo_original" and uncomment the moved block
# 4. Uncomment "moved_demo_renamed" (already uncommented)
# 5. Run terraform plan - you'll see a "moved" operation, not destroy/create
# 6. Run terraform apply
# 7. Remove the moved block (it's only needed once)

# ============================================================================
# Scenario 5: Moving multiple resources in a refactoring
# ============================================================================
# Use case: Restructuring your configuration and moving multiple related resources

resource "hw_bread" "moved_refactor_bread_1" {
  kind        = "multigrain"
  description = "Bread 1 for refactoring example"
}

resource "hw_bread" "moved_refactor_bread_2" {
  kind        = "whole wheat"
  description = "Bread 2 for refactoring example"
}

resource "hw_meat" "moved_refactor_meat_1" {
  kind        = "chicken"
  description = "Meat 1 for refactoring example"
}

resource "hw_meat" "moved_refactor_meat_2" {
  kind        = "pastrami"
  description = "Meat 2 for refactoring example"
}

resource "hw_sandwich" "moved_refactor_sandwich_1" {
  bread_id    = hw_bread.moved_refactor_bread_1.id
  meat_id     = hw_meat.moved_refactor_meat_1.id
  description = "Sandwich 1 - will be moved during refactoring"
}

resource "hw_sandwich" "moved_refactor_sandwich_2" {
  bread_id    = hw_bread.moved_refactor_bread_2.id
  meat_id     = hw_meat.moved_refactor_meat_2.id
  description = "Sandwich 2 - will be moved during refactoring"
}

# Multiple moved blocks for a refactoring operation
# Uncomment to move both sandwiches:
# moved {
#   from = hw_sandwich.moved_refactor_sandwich_1
#   to   = hw_sandwich.refactored_sandwich_1
# }
#
# moved {
#   from = hw_sandwich.moved_refactor_sandwich_2
#   to   = hw_sandwich.refactored_sandwich_2
# }

# ============================================================================
# Important Notes and Workflow:
# ============================================================================
# 1. Moved blocks are processed during terraform plan/apply
# 2. After applying a moved block, you can remove it - it's only needed once
# 3. Moved blocks don't change the actual resource, just Terraform's state
# 4. Always run terraform plan first to verify the move will work correctly
# 5. Moved blocks are idempotent - safe to run multiple times
#
# Typical Workflow:
# Step 1: Add the moved block pointing from old to new address
# Step 2: Run terraform plan - you should see "moved" operations, not "destroy/create"
# Step 3: Apply the changes
# Step 4: Update your resource definition to match the "to" address
# Step 5: Remove the moved block (optional, but recommended after move is complete)
#
# Example:
#   moved {
#     from = hw_sandwich.old_name
#     to   = hw_sandwich.new_name
#   }
#   
#   Then rename: resource "hw_sandwich" "old_name" -> "new_name"

# ============================================================================
# Outputs to demonstrate moved resources
# ============================================================================

output "moved_demo_renamed_id" {
  description = "ID of the renamed sandwich (after move)"
  value       = hw_sandwich.moved_demo_renamed.id
  # Note: After applying the moved block, this will have the same ID
  # as the original resource because it's the same resource, just tracked under a new name
}

output "moved_for_each_sandwich_ids" {
  description = "IDs of sandwiches using for_each (can be moved to new keys)"
  value = {
    for k, v in hw_sandwich.moved_for_each_sandwich : k => v.id
  }
}
