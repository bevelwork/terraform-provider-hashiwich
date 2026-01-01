# Example demonstrating lifecycle blocks in Terraform
# Lifecycle blocks control how Terraform manages resource creation, updates, and destruction

# ============================================================================
# Scenario 1: prevent_destroy - Protect critical resources from deletion
# ============================================================================
# Use case: Protect important resources from accidental destruction
# Example: A signature sandwich that should never be deleted

resource "hw_bread" "lifecycle_signature_bread" {
  kind        = "ciabatta"
  description = "Bread for our signature sandwich - DO NOT DELETE"
}

resource "hw_meat" "lifecycle_signature_meat" {
  kind        = "turkey"
  description = "Meat for our signature sandwich - DO NOT DELETE"
}

resource "hw_sandwich" "lifecycle_signature_sandwich" {
  bread_id    = hw_bread.lifecycle_signature_bread.id
  meat_id     = hw_meat.lifecycle_signature_meat.id
  description = "Our signature sandwich - protected from deletion"

  lifecycle {
    prevent_destroy = true
    # This resource cannot be destroyed via terraform destroy
    # To destroy it, you must first remove this lifecycle block
  }
}

# ============================================================================
# Scenario 2: ignore_changes - Ignore changes to specific attributes
# ============================================================================
# Use case: Allow external systems or manual changes without Terraform reverting them
# Example: Allow description to be updated manually without Terraform managing it

resource "hw_bread" "lifecycle_manual_bread" {
  kind        = "sourdough"
  description = "This description can be changed manually without Terraform reverting it"

  lifecycle {
    ignore_changes = [
      description
      # Terraform will ignore changes to the description attribute
      # Useful when attributes are managed outside of Terraform
    ]
  }
}

resource "hw_meat" "lifecycle_manual_meat" {
  kind        = "ham"
  description = "Meat with ignored description"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "hw_sandwich" "lifecycle_manual_sandwich" {
  bread_id    = hw_bread.lifecycle_manual_bread.id
  meat_id     = hw_meat.lifecycle_manual_meat.id
  description = "Sandwich with ignored description"

  lifecycle {
    ignore_changes = [description]
  }
}

# ============================================================================
# Scenario 3: ignore_changes with all - Ignore all changes after creation
# ============================================================================
# Use case: Resources that should be created but then managed elsewhere
# Example: A resource that's created by Terraform but then managed manually

resource "hw_bread" "lifecycle_manual_managed" {
  kind        = "whole wheat"
  description = "Created by Terraform, but managed manually after creation"

  lifecycle {
    ignore_changes = all
    # After initial creation, Terraform will ignore all changes
    # Useful for resources that are "handed off" to other systems
  }
}

# ============================================================================
# Scenario 4: replace_triggered_by - Force replacement when dependencies change
# ============================================================================
# Use case: Force resource replacement when specific values change
# Example: Replace sandwich when bread type changes (new sandwich, not update)

resource "hw_bread" "lifecycle_replace_bread" {
  kind        = "rye"
  description = "Bread that triggers sandwich replacement when changed"
}

resource "hw_meat" "lifecycle_replace_meat" {
  kind        = "turkey"
  description = "Meat for replace example"
}

resource "hw_sandwich" "lifecycle_replace_sandwich" {
  bread_id    = hw_bread.lifecycle_replace_bread.id
  meat_id     = hw_meat.lifecycle_replace_meat.id
  description = "Sandwich that gets replaced when bread changes"

  lifecycle {
    replace_triggered_by = [
      hw_bread.lifecycle_replace_bread.kind
      # When bread.kind changes, this sandwich will be replaced (destroyed and recreated)
      # instead of just updated
    ]
  }
}

# ============================================================================
# Scenario 5: create_before_destroy - Zero-downtime updates
# ============================================================================
# Use case: Create new resource before destroying old one
# Example: Ensure a sandwich is always available during updates

resource "hw_bread" "lifecycle_zero_downtime_bread" {
  kind        = "baguette"
  description = "Bread for zero-downtime sandwich"

  lifecycle {
    create_before_destroy = true
    # Terraform will create the new resource before destroying the old one
    # This ensures the resource is always available during updates
  }
}

resource "hw_meat" "lifecycle_zero_downtime_meat" {
  kind        = "roast beef"
  description = "Meat for zero-downtime sandwich"

  lifecycle {
    create_before_destroy = true
  }
}

resource "hw_sandwich" "lifecycle_zero_downtime_sandwich" {
  bread_id    = hw_bread.lifecycle_zero_downtime_bread.id
  meat_id     = hw_meat.lifecycle_zero_downtime_meat.id
  description = "Sandwich with zero-downtime updates"

  lifecycle {
    create_before_destroy = true
    # New sandwich is created before old one is destroyed
    # Useful for resources that need to maintain availability
  }
}

# ============================================================================
# Scenario 6: Combining multiple lifecycle rules
# ============================================================================
# Use case: Apply multiple lifecycle rules to a single resource
# Example: Protect from deletion AND ignore certain changes

resource "hw_bread" "lifecycle_combined_bread" {
  kind        = "multigrain"
  description = "Bread with multiple lifecycle rules"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [description]
    # This bread cannot be destroyed AND description changes are ignored
  }
}

resource "hw_meat" "lifecycle_combined_meat" {
  kind        = "chicken"
  description = "Meat with multiple lifecycle rules"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [description]
  }
}

resource "hw_sandwich" "lifecycle_combined_sandwich" {
  bread_id    = hw_bread.lifecycle_combined_bread.id
  meat_id     = hw_meat.lifecycle_combined_meat.id
  description = "Sandwich with combined lifecycle rules - protected and flexible"

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
# Outputs to demonstrate lifecycle behavior
# ============================================================================

output "lifecycle_signature_sandwich" {
  description = "Signature sandwich protected from deletion"
  value       = hw_sandwich.lifecycle_signature_sandwich.id
  # Try: terraform destroy - this resource will prevent destruction
}

output "lifecycle_replace_sandwich" {
  description = "Sandwich that gets replaced when bread changes"
  value       = hw_sandwich.lifecycle_replace_sandwich.id
  # Try: Change hw_bread.lifecycle_replace_bread.kind - sandwich will be replaced
}

output "lifecycle_combined_sandwich" {
  description = "Sandwich with multiple lifecycle rules"
  value       = hw_sandwich.lifecycle_combined_sandwich.id
}
