# Example demonstrating the flatten() function in Terraform
# flatten() takes a list of lists and flattens it into a single list
# Useful for working with nested data structures

# ============================================================================
# Scenario 1: Basic flatten - Simple nested lists
# ============================================================================
# Use case: You have a list of lists and need a single flat list
# Example: Flattening nested sandwich lists

locals {
  # Nested list: list of lists
  flatten_nested_sandwiches = [
    ["sandwich_1", "sandwich_2"],
    ["sandwich_3", "sandwich_4"],
    ["sandwich_5"]
  ]

  # Flattened list: single list with all elements
  flatten_flat_sandwiches = flatten(local.flatten_nested_sandwiches)
  # Result: ["sandwich_1", "sandwich_2", "sandwich_3", "sandwich_4", "sandwich_5"]
}

# ============================================================================
# Scenario 2: Flattening resource attributes from for_each
# ============================================================================
# Use case: When you have multiple resources with lists, and need all items together
# Example: Collecting all sandwich IDs from multiple bags

resource "hw_bread" "flatten_bread_1" {
  kind        = "rye"
  description = "Bread 1 for flatten example"
}

resource "hw_bread" "flatten_bread_2" {
  kind        = "wheat"
  description = "Bread 2 for flatten example"
}

resource "hw_meat" "flatten_meat_1" {
  kind        = "turkey"
  description = "Meat 1 for flatten example"
}

resource "hw_meat" "flatten_meat_2" {
  kind        = "ham"
  description = "Meat 2 for flatten example"
}

resource "hw_meat" "flatten_meat_3" {
  kind        = "roast beef"
  description = "Meat 3 for flatten example"
}

# Create multiple sandwiches
resource "hw_sandwich" "flatten_sandwich_1" {
  bread_id    = hw_bread.flatten_bread_1.id
  meat_id     = hw_meat.flatten_meat_1.id
  description = "Sandwich 1 for flatten example"
}

resource "hw_sandwich" "flatten_sandwich_2" {
  bread_id    = hw_bread.flatten_bread_1.id
  meat_id     = hw_meat.flatten_meat_2.id
  description = "Sandwich 2 for flatten example"
}

resource "hw_sandwich" "flatten_sandwich_3" {
  bread_id    = hw_bread.flatten_bread_2.id
  meat_id     = hw_meat.flatten_meat_3.id
  description = "Sandwich 3 for flatten example"
}

# Create bags with different sandwich combinations
resource "hw_bag" "flatten_bag_1" {
  sandwiches = [
    hw_sandwich.flatten_sandwich_1.id,
    hw_sandwich.flatten_sandwich_2.id
  ]
}

resource "hw_bag" "flatten_bag_2" {
  sandwiches = [
    hw_sandwich.flatten_sandwich_3.id
  ]
}

resource "hw_bag" "flatten_bag_3" {
  sandwiches = [
    hw_sandwich.flatten_sandwich_1.id,
    hw_sandwich.flatten_sandwich_2.id,
    hw_sandwich.flatten_sandwich_3.id
  ]
}

# Flatten all sandwich IDs from all bags into a single list
locals {
  # Each bag has a list of sandwich IDs
  # This creates a list of lists: [[id1, id2], [id3], [id1, id2, id3]]
  flatten_bag_sandwich_lists = [
    hw_bag.flatten_bag_1.sandwiches,
    hw_bag.flatten_bag_2.sandwiches,
    hw_bag.flatten_bag_3.sandwiches
  ]

  # Flatten to get all sandwich IDs in a single list
  flatten_all_sandwich_ids = flatten(local.flatten_bag_sandwich_lists)

  # Get unique sandwich IDs (since some sandwiches appear in multiple bags)
  flatten_unique_sandwich_ids = distinct(local.flatten_all_sandwich_ids)
}

# ============================================================================
# Scenario 3: Flattening with for_each resources
# ============================================================================
# Use case: Collecting attributes from multiple for_each resources
# Example: Getting all prices from multiple sandwich groups

resource "hw_bread" "flatten_group_bread" {
  for_each = {
    group_1 = "ciabatta"
    group_2 = "baguette"
    group_3 = "sourdough"
  }
  kind        = each.value
  description = "Bread for group ${each.key}"
}

resource "hw_meat" "flatten_group_meat" {
  for_each = {
    group_1 = "turkey"
    group_2 = "ham"
    group_3 = "roast beef"
  }
  kind        = each.value
  description = "Meat for group ${each.key}"
}

resource "hw_sandwich" "flatten_group_sandwiches" {
  for_each = hw_bread.flatten_group_bread
  bread_id = each.value.id
  meat_id = hw_meat.flatten_group_meat[each.key].id
  description = "Sandwich for group ${each.key}"
}

# Collect prices from all sandwiches
locals {
  # Create a list of lists where each inner list contains prices
  # This simulates grouping prices (though in this case each group has one price)
  flatten_grouped_prices = [
    [hw_sandwich.flatten_group_sandwiches["group_1"].price],
    [hw_sandwich.flatten_group_sandwiches["group_2"].price],
    [hw_sandwich.flatten_group_sandwiches["group_3"].price]
  ]

  # Flatten to get all prices in a single list
  flatten_all_prices = flatten(local.flatten_grouped_prices)

  # Calculate total from flattened prices
  flatten_total_price = sum(local.flatten_all_prices)
}

# ============================================================================
# Scenario 4: Flattening nested data structures
# ============================================================================
# Use case: Working with complex nested data from data sources or variables
# Example: Flattening nested menu structures

locals {
  # Simulated nested menu structure
  flatten_nested_menu = {
    breakfast = {
      sandwiches = ["egg", "bacon"]
      drinks     = ["coffee", "juice"]
    }
    lunch = {
      sandwiches = ["turkey", "ham", "roast beef"]
      drinks     = ["cola", "water"]
    }
    dinner = {
      sandwiches = ["steak", "chicken"]
      drinks     = ["wine", "beer", "water"]
    }
  }

  # Extract all sandwich lists into a list of lists
  flatten_sandwich_lists = [
    local.flatten_nested_menu.breakfast.sandwiches,
    local.flatten_nested_menu.lunch.sandwiches,
    local.flatten_nested_menu.dinner.sandwiches
  ]

  # Flatten to get all sandwiches in a single list
  flatten_all_sandwiches = flatten(local.flatten_sandwich_lists)
  # Result: ["egg", "bacon", "turkey", "ham", "roast beef", "steak", "chicken"]

  # Extract all drink lists
  flatten_drink_lists = [
    local.flatten_nested_menu.breakfast.drinks,
    local.flatten_nested_menu.lunch.drinks,
    local.flatten_nested_menu.dinner.drinks
  ]

  # Flatten to get all drinks in a single list
  flatten_all_drinks = flatten(local.flatten_drink_lists)
  # Result: ["coffee", "juice", "cola", "water", "wine", "beer", "water"]
}

# ============================================================================
# Scenario 5: Flattening with dynamic blocks
# ============================================================================
# Use case: When dynamic blocks create nested structures that need flattening
# Example: Flattening tags or attributes from dynamic configurations

locals {
  # Simulated dynamic configuration with nested lists
  flatten_dynamic_config = [
    {
      name  = "order_1"
      items = ["sandwich_1", "drink_1"]
    },
    {
      name  = "order_2"
      items = ["sandwich_2", "sandwich_3", "drink_2"]
    },
    {
      name  = "order_3"
      items = ["drink_3"]
    }
  ]

  # Extract all items lists
  flatten_items_lists = [
    for order in local.flatten_dynamic_config : order.items
  ]
  # Result: [["sandwich_1", "drink_1"], ["sandwich_2", "sandwich_3", "drink_2"], ["drink_3"]]

  # Flatten to get all items in a single list
  flatten_all_items = flatten(local.flatten_items_lists)
  # Result: ["sandwich_1", "drink_1", "sandwich_2", "sandwich_3", "drink_2", "drink_3"]
}

# ============================================================================
# Scenario 6: Flattening with count resources
# ============================================================================
# Use case: Collecting attributes from count-based resources
# Example: Getting all IDs from multiple count-based resources

resource "hw_bread" "flatten_count_bread" {
  count       = 3
  kind        = count.index == 0 ? "rye" : count.index == 1 ? "wheat" : "sourdough"
  description = "Bread ${count.index + 1} for count flatten example"
}

resource "hw_meat" "flatten_count_meat" {
  count       = 3
  kind        = count.index == 0 ? "turkey" : count.index == 1 ? "ham" : "roast beef"
  description = "Meat ${count.index + 1} for count flatten example"
}

resource "hw_sandwich" "flatten_count_sandwiches" {
  count       = 3
  bread_id    = hw_bread.flatten_count_bread[count.index].id
  meat_id     = hw_meat.flatten_count_meat[count.index].id
  description = "Sandwich ${count.index + 1} for count flatten example"
}

# Collect all sandwich IDs
locals {
  # Create list of lists from count resources
  flatten_count_sandwich_lists = [
    [hw_sandwich.flatten_count_sandwiches[0].id],
    [hw_sandwich.flatten_count_sandwiches[1].id],
    [hw_sandwich.flatten_count_sandwiches[2].id]
  ]

  # Flatten to single list
  flatten_count_sandwich_ids = flatten(local.flatten_count_sandwich_lists)

  # Alternative: Direct list comprehension (no flatten needed)
  flatten_count_sandwich_ids_direct = [
    for s in hw_sandwich.flatten_count_sandwiches : s.id
  ]
}

# ============================================================================
# Scenario 7: Flattening with mixed empty lists
# ============================================================================
# Use case: Handling lists that may contain empty sublists
# Example: Flattening when some groups might be empty

locals {
  # Lists with some empty sublists
  flatten_mixed_lists = [
    ["item_1", "item_2"],
    [],  # Empty list
    ["item_3"],
    [],  # Another empty list
    ["item_4", "item_5", "item_6"]
  ]

  # Flatten handles empty lists gracefully
  flatten_mixed_result = flatten(local.flatten_mixed_lists)
  # Result: ["item_1", "item_2", "item_3", "item_4", "item_5", "item_6"]
  # Empty lists are simply ignored
}

# ============================================================================
# Scenario 8: Combining flatten with other functions
# ============================================================================
# Use case: Using flatten as part of a larger data transformation
# Example: Flatten, then filter, then calculate

locals {
  # Nested price lists from different categories
  flatten_price_categories = [
    [5.00, 5.00, 5.00],  # Sandwich prices
    [2.50, 2.50],        # Soup prices
    [1.00, 1.00, 1.00]  # Drink prices
  ]

  # Flatten all prices
  flatten_all_category_prices = flatten(local.flatten_price_categories)

  # Filter expensive items (> $3.00) from flattened list
  flatten_expensive_items = [
    for price in local.flatten_all_category_prices : price
    if price > 3.00
  ]

  # Calculate total from flattened prices
  flatten_total_all = sum(local.flatten_all_category_prices)

  # Calculate average from flattened prices
  flatten_average_price = local.flatten_total_all / length(local.flatten_all_category_prices)
}

# ============================================================================
# Outputs to demonstrate flatten results
# ============================================================================

output "flatten_basic_example" {
  description = "Basic flatten example - nested list to flat list"
  value = {
    nested = local.flatten_nested_sandwiches
    flat   = local.flatten_flat_sandwiches
  }
}

output "flatten_bag_sandwich_ids" {
  description = "All sandwich IDs from all bags (flattened)"
  value       = local.flatten_all_sandwich_ids
}

output "flatten_unique_sandwich_ids" {
  description = "Unique sandwich IDs from all bags (flattened and deduplicated)"
  value       = local.flatten_unique_sandwich_ids
}

output "flatten_all_prices" {
  description = "All prices from grouped sandwiches (flattened)"
  value       = local.flatten_all_prices
}

output "flatten_total_price" {
  description = "Total price from flattened price list"
  value       = local.flatten_total_price
}

output "flatten_menu_sandwiches" {
  description = "All sandwiches from nested menu structure (flattened)"
  value       = local.flatten_all_sandwiches
}

output "flatten_menu_drinks" {
  description = "All drinks from nested menu structure (flattened)"
  value       = local.flatten_all_drinks
}

output "flatten_dynamic_items" {
  description = "All items from dynamic configuration (flattened)"
  value       = local.flatten_all_items
}

output "flatten_count_ids" {
  description = "All sandwich IDs from count resources (flattened)"
  value       = local.flatten_count_sandwich_ids
}

output "flatten_mixed_result" {
  description = "Flattened result with empty lists (empty lists are ignored)"
  value       = local.flatten_mixed_result
}

output "flatten_combined_example" {
  description = "Flatten combined with filtering and calculations"
  value = {
    all_prices      = local.flatten_all_category_prices
    expensive_items = local.flatten_expensive_items
    total           = local.flatten_total_all
    average         = local.flatten_average_price
  }
}
