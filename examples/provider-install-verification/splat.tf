# Example demonstrating the splat operator [*] in Terraform
# The splat operator extracts a specific attribute from all items in a collection
# Syntax: collection[*].attribute
# Useful for: Getting all IDs, all names, all prices, etc. from a collection

# ============================================================================
# Setup: Create Collections to Work With
# ============================================================================

# Create multiple bread resources
resource "hw_bread" "splat_bread_1" {
  kind        = "rye"
  description = "Bread 1 for splat examples"
}

resource "hw_bread" "splat_bread_2" {
  kind        = "sourdough"
  description = "Bread 2 for splat examples"
}

resource "hw_bread" "splat_bread_3" {
  kind        = "ciabatta"
  description = "Bread 3 for splat examples"
}

# Create multiple meat resources
resource "hw_meat" "splat_meat_1" {
  kind        = "turkey"
  description = "Meat 1 for splat examples"
}

resource "hw_meat" "splat_meat_2" {
  kind        = "ham"
  description = "Meat 2 for splat examples"
}

resource "hw_meat" "splat_meat_3" {
  kind        = "roast beef"
  description = "Meat 3 for splat examples"
}

# ============================================================================
# Scenario 1: Splat with for_each Resources
# ============================================================================
# Most common use case: Get all IDs from resources created with for_each
# IMPORTANT: For for_each resources, you must use values() to convert the map to a list first
# Syntax: values(resource)[*].attribute (NOT resource[*].attribute)

resource "hw_meat" "splat_for_each_meats" {
  for_each = toset(["turkey", "ham", "roast beef", "chicken", "pastrami"])
  kind     = each.value
}

locals {
  # Splat operator: Get all IDs from for_each resources
  # NOTE: For for_each resources, use values() to convert map to list first
  all_meat_ids_splat = values(hw_meat.splat_for_each_meats)[*].id
  # Result: ["meat-turkey-6", "meat-ham-3", "meat-roast beef-10", ...]
  
  # Equivalent for expression (more verbose):
  all_meat_ids_for = [
    for meat in hw_meat.splat_for_each_meats : meat.id
  ]
  
  # Splat: Get all kinds (use values() for for_each resources)
  all_meat_kinds = values(hw_meat.splat_for_each_meats)[*].kind
  
  # Splat: Get all descriptions (use values() for for_each resources)
  all_meat_descriptions = values(hw_meat.splat_for_each_meats)[*].description
}

# ============================================================================
# Scenario 2: Splat with count Resources
# ============================================================================
# Get all attributes from resources created with count

resource "hw_bread" "splat_count_breads" {
  count       = 4
  kind        = count.index == 0 ? "rye" : count.index == 1 ? "wheat" : count.index == 2 ? "sourdough" : "ciabatta"
  description = "Bread ${count.index + 1}"
}

locals {
  # Splat operator: Get all IDs from count resources
  all_bread_ids_splat = hw_bread.splat_count_breads[*].id
  # Result: ["bread-rye-3", "bread-wheat-5", "bread-sourdough-9", "bread-ciabatta-8"]
  
  # Splat: Get all kinds
  all_bread_kinds = hw_bread.splat_count_breads[*].kind
  
  # Equivalent for expression:
  all_bread_ids_for = [
    for bread in hw_bread.splat_count_breads : bread.id
  ]
}

# ============================================================================
# Scenario 3: Splat with Lists of Objects
# ============================================================================
# Extract attributes from a list of objects

locals {
  # List of objects
  sandwich_list = [
    {
      bread_id = hw_bread.splat_bread_1.id
      meat_id  = hw_meat.splat_meat_1.id
      name     = "Turkey on Rye"
    },
    {
      bread_id = hw_bread.splat_bread_2.id
      meat_id  = hw_meat.splat_meat_2.id
      name     = "Ham on Sourdough"
    },
    {
      bread_id = hw_bread.splat_bread_3.id
      meat_id  = hw_meat.splat_meat_3.id
      name     = "Roast Beef on Ciabatta"
    }
  ]
  
  # Splat: Get all bread_ids from list
  splat_all_bread_ids_from_list = local.sandwich_list[*].bread_id
  # Result: [bread_id_1, bread_id_2, bread_id_3]
  
  # Splat: Get all names
  splat_all_sandwich_names = local.sandwich_list[*].name
  
  # Splat: Get all meat_ids
  splat_all_meat_ids_from_list = local.sandwich_list[*].meat_id
}

# ============================================================================
# Scenario 4: Splat with Maps
# ============================================================================
# Extract attributes from a map of objects
# IMPORTANT: For maps, use values(map)[*].attribute (not map[*].attribute)
# The values() function converts the map to a list of values first

locals {
  # Map of objects
  store_map = {
    store_1 = {
      name     = "Downtown Store"
      bread_id = hw_bread.splat_bread_1.id
      capacity = "50"
    }
    store_2 = {
      name     = "Uptown Store"
      bread_id = hw_bread.splat_bread_2.id
      capacity = "75"
    }
    store_3 = {
      name     = "Airport Store"
      bread_id = hw_bread.splat_bread_3.id
      capacity = "100"
    }
  }
  
  # Splat: Get all names from map (use values() to convert map to list first)
  splat_all_store_names = values(local.store_map)[*].name
  # Result: ["Downtown Store", "Uptown Store", "Airport Store"]
  # Note: For maps, use values(map)[*].attribute to get all values, then splat
  
  # Splat: Get all bread_ids
  splat_all_store_bread_ids = values(local.store_map)[*].bread_id
  
  # Splat: Get all capacities
  splat_all_store_capacities = values(local.store_map)[*].capacity
}

# ============================================================================
# Scenario 5: Splat with Data Sources
# ============================================================================
# Extract attributes from data source outputs

data "hw_deli_meats" "splat_available" {}

locals {
  # Note: Data source returns a list of strings, not objects
  # So splat works differently - each string is already the value
  splat_all_available_meats = data.hw_deli_meats.splat_available.meats
  # This is already a list, so no splat needed
  # But if it were objects, you'd use: data_source[*].attribute
}

# ============================================================================
# Scenario 6: Nested Splat Operations
# ============================================================================
# Splat can be used with nested structures

locals {
  # Nested structure
  nested_stores = {
    region_1 = {
      stores = [
        { name = "Store A", bread_id = hw_bread.splat_bread_1.id },
        { name = "Store B", bread_id = hw_bread.splat_bread_2.id }
      ]
    }
    region_2 = {
      stores = [
        { name = "Store C", bread_id = hw_bread.splat_bread_3.id }
      ]
    }
  }
  
  # Get all store names from all regions
  # First get all stores lists, then splat each
  splat_all_store_names_nested = flatten([
    for region in values(local.nested_stores) : region.stores[*].name
  ])
  # Result: ["Store A", "Store B", "Store C"]
  
  # Get all bread_ids
  splat_all_bread_ids_nested = flatten([
    for region in values(local.nested_stores) : region.stores[*].bread_id
  ])
}

# ============================================================================
# Scenario 7: Splat with Computed Attributes
# ============================================================================
# Get computed attributes from resources

resource "hw_sandwich" "splat_sandwiches" {
  for_each = hw_meat.splat_for_each_meats
  bread_id = hw_bread.splat_bread_1.id
  meat_id  = each.value.id
}

locals {
  # Splat: Get all prices (computed attribute)
  # NOTE: For for_each resources, use values() to convert map to list first
  splat_all_sandwich_prices = values(hw_sandwich.splat_sandwiches)[*].price
  # Result: [5.00, 5.00, 5.00, ...] (all prices)
  
  # Splat: Get all IDs (use values() for for_each resources)
  splat_all_sandwich_ids = values(hw_sandwich.splat_sandwiches)[*].id
  
  # Calculate total cost using splat (use values() for for_each resources)
  splat_total_sandwich_cost = sum(values(hw_sandwich.splat_sandwiches)[*].price)
  
  # Get average price (use values() for for_each resources)
  splat_average_sandwich_price = sum(values(hw_sandwich.splat_sandwiches)[*].price) / length(values(hw_sandwich.splat_sandwiches)[*].price)
}

# ============================================================================
# Scenario 8: When to Use Splat vs For Expressions
# ============================================================================
# Splat is simpler for basic attribute extraction
# For expressions are more flexible for complex transformations

locals {
  # Use SPLAT when: Just extracting a single attribute
  # NOTE: For for_each resources, use values() first
  simple_extraction_splat = values(hw_meat.splat_for_each_meats)[*].id
  # Clean and readable
  
  # Use FOR when: Need filtering, transformation, or complex logic
  filtered_extraction_for = [
    for meat in hw_meat.splat_for_each_meats : meat.id
    if meat.kind != "chicken"
  ]
  # Can't do this with splat - need for expression
  
  # Use FOR when: Need to transform the value
  transformed_extraction_for = [
    for meat in hw_meat.splat_for_each_meats : upper(meat.kind)
  ]
  # Can't transform with splat - need for expression
  
  # Use SPLAT when: Simple attribute extraction from all items
  all_ids_splat = hw_bread.splat_count_breads[*].id
  # Much simpler than for expression
}

# ============================================================================
# Scenario 9: Splat with Sets
# ============================================================================
# Splat works with sets too (after conversion if needed)

locals {
  # Set of resource IDs
  bread_id_set = toset([
    hw_bread.splat_bread_1.id,
    hw_bread.splat_bread_2.id,
    hw_bread.splat_bread_3.id
  ])
  
  # Note: Sets don't have attributes to extract with splat
  # But if you have a set of objects, convert to list first
  # For sets of simple values, splat doesn't apply
}

# ============================================================================
# Scenario 10: Practical Use Cases
# ============================================================================

# Use Case 1: Get all resource IDs for a bag
resource "hw_bag" "splat_bag" {
  sandwiches = values(hw_sandwich.splat_sandwiches)[*].id
  # Splat gets all sandwich IDs to put in the bag (use values() for for_each resources)
}

# Use Case 2: Calculate totals
locals {
  # Total cost of all sandwiches (use values() for for_each resources)
  splat_total_cost = sum(values(hw_sandwich.splat_sandwiches)[*].price)
  
  # Count of all breads (count resources work directly with splat)
  splat_bread_count = length(hw_bread.splat_count_breads[*].id)
  
  # All unique bread kinds (count resources work directly with splat)
  splat_unique_bread_kinds = toset(hw_bread.splat_count_breads[*].kind)
}

# Use Case 3: Create dependent resources
# NOTE: Using splat with for_each requires the values to be known at plan time
# For count resources, we can use splat directly, but need to be careful with for_each
resource "hw_sandwich" "splat_dependent" {
  for_each = {
    for idx, bread_id in hw_bread.splat_count_breads[*].id : "bread-${idx}" => bread_id
  }
  bread_id = each.value
  meat_id  = hw_meat.splat_meat_1.id
  # Creates a sandwich for each bread using splat (with static keys for for_each)
}

# ============================================================================
# Common Splat Patterns
# ============================================================================

locals {
  # Pattern 1: Get all IDs (use values() for for_each resources)
  pattern_all_ids = values(hw_meat.splat_for_each_meats)[*].id
  
  # Pattern 2: Get all of a specific attribute (use values() for for_each resources)
  pattern_all_kinds = values(hw_meat.splat_for_each_meats)[*].kind
  
  # Pattern 3: Use in functions (use values() for for_each resources)
  pattern_sum_prices = sum(values(hw_sandwich.splat_sandwiches)[*].price)
  pattern_max_price  = max(values(hw_sandwich.splat_sandwiches)[*].price...)
  pattern_min_price  = min(values(hw_sandwich.splat_sandwiches)[*].price...)
  
  # Pattern 4: Convert to set (count resources work directly)
  pattern_to_set = toset(hw_bread.splat_count_breads[*].kind)
  
  # Pattern 5: Use in conditionals (use values() for for_each resources)
  pattern_any_has_price = length([
    for price in values(hw_sandwich.splat_sandwiches)[*].price : price
    if price > 4.00
  ]) > 0
}

# ============================================================================
# Splat Operator Syntax Reference
# ============================================================================
#
# BASIC SYNTAX:
#   collection[*].attribute
#
# EXAMPLES:
#   resource[*].id              - Get all IDs from resources
#   list[*].property            - Get property from all list items
#   map[*].value                - Get value from all map items
#
# WITH FUNCTIONS:
#   sum(resource[*].price)      - Sum all prices
#   length(resource[*].id)      - Count all resources
#   toset(resource[*].kind)     - Convert to set
#
# NESTED:
#   flatten([for x in y : x.items[*].id])  - Nested splat with flatten
#
# LIMITATIONS:
#   - Can only extract one attribute at a time
#   - No filtering (use for expression instead)
#   - No transformation (use for expression instead)
#   - Works with collections (list, set, map) of objects
#
# WHEN TO USE SPLAT:
#   ✅ Simple attribute extraction from all items
#   ✅ Getting all IDs, names, prices, etc.
#   ✅ When you need all items (no filtering)
#   ✅ Cleaner syntax than for expressions for simple cases
#
# WHEN TO USE FOR EXPRESSIONS:
#   ✅ Need filtering (if clause)
#   ✅ Need transformation
#   ✅ Need multiple attributes
#   ✅ Complex logic

# ============================================================================
# Outputs: Demonstrating Splat Usage
# ============================================================================

output "splat_for_each_examples" {
  description = "Splat examples with for_each resources"
  value = {
    all_meat_ids        = values(hw_meat.splat_for_each_meats)[*].id
    all_meat_kinds      = values(hw_meat.splat_for_each_meats)[*].kind
    equivalent_for_expr = local.all_meat_ids_for
  }
}

output "splat_count_examples" {
  description = "Splat examples with count resources"
  value = {
    all_bread_ids   = hw_bread.splat_count_breads[*].id
    all_bread_kinds = hw_bread.splat_count_breads[*].kind
    bread_count     = length(hw_bread.splat_count_breads[*].id)
  }
}

output "splat_list_examples" {
  description = "Splat examples with lists"
  value = {
    all_bread_ids = local.splat_all_bread_ids_from_list
    all_names     = local.splat_all_sandwich_names
  }
}

output "splat_map_examples" {
  description = "Splat examples with maps"
  value = {
    all_store_names = local.splat_all_store_names
    all_capacities  = local.splat_all_store_capacities
  }
}

output "splat_computed_examples" {
  description = "Splat examples with computed attributes"
  value = {
    all_prices        = values(hw_sandwich.splat_sandwiches)[*].price
    total_cost        = local.splat_total_sandwich_cost
    average_price     = local.splat_average_sandwich_price
  }
}

output "splat_practical_examples" {
  description = "Practical splat usage examples"
  value = {
    bag_sandwiches     = hw_bag.splat_bag.sandwiches
    total_cost         = local.splat_total_cost
    unique_bread_kinds = local.splat_unique_bread_kinds
  }
}
