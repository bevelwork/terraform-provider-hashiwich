# Example demonstrating try() with map/object key access
# Scenario: Access a map value that might not have the key

# Create a price map
locals {
  try_price_map = {
    sandwich = 5.00
    drink    = 1.00
    soup     = 2.50
    salad    = 4.00
    cookie   = 1.50
    brownie  = 2.00
  }

  # Try to get soup price, but it might not be in the map
  # This is safe even if the key doesn't exist
  soup_price = try(
    local.try_price_map["soup"],
    2.50 # fallback if key doesn't exist
  )

  # Try to get a price for an item that doesn't exist in the map
  stroopwafel_price = try(
    local.try_price_map["stroopwafel"],
    1.75 # fallback - this key doesn't exist, so uses fallback
  )

  # Try multiple keys in order
  dessert_price = try(
    local.try_price_map["cookie"],
    local.try_price_map["brownie"],
    2.00 # fallback if neither exists
  )
}

# Create resources using the map with try()
resource "hw_soup" "try_map_example" {
  kind        = "tomato"
  temperature = "hot"
}

resource "hw_stroopwafel" "try_map_example" {
  kind = "classic"
}

# Compare actual prices vs map prices
locals {
  # Actual resource price vs map price
  soup_price_comparison = {
    actual   = hw_soup.try_map_example.price
    from_map = local.soup_price
  }

  stroopwafel_price_comparison = {
    actual   = hw_stroopwafel.try_map_example.price
    from_map = local.stroopwafel_price
  }
}

# Output to demonstrate map key access
output "try_map_soup_price" {
  description = "Soup price from map (with fallback if key missing)"
  value       = local.soup_price
}

output "try_map_stroopwafel_price" {
  description = "Stroopwafel price from map (uses fallback since key doesn't exist)"
  value       = local.stroopwafel_price
}

output "try_map_price_comparison" {
  description = "Comparison of actual prices vs map prices"
  value = {
    soup        = local.soup_price_comparison
    stroopwafel = local.stroopwafel_price_comparison
  }
}

# Example: Try to get price from a conditional map
locals {
  # Map that might or might not have certain keys based on condition
  has_desserts = true
  conditional_prices = local.has_desserts ? {
    cookie  = 1.50
    brownie = 2.00
  } : {}

  # Try to get price, with fallback
  conditional_cookie_price = try(
    local.conditional_prices["cookie"],
    0 # fallback if map is empty or key doesn't exist
  )
}
