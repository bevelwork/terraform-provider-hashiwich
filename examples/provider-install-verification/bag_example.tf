# Example demonstrating a bag that can hold 1-5 sandwiches
# Using locals to validate and enforce the constraint

# Get available meats to create sandwiches
data "hw_deli_meats" "bag_available" {}

# Create some sandwiches for the bag
resource "hw_bread" "bag_bread" {
  kind        = "rye"
  description = "Bread for bag sandwiches"
}

# Create a few different meat resources
resource "hw_meat" "bag_meat_1" {
  kind        = "turkey"
  description = "Turkey for bag sandwich 1"
}

resource "hw_meat" "bag_meat_2" {
  kind        = "ham"
  description = "Ham for bag sandwich 2"
}

resource "hw_meat" "bag_meat_3" {
  kind        = "roast beef"
  description = "Roast beef for bag sandwich 3"
}

resource "hw_meat" "bag_meat_4" {
  kind        = "chicken"
  description = "Chicken for bag sandwich 4"
}

resource "hw_meat" "bag_meat_5" {
  kind        = "pastrami"
  description = "Pastrami for bag sandwich 5"
}

# Create sandwiches
resource "hw_sandwich" "bag_sandwich_1" {
  bread_id    = hw_bread.bag_bread.id
  meat_id     = hw_meat.bag_meat_1.id
  description = "Turkey sandwich for bag"
}

resource "hw_sandwich" "bag_sandwich_2" {
  bread_id    = hw_bread.bag_bread.id
  meat_id     = hw_meat.bag_meat_2.id
  description = "Ham sandwich for bag"
}

resource "hw_sandwich" "bag_sandwich_3" {
  bread_id    = hw_bread.bag_bread.id
  meat_id     = hw_meat.bag_meat_3.id
  description = "Roast beef sandwich for bag"
}

resource "hw_sandwich" "bag_sandwich_4" {
  bread_id    = hw_bread.bag_bread.id
  meat_id     = hw_meat.bag_meat_4.id
  description = "Chicken sandwich for bag"
}

resource "hw_sandwich" "bag_sandwich_5" {
  bread_id    = hw_bread.bag_bread.id
  meat_id     = hw_meat.bag_meat_5.id
  description = "Pastrami sandwich for bag"
}

# Use locals to define which sandwiches to include and validate constraints
locals {
  # All available sandwich IDs
  all_sandwich_ids = [
    hw_sandwich.bag_sandwich_1.id,
    hw_sandwich.bag_sandwich_2.id,
    hw_sandwich.bag_sandwich_3.id,
    hw_sandwich.bag_sandwich_4.id,
    hw_sandwich.bag_sandwich_5.id,
  ]

  # Number of sandwiches to include (must be between 1 and 5)
  # Change this value to test different bag configurations
  bag_sandwich_count = 3

  # Constraints: bag must contain at least 1 and at most 5 sandwiches
  bag_min_sandwiches = 1
  bag_max_sandwiches = 5

  # Select the first N sandwiches based on count
  # slice() will fail with a clear error if count is out of bounds (less than 1 or greater than 5)
  bag_selected_sandwich_ids = slice(local.all_sandwich_ids, 0, local.bag_sandwich_count)
}

# Create the bag with validated sandwich IDs
# The bag must contain between 1 and 5 sandwiches (enforced by slice() bounds)
resource "hw_bag" "example" {
  description = "Bag containing ${local.bag_sandwich_count} sandwich(es) (must be 1-5)"

  sandwiches = local.bag_selected_sandwich_ids

  # Use lifecycle precondition to provide a clear error message if constraints are violated
  lifecycle {
    precondition {
      condition     = local.bag_sandwich_count >= local.bag_min_sandwiches && local.bag_sandwich_count <= local.bag_max_sandwiches
      error_message = "Bag must contain between ${local.bag_min_sandwiches} and ${local.bag_max_sandwiches} sandwiches, but sandwich_count is ${local.bag_sandwich_count}"
    }
  }
}

# Output to show what's in the bag
output "bag_sandwich_count" {
  description = "Number of sandwiches in the bag"
  value       = length(local.bag_selected_sandwich_ids)
}

output "bag_sandwich_ids" {
  description = "IDs of sandwiches in the bag"
  value       = local.bag_selected_sandwich_ids
}
