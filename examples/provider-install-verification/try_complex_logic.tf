# Example demonstrating try() combined with conditionals for complex logic
# Scenario: Use try() with conditionals for flexible defaults

# Create some resources
resource "hw_bread" "try_complex_bread" {
  kind        = "rye"
  description = "Bread for complex logic example"
}

resource "hw_meat" "try_complex_meat" {
  kind        = "turkey"
  description = "Meat for complex logic example"
}

resource "hw_sandwich" "try_complex_sandwich" {
  bread_id    = hw_bread.try_complex_bread.id
  meat_id     = hw_meat.try_complex_meat.id
  description = "Sandwich for complex logic"
}

# Create multiple sandwiches using for_each
resource "hw_meat" "try_complex_meats" {
  for_each = toset(["ham", "roast beef", "chicken"])
  kind     = each.value
}

resource "hw_sandwich" "try_complex_sandwiches" {
  for_each    = hw_meat.try_complex_meats
  bread_id    = hw_bread.try_complex_bread.id
  meat_id     = each.value.id
  description = "Sandwich: ${each.value.kind}"
}

# Complex logic: Try to get a total price attribute, but calculate if it doesn't exist
locals {
  # Since resources don't have a total_price attribute, we calculate it
  # This demonstrates using try() with calculations as fallback
  # In a real scenario, you might try a computed attribute first
  try_complex_total_sandwich_cost = sum([for s in hw_sandwich.try_complex_sandwiches : s.price])

  # Calculate count from for_each resources
  try_complex_sandwich_count = length(hw_sandwich.try_complex_sandwiches)

  # Combine try() with conditionals
  # Calculate discounted price (10% off) from regular price
  # This demonstrates using try() with calculations
  try_complex_discounted_price = try(
    hw_sandwich.try_complex_sandwich.price * 0.9, # calculate 10% off
    hw_sandwich.try_complex_sandwich.price        # fallback to regular price
  )
}

# Use try() with functions for complex calculations
locals {
  # Calculate average price from list of sandwiches
  # This demonstrates using try() with calculations as the primary method
  try_complex_average_price = try(
    sum([for s in hw_sandwich.try_complex_sandwiches : s.price]) / length(hw_sandwich.try_complex_sandwiches), # calculate average
    0 # fallback if no sandwiches
  )

  # Calculate total cost using multiple methods with try()
  # Demonstrates try() with calculation fallbacks
  try_complex_total_cost = try(
    sum([for s in hw_sandwich.try_complex_sandwiches : s.price]), # method 1: sum prices from for_each
    local.try_complex_total_sandwich_cost,                         # method 2: use calculated total
    0                                                              # method 3: fallback
  )
}

# Output to demonstrate complex logic
output "try_complex_total_cost" {
  description = "Total cost using try() with calculation fallback"
  value       = local.try_complex_total_sandwich_cost
}

output "try_complex_average_price" {
  description = "Average price using try() with calculation fallback"
  value       = local.try_complex_average_price
}

output "try_complex_discounted_price" {
  description = "Discounted price using try() with conditional calculation"
  value       = local.try_complex_discounted_price
}
