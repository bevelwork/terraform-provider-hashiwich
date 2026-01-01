# Example demonstrating sensitive values in Terraform
# Sensitive values are redacted in Terraform output to protect secrets
# Use this for: passwords, API keys, tokens, personal information, etc.

# ============================================================================
# Scenario 1: Sensitive Variables
# ============================================================================
# Mark variables as sensitive to prevent them from appearing in logs/outputs

variable "sensitive_api_key" {
  description = "API key for external service (sensitive)"
  type        = string
  sensitive   = true
  # Default provided for example - in production, use -var or .tfvars file
  default = "sk_live_1234567890abcdef"
}

variable "sensitive_database_password" {
  description = "Database password (sensitive)"
  type        = string
  sensitive   = true
  default     = "SuperSecretPassword123!"
}

variable "sensitive_customer_email" {
  description = "Customer email address (sensitive - PII)"
  type        = string
  sensitive   = true
  default     = "customer@example.com"
}

variable "sensitive_secret_recipe" {
  description = "Secret sandwich recipe (sensitive business information)"
  type        = string
  sensitive   = true
  default     = "Special sauce recipe: mayo, mustard, secret ingredient"
}

# Non-sensitive variable for comparison
variable "public_menu_item" {
  description = "Public menu item (not sensitive)"
  type        = string
  default     = "Turkey Sandwich"
}

# ============================================================================
# Scenario 2: Sensitive Resource Attributes
# ============================================================================
# Some resource attributes are automatically marked as sensitive by providers
# You can also mark custom attributes as sensitive

# Example: Storing sensitive data in a local value (for demonstration)
# In real scenarios, this might be used with resources that accept sensitive data
locals {
  # Sensitive local value
  sensitive_api_token = var.sensitive_api_key

  # Non-sensitive local for comparison
  public_api_endpoint = "https://api.example.com/v1"
}

# ============================================================================
# Scenario 3: Sensitive Outputs
# ============================================================================
# Mark outputs as sensitive to redact them in terraform output/plan/apply

# Sensitive output - will be redacted
output "sensitive_api_key_output" {
  description = "API key output (sensitive - will be redacted)"
  value       = var.sensitive_api_key
  sensitive   = true
}

output "sensitive_password_output" {
  description = "Database password (sensitive - will be redacted)"
  value       = var.sensitive_database_password
  sensitive   = true
}

output "sensitive_customer_info" {
  description = "Customer information (sensitive - PII)"
  value = {
    email    = var.sensitive_customer_email
    password = var.sensitive_database_password
  }
  sensitive = true
}

# Non-sensitive output for comparison
output "public_menu_output" {
  description = "Public menu item (not sensitive - will be visible)"
  value       = var.public_menu_item
  # sensitive = false (default)
}

# ============================================================================
# Scenario 4: Partially Sensitive Outputs
# ============================================================================
# You can have outputs with both sensitive and non-sensitive data

output "sandwich_order_with_sensitive" {
  description = "Order with sensitive customer data"
  value = {
    order_id      = "ORD-12345"                  # Not sensitive
    customer_id   = "CUST-67890"                 # Not sensitive
    email         = var.sensitive_customer_email # Sensitive
    total_price   = 12.50                        # Not sensitive
    payment_token = "tok_abc123xyz"              # Sensitive (if this were real)
  }
  sensitive = true # Entire output marked sensitive
}

# Better approach: Separate sensitive and non-sensitive outputs
output "sandwich_order_public" {
  description = "Public order information"
  value = {
    order_id    = "ORD-12345"
    customer_id = "CUST-67890"
    total_price = 12.50
  }
  # Not marked sensitive - safe to display
}

output "sandwich_order_sensitive" {
  description = "Sensitive order information (redacted)"
  value = {
    email         = var.sensitive_customer_email
    payment_token = "tok_abc123xyz"
  }
  sensitive = true
}

# ============================================================================
# Scenario 5: Sensitive Values in Resource Attributes
# ============================================================================
# Some resources have attributes that should be marked sensitive
# This is often done automatically by providers, but you can also use
# sensitive = true in variable definitions

# Example: If we had a resource that stored API keys
# resource "some_resource" "example" {
#   api_key = var.sensitive_api_key  # Will be redacted if variable is sensitive
#   name    = "example"
# }

# ============================================================================
# Scenario 6: Sensitive Values in Data Sources
# ============================================================================
# Data sources can also work with sensitive values

# Example: Querying with sensitive credentials
# data "external" "sensitive_query" {
#   program = ["sh", "-c", "echo '{\"result\":\"${var.sensitive_api_key}\"}'"]
# }
#
# output "sensitive_query_result" {
#   value     = data.external.sensitive_query.result
#   sensitive = true
# }

# ============================================================================
# Scenario 7: Using Sensitive Values in Expressions
# ============================================================================
# Sensitive values can be used in expressions, but results may be marked sensitive

locals {
  # Using sensitive variable in expression
  sensitive_connection_string = "https://api.example.com?key=${var.sensitive_api_key}"

  # Combining sensitive and non-sensitive
  sensitive_config = {
    endpoint = local.public_api_endpoint
    api_key  = var.sensitive_api_key
  }
}

output "sensitive_connection_string" {
  description = "Connection string with API key (sensitive)"
  value       = local.sensitive_connection_string
  sensitive   = true
}

output "sensitive_config" {
  description = "Configuration with sensitive data"
  value       = local.sensitive_config
  sensitive   = true
}

# ============================================================================
# Scenario 8: Conditional Sensitive Outputs
# ============================================================================
# Note: The sensitive attribute must be a static boolean (true/false)
# You cannot use variables or expressions for the sensitive attribute
# However, you can conditionally include/exclude sensitive data in the value

variable "include_sensitive_data" {
  description = "Whether to include sensitive data in output"
  type        = bool
  default     = false
}

# Option 1: Always mark as sensitive if it might contain sensitive data
output "conditional_sensitive_output" {
  description = "Output that may contain sensitive data (always marked sensitive)"
  value = var.include_sensitive_data ? {
    api_key = var.sensitive_api_key
    secret  = "secret_value"
    } : {
    message = "Sensitive data not included"
  }
  sensitive = true # Must be static boolean - mark as sensitive if it might contain secrets
}

# Option 2: Create separate outputs for sensitive and non-sensitive cases
output "sensitive_output_when_enabled" {
  description = "Sensitive output (only use when include_sensitive_data is true)"
  value = var.include_sensitive_data ? {
    api_key = var.sensitive_api_key
    secret  = "secret_value"
  } : null
  sensitive = true
}

output "non_sensitive_output_when_disabled" {
  description = "Non-sensitive output (when include_sensitive_data is false)"
  value = var.include_sensitive_data ? null : {
    message = "Sensitive data not included"
  }
  # sensitive = false (default)
}

# ============================================================================
# Scenario 9: Sensitive Values in Lists and Maps
# ============================================================================
# Sensitive values can be in complex data structures

variable "sensitive_credentials" {
  description = "Map of sensitive credentials"
  type        = map(string)
  sensitive   = true
  default = {
    api_key      = "sk_live_1234567890"
    db_password  = "SecurePassword123!"
    secret_token = "tok_abc123xyz"
  }
}

output "sensitive_credentials_output" {
  description = "Sensitive credentials map (all redacted)"
  value       = var.sensitive_credentials
  sensitive   = true
}

# ============================================================================
# Scenario 10: Demonstrating Redaction Behavior
# ============================================================================
# This section shows what gets redacted vs what doesn't

# Non-sensitive output - fully visible
output "non_sensitive_example" {
  description = "Non-sensitive output - fully visible in terraform output"
  value = {
    menu_item = "Turkey Sandwich"
    price     = 5.00
    available = true
  }
}

# Sensitive output - fully redacted
output "fully_sensitive_example" {
  description = "Fully sensitive output - completely redacted"
  value = {
    api_key  = var.sensitive_api_key
    password = var.sensitive_database_password
    secret   = "hidden_secret"
  }
  sensitive = true
}

# Mixed output - entire output redacted if any part is sensitive
output "mixed_sensitive_example" {
  description = "Mixed output - entire output redacted because it contains sensitive data"
  value = {
    public_data  = "This is public"
    private_data = var.sensitive_api_key
    more_public  = "Also public"
  }
  sensitive = true
}

# ============================================================================
# Best Practices for Sensitive Values
# ============================================================================
#
# 1. Always mark variables containing secrets as sensitive
#    variable "password" {
#      type      = string
#      sensitive = true
#    }
#
# 2. Mark outputs as sensitive if they contain secrets
#    output "api_key" {
#       value     = var.api_key
#       sensitive = true
#     }
#
# 3. Use sensitive = true for entire outputs if they contain any sensitive data
#    (Terraform redacts the entire output, not just sensitive fields)
#
# 4. Separate sensitive and non-sensitive outputs when possible
#    - Makes it easier to share non-sensitive information
#    - Keeps sensitive data isolated
#
# 5. Never commit sensitive values to version control
#    - Use .tfvars files with .gitignore
#    - Use environment variables
#    - Use secret management systems (AWS Secrets Manager, HashiCorp Vault, etc.)
#
# 6. Use -var-file for sensitive values
#    terraform apply -var-file="secrets.tfvars"
#    (Add secrets.tfvars to .gitignore)
#
# 7. Use environment variables for sensitive values
#    export TF_VAR_sensitive_api_key="your-key"
#    terraform apply
#
# 8. Be aware that sensitive values still appear in:
#    - State files (use encrypted backends)
#    - Plan files (use -out and protect plan files)
#    - Logs (be careful with verbose logging)
#
# 9. Use remote backends with encryption for state files
#    - S3 with encryption
#    - Terraform Cloud (encrypted by default)
#
# 10. Rotate sensitive values regularly
#     - Change passwords/keys periodically
#     - Update Terraform variables accordingly

# ============================================================================
# Testing Sensitive Output Redaction
# ============================================================================
# To see sensitive redaction in action:
#
# 1. Run: terraform plan
#    - Sensitive values will show as <sensitive> or <redacted>
#    - Example: api_key = <sensitive>
#
# 2. Run: terraform apply
#    - Sensitive outputs will be redacted in console output
#    - Example: sensitive_api_key_output = <sensitive>
#
# 3. Run: terraform output
#    - Non-sensitive outputs: fully visible
#    - Sensitive outputs: <sensitive> or <redacted>
#
# 4. Run: terraform output -json
#    - Sensitive values will be null or redacted in JSON output
#
# 5. Run: terraform output sensitive_api_key_output
#    - Will show: <sensitive> (value is redacted)
#
# Note: Sensitive values are still stored in state files
# Always use encrypted backends and protect state files!

# ============================================================================
# Example: Protecting Customer Data (PII)
# ============================================================================
# Personal Identifiable Information (PII) should be marked sensitive

variable "customer_pii" {
  description = "Customer personal information (PII - sensitive)"
  type = object({
    email   = string
    phone   = string
    address = string
  })
  sensitive = true
  default = {
    email   = "customer@example.com"
    phone   = "+1-555-123-4567"
    address = "123 Main St, City, State 12345"
  }
}

output "customer_info" {
  description = "Customer information (PII - redacted)"
  value       = var.customer_pii
  sensitive   = true
}

# Public customer data (non-sensitive)
output "customer_order_summary" {
  description = "Public order summary (no PII)"
  value = {
    order_id    = "ORD-12345"
    total_price = 25.50
    item_count  = 3
    order_date  = "2024-01-01"
    # No email, phone, or address - safe to display
  }
}

# ============================================================================
# Example: Protecting Business Secrets
# ============================================================================
# Protect proprietary information like recipes, pricing strategies, etc.

variable "secret_recipe_formula" {
  description = "Secret recipe formula (business secret - sensitive)"
  type        = string
  sensitive   = true
  default     = "Mayo 50%, Mustard 30%, Secret Spice 20%"
}

variable "pricing_strategy" {
  description = "Internal pricing strategy (business secret - sensitive)"
  type        = string
  sensitive   = true
  default     = "Cost + 200% markup, seasonal adjustments apply"
}

output "business_secrets" {
  description = "Business secrets (redacted)"
  value = {
    recipe_formula = var.secret_recipe_formula
    pricing        = var.pricing_strategy
  }
  sensitive = true
}

# Public menu pricing (non-sensitive)
output "public_menu_pricing" {
  description = "Public menu prices (safe to display)"
  value = {
    sandwich = "$5.00"
    soup     = "$2.50"
    drink    = "$1.00"
  }
}
