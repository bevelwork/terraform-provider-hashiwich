# Example demonstrating variables and budget constraints
# Purchase as many sandwiches as possible while staying under budget

variable "budget" {
  description = "Total budget in dollars for purchasing sandwiches"
  type        = number
  default     = 100.00
}

# Get menu prices (includes upcharge if configured)
data "hw_menu" "budget_menu" {}

# Create bread and meat resources for the sandwiches
resource "hw_bread" "budget_bread" {
  kind        = "rye"
  description = "Bread for budget example sandwiches"
}

resource "hw_meat" "budget_meat" {
  kind        = "turkey"
  description = "Turkey for budget example sandwiches"
}

# Calculate how many sandwiches we can afford
locals {
  # Get sandwich price from menu (already includes upcharge if configured)
  budget_sandwich_price = data.hw_menu.budget_menu.prices.sandwich

  # Calculate maximum number of sandwiches we can afford
  # Use floor() to ensure we don't exceed budget
  budget_max_sandwiches = floor(var.budget / local.budget_sandwich_price)

  # Create a list of sandwich indices (0, 1, 2, ..., max_sandwiches-1)
  budget_sandwich_indices = range(local.budget_max_sandwiches)
}

# Create as many sandwiches as we can afford
resource "hw_sandwich" "budget_sandwiches" {
  count = local.budget_max_sandwiches

  bread_id    = hw_bread.budget_bread.id
  meat_id     = hw_meat.budget_meat.id
  description = "Budget sandwich #${count.index + 1}"
}

# Calculate total cost and remaining budget
locals {
  # Calculate total cost of all sandwiches
  budget_total_cost = sum([for s in hw_sandwich.budget_sandwiches : s.price])

  # Calculate remaining budget
  budget_remaining = var.budget - local.budget_total_cost

  # Calculate how much we could afford for one more sandwich
  budget_can_afford_more = local.budget_remaining >= local.budget_sandwich_price
}

# Outputs to demonstrate the budget calculation
output "budget_total" {
  description = "Total budget available"
  value       = var.budget
}

output "budget_sandwich_price" {
  description = "Price per sandwich from menu (including any upcharge)"
  value       = local.budget_sandwich_price
}

output "budget_max_sandwiches" {
  description = "Maximum number of sandwiches we can afford"
  value       = local.budget_max_sandwiches
}

output "budget_total_cost" {
  description = "Total cost of all sandwiches purchased"
  value       = local.budget_total_cost
}

output "budget_remaining" {
  description = "Remaining budget after purchasing sandwiches"
  value       = local.budget_remaining
}

output "budget_can_afford_more" {
  description = "Whether we can afford one more sandwich"
  value       = local.budget_can_afford_more
}

output "budget_sandwich_ids" {
  description = "IDs of all sandwiches purchased"
  value       = [for s in hw_sandwich.budget_sandwiches : s.id]
}

output "budget_menu_prices" {
  description = "All menu prices (for reference)"
  value       = data.hw_menu.budget_menu.prices
}
