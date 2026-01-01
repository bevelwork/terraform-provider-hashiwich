# Example demonstrating conditional resource creation using count with ternary
# This shows how to create or skip a resource based on a condition

locals {
  count_create_drink        = true
  count_drink_kind          = "cola"
  count_environment         = "dev"
  count_should_create_drink = local.count_create_drink && local.count_drink_kind != ""
}

# Example 1: Simple ternary with count
# If create_drink is true, count = 1 (creates resource)
# If create_drink is false, count = 0 (skips resource)
resource "hw_drink" "conditional" {
  count = local.count_create_drink ? 1 : 0

  kind = local.count_drink_kind

  dynamic "ice" {
    for_each = strcontains(lower(local.count_drink_kind), "hot") ? [] : [
      {
        some = false
        lots = true
        max  = false
      }
    ]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Conditionally created drink: ${local.count_drink_kind}"
}

# Example 2: Ternary based on data source value
data "hw_order" "count_example" {}

# Create bread and meat resources for this example
resource "hw_bread" "count_rye" {
  kind        = "rye"
  description = "Rye bread for conditional count example"
}

resource "hw_meat" "count_turkey" {
  kind        = "turkey"
  description = "Turkey for conditional count example"
}

# Only create bread if the order specifies a bread type
resource "hw_bread" "conditional_from_order" {
  count = data.hw_order.count_example.sandwich.bread != "" ? 1 : 0

  kind        = data.hw_order.count_example.sandwich.bread
  description = "Bread created from order: ${data.hw_order.count_example.sandwich.bread}"
}

# Example 3: Multiple conditions with ternary
# Only create in production environment
resource "hw_sandwich" "production_only" {
  count = local.count_environment == "production" ? 1 : 0

  bread_id    = hw_bread.count_rye.id
  meat_id     = hw_meat.count_turkey.id
  description = "Production-only sandwich"
}

# Example 4: Using locals to compute count value
resource "hw_drink" "with_local" {
  count = local.count_should_create_drink ? 1 : 0

  kind        = local.count_drink_kind
  description = "Drink created based on local value: ${local.count_drink_kind}"

  dynamic "ice" {
    for_each = strcontains(lower(local.count_drink_kind), "hot") ? [] : [
      {
        some = false
        lots = true
        max  = false
      }
    ]
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }
}

# Example 5: Conditional output based on count
output "conditional_drink_id" {
  description = "ID of the conditionally created drink (empty if not created)"
  value       = local.count_create_drink ? hw_drink.conditional[0].id : null
}

output "conditional_drink_created" {
  description = "Whether the drink was created"
  value       = local.count_create_drink
}
