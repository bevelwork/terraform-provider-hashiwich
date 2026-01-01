# Example demonstrating the Party Pack module
# Creates a party pack with 10 sandwiches, 10 drinks, sides, and optional napkins
# 
# NOTE: Module is commented out for local development.
# When ready to test, push a new version to registry.terraform.io and uncomment.

module "party_pack" {
  source = "./modules/party-pack"

  # Sides to include (can be: soup, salad, cookie, brownie, stroopwafel)
  sides = ["soup", "salad", "cookie", "brownie"]

  # Include napkins
  include_napkins = true
  napkin_quantity = 25

  # Customize drinks
  drink_kind = "cola"

  # Customize sandwiches
  sandwich_bread = "rye"
  sandwich_meat  = "turkey"
}

# Output the party pack details
output "party_pack_total_cost" {
  description = "Total cost of the party pack"
  value       = module.party_pack.total_cost
}

output "party_pack_breakdown" {
  description = "Cost breakdown of the party pack"
  value = {
    sandwiches = module.party_pack.sandwiches_cost
    drinks     = module.party_pack.drinks_cost
    sides      = module.party_pack.sides_cost
    napkins    = module.party_pack.napkins_cost
    total      = module.party_pack.total_cost
  }
}

output "party_pack_contents" {
  description = "Contents of the party pack"
  value = {
    sandwich_count   = module.party_pack.sandwich_count
    drink_count      = module.party_pack.drink_count
    sides            = module.party_pack.sides_included
    includes_napkins = module.party_pack.includes_napkins
  }
}
