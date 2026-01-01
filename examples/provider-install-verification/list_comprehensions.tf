# Example demonstrating list comprehensions (for expressions)
# Creates a sandwich for every kind of meat on rye bread

# Get all available deli meats
data "hw_deli_meats" "list_comp_available" {}

# Create rye bread (one resource for all sandwiches)
resource "hw_bread" "list_comp_rye" {
  kind        = "rye"
  description = "Rye bread for all list comprehension sandwiches"
}

# Create a meat resource for each type of meat using for_each
# This creates one resource per unique meat type
resource "hw_meat" "list_comp_meats" {
  for_each = toset(data.hw_deli_meats.list_comp_available.meats)

  kind        = each.value
  description = "Meat for list comprehension example: ${each.value}"
}

# Create a sandwich for each meat type using for_each
# This demonstrates creating resources from a data source list
resource "hw_sandwich" "list_comp_sandwiches" {
  for_each = hw_meat.list_comp_meats

  bread_id    = hw_bread.list_comp_rye.id
  meat_id     = each.value.id
  description = "List comprehension sandwich: ${each.value.kind} on rye"
}

# List comprehension examples using for expressions
locals {
  # Example 1: Transform list - get all sandwich names
  sandwich_names = [
    for sandwich in hw_sandwich.list_comp_sandwiches : sandwich.name
  ]

  # Example 2: Transform to map - create a map of meat -> sandwich price
  meat_to_price = {
    for meat in hw_meat.list_comp_meats : meat.kind => hw_sandwich.list_comp_sandwiches[meat.kind].price
  }

  # Example 3: Filter and transform - get only expensive sandwiches (> $5.00)
  expensive_sandwiches = [
    for sandwich in hw_sandwich.list_comp_sandwiches : sandwich.name
    if sandwich.price > 5.00
  ]

  # Example 4: Create a map with conditional logic
  sandwich_details = {
    for sandwich in hw_sandwich.list_comp_sandwiches : sandwich.id => {
      name         = sandwich.name
      price        = sandwich.price
      description  = sandwich.description
      is_expensive = sandwich.price > 5.00
    }
  }

  # Example 5: Transform list of strings - uppercase all meat names
  uppercase_meats = [
    for meat in data.hw_deli_meats.list_comp_available.meats : upper(meat)
  ]

  # Example 6: Create a list of objects with calculations
  sandwich_summaries = [
    for sandwich in hw_sandwich.list_comp_sandwiches : {
      id          = sandwich.id
      name        = sandwich.name
      price       = sandwich.price
      price_label = "${sandwich.price} dollars"
      description = sandwich.description
    }
  ]

  # Example 7: Filter meats by name pattern - get meats containing "salad"
  salad_meats = [
    for meat in data.hw_deli_meats.list_comp_available.meats : meat
    if strcontains(meat, "salad")
  ]

  # Example 8: Transform with index - add position numbers
  # Note: When iterating over for_each resources, we need to convert to list first
  # to get numeric indices, or use range() with length()
  numbered_sandwiches = [
    for idx in range(length(hw_sandwich.list_comp_sandwiches)) : {
      number = idx + 1
      name   = values(hw_sandwich.list_comp_sandwiches)[idx].name
      price  = values(hw_sandwich.list_comp_sandwiches)[idx].price
    }
  ]

  # Example 9: Calculate total cost using list comprehension
  list_comp_total_sandwich_cost = sum([
    for sandwich in hw_sandwich.list_comp_sandwiches : sandwich.price
  ])

  # Example 10: Group by price range
  sandwiches_by_price = {
    cheap = [
      for sandwich in hw_sandwich.list_comp_sandwiches : sandwich.name
      if sandwich.price <= 5.00
    ]
    expensive = [
      for sandwich in hw_sandwich.list_comp_sandwiches : sandwich.name
      if sandwich.price > 5.00
    ]
  }
}

# Outputs to demonstrate list comprehension results
output "list_comp_sandwich_names" {
  description = "List of all sandwich names (list comprehension example)"
  value       = local.sandwich_names
}

output "list_comp_meat_to_price" {
  description = "Map of meat type to sandwich price (list comprehension example)"
  value       = local.meat_to_price
}

output "list_comp_expensive_sandwiches" {
  description = "Names of sandwiches costing more than $5.00 (filtered list comprehension)"
  value       = local.expensive_sandwiches
}

output "list_comp_sandwich_details" {
  description = "Detailed map of all sandwiches (complex list comprehension)"
  value       = local.sandwich_details
}

output "list_comp_uppercase_meats" {
  description = "All meat names in uppercase (transformation example)"
  value       = local.uppercase_meats
}

output "list_comp_salad_meats" {
  description = "Meats containing 'salad' (filtered list comprehension)"
  value       = local.salad_meats
}

output "list_comp_numbered_sandwiches" {
  description = "Sandwiches with position numbers (list comprehension with index)"
  value       = local.numbered_sandwiches
}

output "list_comp_total_cost" {
  description = "Total cost of all sandwiches (sum with list comprehension)"
  value       = local.list_comp_total_sandwich_cost
}

output "list_comp_sandwiches_by_price" {
  description = "Sandwiches grouped by price range (grouped list comprehension)"
  value       = local.sandwiches_by_price
}

output "list_comp_sandwich_count" {
  description = "Total number of sandwiches created"
  value       = length(hw_sandwich.list_comp_sandwiches)
}
