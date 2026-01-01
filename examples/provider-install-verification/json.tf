# Example demonstrating JSON handling in Terraform
# Shows how to load JSON data and create resources based on JSON contents

# ============================================================================
# Category 1: Loading JSON from Files
# ============================================================================
# Read and parse JSON files

locals {
  # jsondecode(): Parse JSON string into Terraform object
  # Syntax: jsondecode(json_string)

  # Load JSON from file (safe with try() for missing files)
  json_from_file = jsondecode(try(
    file("${path.module}/config/stores.json"),
    "{}"
  ))
  # Result: Terraform object/map from JSON file

  # Load JSON with default structure
  json_stores_config = jsondecode(try(
    file("${path.module}/config/stores.json"),
    jsonencode({
      stores = []
    })
  ))
  # Result: Object with stores array, or empty structure if file missing
}

# ============================================================================
# Category 2: Inline JSON Definitions
# ============================================================================
# Define JSON data directly in Terraform

locals {
  # Define JSON inline using jsondecode()
  json_inline_example = jsondecode(jsonencode({
    store_name = "Downtown Store"
    capacity   = 50
    location   = "Main Street"
    items = [
      { name = "bread", type = "rye", price = 3.50 },
      { name = "meat", type = "turkey", price = 4.00 }
    ]
  }))
  # Result: Terraform object from inline JSON

  # Simple JSON object
  json_simple_config = jsondecode(jsonencode({
    environment = "production"
    region      = "us-east-1"
    enabled     = true
  }))

  # JSON array
  json_array_example = jsondecode(jsonencode([
    { name = "bread-1", kind = "rye" },
    { name = "bread-2", kind = "sourdough" },
    { name = "bread-3", kind = "wheat" }
  ]))
  # Result: List of objects
}

# ============================================================================
# Category 3: Accessing JSON Properties
# ============================================================================
# Extract values from parsed JSON

locals {
  # Access top-level properties
  json_store_name = try(local.json_from_file.store_name, "Default Store")
  json_capacity   = try(local.json_from_file.capacity, 50)

  # Access nested properties
  json_nested_value = try(local.json_from_file.config.settings.timeout, 30)

  # Access array elements
  json_first_item = try(local.json_array_example[0], { name = "default", kind = "rye" })
  json_item_name  = try(local.json_array_example[0].name, "default")

  # Safe access with multiple fallbacks
  json_safe_access = try(
    local.json_from_file.store.name,
    local.json_from_file.default_store,
    "Unknown Store"
  )
}

# ============================================================================
# Category 4: Creating Resources from JSON (for_each)
# ============================================================================
# Use JSON data to create multiple resources

# Example JSON structure (would typically come from a file):
# {
#   "breads": [
#     { "kind": "rye", "description": "Fresh rye bread" },
#     { "kind": "sourdough", "description": "Artisan sourdough" },
#     { "kind": "wheat", "description": "Whole wheat bread" }
#   ]
# }

locals {
  # Parse JSON configuration
  json_breads_config = jsondecode(try(
    file("${path.module}/config/breads.json"),
    jsonencode({
      breads = [
        { kind = "rye", description = "Fresh rye bread" },
        { kind = "sourdough", description = "Artisan sourdough" },
        { kind = "wheat", description = "Whole wheat bread" }
      ]
    })
  ))

  # Convert JSON array to map for for_each
  json_breads_map = {
    for idx, bread in local.json_breads_config.breads :
    bread.kind => bread
  }
  # Result: { "rye" => { kind = "rye", description = "..." }, ... }
}

# Create resources from JSON data using for_each
resource "hw_bread" "json_breads" {
  for_each = local.json_breads_map

  kind        = each.value.kind
  description = try(each.value.description, "Bread from JSON config")
}

# ============================================================================
# Category 5: Creating Resources from JSON (count)
# ============================================================================
# Use JSON array length for count-based creation

locals {
  # JSON array for count-based resources
  json_meats_config = jsondecode(try(
    file("${path.module}/config/meats.json"),
    jsonencode({
      meats = [
        { kind = "turkey", description = "Premium turkey" },
        { kind = "ham", description = "Sliced ham" },
        { kind = "roast beef", description = "Roast beef" }
      ]
    })
  ))

  json_meats_list = local.json_meats_config.meats
}

# Create resources using count
resource "hw_meat" "json_meats" {
  count = length(local.json_meats_list)

  kind        = local.json_meats_list[count.index].kind
  description = try(local.json_meats_list[count.index].description, "Meat from JSON")
}

# ============================================================================
# Category 6: Complex JSON Structures
# ============================================================================
# Working with nested JSON objects and arrays

locals {
  # Complex JSON structure
  json_complex_config = jsondecode(try(
    file("${path.module}/config/complex-store.json"),
    jsonencode({
      store = {
        name     = "Main Store"
        location = "Downtown"
        capacity = 100
        equipment = {
          oven = {
            type        = "commercial"
            description = "Large commercial oven"
          }
          fridge = {
            size        = "large"
            description = "Walk-in refrigerator"
          }
        }
        staff = [
          { name = "Alice", role = "manager", experience = "expert" },
          { name = "Bob", role = "cook", experience = "experienced" },
          { name = "Charlie", role = "cook", experience = "junior" }
        ]
      }
    })
  ))

  # Access nested values
  json_oven_type   = try(local.json_complex_config.store.equipment.oven.type, "standard")
  json_fridge_size = try(local.json_complex_config.store.equipment.fridge.size, "medium")

  # Access array elements
  json_first_staff = try(local.json_complex_config.store.staff[0], {})
  json_staff_names = [for staff in try(local.json_complex_config.store.staff, []) : staff.name]
}

# Create resources from complex JSON
resource "hw_oven" "json_oven" {
  type        = local.json_oven_type
  description = try(local.json_complex_config.store.equipment.oven.description, "Oven from JSON")
}

resource "hw_fridge" "json_fridge" {
  size        = local.json_fridge_size
  description = try(local.json_complex_config.store.equipment.fridge.description, "Fridge from JSON")
}

# Create cooks from JSON staff array
resource "hw_cook" "json_cooks" {
  for_each = {
    for idx, staff in try(local.json_complex_config.store.staff, []) :
    staff.name => staff
    if staff.role == "cook"
  }

  name        = each.value.name
  experience  = each.value.experience
  description = "Cook from JSON config: ${each.value.name}"
}

# ============================================================================
# Category 7: JSON with Conditional Logic
# ============================================================================
# Use JSON data in conditional expressions

locals {
  # JSON with feature flags
  json_features_config = jsondecode(try(
    file("${path.module}/config/features.json"),
    jsonencode({
      features = {
        enable_premium_bread = true
        enable_special_meats = false
        max_items            = 10
      }
    })
  ))

  json_enable_premium = try(local.json_features_config.features.enable_premium_bread, false)
  json_max_items      = try(local.json_features_config.features.max_items, 5)
}

# Conditional resource creation based on JSON
resource "hw_bread" "json_premium_bread" {
  count = local.json_enable_premium ? 1 : 0

  kind        = "ciabatta"
  description = "Premium bread enabled via JSON config"
}

# ============================================================================
# Category 8: Transforming JSON Data
# ============================================================================
# Transform JSON data before using it

locals {
  # Original JSON structure
  json_raw_data = jsondecode(try(
    file("${path.module}/config/raw-data.json"),
    jsonencode({
      items = [
        { type = "bread", name = "rye", price = 3.5 },
        { type = "bread", name = "sourdough", price = 4.0 },
        { type = "meat", name = "turkey", price = 4.5 }
      ]
    })
  ))

  # Transform: Filter items by type
  json_bread_items = [
    for item in try(local.json_raw_data.items, []) :
    item if item.type == "bread"
  ]

  # Transform: Create map keyed by name
  json_items_by_name = {
    for item in try(local.json_raw_data.items, []) :
    item.name => item
  }

  # Transform: Calculate totals
  json_total_price = sum([
    for item in try(local.json_raw_data.items, []) :
    try(item.price, 0)
  ])

  # Transform: Extract unique types
  json_unique_types = toset([
    for item in try(local.json_raw_data.items, []) :
    item.type
  ])
}

# ============================================================================
# Category 9: JSON Validation and Error Handling
# ============================================================================
# Validate JSON structure and handle errors

locals {
  # Load JSON with validation
  json_validated_config = try(
    jsondecode(file("${path.module}/config/validated.json")),
    null
  )

  # Check if JSON loaded successfully
  json_is_valid = local.json_validated_config != null

  # Validate required fields exist
  json_has_required_fields = local.json_is_valid && try(local.json_validated_config.store_name, null) != null && try(local.json_validated_config.capacity, null) != null

  # Safe access with validation
  json_validated_store_name = local.json_has_required_fields ? local.json_validated_config.store_name : "Default Store"

  # Validate JSON array structure
  json_validated_items = try(
    local.json_validated_config.items,
    []
  )

  json_items_are_valid = length(local.json_validated_items) > 0 && alltrue([for item in local.json_validated_items : try(item.name, null) != null && try(item.kind, null) != null])
}

# ============================================================================
# Category 10: Practical Examples
# ============================================================================
# Real-world use cases

# Example 1: Store configuration from JSON
locals {
  json_store_full_config = jsondecode(try(
    file("${path.module}/config/store-full.json"),
    jsonencode({
      store = {
        name        = "JSON Configured Store"
        description = "Store configured via JSON file"
        oven = {
          type = "commercial"
        }
        cooks = [
          { name = "Cook 1", experience = "experienced" },
          { name = "Cook 2", experience = "junior" }
        ]
        tables = {
          quantity = 8
          size     = "medium"
        }
        chairs = {
          quantity = 16
          style    = "comfortable"
        }
        fridge = {
          size = "large"
        }
      }
    })
  ))
}

# Create complete store from JSON
resource "hw_oven" "json_store_oven" {
  type        = local.json_store_full_config.store.oven.type
  description = "Oven from JSON store config"
}

resource "hw_cook" "json_store_cooks" {
  for_each = {
    for idx, cook in local.json_store_full_config.store.cooks :
    cook.name => cook
  }

  name       = each.value.name
  experience = each.value.experience
}

resource "hw_tables" "json_store_tables" {
  quantity    = local.json_store_full_config.store.tables.quantity
  size        = local.json_store_full_config.store.tables.size
  description = "Tables from JSON config"
}

resource "hw_chairs" "json_store_chairs" {
  quantity    = local.json_store_full_config.store.chairs.quantity
  style       = local.json_store_full_config.store.chairs.style
  description = "Chairs from JSON config"
}

resource "hw_fridge" "json_store_fridge" {
  size        = local.json_store_full_config.store.fridge.size
  description = "Fridge from JSON config"
}

resource "hw_store" "json_store" {
  name      = local.json_store_full_config.store.name
  oven_id   = hw_oven.json_store_oven.id
  cook_ids  = [for cook in hw_cook.json_store_cooks : cook.id]
  tables_id = hw_tables.json_store_tables.id
  chairs_id = hw_chairs.json_store_chairs.id
  fridge_id = hw_fridge.json_store_fridge.id
}

# Example 2: Menu items from JSON
locals {
  json_menu_config = jsondecode(try(
    file("${path.module}/config/menu.json"),
    jsonencode({
      menu = {
        sandwiches = [
          { bread_kind = "rye", meat_kind = "turkey" },
          { bread_kind = "sourdough", meat_kind = "ham" }
        ]
        drinks = [
          { type = "soda", size = "large" },
          { type = "juice", size = "medium" }
        ]
      }
    })
  ))
}

# Create sandwiches from JSON menu
resource "hw_bread" "json_menu_breads" {
  for_each = toset([
    for sandwich in try(local.json_menu_config.menu.sandwiches, []) :
    sandwich.bread_kind
  ])

  kind        = each.value
  description = "Bread for menu item: ${each.value}"
}

resource "hw_meat" "json_menu_meats" {
  for_each = toset([
    for sandwich in try(local.json_menu_config.menu.sandwiches, []) :
    sandwich.meat_kind
  ])

  kind        = each.value
  description = "Meat for menu item: ${each.value}"
}

resource "hw_sandwich" "json_menu_sandwiches" {
  for_each = {
    for idx, sandwich in try(local.json_menu_config.menu.sandwiches, []) :
    "sandwich-${idx}" => sandwich
  }

  bread_id = hw_bread.json_menu_breads[each.value.bread_kind].id
  meat_id  = hw_meat.json_menu_meats[each.value.meat_kind].id
}

# ============================================================================
# Category 11: JSON Encoding (Terraform to JSON)
# ============================================================================
# Convert Terraform values to JSON

locals {
  # jsonencode(): Convert Terraform value to JSON string
  json_encoded_config = jsonencode({
    store_name = "Encoded Store"
    items = [
      { name = "bread", price = 3.50 },
      { name = "meat", price = 4.00 }
    ]
    settings = {
      enabled = true
      timeout = 30
    }
  })
  # Result: JSON string representation

  # Encode resource outputs to JSON
  json_encoded_resources = jsonencode({
    bread_ids = [for bread in hw_bread.json_breads : bread.id]
    meat_ids  = [for meat in hw_meat.json_meats : meat.id]
    store_id  = try(hw_store.json_store.id, null)
  })

  # Encode for external systems
  json_export_data = jsonencode({
    timestamp = timestamp()
    resources = {
      breads = length(hw_bread.json_breads)
      meats  = length(hw_meat.json_meats)
      stores = try(hw_store.json_store.id != null ? 1 : 0, 0)
    }
  })
}

# ============================================================================
# JSON Best Practices
# ============================================================================
#
# 1. ALWAYS use try() when loading JSON from files
#    ✅ jsondecode(try(file("config.json"), "{}"))
#    ❌ jsondecode(file("config.json"))  # Fails if file missing
#
# 2. Provide meaningful default structures
#    ✅ jsondecode(try(file("config.json"), jsonencode({ items = [] })))
#    ❌ jsondecode(try(file("config.json"), "{}"))  # May cause access errors
#
# 3. Use try() for accessing nested properties
#    ✅ try(json.store.equipment.oven.type, "default")
#    ❌ json.store.equipment.oven.type  # Fails if any level missing
#
# 4. Validate JSON structure before using
#    ✅ Check for null, check required fields exist
#    ✅ Validate array elements have required properties
#
# 5. Use for_each with maps (not arrays) when possible
#    ✅ for_each = { for item in items : item.key => item }
#    ⚠️  for_each with arrays requires unique keys
#
# 6. Handle missing or empty arrays gracefully
#    ✅ try(json.items, [])
#    ❌ json.items  # Fails if items doesn't exist
#
# 7. Use jsonencode() for creating JSON strings
#    ✅ jsonencode({ key = "value" })
#    ✅ Useful for defaults, exports, API calls
#
# 8. Document expected JSON structure
#    ✅ Add comments showing expected JSON schema
#    ✅ Include example JSON in comments
#
# 9. Transform JSON data before using in resources
#    ✅ Filter, map, validate in locals first
#    ✅ Keep resource blocks clean and readable
#
# 10. Test with missing/invalid JSON
#     ✅ Ensure try() fallbacks work correctly
#     ✅ Validate error handling

# ============================================================================
# JSON Function Reference
# ============================================================================
#
# PARSING:
#   jsondecode(json_string)     - Parse JSON string to Terraform object
#   jsonencode(value)            - Convert Terraform value to JSON string
#
# LOADING:
#   jsondecode(file(path))       - Load and parse JSON file
#   jsondecode(try(file(path), "{}")) - Safe JSON file loading
#
# ACCESS:
#   json.key                     - Access object property
#   json.array[0]               - Access array element
#   json.nested.key             - Access nested property
#   try(json.key, default)      - Safe access with default
#
# TRANSFORMATION:
#   [for item in json.items : item.name]  - Extract values
#   {for item in json.items : item.key => item} - Create map
#   [for item in json.items : item if item.enabled] - Filter
#
# VALIDATION:
#   json != null                 - Check if loaded
#   try(json.key, null) != null - Check if property exists
#   length(json.items) > 0      - Check if array has items

# ============================================================================
# Outputs: Demonstrating JSON Usage
# ============================================================================

output "json_basic_examples" {
  description = "Basic JSON loading examples"
  value = {
    from_file      = local.json_from_file
    inline_example = local.json_inline_example
    simple_config  = local.json_simple_config
  }
}

output "json_resource_examples" {
  description = "Resources created from JSON"
  value = {
    bread_count = length(hw_bread.json_breads)
    meat_count  = length(hw_meat.json_meats)
    bread_ids   = [for bread in hw_bread.json_breads : bread.id]
    meat_ids    = [for meat in hw_meat.json_meats : meat.id]
  }
}

output "json_complex_examples" {
  description = "Complex JSON structure examples"
  value = {
    oven_type   = local.json_oven_type
    fridge_size = local.json_fridge_size
    staff_names = local.json_staff_names
    cook_count  = length(hw_cook.json_cooks)
  }
}

output "json_transformation_examples" {
  description = "JSON transformation examples"
  value = {
    bread_items  = local.json_bread_items
    total_price  = local.json_total_price
    unique_types = local.json_unique_types
  }
}

output "json_encoding_examples" {
  description = "JSON encoding examples"
  value = {
    encoded_config    = local.json_encoded_config
    encoded_resources = local.json_encoded_resources
  }
  sensitive = false # Set to true if contains sensitive data
}
