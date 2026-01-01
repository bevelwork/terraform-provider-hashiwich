# Example demonstrating provider aliases and upcharge configuration
# Airport locations charge a $10.00 upcharge on all items

# Configure the airport provider alias with $10.00 upcharge
provider "hw" {
  alias    = "airport"
  upcharge = 10.00
}

# Create bread for the airport sandwich
resource "hw_bread" "airport_bread" {
  provider    = hw.airport
  kind        = "ciabatta"
  description = "Bread for airport sandwich"
}

# Create meat for the airport sandwich
resource "hw_meat" "airport_meat" {
  provider    = hw.airport
  kind        = "turkey"
  description = "Turkey for airport sandwich"
}

# Create sandwich at airport (base $5.00 + $10.00 upcharge = $15.00)
resource "hw_sandwich" "airport_combo_sandwich" {
  provider    = hw.airport
  bread_id    = hw_bread.airport_bread.id
  meat_id     = hw_meat.airport_meat.id
  description = "Airport combo sandwich"
}

# Create drink at airport (base $1.00 + $10.00 upcharge = $11.00)
resource "hw_drink" "airport_combo_drink" {
  provider    = hw.airport
  kind        = "cola"
  description = "Airport combo drink"

  dynamic "ice" {
    for_each = [
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

# Calculate total cost of the combo
locals {
  airport_sandwich_price = hw_sandwich.airport_combo_sandwich.price
  airport_drink_price    = hw_drink.airport_combo_drink.price
  airport_total_cost     = local.airport_sandwich_price + local.airport_drink_price
}

# Output the total cost
output "airport_combo_total_cost" {
  description = "Total cost of the airport sandwich and drink combo"
  value       = local.airport_total_cost
}

# Output individual prices for reference
output "airport_sandwich_price" {
  description = "Price of the airport sandwich (base $5.00 + $10.00 upcharge)"
  value       = hw_sandwich.airport_combo_sandwich.price
}

output "airport_drink_price" {
  description = "Price of the airport drink (base $1.00 + $10.00 upcharge)"
  value       = hw_drink.airport_combo_drink.price
}
