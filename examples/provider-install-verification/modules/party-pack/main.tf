# Party Pack Module
# Creates 10 sandwiches, 10 drinks, and optional sides and napkins

# Get menu for pricing
data "hw_menu" "party_pack_menu" {}

# Create bread for all sandwiches
resource "hw_bread" "party_pack_bread" {
  kind        = var.sandwich_bread
  description = "Bread for party pack sandwiches"
}

# Create meat for all sandwiches
resource "hw_meat" "party_pack_meat" {
  kind        = var.sandwich_meat
  description = "Meat for party pack sandwiches"
}

# Create 10 sandwiches
resource "hw_sandwich" "party_pack_sandwiches" {
  count = 10

  bread_id    = hw_bread.party_pack_bread.id
  meat_id     = hw_meat.party_pack_meat.id
  description = "Party pack sandwich #${count.index + 1}"
}

# Create 10 drinks
resource "hw_drink" "party_pack_drinks" {
  count = 10

  kind        = var.drink_kind
  description = "Party pack drink #${count.index + 1}"

  dynamic "ice" {
    for_each = strcontains(lower(var.drink_kind), "hot") ? [] : [
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

# Create sides based on the sides variable
locals {
  # Map side names to resource types
  side_resource_map = {
    "soup"        = "hw_soup"
    "salad"       = "hw_salad"
    "cookie"      = "hw_cookie"
    "brownie"     = "hw_brownie"
    "stroopwafel" = "hw_stroopwafel"
  }

  # Create a map of side counts
  side_counts = {
    for side in var.sides : side => length([for s in var.sides : s if s == side])
  }

  # Get unique sides
  unique_sides = distinct(var.sides)
}

# Create soups if requested
resource "hw_soup" "party_pack" {
  for_each = {
    for side in local.unique_sides : side => side
    if side == "soup"
  }

  kind        = "tomato"
  temperature = "hot"
  description = "Party pack soup"
}

# Create salads if requested
resource "hw_salad" "party_pack" {
  for_each = {
    for side in local.unique_sides : side => side
    if side == "salad"
  }

  kind        = "caesar"
  dressing    = "caesar"
  size        = "medium"
  description = "Party pack salad"
}

# Create cookies if requested
resource "hw_cookie" "party_pack" {
  for_each = {
    for side in local.unique_sides : side => side
    if side == "cookie"
  }

  kind        = "chocolate chip"
  description = "Party pack cookie"
}

# Create brownies if requested
resource "hw_brownie" "party_pack" {
  for_each = {
    for side in local.unique_sides : side => side
    if side == "brownie"
  }

  kind        = "fudge"
  description = "Party pack brownie"
}

# Create stroopwafels if requested
resource "hw_stroopwafel" "party_pack" {
  for_each = {
    for side in local.unique_sides : side => side
    if side == "stroopwafel"
  }

  kind        = "classic"
  description = "Party pack stroopwafel"
}

# Create napkins if requested
resource "hw_napkin" "party_pack" {
  count = var.include_napkins ? 1 : 0

  quantity    = var.napkin_quantity
  description = "Napkins for party pack"
}

# Calculate totals
locals {
  # Total cost of sandwiches
  sandwiches_cost = sum([for s in hw_sandwich.party_pack_sandwiches : s.price])

  # Total cost of drinks
  drinks_cost = sum([for d in hw_drink.party_pack_drinks : d.price])

  # Total cost of sides (using try() to handle empty maps)
  soups_cost        = try(sum([for s in hw_soup.party_pack : s.price]), 0)
  salads_cost       = try(sum([for s in hw_salad.party_pack : s.price]), 0)
  cookies_cost      = try(sum([for s in hw_cookie.party_pack : s.price]), 0)
  brownies_cost     = try(sum([for s in hw_brownie.party_pack : s.price]), 0)
  stroopwafels_cost = try(sum([for s in hw_stroopwafel.party_pack : s.price]), 0)

  sides_cost = local.soups_cost + local.salads_cost + local.cookies_cost + local.brownies_cost + local.stroopwafels_cost

  # Total cost of napkins
  napkins_cost = var.include_napkins ? hw_napkin.party_pack[0].price : 0

  # Grand total
  total_cost = local.sandwiches_cost + local.drinks_cost + local.sides_cost + local.napkins_cost
}
