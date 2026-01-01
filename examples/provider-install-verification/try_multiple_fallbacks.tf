# Example demonstrating try() with multiple fallback values
# Scenario: Try multiple sources in order of preference

variable "try_custom_price" {
  description = "Optional custom price override"
  type        = number
  default     = null
}

# Create a sandwich
resource "hw_bread" "try_fallback_bread" {
  kind        = "rye"
  description = "Bread for fallback example"
}

resource "hw_meat" "try_fallback_meat" {
  kind        = "turkey"
  description = "Meat for fallback example"
}

resource "hw_sandwich" "try_fallback_example" {
  bread_id    = hw_bread.try_fallback_bread.id
  meat_id     = hw_meat.try_fallback_meat.id
  description = "Sandwich for fallback example"
}

# Use try() to attempt multiple values in order
locals {
  # Try custom price first, then resource price, then default
  # try() evaluates left to right and returns the first non-null value
  final_price = try(
    var.try_custom_price,                   # First: try variable (might be null)
    hw_sandwich.try_fallback_example.price, # Second: try resource price
    5.00                                    # Third: fallback to default
  )

  # Another example: try multiple variable sources
  description_source = try(
    var.try_custom_price,                         # This will be null, so try next
    hw_sandwich.try_fallback_example.description, # This exists, so use it
    "Default description"                         # Won't reach here
  )
}

# Output to demonstrate the fallback chain
output "try_fallback_price" {
  description = "Price after trying custom, resource, then default"
  value       = local.final_price
}

output "try_fallback_description" {
  description = "Description after trying multiple sources"
  value       = local.description_source
}

# Example: Try multiple resource attributes
locals {
  # Try to get name, then description, then a default
  display_name = try(
    hw_sandwich.try_fallback_example.name,
    hw_sandwich.try_fallback_example.description,
    "Unknown sandwich"
  )
}

output "try_display_name" {
  description = "Display name from multiple fallback sources"
  value       = local.display_name
}
