# Example showing conditional logic for ice based on drink kind using dynamic blocks
# When drink kind contains "hot", use "lots" ice
# Otherwise, use "some" ice

# Variable for the drink kind
variable "drink_kind" {
  description = "The kind of drink to create"
  type        = string
  default     = "tea"
}

# Local values for conditional ice configuration
locals {
  # Ice configuration map for dynamic block
  ice_configs = {
    hot = {
      some = false
      lots = true
      max  = false
    }
    default = {
      some = true
      lots = false
      max  = false
    }
  }
}

# Example 1: Tea with conditional ice block using dynamic (will use "some")
resource "hw_drink" "conditional_tea" {
  kind = "tea"

  dynamic "ice" {
    for_each = strcontains("tea", "hot") ? [local.ice_configs.hot] : [local.ice_configs.default]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Tea with conditional ice: uses 'some' because it doesn't contain 'hot'"
}

# Example 2: Hot tea using dynamic block (will use "lots")
resource "hw_drink" "conditional_hot_tea" {
  kind = "hot tea"

  dynamic "ice" {
    for_each = strcontains("hot tea", "hot") ? [local.ice_configs.hot] : [local.ice_configs.default]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Hot tea with conditional ice: uses 'lots' because it contains 'hot'"
}

# Example 3: Using variable with dynamic block
resource "hw_drink" "variable_conditional" {
  kind = var.drink_kind

  dynamic "ice" {
    for_each = strcontains(var.drink_kind, "hot") ? [local.ice_configs.hot] : [local.ice_configs.default]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Drink with ice determined by variable using dynamic block: ${var.drink_kind}"
}

# Example 4: Using local value with dynamic block
resource "hw_drink" "local_conditional" {
  kind = var.drink_kind

  dynamic "ice" {
    for_each = strcontains(var.drink_kind, "hot") ? [local.ice_configs.hot] : [local.ice_configs.default]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Drink with ice determined by strcontains check using dynamic block"
}

# Example 5: Soda using dynamic block (will use "some")
resource "hw_drink" "conditional_soda" {
  kind = "cola"

  dynamic "ice" {
    for_each = strcontains("cola", "hot") ? [local.ice_configs.hot] : [local.ice_configs.default]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Soda with conditional ice: uses 'some' because it doesn't contain 'hot'"
}
