# ============================================================================
# Variable Validation Examples
# ============================================================================
# This file demonstrates various validation patterns for Terraform variables.
# Validation blocks ensure that variable values meet your requirements before
# Terraform attempts to create or modify resources.
#
# Validation blocks use the format:
#   validation {
#     condition     = <boolean expression>
#     error_message = "Error message shown when validation fails"
#   }
#
# You can have multiple validation blocks per variable.
# All validations must pass for the variable to be accepted.

# ============================================================================
# Example 1: String Length Validation
# ============================================================================
variable "store_name" {
  description = <<-EOT
    Name of the store (must be between 3 and 50 characters).
    
    VALIDATION RULES:
    - Minimum length: 3 characters
    - Maximum length: 50 characters
    
    EXAMPLE VALID VALUES:
    - "Downtown Deli"
    - "Main Street Sandwich Shop"
    
    EXAMPLE INVALID VALUES:
    - "AB" (too short)
    - "A" * 51 (too long)
  EOT
  type        = string
  default     = "My Sandwich Shop"

  validation {
    condition     = length(var.store_name) >= 3 && length(var.store_name) <= 50
    error_message = "Store name must be between 3 and 50 characters long."
  }
}

# ============================================================================
# Example 2: String Pattern Validation (Regex)
# ============================================================================
variable "store_id" {
  description = <<-EOT
    Store identifier (must match pattern: 3 letters, dash, 4 digits).
    
    VALIDATION RULES:
    - Must match pattern: AAA-1234
    - 3 uppercase letters, dash, 4 digits
    
    EXAMPLE VALID VALUES:
    - "ABC-1234"
    - "XYZ-9876"
    
    EXAMPLE INVALID VALUES:
    - "abc-1234" (lowercase letters)
    - "ABC1234" (missing dash)
    - "AB-1234" (only 2 letters)
    - "ABC-123" (only 3 digits)
  EOT
  type        = string
  default     = "STO-0001"

  validation {
    condition     = can(regex("^[A-Z]{3}-[0-9]{4}$", var.store_id))
    error_message = "Store ID must be in format AAA-1234 (3 uppercase letters, dash, 4 digits)."
  }
}

# ============================================================================
# Example 3: String Enum/Allowed Values
# ============================================================================
variable "bread_type" {
  description = <<-EOT
    Type of bread (must be one of the allowed values).
    
    VALIDATION RULES:
    - Must be one of: rye, sourdough, wheat, ciabatta, white, multigrain
    
    EXAMPLE VALID VALUES:
    - "rye"
    - "sourdough"
    - "wheat"
    
    EXAMPLE INVALID VALUES:
    - "bagel" (not in allowed list)
    - "RYE" (case-sensitive, must be lowercase)
  EOT
  type        = string
  default     = "rye"

  validation {
    condition     = contains(["rye", "sourdough", "wheat", "ciabatta", "white", "multigrain"], var.bread_type)
    error_message = "Bread type must be one of: rye, sourdough, wheat, ciabatta, white, multigrain."
  }
}

# ============================================================================
# Example 4: Number Range Validation
# ============================================================================
variable "sandwich_price" {
  description = <<-EOT
    Price of a sandwich in dollars (must be between $1.00 and $20.00).
    
    VALIDATION RULES:
    - Minimum: 1.00
    - Maximum: 20.00
    
    EXAMPLE VALID VALUES:
    - 5.00
    - 12.50
    - 1.00
    - 20.00
    
    EXAMPLE INVALID VALUES:
    - 0.99 (below minimum)
    - 20.01 (above maximum)
    - -5.00 (negative)
  EOT
  type        = number
  default     = 5.00

  validation {
    condition     = var.sandwich_price >= 1.00 && var.sandwich_price <= 20.00
    error_message = "Sandwich price must be between $1.00 and $20.00."
  }
}

# ============================================================================
# Example 5: Number Integer Validation
# ============================================================================
variable "table_count" {
  description = <<-EOT
    Number of tables (must be a positive integer).
    
    VALIDATION RULES:
    - Must be a positive integer (>= 1)
    - No decimal values allowed
    
    EXAMPLE VALID VALUES:
    - 1
    - 10
    - 50
    
    EXAMPLE INVALID VALUES:
    - 0 (must be positive)
    - -5 (negative)
    - 5.5 (must be integer)
  EOT
  type        = number
  default     = 10

  validation {
    condition     = var.table_count >= 1 && floor(var.table_count) == var.table_count
    error_message = "Table count must be a positive integer (1 or greater)."
  }
}

# ============================================================================
# Example 6: List Length Validation
# ============================================================================
variable "meat_selections" {
  description = <<-EOT
    List of meat types (must have between 1 and 10 items).
    
    VALIDATION RULES:
    - Minimum items: 1
    - Maximum items: 10
    
    EXAMPLE VALID VALUES:
    - ["turkey"]
    - ["turkey", "ham", "roast beef"]
    - ["turkey", "ham", "chicken", "pastrami", "salami", "roast beef", "corned beef", "bologna", "mortadella", "prosciutto"]
    
    EXAMPLE INVALID VALUES:
    - [] (empty list)
    - List with 11+ items
  EOT
  type        = list(string)
  default     = ["turkey", "ham"]

  validation {
    condition     = length(var.meat_selections) >= 1 && length(var.meat_selections) <= 10
    error_message = "Meat selections must contain between 1 and 10 items."
  }
}

# ============================================================================
# Example 7: List Item Validation (All Items Must Match Pattern)
# ============================================================================
variable "store_locations" {
  description = <<-EOT
    List of store location codes (each must be 2 uppercase letters).
    
    VALIDATION RULES:
    - Each item must be exactly 2 uppercase letters
    - Pattern: [A-Z]{2}
    
    EXAMPLE VALID VALUES:
    - ["NY", "CA", "TX"]
    - ["MA", "FL"]
    
    EXAMPLE INVALID VALUES:
    - ["ny", "CA"] (lowercase not allowed)
    - ["NYC", "CA"] (NYC is 3 characters)
    - ["N1", "CA"] (numbers not allowed)
  EOT
  type        = list(string)
  default     = ["NY", "CA"]

  validation {
    condition = alltrue([
      for loc in var.store_locations : can(regex("^[A-Z]{2}$", loc))
    ])
    error_message = "Each store location must be exactly 2 uppercase letters (e.g., 'NY', 'CA', 'TX')."
  }
}

# ============================================================================
# Example 8: Map Key Validation
# ============================================================================
variable "store_configs" {
  description = <<-EOT
    Map of store configurations (keys must be valid store IDs).
    
    VALIDATION RULES:
    - All keys must match pattern: STO-#### (STO- followed by 4 digits)
    
    EXAMPLE VALID VALUES:
    - { "STO-0001" = "Downtown", "STO-0002" = "Uptown" }
    
    EXAMPLE INVALID VALUES:
    - { "store-1" = "Downtown" } (invalid key format)
    - { "STO-1" = "Downtown" } (not 4 digits)
  EOT
  type        = map(string)
  default = {
    "STO-0001" = "Downtown Location"
    "STO-0002" = "Uptown Location"
  }

  validation {
    condition = alltrue([
      for key in keys(var.store_configs) : can(regex("^STO-[0-9]{4}$", key))
    ])
    error_message = "All store config keys must be in format STO-#### (e.g., STO-0001)."
  }
}

# ============================================================================
# Example 9: Object Attribute Validation
# ============================================================================
variable "sandwich_spec" {
  description = <<-EOT
    Sandwich specification object with validated attributes.
    
    VALIDATION RULES:
    - bread_type: must be one of allowed values
    - price: must be between 1.00 and 20.00
    - quantity: must be positive integer
    
    EXAMPLE VALID VALUES:
    - { bread_type = "rye", price = 5.50, quantity = 10 }
    
    EXAMPLE INVALID VALUES:
    - { bread_type = "bagel", price = 5.50, quantity = 10 } (invalid bread type)
    - { bread_type = "rye", price = 25.00, quantity = 10 } (price too high)
    - { bread_type = "rye", price = 5.50, quantity = -5 } (negative quantity)
  EOT
  type = object({
    bread_type = string
    price      = number
    quantity   = number
  })
  default = {
    bread_type = "rye"
    price      = 5.00
    quantity   = 1
  }

  validation {
    condition     = contains(["rye", "sourdough", "wheat", "ciabatta", "white", "multigrain"], var.sandwich_spec.bread_type)
    error_message = "bread_type must be one of: rye, sourdough, wheat, ciabatta, white, multigrain."
  }

  validation {
    condition     = var.sandwich_spec.price >= 1.00 && var.sandwich_spec.price <= 20.00
    error_message = "price must be between $1.00 and $20.00."
  }

  validation {
    condition     = var.sandwich_spec.quantity >= 1 && floor(var.sandwich_spec.quantity) == var.sandwich_spec.quantity
    error_message = "quantity must be a positive integer."
  }
}

# ============================================================================
# Example 10: Multiple Validation Blocks (All Must Pass)
# ============================================================================
variable "email_address" {
  description = <<-EOT
    Email address with multiple validation rules.
    
    VALIDATION RULES:
    - Must contain @ symbol
    - Must be at least 5 characters
    - Must end with valid domain (.com, .org, .net, etc.)
    
    EXAMPLE VALID VALUES:
    - "user@example.com"
    - "admin@store.org"
    
    EXAMPLE INVALID VALUES:
    - "user" (no @)
    - "a@b" (too short)
    - "user@" (no domain)
  EOT
  type        = string
  default     = "admin@example.com"

  # Validation 1: Must contain @
  validation {
    condition     = can(regex("@", var.email_address))
    error_message = "Email address must contain an @ symbol."
  }

  # Validation 2: Minimum length
  validation {
    condition     = length(var.email_address) >= 5
    error_message = "Email address must be at least 5 characters long."
  }

  # Validation 3: Must have valid domain format
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.email_address))
    error_message = "Email address must have a valid domain format (e.g., user@example.com)."
  }
}

# ============================================================================
# Example 11: Conditional Validation (Based on Another Attribute)
# ============================================================================
variable "discount_config" {
  description = <<-EOT
    Discount configuration with conditional validation.
    
    VALIDATION RULES:
    - If discount_type is "percentage", discount_value must be 0-100
    - If discount_type is "fixed", discount_value must be positive
    - discount_type must be "percentage" or "fixed"
    
    EXAMPLE VALID VALUES:
    - { discount_type = "percentage", discount_value = 10 }
    - { discount_type = "fixed", discount_value = 2.50 }
    
    EXAMPLE INVALID VALUES:
    - { discount_type = "percentage", discount_value = 150 } (percentage > 100)
    - { discount_type = "fixed", discount_value = -5 } (negative fixed)
    - { discount_type = "invalid", discount_value = 10 } (invalid type)
  EOT
  type = object({
    discount_type  = string
    discount_value = number
  })
  default = {
    discount_type  = "percentage"
    discount_value = 10
  }

  # Validate discount_type
  validation {
    condition     = contains(["percentage", "fixed"], var.discount_config.discount_type)
    error_message = "discount_type must be either 'percentage' or 'fixed'."
  }

  # Conditional validation: percentage must be 0-100
  validation {
    condition     = var.discount_config.discount_type != "percentage" || (var.discount_config.discount_value >= 0 && var.discount_config.discount_value <= 100)
    error_message = "When discount_type is 'percentage', discount_value must be between 0 and 100."
  }

  # Conditional validation: fixed must be positive
  validation {
    condition     = var.discount_config.discount_type != "fixed" || var.discount_config.discount_value > 0
    error_message = "When discount_type is 'fixed', discount_value must be greater than 0."
  }
}

# ============================================================================
# Example 12: Boolean with Dependent Validation
# ============================================================================
variable "enable_premium_features" {
  description = <<-EOT
    Whether to enable premium features (boolean).
    
    VALIDATION RULES:
    - Must be true or false (boolean)
    
    EXAMPLE VALID VALUES:
    - true
    - false
    
    NOTE: Boolean validation is usually implicit, but this shows the pattern.
  EOT
  type        = bool
  default     = false

  # Note: Booleans are already type-validated, but this shows the pattern
  validation {
    condition     = var.enable_premium_features == true || var.enable_premium_features == false
    error_message = "enable_premium_features must be either true or false."
  }
}

# ============================================================================
# Example 13: Complex String Validation (Multiple Patterns)
# ============================================================================
variable "phone_number" {
  description = <<-EOT
    Phone number in format (XXX) XXX-XXXX or XXX-XXX-XXXX.
    
    VALIDATION RULES:
    - Must match one of two patterns:
      1. (XXX) XXX-XXXX
      2. XXX-XXX-XXXX
    - Where X is a digit
    
    EXAMPLE VALID VALUES:
    - "(555) 123-4567"
    - "555-123-4567"
    
    EXAMPLE INVALID VALUES:
    - "5551234567" (no formatting)
    - "555-123-45" (too short)
    - "(555)123-4567" (missing space)
  EOT
  type        = string
  default     = "(555) 123-4567"

  validation {
    condition     = can(regex("^\\([0-9]{3}\\) [0-9]{3}-[0-9]{4}$", var.phone_number)) || can(regex("^[0-9]{3}-[0-9]{3}-[0-9]{4}$", var.phone_number))
    error_message = "Phone number must be in format (XXX) XXX-XXXX or XXX-XXX-XXXX."
  }
}

# ============================================================================
# Example 14: List of Objects with Validation
# ============================================================================
variable "menu_items" {
  description = <<-EOT
    List of menu items, each with validated attributes.
    
    VALIDATION RULES:
    - Each item must have a name (non-empty string)
    - Each item must have a price between 0.50 and 50.00
    - List must have at least 1 item
    
    EXAMPLE VALID VALUES:
    - [{ name = "Sandwich", price = 5.00 }, { name = "Soup", price = 3.50 }]
    
    EXAMPLE INVALID VALUES:
    - [] (empty list)
    - [{ name = "", price = 5.00 }] (empty name)
    - [{ name = "Sandwich", price = 100.00 }] (price too high)
  EOT
  type = list(object({
    name  = string
    price = number
  }))
  default = [
    {
      name  = "Sandwich"
      price = 5.00
    }
  ]

  validation {
    condition     = length(var.menu_items) >= 1
    error_message = "Menu items list must contain at least one item."
  }

  validation {
    condition = alltrue([
      for item in var.menu_items : length(item.name) > 0
    ])
    error_message = "All menu items must have a non-empty name."
  }

  validation {
    condition = alltrue([
      for item in var.menu_items : item.price >= 0.50 && item.price <= 50.00
    ])
    error_message = "All menu item prices must be between $0.50 and $50.00."
  }
}

# ============================================================================
# Example 15: Validation with try() for Safe Access
# ============================================================================
variable "optional_config" {
  description = <<-EOT
    Optional configuration object.
    
    VALIDATION RULES:
    - If timeout is provided, it must be between 1 and 300 seconds
    - Uses try() to safely access optional attributes
    
    EXAMPLE VALID VALUES:
    - { timeout = 30 }
    - { timeout = 60, retries = 3 }
    - {} (empty, all optional)
    
    EXAMPLE INVALID VALUES:
    - { timeout = 0 } (too low)
    - { timeout = 500 } (too high)
  EOT
  type = object({
    timeout = optional(number)
    retries = optional(number)
  })
  default = {
    timeout = 30
  }

  validation {
    condition     = try(var.optional_config.timeout, 30) >= 1 && try(var.optional_config.timeout, 30) <= 300
    error_message = "If provided, timeout must be between 1 and 300 seconds."
  }
}

# ============================================================================
# Example Resources Using Validated Variables
# ============================================================================

# Example: Using validated store_name
resource "hw_bread" "validated_bread" {
  count       = 1
  kind        = var.bread_type
  description = "Bread for ${var.store_name}"
}

# Example: Using validated sandwich_spec
resource "hw_meat" "validated_meat" {
  count = var.sandwich_spec.quantity
  kind  = "turkey"
}

# ============================================================================
# Outputs Demonstrating Validation
# ============================================================================

output "validation_examples" {
  description = "Examples of validated variables"
  value = {
    store_name      = var.store_name
    store_id        = var.store_id
    bread_type      = var.bread_type
    sandwich_price  = var.sandwich_price
    table_count     = var.table_count
    meat_selections = var.meat_selections
    store_locations = var.store_locations
    store_configs   = var.store_configs
    sandwich_spec   = var.sandwich_spec
    email_address   = var.email_address
    discount_config = var.discount_config
    phone_number    = var.phone_number
    menu_items      = var.menu_items
  }
}

output "validation_info" {
  description = "Information about variable validation"
  value = {
    note            = "All variables above have validation rules. Try setting invalid values to see validation errors."
    example_command = "terraform apply -var='sandwich_price=25.00'"
    example_error   = "This will fail validation: sandwich_price must be between $1.00 and $20.00"
  }
}
