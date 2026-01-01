# Example demonstrating ignore_changes lifecycle block
# ignore_changes tells Terraform to ignore changes to specific attributes
# Useful when attributes are managed outside of Terraform or change frequently

# ============================================================================
# Scenario 1: Ignoring Single Attribute
# ============================================================================
# Ignore changes to description - allow manual updates without Terraform reverting

resource "hw_bread" "ignore_single_bread" {
  kind        = "rye"
  description = "This description can be changed manually without Terraform reverting it"

  lifecycle {
    ignore_changes = [description]
    # Terraform will ignore any changes to the description attribute
    # Useful when descriptions are managed by external systems or users
  }
}

resource "hw_meat" "ignore_single_meat" {
  kind        = "turkey"
  description = "Meat with ignored description"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "hw_sandwich" "ignore_single_sandwich" {
  bread_id    = hw_bread.ignore_single_bread.id
  meat_id     = hw_meat.ignore_single_meat.id
  description = "Sandwich with ignored description"

  lifecycle {
    ignore_changes = [description]
  }
}

# ============================================================================
# Scenario 2: Ignoring Multiple Attributes
# ============================================================================
# Ignore changes to multiple attributes

resource "hw_bread" "ignore_multiple_bread" {
  kind        = "sourdough"
  description = "Bread with multiple ignored attributes"

  lifecycle {
    ignore_changes = [
      description,
      # Add more attributes here if needed
    ]
  }
}

# ============================================================================
# Scenario 3: Ignoring All Changes
# ============================================================================
# Ignore all changes after initial creation
# Resource is created by Terraform but then managed manually

resource "hw_bread" "ignore_all_bread" {
  kind        = "ciabatta"
  description = "Created by Terraform, but managed manually after creation"

  lifecycle {
    ignore_changes = all
    # After initial creation, Terraform will ignore ALL changes
    # Useful for resources that are "handed off" to other systems
    # or managed through a different interface
  }
}

# ============================================================================
# Scenario 4: Ignoring Tags/Labels (Common Pattern)
# ============================================================================
# In real cloud providers, tags are often managed separately
# This pattern shows how to ignore tag changes

# Example pattern (commented since we don't have tags):
# resource "aws_instance" "example" {
#   # ... other config ...
#   tags = {
#     Name = "example"
#     Environment = "dev"
#   }
#
#   lifecycle {
#     ignore_changes = [tags]
#     # Tags might be managed by a tag management system
#     # Terraform won't revert tag changes made outside Terraform
#   }
# }

# ============================================================================
# Scenario 5: Ignoring Computed Attributes
# ============================================================================
# Sometimes computed attributes change due to external factors
# You might want to ignore those changes

resource "hw_sandwich" "ignore_computed_sandwich" {
  bread_id    = hw_bread.ignore_single_bread.id
  meat_id     = hw_meat.ignore_single_meat.id
  description = "Sandwich with ignored price (if price changes externally)"

  lifecycle {
    # Note: price is computed, but if it were to change externally,
    # you could ignore it like this:
    # ignore_changes = [price]
    # For this example, we'll ignore description
    ignore_changes = [description]
  }
}

# ============================================================================
# Scenario 6: Conditional ignore_changes
# ============================================================================
# You can't conditionally set ignore_changes, but you can use
# separate resources with different ignore_changes configurations

# Example: Different ignore rules for different environments
# resource "hw_bread" "dev_bread" {
#   kind        = "rye"
#   description = "Dev bread - ignore description changes"
#
#   lifecycle {
#     ignore_changes = [description]
#   }
# }
#
# resource "hw_bread" "prod_bread" {
#   kind        = "rye"
#   description = "Prod bread - manage all changes"
#
#   lifecycle {
#     # No ignore_changes - Terraform manages everything
#   }
# }

# ============================================================================
# Scenario 7: Combining ignore_changes with Other Lifecycle Rules
# ============================================================================
# You can combine ignore_changes with other lifecycle rules

resource "hw_bread" "ignore_combined_bread" {
  kind        = "multigrain"
  description = "Bread with multiple lifecycle rules"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [description]
    # This bread cannot be destroyed AND description changes are ignored
  }
}

resource "hw_meat" "ignore_combined_meat" {
  kind        = "chicken"
  description = "Meat with multiple lifecycle rules"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [description]
  }
}

resource "hw_sandwich" "ignore_combined_sandwich" {
  bread_id    = hw_bread.ignore_combined_bread.id
  meat_id     = hw_meat.ignore_combined_meat.id
  description = "Sandwich with combined lifecycle rules"

  lifecycle {
    prevent_destroy       = true
    ignore_changes        = [description]
    create_before_destroy = true
    # Multiple rules can be combined:
    # - Cannot be destroyed
    # - Description changes are ignored
    # - Created before destroyed during updates
  }
}

# ============================================================================
# Scenario 8: Ignoring Nested Attributes
# ============================================================================
# For resources with nested objects, you can ignore specific nested attributes

# Example pattern (if we had nested attributes):
# resource "some_resource" "example" {
#   config {
#     setting1 = "value1"
#     setting2 = "value2"
#   }
#
#   lifecycle {
#     ignore_changes = [config.setting2]
#     # Only ignore changes to setting2, not setting1
#   }
# }

# ============================================================================
# Common Use Cases for ignore_changes
# ============================================================================
#
# 1. External Management
#    - Attributes managed by other systems
#    - Manual changes that shouldn't be reverted
#    - Third-party tool modifications
#
# 2. Frequently Changing Attributes
#    - Timestamps that update automatically
#    - Status fields that change frequently
#    - Metrics or counters
#
# 3. Tag/Label Management
#    - Tags managed by tag management systems
#    - Labels added by monitoring tools
#    - Cost allocation tags
#
# 4. Computed Attributes
#    - Attributes computed by the provider
#    - Values that change based on external state
#    - Auto-generated values
#
# 5. Gradual Migration
#    - Migrating from manual to Terraform management
#    - Phased adoption of infrastructure as code
#    - Temporary ignore during transition

# ============================================================================
# Best Practices
# ============================================================================
#
# 1. Use sparingly
#    - Only ignore attributes that truly need to be managed externally
#    - Document why attributes are ignored
#
# 2. Be specific
#    - Ignore specific attributes, not all changes
#    - Use ignore_changes = [attribute] instead of ignore_changes = all
#
# 3. Document the reason
#    - Add comments explaining why attributes are ignored
#    - Note what system manages the ignored attributes
#
# 4. Review regularly
#    - Periodically check if ignore_changes is still needed
#    - Consider migrating to full Terraform management when possible
#
# 5. Test changes
#    - Verify that ignored attributes don't cause issues
#    - Test that Terraform doesn't try to revert changes
#
# 6. Use with caution
#    - ignore_changes can hide configuration drift
#    - May lead to unexpected behavior if not understood
#
# 7. Combine with other tools
#    - Use with terraform plan to see what would change
#    - Monitor ignored attributes separately if needed

# ============================================================================
# Testing ignore_changes
# ============================================================================
#
# To test that ignore_changes works:
#
# 1. Create the resource:
#    terraform apply
#
# 2. Manually change the ignored attribute (if possible):
#    # For example, change description in the provider/API
#
# 3. Run terraform plan:
#    terraform plan
#    # Should show: No changes (ignored attribute changes are not shown)
#
# 4. Change a non-ignored attribute:
#    # Change kind instead of description
#
# 5. Run terraform plan again:
#    terraform plan
#    # Should show changes to the non-ignored attribute
#    # Ignored attribute changes are still not shown

# ============================================================================
# Outputs
# ============================================================================

output "ignore_changes_example" {
  description = "Example resources demonstrating ignore_changes"
  value = {
    single_ignore = {
      bread_id    = hw_bread.ignore_single_bread.id
      description = hw_bread.ignore_single_bread.description
      note        = "Description changes are ignored"
    }
    all_ignore = {
      bread_id    = hw_bread.ignore_all_bread.id
      description = hw_bread.ignore_all_bread.description
      note        = "All changes are ignored after creation"
    }
    combined = {
      sandwich_id = hw_sandwich.ignore_combined_sandwich.id
      description = hw_sandwich.ignore_combined_sandwich.description
      note        = "Combined with prevent_destroy and create_before_destroy"
    }
  }
}
