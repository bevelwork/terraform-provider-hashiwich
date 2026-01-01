# Example demonstrating try() with optional resource attributes
# Scenario: Get a description from a resource, but use a default if it's not set

# Create a sandwich without a description (description is optional)
resource "hw_bread" "try_bread" {
  kind        = "rye"
  description = "Bread for try example"
}

resource "hw_meat" "try_meat" {
  kind        = "turkey"
  description = "Meat for try example"
}

resource "hw_sandwich" "try_example" {
  bread_id = hw_bread.try_bread.id
  meat_id  = hw_meat.try_meat.id
  # description is optional - intentionally not set, so it will be null
}

# Create another sandwich WITH a description
resource "hw_sandwich" "try_with_description" {
  bread_id    = hw_bread.try_bread.id
  meat_id     = hw_meat.try_meat.id
  description = "This sandwich has a custom description"
}

# Use try() to safely get description with a fallback
locals {
  # Try to get description, fallback to default if null
  try_optional_sandwich_description = try(
    hw_sandwich.try_example.description,
    "A delicious sandwich" # fallback value
  )

  # This one will use the actual description since it exists
  try_optional_sandwich_with_desc = try(
    hw_sandwich.try_with_description.description,
    "Default description"
  )
}

# Output to show the results
output "try_optional_description" {
  description = "Description from sandwich without description (uses fallback)"
  value       = local.try_optional_sandwich_description
}

output "try_with_description_result" {
  description = "Description from sandwich with description (uses actual value)"
  value       = local.try_optional_sandwich_with_desc
}
