# Example demonstrating try() with nested data source attributes
# Scenario: Access nested data that might not exist

# Get order data (might have nested structure)
data "hw_order" "try_nested_example" {}

# Use try() to safely access nested attributes
locals {
  # Try to get drink kind from nested order structure
  # If the structure doesn't exist or is null, use fallback
  try_nested_drink_kind = try(
    data.hw_order.try_nested_example.drink.kind,
    "cola" # fallback if drink or kind doesn't exist
  )

  # Try to get sandwich bread type
  try_nested_sandwich_bread = try(
    data.hw_order.try_nested_example.sandwich.bread,
    "rye" # fallback
  )

  # Try to get sandwich meat type
  try_nested_sandwich_meat = try(
    data.hw_order.try_nested_example.sandwich.meat,
    "turkey" # fallback
  )

  # Try to get sandwich name
  try_nested_sandwich_name = try(
    data.hw_order.try_nested_example.sandwich.name,
    "Custom sandwich" # fallback
  )
}

# Create resources based on the order data (with fallbacks)
resource "hw_bread" "try_nested_bread" {
  kind        = local.try_nested_sandwich_bread
  description = "Bread from order data with try() fallback"
}

resource "hw_meat" "try_nested_meat" {
  kind        = local.try_nested_sandwich_meat
  description = "Meat from order data with try() fallback"
}

resource "hw_sandwich" "try_nested_sandwich" {
  bread_id    = hw_bread.try_nested_bread.id
  meat_id     = hw_meat.try_nested_meat.id
  description = "Sandwich created from order: ${local.try_nested_sandwich_name}"
}

# Try to access drink ice configuration (nested list)
locals {
  # Try to get ice configuration, with fallback
  has_ice = try(
    length(data.hw_order.try_nested_example.drink.ice) > 0,
    false
  )
}

# Create drink based on order
resource "hw_drink" "try_nested_drink" {
  kind        = local.try_nested_drink_kind
  description = "Drink from order data with try() fallback"

  # Use try() to conditionally include ice
  dynamic "ice" {
    for_each = try(
      data.hw_order.try_nested_example.drink.ice,
      [] # fallback to empty list if ice doesn't exist
    )
    content {
      some = try(ice.value.some, false)
      lots = try(ice.value.lots, false)
      max  = try(ice.value.max, false)
    }
  }
}

# Output to show nested data access
output "try_nested_drink_kind" {
  description = "Drink kind from nested order data (with fallback)"
  value       = local.try_nested_drink_kind
}

output "try_nested_sandwich_name" {
  description = "Sandwich name from nested order data (with fallback)"
  value       = local.try_nested_sandwich_name
}
