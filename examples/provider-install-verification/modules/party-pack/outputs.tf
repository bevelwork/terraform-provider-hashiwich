output "total_cost" {
  description = "Total cost of the party pack"
  value       = local.total_cost
}

output "sandwiches_cost" {
  description = "Total cost of sandwiches"
  value       = local.sandwiches_cost
}

output "drinks_cost" {
  description = "Total cost of drinks"
  value       = local.drinks_cost
}

output "sides_cost" {
  description = "Total cost of sides"
  value       = local.sides_cost
}

output "napkins_cost" {
  description = "Total cost of napkins (0 if not included)"
  value       = local.napkins_cost
}

output "sandwich_count" {
  description = "Number of sandwiches in the party pack"
  value       = length(hw_sandwich.party_pack_sandwiches)
}

output "drink_count" {
  description = "Number of drinks in the party pack"
  value       = length(hw_drink.party_pack_drinks)
}

output "sides_included" {
  description = "List of sides included in the party pack"
  value       = var.sides
}

output "includes_napkins" {
  description = "Whether napkins are included"
  value       = var.include_napkins
}

output "sandwich_ids" {
  description = "IDs of all sandwiches in the party pack"
  value       = [for s in hw_sandwich.party_pack_sandwiches : s.id]
}

output "drink_ids" {
  description = "IDs of all drinks in the party pack"
  value       = [for d in hw_drink.party_pack_drinks : d.id]
}
