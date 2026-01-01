# Example demonstrating property access in Terraform
# Shows how to access specific items from maps, sets, and lists
# Essential for working with complex data structures

# ============================================================================
# Setup: Create Sample Data Structures
# ============================================================================

# Create some resources to work with
resource "hw_bread" "access_bread_1" {
  kind        = "rye"
  description = "Bread 1 for property access examples"
}

resource "hw_bread" "access_bread_2" {
  kind        = "sourdough"
  description = "Bread 2 for property access examples"
}

resource "hw_bread" "access_bread_3" {
  kind        = "ciabatta"
  description = "Bread 3 for property access examples"
}

resource "hw_meat" "access_meat_1" {
  kind        = "turkey"
  description = "Meat 1 for property access examples"
}

resource "hw_meat" "access_meat_2" {
  kind        = "ham"
  description = "Meat 2 for property access examples"
}

resource "hw_meat" "access_meat_3" {
  kind        = "roast beef"
  description = "Meat 3 for property access examples"
}

# ============================================================================
# Scenario 1: Accessing Items from a LIST
# ============================================================================
# Lists are ordered collections accessed by numeric index (0-based)

locals {
  # Create a list of bread IDs
  bread_list = [
    hw_bread.access_bread_1.id,
    hw_bread.access_bread_2.id,
    hw_bread.access_bread_3.id
  ]
  
  # Access items by index
  first_bread  = local.bread_list[0]   # First item (index 0)
  second_bread = local.bread_list[1]    # Second item (index 1)
  third_bread  = local.bread_list[2]    # Third item (index 2)
  # last_bread = local.bread_list[-1]   # Last item (Terraform doesn't support negative indices)
  
  # Access with length calculation for last item
  last_bread = local.bread_list[length(local.bread_list) - 1]
  
  # Access with bounds checking (using try)
  safe_access = try(local.bread_list[5], "not-found")  # Returns "not-found" if index doesn't exist
}

# Example: Using list access in resources
resource "hw_sandwich" "access_list_sandwich" {
  bread_id    = local.bread_list[0]  # Use first bread from list
  meat_id     = hw_meat.access_meat_1.id
  description = "Sandwich using first bread from list"
}

# ============================================================================
# Scenario 2: Accessing Items from a MAP
# ============================================================================
# Maps are key-value pairs accessed by key name

locals {
  # Create a map of bread types to bread IDs
  bread_map = {
    "rye"      = hw_bread.access_bread_1.id
    "sourdough" = hw_bread.access_bread_2.id
    "ciabatta"  = hw_bread.access_bread_3.id
  }
  
  # Access items by key
  rye_bread_id      = local.bread_map["rye"]        # Access by key in brackets
  sourdough_bread_id = local.bread_map.sourdough    # Access by key with dot notation
  ciabatta_bread_id  = local.bread_map["ciabatta"]  # Both syntaxes work
  
  # Access with try() for safe access
  safe_map_access = try(local.bread_map["wheat"], "not-found")  # Returns "not-found" if key doesn't exist
  
  # Access with lookup() function
  lookup_bread = lookup(local.bread_map, "rye", "default")  # lookup(map, key, default)
}

# Example: Using map access in resources
resource "hw_sandwich" "access_map_sandwich" {
  bread_id    = local.bread_map["rye"]  # Access by key
  meat_id     = hw_meat.access_meat_1.id
  description = "Sandwich using bread from map"
}

# ============================================================================
# Scenario 3: Accessing Items from a SET
# ============================================================================
# Sets are unordered collections - you can't access by index
# Must convert to list or use for expressions

locals {
  # Create a set of meat types
  meat_set = toset([
    hw_meat.access_meat_1.kind,
    hw_meat.access_meat_2.kind,
    hw_meat.access_meat_3.kind
  ])
  
  # Convert set to list to access by index
  meat_list_from_set = tolist(local.meat_set)
  first_meat_from_set = local.meat_list_from_set[0]  # Now accessible by index
  
  # Check if item exists in set
  has_turkey = contains(local.meat_set, "turkey")  # Returns true/false
  
  # Filter set to find specific item
  turkey_meat = [
    for meat in local.meat_set : meat
    if meat == "turkey"
  ][0]  # Get first (and only) match
}

# ============================================================================
# Scenario 4: Accessing Nested Properties
# ============================================================================
# Accessing properties within complex data structures

locals {
  # Nested map structure
  store_info = {
    location_1 = {
      name     = "Downtown Store"
      bread_id = hw_bread.access_bread_1.id
      meat_id  = hw_meat.access_meat_1.id
    }
    location_2 = {
      name     = "Uptown Store"
      bread_id = hw_bread.access_bread_2.id
      meat_id  = hw_meat.access_meat_2.id
    }
  }
  
  # Access nested properties
  downtown_bread = local.store_info["location_1"].bread_id
  uptown_name    = local.store_info.location_2.name
  
  # Access with chaining
  nested_access = local.store_info["location_1"]["bread_id"]  # Alternative syntax
}

# ============================================================================
# Scenario 5: Accessing from for_each Resources
# ============================================================================
# Accessing specific instances from resources created with for_each

resource "hw_meat" "access_for_each_meats" {
  for_each = toset(["turkey", "ham", "roast beef", "chicken"])
  kind     = each.value
}

locals {
  # Access specific instance from for_each resource
  turkey_meat_id   = hw_meat.access_for_each_meats["turkey"].id
  ham_meat_id      = hw_meat.access_for_each_meats["ham"].id
  roast_beef_id    = hw_meat.access_for_each_meats["roast beef"].id
  
  # Access all IDs as a map
  all_meat_ids = {
    for key, meat in hw_meat.access_for_each_meats : key => meat.id
  }
  
  # Access all IDs as a list
  all_meat_ids_list = [
    for meat in hw_meat.access_for_each_meats : meat.id
  ]
}

# ============================================================================
# Scenario 6: Accessing from count Resources
# ============================================================================
# Accessing specific instances from resources created with count

resource "hw_bread" "access_count_breads" {
  count       = 3
  kind        = count.index == 0 ? "rye" : count.index == 1 ? "wheat" : "sourdough"
  description = "Bread ${count.index + 1}"
}

locals {
  # Access specific instance from count resource
  first_bread_count  = hw_bread.access_count_breads[0].id
  second_bread_count = hw_bread.access_count_breads[1].id
  third_bread_count  = hw_bread.access_count_breads[2].id
  
  # Access all IDs as a list
  all_bread_ids_count = [
    for bread in hw_bread.access_count_breads : bread.id
  ]
}

# ============================================================================
# Scenario 7: Safe Access Patterns
# ============================================================================
# Using try() and other functions for safe property access

locals {
  # Safe list access
  safe_list_item = try(local.bread_list[10], null)  # Returns null if index out of bounds
  
  # Safe map access
  safe_map_item = try(local.bread_map["nonexistent"], "default-value")
  
  # Safe nested access
  safe_nested = try(local.store_info["location_3"].name, "not-found")
  
  # Using lookup with default
  lookup_with_default = lookup(local.bread_map, "wheat", hw_bread.access_bread_1.id)
}

# ============================================================================
# Scenario 8: Accessing Attributes from Data Sources
# ============================================================================
# Accessing properties from data source outputs

data "hw_deli_meats" "access_available" {}

locals {
  # Access list from data source
  first_available_meat = data.hw_deli_meats.access_available.meats[0]
  all_available_meats  = data.hw_deli_meats.access_available.meats
  
  # Access with length check
  last_available_meat = data.hw_deli_meats.access_available.meats[
    length(data.hw_deli_meats.access_available.meats) - 1
  ]
}

# ============================================================================
# Scenario 9: Complex Access Patterns
# ============================================================================
# Combining multiple access methods

locals {
  # Access from map, then use in list comprehension
  bread_ids_from_map = [
    for key, value in local.bread_map : value
  ]
  
  # Filter and access
  filtered_breads = [
    for bread in hw_bread.access_count_breads : bread.id
    if bread.kind == "rye"
  ]
  
  # Access and transform
  transformed_map = {
    for key, value in local.bread_map : upper(key) => value
  }
  
  # Access nested and extract
  all_store_breads = [
    for location, info in local.store_info : info.bread_id
  ]
}

# ============================================================================
# Scenario 10: Practical Examples
# ============================================================================
# Real-world access patterns

# Example 1: Pick a specific bread from a list
resource "hw_sandwich" "pick_from_list" {
  bread_id    = local.bread_list[1]  # Pick second bread
  meat_id     = hw_meat.access_meat_1.id
  description = "Sandwich using bread picked from list (index 1)"
}

# Example 2: Pick a specific bread from a map
resource "hw_sandwich" "pick_from_map" {
  bread_id    = local.bread_map["sourdough"]  # Pick by key
  meat_id     = hw_meat.access_meat_2.id
  description = "Sandwich using bread picked from map (key: sourdough)"
}

# Example 3: Pick from set (convert to list first)
resource "hw_sandwich" "pick_from_set" {
  bread_id    = hw_bread.access_bread_1.id
  meat_id     = hw_meat.access_for_each_meats[local.meat_list_from_set[0]].id
  description = "Sandwich using meat picked from set (converted to list)"
}

# Example 4: Conditional access
resource "hw_sandwich" "conditional_access" {
  bread_id    = contains(keys(local.bread_map), "rye") ? local.bread_map["rye"] : local.bread_list[0]
  meat_id     = hw_meat.access_meat_1.id
  description = "Sandwich with conditional bread selection"
}

# ============================================================================
# Outputs: Demonstrating Property Access
# ============================================================================

output "list_access_examples" {
  description = "Examples of accessing items from lists"
  value = {
    first_item  = local.first_bread
    second_item = local.second_bread
    last_item   = local.last_bread
    safe_access = local.safe_access
  }
}

output "map_access_examples" {
  description = "Examples of accessing items from maps"
  value = {
    bracket_notation = local.bread_map["rye"]
    dot_notation     = local.bread_map.sourdough
    lookup_function  = local.lookup_bread
    safe_access      = local.safe_map_access
  }
}

output "set_access_examples" {
  description = "Examples of accessing items from sets"
  value = {
    converted_to_list = local.meat_list_from_set
    first_from_set    = local.first_meat_from_set
    contains_check    = local.has_turkey
    filtered_item     = local.turkey_meat
  }
}

output "nested_access_examples" {
  description = "Examples of accessing nested properties"
  value = {
    nested_map_access = local.downtown_bread
    chained_access    = local.nested_access
    all_nested_values = local.all_store_breads
  }
}

output "for_each_access_examples" {
  description = "Examples of accessing for_each resources"
  value = {
    specific_key    = local.turkey_meat_id
    all_as_map      = local.all_meat_ids
    all_as_list     = local.all_meat_ids_list
  }
}

output "count_access_examples" {
  description = "Examples of accessing count resources"
  value = {
    first_instance  = local.first_bread_count
    all_instances   = local.all_bread_ids_count
  }
}

output "data_source_access_examples" {
  description = "Examples of accessing data source properties"
  value = {
    first_meat      = local.first_available_meat
    last_meat       = local.last_available_meat
    all_meats       = local.all_available_meats
  }
}

# ============================================================================
# Property Access Cheat Sheet
# ============================================================================
#
# LIST ACCESS:
#   list[0]              - First item (index 0)
#   list[1]              - Second item (index 1)
#   list[length(list)-1] - Last item
#   try(list[5], null)   - Safe access with fallback
#
# MAP ACCESS:
#   map["key"]           - Access by key (bracket notation)
#   map.key              - Access by key (dot notation)
#   lookup(map, "key", "default") - Access with default value
#   try(map["key"], null) - Safe access with fallback
#
# SET ACCESS:
#   tolist(set)[0]       - Convert to list, then access by index
#   contains(set, "value") - Check if value exists
#   [for x in set : x if condition][0] - Filter and get first
#
# NESTED ACCESS:
#   map["key1"]["key2"]   - Chained bracket notation
#   map.key1.key2         - Chained dot notation
#   map["key1"].key2      - Mixed notation
#
# FOR_EACH RESOURCE ACCESS:
#   resource["key"].id    - Access specific instance by key
#   resource.key.id       - Alternative syntax
#
# COUNT RESOURCE ACCESS:
#   resource[0].id        - Access first instance
#   resource[1].id        - Access second instance
#
# SAFE ACCESS PATTERNS:
#   try(expression, fallback) - Returns fallback if expression errors
#   lookup(map, key, default) - Returns default if key doesn't exist
#   contains(collection, value) - Check if value exists before access
