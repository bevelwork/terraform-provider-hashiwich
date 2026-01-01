# Example demonstrating Terraform variables and .tfvars files
# Variables allow you to parameterize your Terraform configurations
# .tfvars files provide a way to set variable values without hardcoding them

# ============================================================================
# Variable Declaration Basics
# ============================================================================
# Variables are declared with: variable "name" { ... }
# They can have: type, description, default, validation, sensitive

# ============================================================================
# Variable 1: Simple String Variable with Default
# ============================================================================
variable "sandwich_bread_type" {
  description = <<-EOT
    Type of bread to use for sandwiches.
    
    HOW TO USE .tfvars FILES:
    
    1. Create a .tfvars file (e.g., terraform.tfvars):
       sandwich_bread_type = "sourdough"
    
    2. Use -var-file flag:
       terraform apply -var-file="production.tfvars"
       terraform apply -var-file="development.tfvars"
    
    3. Auto-loaded files (terraform.tfvars or *.auto.tfvars):
       - terraform.tfvars (automatically loaded if present)
       - terraform.tfvars.json (JSON format)
       - *.auto.tfvars (all files matching this pattern)
       - *.auto.tfvars.json (JSON format)
    
    4. Command line:
       terraform apply -var='sandwich_bread_type="ciabatta"'
    
    5. Environment variables:
       export TF_VAR_sandwich_bread_type="baguette"
       terraform apply
    
    PRIORITY (highest to lowest):
    1. Command line (-var)
    2. .tfvars files (-var-file)
    3. terraform.tfvars (auto-loaded)
    4. *.auto.tfvars (auto-loaded)
    5. Environment variables (TF_VAR_*)
    6. Variable defaults (this value)
    
    BEST PRACTICES:
    - Use defaults for development/testing
    - Use .tfvars files for different environments
    - Never commit .tfvars with secrets (add to .gitignore)
    - Use terraform.tfvars.example as a template
  EOT
  type        = string
  default     = "rye"  # Sensible default for development
}

# ============================================================================
# Variable 2: Number Variable
# ============================================================================
# Note: store_budget is already defined in optimization.tf
# This is an example of how to declare a number variable:
#
# variable "example_budget" {
#   description = <<-EOT
#     Total budget available (in dollars).
#     
#     EXAMPLE .tfvars FILE (budget.tfvars):
#     example_budget = 5000.00
#     
#     EXAMPLE COMMAND LINE:
#     terraform apply -var="example_budget=3000"
#     
#     EXAMPLE ENVIRONMENT VARIABLE:
#     export TF_VAR_example_budget=4000
#     terraform apply
#   EOT
#   type        = number
#   default     = 3000.00  # Default budget for development
# }

# ============================================================================
# Variable 3: Boolean Variable
# ============================================================================
variable "include_drinks" {
  description = <<-EOT
    Whether to include drinks in the order.
    
    EXAMPLE .tfvars:
    include_drinks = true
    
    EXAMPLE COMMAND LINE:
    terraform apply -var="include_drinks=false"
  EOT
  type        = bool
  default     = true  # Default to including drinks
}

# ============================================================================
# Variable 4: List Variable
# ============================================================================
variable "meat_types" {
  description = <<-EOT
    List of meat types to create sandwiches for.
    
    EXAMPLE .tfvars:
    meat_types = ["turkey", "ham", "roast beef", "chicken"]
    
    EXAMPLE COMMAND LINE:
    terraform apply -var='meat_types=["turkey","ham"]'
    
    EXAMPLE ENVIRONMENT VARIABLE (comma-separated):
    export TF_VAR_meat_types='["turkey","ham"]'
  EOT
  type        = list(string)
  default     = ["turkey", "ham"]  # Default to common meats
}

# ============================================================================
# Variable 5: Map Variable
# ============================================================================
variable "store_config" {
  description = <<-EOT
    Map of store configuration settings.
    
    EXAMPLE .tfvars:
    store_config = {
      name        = "Downtown Location"
      max_customers = 50
      open_hours   = "9am-5pm"
    }
    
    EXAMPLE COMMAND LINE:
    terraform apply -var='store_config={"name"="Main St","max_customers"=30}'
  EOT
  type = map(string)
  default = {
    name         = "Default Store"
    max_customers = "25"
    open_hours    = "8am-6pm"
  }
}

# ============================================================================
# Variable 6: Object Variable
# ============================================================================
variable "sandwich_config" {
  description = <<-EOT
    Object containing sandwich configuration.
    
    EXAMPLE .tfvars:
    sandwich_config = {
      bread_type = "sourdough"
      meat_type  = "turkey"
      price      = 5.50
      available  = true
    }
    
    EXAMPLE COMMAND LINE (complex, better to use .tfvars):
    terraform apply -var-file="config.tfvars"
  EOT
  type = object({
    bread_type = string
    meat_type  = string
    price      = number
    available  = bool
  })
  default = {
    bread_type = "rye"
    meat_type  = "turkey"
    price      = 5.00
    available  = true
  }
}

# ============================================================================
# Variable 7: Sensitive Variable
# ============================================================================
variable "api_key" {
  description = <<-EOT
    API key for external service (sensitive - will be redacted in output).
    
    IMPORTANT FOR .tfvars:
    - Never commit .tfvars files with sensitive values to version control
    - Add terraform.tfvars to .gitignore
    - Use terraform.tfvars.example as a template (without real values)
    - Consider using secret management (AWS Secrets Manager, HashiCorp Vault, etc.)
    
    EXAMPLE .tfvars (DO NOT COMMIT THIS FILE):
    api_key = "sk_live_1234567890abcdef"
    
    EXAMPLE .gitignore entry:
    terraform.tfvars
    *.tfvars
    !terraform.tfvars.example
    
    EXAMPLE terraform.tfvars.example (safe to commit):
    api_key = "your-api-key-here"
  EOT
  type        = string
  sensitive   = true
  default     = "dev-key-not-for-production"  # Default for local development
}

# ============================================================================
# Variable 8: Variable with Validation
# ============================================================================
variable "sandwich_count" {
  description = <<-EOT
    Number of sandwiches to create (must be between 1 and 100).
    
    EXAMPLE .tfvars:
    sandwich_count = 50
    
    VALIDATION:
    - Terraform will reject values outside the range
    - Error message will guide you to valid values
    
    EXAMPLE INVALID VALUE:
    terraform apply -var="sandwich_count=150"
    # Error: Invalid value for variable
    
    EXAMPLE VALID VALUE:
    terraform apply -var="sandwich_count=25"
  EOT
  type        = number
  default     = 10
  
  validation {
    condition     = var.sandwich_count >= 1 && var.sandwich_count <= 100
    error_message = "Sandwich count must be between 1 and 100."
  }
}

# ============================================================================
# Variable 9: Variable with Nullable Default
# ============================================================================
variable "custom_description" {
  description = <<-EOT
    Optional custom description (null means use default).
    
    EXAMPLE .tfvars (explicit null):
    custom_description = null
    
    EXAMPLE .tfvars (with value):
    custom_description = "Special order for event"
    
    EXAMPLE .tfvars (omit variable - uses default):
    # Don't include custom_description, will use default
  EOT
  type        = string
  default     = null  # Nullable - can be omitted
  nullable    = true
}

# ============================================================================
# Example: Using Variables in Resources
# ============================================================================

resource "hw_bread" "variable_bread" {
  kind        = var.sandwich_bread_type
  description = var.custom_description != null ? var.custom_description : "Bread created from variable"
}

resource "hw_meat" "variable_meats" {
  for_each = toset(var.meat_types)
  kind     = each.value
}

resource "hw_sandwich" "variable_sandwiches" {
  for_each = var.include_drinks ? hw_meat.variable_meats : {}
  bread_id = hw_bread.variable_bread.id
  meat_id  = each.value.id
}

# ============================================================================
# Example .tfvars File Structure
# ============================================================================
# 
# Create a file named terraform.tfvars (or production.tfvars, dev.tfvars, etc.):
#
# # Production environment variables
# sandwich_bread_type = "sourdough"
# store_budget        = 10000.00
# include_drinks      = true
# meat_types          = ["turkey", "ham", "roast beef", "chicken", "pastrami"]
# sandwich_count      = 50
# 
# store_config = {
#   name         = "Production Store"
#   max_customers = "100"
#   open_hours    = "7am-9pm"
# }
# 
# sandwich_config = {
#   bread_type = "sourdough"
#   meat_type  = "turkey"
#   price      = 5.50
#   available  = true
# }
# 
# # Sensitive - use secret management in production
# api_key = "sk_live_production_key_here"

# ============================================================================
# Example .tfvars.json File (JSON format)
# ============================================================================
# 
# Create terraform.tfvars.json:
# {
#   "sandwich_bread_type": "ciabatta",
#   "store_budget": 5000.00,
#   "include_drinks": true,
#   "meat_types": ["turkey", "ham"],
#   "sandwich_count": 25,
#   "store_config": {
#     "name": "JSON Config Store",
#     "max_customers": "50",
#     "open_hours": "9am-5pm"
#   }
# }

# ============================================================================
# Multiple .tfvars Files for Different Environments
# ============================================================================
# 
# Common pattern:
# - terraform.tfvars (local development - in .gitignore)
# - dev.tfvars (development environment)
# - staging.tfvars (staging environment)
# - production.tfvars (production environment - in .gitignore if has secrets)
# 
# Usage:
# terraform apply -var-file="dev.tfvars"
# terraform apply -var-file="staging.tfvars"
# terraform apply -var-file="production.tfvars"
# 
# Or use workspaces:
# terraform workspace select dev
# terraform apply -var-file="dev.tfvars"

# ============================================================================
# Outputs Demonstrating Variable Usage
# ============================================================================

output "variable_examples" {
  description = "Examples of variables in use"
  value = {
    bread_type      = var.sandwich_bread_type
    budget          = var.store_budget
    include_drinks  = var.include_drinks
    meat_types      = var.meat_types
    store_config    = var.store_config
    sandwich_config = var.sandwich_config
    sandwich_count  = var.sandwich_count
    custom_desc     = var.custom_description
  }
}

output "variable_sources" {
  description = "Information about variable sources"
  value = {
    note = "Variables can be set via: .tfvars files, command line, environment variables, or defaults"
    current_bread = "Current bread type: ${var.sandwich_bread_type}"
    current_budget = "Current budget: $${var.store_budget}"
  }
}
