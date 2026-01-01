# Example demonstrating try() for environment-specific resources
# Scenario: Reference resources that might exist in one environment but not another

variable "try_environment" {
  description = "Environment name (production, staging, dev)"
  type        = string
  default     = "dev"
}

# Airport provider with upcharge (typically only in production)
provider "hw" {
  alias    = "try_airport"
  upcharge = 10.00
}

# Create airport resources only in production
resource "hw_bread" "try_env_airport_bread" {
  count    = var.try_environment == "production" ? 1 : 0
  provider = hw.try_airport
  kind     = "ciabatta"
}

resource "hw_meat" "try_env_airport_meat" {
  count    = var.try_environment == "production" ? 1 : 0
  provider = hw.try_airport
  kind     = "turkey"
}

resource "hw_sandwich" "try_env_airport" {
  count    = var.try_environment == "production" ? 1 : 0
  provider = hw.try_airport
  bread_id = hw_bread.try_env_airport_bread[0].id
  meat_id  = hw_meat.try_env_airport_meat[0].id
}

# Regular resources (exist in all environments)
resource "hw_bread" "try_env_regular_bread" {
  kind = "rye"
}

resource "hw_meat" "try_env_regular_meat" {
  kind = "turkey"
}

resource "hw_sandwich" "try_env_regular" {
  bread_id = hw_bread.try_env_regular_bread.id
  meat_id  = hw_meat.try_env_regular_meat.id
}

# Use try() to safely access environment-specific resources
locals {
  # Try to get airport sandwich price (only exists in production)
  # Falls back to regular sandwich price in other environments
  try_env_sandwich_price = try(
    hw_sandwich.try_env_airport[0].price, # production: airport price
    hw_sandwich.try_env_regular.price     # dev/staging: regular price
  )

  # Try to get airport sandwich description
  try_env_sandwich_description = try(
    hw_sandwich.try_env_airport[0].description,
    hw_sandwich.try_env_regular.description,
    "Standard sandwich"
  )

  # Determine which environment we're using based on resource existence
  try_env_is_production = try(
    hw_sandwich.try_env_airport[0].id != null,
    false
  )
}

# Output that works in all environments
output "try_env_sandwich_price" {
  description = "Sandwich price (airport in production, regular in dev/staging)"
  value       = local.try_env_sandwich_price
}

output "try_env_sandwich_description" {
  description = "Sandwich description (works in all environments)"
  value       = local.try_env_sandwich_description
}

output "try_env_is_production" {
  description = "Whether we're in production (based on resource existence)"
  value       = local.try_env_is_production
}

# Example: Try to get environment-specific totals
locals {
  # Try to calculate total cost differently per environment
  try_env_total_cost = try(
    # Production: try airport prices
    hw_sandwich.try_env_airport[0].price,
    # Dev/Staging: use regular prices
    hw_sandwich.try_env_regular.price,
    # Fallback
    0
  )
}

output "try_env_total_cost" {
  description = "Total cost (environment-specific)"
  value       = local.try_env_total_cost
}
