# Example demonstrating advanced Terraform data types
# Shows: list, set, map, object, and tuple types

# ============================================================================
# LIST TYPE
# ============================================================================
# Lists are ordered collections of values of the same type
# Elements can be accessed by index: list[0], list[1], etc.

variable "types_sandwich_list" {
  description = "List of sandwich types (ordered, allows duplicates)"
  type        = list(string)
  default     = ["turkey", "ham", "turkey", "roast beef"]
}

locals {
  # List example: Get first sandwich type
  types_first_sandwich = var.types_sandwich_list[0]

  # List example: Get last sandwich type
  types_last_sandwich = var.types_sandwich_list[length(var.types_sandwich_list) - 1]

  # List example: Transform list (list comprehension)
  types_uppercase_sandwiches = [for s in var.types_sandwich_list : upper(s)]

  # List example: Filter list
  types_turkey_sandwiches = [for s in var.types_sandwich_list : s if s == "turkey"]
}

# ============================================================================
# SET TYPE
# ============================================================================
# Sets are unordered collections of unique values
# Automatically removes duplicates and has no order

variable "types_meat_set" {
  description = "Set of unique meat types (unordered, no duplicates)"
  type        = set(string)
  default     = ["turkey", "ham", "turkey", "roast beef", "chicken"]
  # Note: "turkey" appears twice but set will only have one
}

locals {
  # Set example: Convert set to list for indexing
  types_meat_list = tolist(var.types_meat_set)

  # Set example: Check if set contains a value
  types_has_turkey = contains(var.types_meat_set, "turkey")

  # Set example: Get set size
  types_meat_count = length(var.types_meat_set)
}

# ============================================================================
# MAP TYPE
# ============================================================================
# Maps are key-value pairs where keys are strings
# Values can be accessed by key: map["key"]

variable "types_price_map" {
  description = "Map of item names to prices"
  type        = map(number)
  default = {
    sandwich = 5.00
    drink    = 1.00
    soup     = 2.50
    salad    = 4.00
    cookie   = 1.50
  }
}

locals {
  # Map example: Access value by key
  types_sandwich_price = var.types_price_map["sandwich"]

  # Map example: Get all keys
  types_menu_items = keys(var.types_price_map)

  # Map example: Get all values
  types_all_prices = values(var.types_price_map)

  # Map example: Transform map (map comprehension)
  types_discounted_prices = {
    for item, price in var.types_price_map : item => price * 0.9
  }

  # Map example: Filter map
  types_expensive_items = {
    for item, price in var.types_price_map : item => price
    if price > 3.00
  }
}

# ============================================================================
# OBJECT TYPE
# ============================================================================
# Objects are collections of named attributes with specific types
# Each attribute can have a different type

variable "types_order_object" {
  description = "Object representing an order with different attribute types"
  type = object({
    order_id    = string
    quantity    = number
    items       = list(string)
    is_priority = bool
    metadata    = map(string)
  })
  default = {
    order_id    = "ORD-123"
    quantity    = 5
    items       = ["sandwich", "drink", "cookie"]
    is_priority = true
    metadata = {
      customer = "John Doe"
      location = "downtown"
    }
  }
}

locals {
  # Object example: Access attributes with dot notation
  types_order_id       = var.types_order_object.order_id
  types_order_quantity = var.types_order_object.quantity

  # Object example: Access nested attributes
  types_customer_name = var.types_order_object.metadata["customer"]

  # Object example: Create new object from existing
  types_order_summary = {
    id         = var.types_order_object.order_id
    item_count = length(var.types_order_object.items)
    priority   = var.types_order_object.is_priority
  }
}

# ============================================================================
# TUPLE TYPE
# ============================================================================
# Tuples are ordered collections with specific types at each position
# Unlike lists, each position can have a different type

variable "types_menu_tuple" {
  description = "Tuple with specific types at each position: (string, number, bool)"
  type        = tuple([string, number, bool])
  default     = ["sandwich", 5.00, true]
}

locals {
  # Tuple example: Access by index (like list)
  types_item_name      = var.types_menu_tuple[0] # string: "sandwich"
  types_item_price     = var.types_menu_tuple[1] # number: 5.00
  types_item_available = var.types_menu_tuple[2] # bool: true

  # Tuple example: Convert tuple to list (loses type safety)
  types_menu_list = tolist(var.types_menu_tuple)
}

# ============================================================================
# COMPLEX NESTED TYPES
# ============================================================================

variable "types_complex_order" {
  description = "Complex nested structure combining multiple types"
  type = object({
    customer = object({
      name  = string
      email = string
    })
    items = list(object({
      name     = string
      price    = number
      quantity = number
    }))
    tags     = set(string)
    metadata = map(string)
  })
  default = {
    customer = {
      name  = "Jane Smith"
      email = "jane@example.com"
    }
    items = [
      {
        name     = "sandwich"
        price    = 5.00
        quantity = 2
      },
      {
        name     = "drink"
        price    = 1.00
        quantity = 2
      }
    ]
    tags = ["lunch", "priority", "delivery"]
    metadata = {
      source = "web"
      region = "us-east"
    }
  }
}

locals {
  # Complex nested example: Access nested object
  types_complex_customer_name = var.types_complex_order.customer.name

  # Complex nested example: Access list of objects
  types_complex_first_item       = var.types_complex_order.items[0]
  types_complex_first_item_price = var.types_complex_order.items[0].price

  # Complex nested example: Calculate total from list of objects
  types_complex_order_total = sum([
    for item in var.types_complex_order.items : item.price * item.quantity
  ])

  # Complex nested example: Check if tag exists in set
  types_complex_has_delivery_tag = contains(var.types_complex_order.tags, "delivery")

  # Complex nested example: Get metadata value
  types_complex_order_source = var.types_complex_order.metadata["source"]
}

# ============================================================================
# TYPE CONVERSIONS
# ============================================================================

locals {
  # Convert list to set (removes duplicates, loses order)
  types_list_to_set = toset(var.types_sandwich_list)

  # Convert set to list (preserves uniqueness, adds order)
  types_set_to_list = tolist(var.types_meat_set)

  # Convert map to object (requires known structure)
  types_map_to_object = {
    for k, v in var.types_price_map : k => v
  }

  # Convert tuple to list
  types_tuple_to_list = tolist(var.types_menu_tuple)
}

# ============================================================================
# OUTPUTS DEMONSTRATING TYPES
# ============================================================================

output "types_list_examples" {
  description = "Examples of list operations"
  value = {
    original_list  = var.types_sandwich_list
    first_item     = local.types_first_sandwich
    last_item      = local.types_last_sandwich
    uppercase_list = local.types_uppercase_sandwiches
    filtered_list  = local.types_turkey_sandwiches
    list_length    = length(var.types_sandwich_list)
  }
}

output "types_set_examples" {
  description = "Examples of set operations"
  value = {
    original_set = var.types_meat_set
    set_as_list  = local.types_meat_list
    has_turkey   = local.types_has_turkey
    set_size     = local.types_meat_count
    # Note: Sets are displayed as lists in outputs but maintain uniqueness
  }
}

output "types_map_examples" {
  description = "Examples of map operations"
  value = {
    original_map      = var.types_price_map
    sandwich_price    = local.types_sandwich_price
    all_keys          = local.types_menu_items
    all_values        = local.types_all_prices
    discounted_prices = local.types_discounted_prices
    expensive_items   = local.types_expensive_items
  }
}

output "types_object_examples" {
  description = "Examples of object operations"
  value = {
    order_id       = local.types_order_id
    order_quantity = local.types_order_quantity
    customer_name  = local.types_customer_name
    order_summary  = local.types_order_summary
  }
}

output "types_tuple_examples" {
  description = "Examples of tuple operations"
  value = {
    original_tuple = var.types_menu_tuple
    item_name      = local.types_item_name
    item_price     = local.types_item_price
    item_available = local.types_item_available
    tuple_as_list  = local.types_menu_list
  }
}

output "types_complex_nested_examples" {
  description = "Examples of complex nested types"
  value = {
    customer_name    = local.types_complex_customer_name
    first_item       = local.types_complex_first_item
    first_item_price = local.types_complex_first_item_price
    order_total      = local.types_complex_order_total
    has_delivery_tag = local.types_complex_has_delivery_tag
    order_source     = local.types_complex_order_source
  }
}

output "types_conversion_examples" {
  description = "Examples of type conversions"
  value = {
    list_to_set   = local.types_list_to_set
    set_to_list   = local.types_set_to_list
    tuple_to_list = local.types_tuple_to_list
  }
}
