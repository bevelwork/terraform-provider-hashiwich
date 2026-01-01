# Example demonstrating try() with conditionally created resources
# Scenario: Reference a resource that might not exist based on a condition

locals {
  create_dessert = true # Change to false to see try() in action
}

# Conditionally create a cookie based on local.create_dessert
resource "hw_cookie" "try_optional" {
  count = local.create_dessert ? 1 : 0
  kind  = "chocolate chip"
}

# Conditionally create a brownie
resource "hw_brownie" "try_optional" {
  count = local.create_dessert ? 1 : 0
  kind  = "fudge"
}

# This would error without try() if count = 0
# try() safely handles the case where the resource doesn't exist
output "try_cookie_price" {
  description = "Price of conditionally created cookie (0 if not created)"
  value       = try(hw_cookie.try_optional[0].price, 0)
}

output "try_brownie_price" {
  description = "Price of conditionally created brownie (0 if not created)"
  value       = try(hw_brownie.try_optional[0].price, 0)
}

# You can also use try() to get other attributes
output "try_cookie_kind" {
  description = "Kind of conditionally created cookie (null if not created)"
  value       = try(hw_cookie.try_optional[0].kind, null)
}

# Calculate total cost only if resources exist
locals {
  total_dessert_cost = try(
    hw_cookie.try_optional[0].price + hw_brownie.try_optional[0].price,
    0
  )
}

output "try_total_dessert_cost" {
  description = "Total cost of desserts (0 if none created)"
  value       = local.total_dessert_cost
}
