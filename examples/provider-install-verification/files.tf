# Example demonstrating file reading in Terraform
# Shows how to read file contents and safely handle missing files

# ============================================================================
# Setup: Create Example Files (for demonstration)
# ============================================================================
# In a real scenario, these files would exist in your filesystem
# For this example, we'll show how to read them if they exist

# Example file locations (these would be in your project directory):
# - config/bread-config.txt
# - config/meat-config.txt
# - config/store-settings.json
# - config/optional-config.txt (may or may not exist)

# ============================================================================
# Category 1: Basic File Reading
# ============================================================================
# Read file contents into variables or locals

locals {
  # file(): Read entire file contents as string
  # Syntax: file(path)
  # Path is relative to the Terraform configuration directory
  # NOTE: file() will fail if the file doesn't exist - use try() for optional files
  
  # Basic file read (wrapped in try() for safety - will use default if file missing)
  # In production, you might use: file("${path.module}/config/bread-config.txt")
  # But that will fail if file doesn't exist, so we use try() here
  files_basic_read = try(file("${path.module}/config/bread-config.txt"), "File not found - this is a default value")
  # Result: Contents of bread-config.txt as a string, or default if file missing
  
  # Reading JSON file (safe with try())
  files_json_content = try(file("${path.module}/config/store-settings.json"), "{}")
  # Result: JSON content as string (use jsondecode() to parse), or "{}" if file missing
  
  # Reading with path.module (current module directory)
  files_module_path_read = try(file("${path.module}/config/meat-config.txt"), "Default meat config")
  
  # Reading with path.root (root module directory)
  files_root_path_read = try(file("${path.root}/config/bread-config.txt"), "Default bread config")
  
  # Reading with path.cwd (current working directory)
  files_cwd_path_read = try(file("${path.cwd}/config/bread-config.txt"), "Default config")
}

# ============================================================================
# Category 2: Safe File Reading with try()
# ============================================================================
# Handle missing files gracefully using try()

locals {
  # try(): Attempt to read file, return default if it fails
  # This prevents Terraform from failing if the file doesn't exist
  
  # Safe file read with default empty string
  files_safe_read_1 = try(file("${path.module}/config/optional-config.txt"), "")
  # Result: File contents if exists, empty string if not
  
  # Safe file read with custom default
  files_safe_read_2 = try(file("${path.module}/config/optional-config.txt"), "default-config-value")
  # Result: File contents if exists, "default-config-value" if not
  
  # Safe file read with default from another file
  files_safe_read_3 = try(
    file("${path.module}/config/optional-config.txt"),
    try(file("${path.module}/config/default-config.txt"), "default-value")
  )
  # Result: optional-config.txt if exists, otherwise default-config.txt, otherwise "default-value"
  
  # Safe file read with conditional default
  files_safe_read_4 = try(
    file("${path.module}/config/environment-specific.txt"),
    try(file("${path.module}/config/default.txt"), "default-value")
  )
  # Tries environment-specific first, falls back to default, then to string default
}

# ============================================================================
# Category 3: Reading Files into Resource Attributes
# ============================================================================
# Use file contents in resource configurations

# Example: Read bread description from file
resource "hw_bread" "file_bread_1" {
  kind        = "rye"
  description = try(file("${path.module}/config/bread-description.txt"), "Default bread description")
  # Uses file content if exists, default string if not
}

# Example: Read meat description from file
resource "hw_meat" "file_meat_1" {
  kind        = "turkey"
  description = try(file("${path.module}/config/meat-description.txt"), "Premium turkey")
  # Safe file read with fallback
}

# Example: Multiple fallbacks
resource "hw_bread" "file_bread_2" {
  kind        = "sourdough"
  description = try(
    file("${path.module}/config/bread-description.txt"),
    try(file("${path.module}/config/default-description.txt"), "Standard bread description")
  )
  # Tries first file, then second file, then default string
}

# ============================================================================
# Category 4: Reading JSON Files
# ============================================================================
# Parse JSON file contents

locals {
  # Read JSON file and parse it
  files_json_raw = try(file("${path.module}/config/store-settings.json"), "{}")
  # Get file content, default to empty JSON object string
  
  files_json_parsed = jsondecode(local.files_json_raw)
  # Parse JSON string into Terraform object
  # Result: Object with keys/values from JSON
  
  # Access JSON properties safely
  files_store_name = try(local.files_json_parsed.store_name, "Default Store")
  files_store_capacity = try(local.files_json_parsed.capacity, 50)
  
  # Safe JSON read with full fallback
  files_safe_json = try(
    jsondecode(file("${path.module}/config/store-settings.json")),
    {
      store_name = "Default Store"
      capacity   = 50
      location   = "Unknown"
    }
  )
  # Reads and parses JSON, or uses default object if file missing
}

# ============================================================================
# Category 5: Reading Multiple Files
# ============================================================================
# Read and combine multiple files

locals {
  # Read multiple files into a list
  files_multiple_configs = [
    try(file("${path.module}/config/config1.txt"), ""),
    try(file("${path.module}/config/config2.txt"), ""),
    try(file("${path.module}/config/config3.txt"), "")
  ]
  # List of file contents, empty strings for missing files
  
  # Combine file contents
  files_combined_content = join("\n", [
    try(file("${path.module}/config/header.txt"), "# Header"),
    try(file("${path.module}/config/body.txt"), "# Body content"),
    try(file("${path.module}/config/footer.txt"), "# Footer")
  ])
  # Combines multiple files with newlines, defaults for missing files
  
  # Read files conditionally
  files_conditional_read = var.environment == "production" ? try(file("${path.module}/config/prod-config.txt"), "") : try(file("${path.module}/config/dev-config.txt"), "")
  # Reads different files based on variable
}

# ============================================================================
# Category 6: File Reading Patterns
# ============================================================================
# Common patterns for file handling

locals {
  # Pattern 1: Environment-specific configs
  files_env_config = try(
    file("${path.module}/config/${var.environment}.txt"),
    try(file("${path.module}/config/default.txt"), "fallback-value")
  )
  # Tries environment-specific file, then default, then fallback
  
  # Pattern 2: Feature flags from file
  files_feature_enabled = try(
    file("${path.module}/config/features.txt"),
    "disabled"
  ) != "disabled"
  # Reads feature file, checks if not "disabled"
  
  # Pattern 3: Template file with defaults
  files_template = try(
    file("${path.module}/templates/resource-template.txt"),
    "resource \"hw_bread\" \"example\" {\n  kind = \"rye\"\n}"
  )
  # Uses template file if exists, otherwise inline template
  
  # Pattern 4: Version from file
  files_version = try(
    trimspace(file("${path.module}/VERSION")),
    "1.0.0"
  )
  # Reads version file, trims whitespace, defaults to "1.0.0"
  
  # Pattern 5: Secrets from file (with warning about security)
  files_secret = try(
    file("${path.module}/secrets/api-key.txt"),
    ""
  )
  # WARNING: Don't commit secrets to version control!
  # Use proper secret management in production
}

# ============================================================================
# Category 7: Error Handling Strategies
# ============================================================================
# Different approaches to handle missing files

locals {
  # Strategy 1: Silent failure with default
  files_strategy_1 = try(file("${path.module}/config/optional.txt"), "default")
  # Simple and clean, always returns a value
  
  # Strategy 2: Fail fast (no try)
  # files_strategy_2 = file("${path.module}/config/required.txt")
  # Will fail immediately if file doesn't exist - use for required files
  
  # Strategy 3: Multiple fallback files
  files_strategy_3 = try(
    file("${path.module}/config/primary.txt"),
    file("${path.module}/config/secondary.txt"),
    file("${path.module}/config/tertiary.txt"),
    "final-fallback"
  )
  # Tries multiple files in order
  
  # Strategy 4: Conditional file reading
  files_strategy_4 = var.environment == "production" ? try(file("${path.module}/config/custom.txt"), try(file("${path.module}/config/default.txt"), "default-value")) : try(file("${path.module}/config/default.txt"), "default-value")
  # Reads different files based on environment variable
}

# ============================================================================
# Category 8: File Reading with Validation
# ============================================================================
# Validate file contents after reading

variable "environment" {
  description = "Environment name for file selection"
  type        = string
  default     = "development"
}

locals {
  # Read and validate file content
  files_validated_content = try(
    file("${path.module}/config/${var.environment}.txt"),
    ""
  )
  
  # Validate that content is not empty
  files_is_valid = local.files_validated_content != ""
  
  # Use validated content or error
  files_safe_validated = local.files_is_valid ? local.files_validated_content : "Configuration file is missing or empty"
  
  # Validate JSON structure
  files_validated_json = try(
    jsondecode(file("${path.module}/config/settings.json")),
    null
  )
  
  files_has_required_fields = local.files_validated_json != null && try(local.files_validated_json.store_name, null) != null && try(local.files_validated_json.capacity, null) != null
}

# ============================================================================
# Category 9: Practical Examples
# ============================================================================
# Real-world use cases

# Example 1: Read store configuration from file
resource "hw_store" "file_store_example" {
  name      = try(trimspace(file("${path.module}/config/store-name.txt")), "File-Based Store")
  oven_id   = hw_oven.file_oven.id
  cook_ids  = [hw_cook.file_cook.id]
  tables_id = hw_tables.file_tables.id
  chairs_id = hw_chairs.file_chairs.id
  fridge_id = hw_fridge.file_fridge.id
}

# Supporting resources for store
resource "hw_oven" "file_oven" {
  type = "commercial"
}

resource "hw_cook" "file_cook" {
  name       = try(trimspace(file("${path.module}/config/cook-name.txt")), "Default Cook")
  experience = "experienced"
}

resource "hw_tables" "file_tables" {
  quantity = try(tonumber(trimspace(file("${path.module}/config/table-count.txt"))), 10)
  size    = "medium"
}

resource "hw_chairs" "file_chairs" {
  quantity = try(tonumber(trimspace(file("${path.module}/config/chair-count.txt"))), 20)
  style    = "comfortable"
}

resource "hw_fridge" "file_fridge" {
  size = try(trimspace(file("${path.module}/config/fridge-size.txt")), "medium")
}

# Example 2: Read description from markdown file
resource "hw_bread" "file_bread_markdown" {
  kind        = "ciabatta"
  description = try(
    file("${path.module}/docs/bread-description.md"),
    "Fresh ciabatta bread"
  )
}

# Example 3: Read list of items from file (one per line)
locals {
  files_item_list_raw = try(
    file("${path.module}/config/items.txt"),
    "item1\nitem2\nitem3"
  )
  
  files_item_list = split("\n", local.files_item_list_raw)
  # Splits file content by newlines into list
}

# ============================================================================
# Category 10: Path Functions Reference
# ============================================================================
# Understanding path context in Terraform

locals {
  # path.module: Directory containing the current module
  files_module_path = path.module
  # Example: /home/user/project/modules/my-module
  
  # path.root: Root module directory
  files_root_path = path.root
  # Example: /home/user/project
  
  # path.cwd: Current working directory (where terraform was run)
  files_cwd_path_example = path.cwd
  # Example: /home/user/project/examples
  
  # Using paths in file() calls (wrapped in try() for safety)
  files_relative_to_module = try(file("${path.module}/config.txt"), "default")
  files_relative_to_root   = try(file("${path.root}/config.txt"), "default")
  files_relative_to_cwd    = try(file("${path.cwd}/config.txt"), "default")
  
  # Absolute paths (use with caution)
  # files_absolute = file("/etc/config.txt")  # Not recommended
}

# ============================================================================
# File Reading Best Practices
# ============================================================================
#
# 1. ALWAYS use try() for optional files
#    ✅ try(file("path"), "default")
#    ❌ file("path")  # Will fail if file missing
#
# 2. Use path.module for module-relative paths
#    ✅ file("${path.module}/config.txt")
#    ❌ file("config.txt")  # May not work as expected
#
# 3. Provide meaningful defaults
#    ✅ try(file("config.txt"), "sensible-default")
#    ❌ try(file("config.txt"), "")  # Empty string may cause issues
#
# 4. Validate file contents when needed
#    ✅ Check for empty strings, validate JSON structure
#
# 5. Don't commit secrets to files
#    ❌ file("secrets/api-key.txt")  # Use proper secret management
#    ✅ Use environment variables or secret stores
#
# 6. Use trimspace() for files that may have trailing newlines
#    ✅ trimspace(file("version.txt"))
#    ❌ file("version.txt")  # May include \n
#
# 7. Handle JSON files properly
#    ✅ jsondecode(try(file("config.json"), "{}"))
#    ❌ jsondecode(file("config.json"))  # Fails if file missing
#
# 8. Consider file size
#    ⚠️  file() reads entire file into memory
#    ⚠️  Large files may cause performance issues
#
# 9. Use conditional file reading for environment-specific configs
#    ✅ try(file("${var.env}.txt"), file("default.txt"))
#
# 10. Document which files are required vs optional
#     # Required: config.txt (will fail if missing)
#     # Optional: optional.txt (uses default if missing)

# ============================================================================
# Common File Reading Patterns Reference
# ============================================================================
#
# BASIC:
#   file(path)                    - Read file (fails if missing)
#
# SAFE:
#   try(file(path), default)      - Read file with default
#   try(file(path1), file(path2)) - Multiple fallbacks
#
# JSON:
#   jsondecode(file(path))        - Read and parse JSON
#   jsondecode(try(file(path), "{}")) - Safe JSON read
#
# VALIDATION:
#   trimspace(file(path))         - Remove whitespace
#   file(path) != ""              - Check if not empty
#
# CONDITIONAL:
#   var.use_file ? file(path) : default
#   try(file("${var.env}.txt"), file("default.txt"))
#
# MULTIPLE:
#   [file(path1), file(path2)]    - List of file contents
#   join("\n", [file(p1), file(p2)]) - Combine files

# ============================================================================
# Outputs: Demonstrating File Reading
# ============================================================================

output "files_basic_examples" {
  description = "Basic file reading examples"
  value = {
    safe_read_default = local.files_safe_read_1
    safe_read_custom  = local.files_safe_read_2
  }
  sensitive = true  # May contain file contents
}

output "files_json_examples" {
  description = "JSON file reading examples"
  value = {
    parsed_json     = local.files_json_parsed
    safe_json       = local.files_safe_json
    store_name      = local.files_store_name
    store_capacity  = local.files_store_capacity
  }
}

output "files_path_examples" {
  description = "Path function examples"
  value = {
    module_path = local.files_module_path
    root_path   = local.files_root_path
    cwd_path    = local.files_cwd_path_example
  }
}

output "files_pattern_examples" {
  description = "Common file reading patterns"
  value = {
    env_config      = local.files_env_config
    version         = local.files_version
    combined_content = local.files_combined_content
  }
  sensitive = true
}

output "files_validation_examples" {
  description = "File validation examples"
  value = {
    is_valid           = local.files_is_valid
    has_required_fields = local.files_has_required_fields
  }
}
