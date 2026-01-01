# Example demonstrating Terraform string manipulation functions
# This file shows various functions you can use to work with strings in Terraform

# ============================================================================
# Setup: Create Resources for Examples
# ============================================================================

resource "hw_bread" "string_bread_1" {
  kind        = "rye"
  description = "Fresh Rye Bread"
}

resource "hw_bread" "string_bread_2" {
  kind        = "sourdough"
  description = "Artisan Sourdough"
}

resource "hw_meat" "string_meat_1" {
  kind        = "turkey"
  description = "Premium Turkey"
}

# ============================================================================
# Category 1: Trimming Functions
# ============================================================================
# Remove prefixes, suffixes, or whitespace from strings

locals {
  # trimprefix: Remove a prefix from a string
  string_trimprefix_example_1 = trimprefix("hw_bread.example", "hw_")
  # Result: "bread.example"
  
  string_trimprefix_example_2 = trimprefix("https://example.com", "https://")
  # Result: "example.com"
  
  string_trimprefix_example_3 = trimprefix(hw_bread.string_bread_1.id, "bread-")
  # Removes "bread-" prefix from resource ID
  
  # trimsuffix: Remove a suffix from a string
  string_trimsuffix_example_1 = trimsuffix("example.txt", ".txt")
  # Result: "example"
  
  string_trimsuffix_example_2 = trimsuffix("store-v1", "-v1")
  # Result: "store"
  
  string_trimsuffix_example_3 = trimsuffix("bread-rye-123", "-123")
  # Removes "-123" suffix
  
  # trim: Remove specified characters from start and end
  string_trim_example_1 = trim("!!!Hello!!!", "!")
  # Result: "Hello"
  
  string_trim_example_2 = trim("***bread***", "*")
  # Result: "bread"
  
  # trimspace: Remove leading and trailing whitespace
  string_trimspace_example_1 = trimspace("  hello world  ")
  # Result: "hello world"
  
  string_trimspace_example_2 = trimspace("\t\n  bread  \n\t")
  # Result: "bread"
  
  string_trimspace_example_3 = trimspace("  ${hw_bread.string_bread_1.kind}  ")
  # Trims whitespace from resource attribute
}

# ============================================================================
# Category 2: String Slicing and Extraction
# ============================================================================
# Extract portions of strings

locals {
  # substr: Extract substring (start, length)
  # Note: substr is the function for strings; slice() is for lists
  string_substr_example_1 = substr("hello world", 0, 5)
  # Result: "hello" (start at 0, length 5)
  
  string_substr_example_2 = substr("bread-rye-123", 6, 3)
  # Result: "rye" (start at 6, length 3)
  
  string_substr_example_3 = substr(hw_bread.string_bread_1.id, 0, 5)
  # Gets first 5 characters of resource ID
  
  # Get last N characters (using length)
  bread_id = hw_bread.string_bread_1.id
  string_last_3_chars = substr(local.bread_id, length(local.bread_id) - 3, 3)
  # Gets last 3 characters
  
  # Get characters after a prefix
  string_after_prefix = substr(hw_bread.string_bread_1.id, 6, length(hw_bread.string_bread_1.id) - 6)
  # Gets everything after "bread-"
}

# ============================================================================
# Category 3: Splitting and Joining
# ============================================================================
# Break strings into parts or combine parts into strings

locals {
  # split: Split string into list by separator
  string_split_example_1 = split(",", "apple,banana,cherry")
  # Result: ["apple", "banana", "cherry"]
  
  string_split_example_2 = split("-", "bread-rye-123")
  # Result: ["bread", "rye", "123"]
  
  string_split_example_3 = split("/", "path/to/resource")
  # Result: ["path", "to", "resource"]
  
  string_split_example_4 = split(".", hw_bread.string_bread_1.id)
  # Splits resource ID by "."
  
  # join: Combine list elements into string with separator
  string_join_example_1 = join("-", ["bread", "rye", "123"])
  # Result: "bread-rye-123"
  
  string_join_example_2 = join(", ", ["apple", "banana", "cherry"])
  # Result: "apple, banana, cherry"
  
  string_join_example_3 = join("", ["hw_", "bread", "_", "example"])
  # Result: "hw_bread_example" (no separator)
  
  # Combine split and join for transformation
  string_transform_example = join("_", split("-", "bread-rye-123"))
  # Result: "bread_rye_123" (replace "-" with "_")
  
}

# ============================================================================
# Category 4: String Replacement
# ============================================================================
# Replace parts of strings

locals {
  # replace: Replace all occurrences of substring
  string_replace_example_1 = replace("hello world", "world", "terraform")
  # Result: "hello terraform"
  
  string_replace_example_2 = replace("bread-rye-123", "-", "_")
  # Result: "bread_rye_123" (replace all "-" with "_")
  
  string_replace_example_3 = replace(hw_bread.string_bread_1.id, "bread", "hw_bread")
  # Replaces "bread" with "hw_bread"
  
  # regex: Replace using regular expression (regex function with replace pattern)
  # Note: Terraform uses regex() for matching, replace() for simple replacement
  # For regex replacement, combine regex() with replace() or use replace() with patterns
  string_regexreplace_example_1 = replace("bread-123", regex("\\d+", "bread-123"), "XXX")
  # Result: "bread-XXX" (replace digits with XXX) - workaround using regex + replace
  
  string_regexreplace_example_2 = replace("bread-rye-123", regex("-\\d+$", "bread-rye-123"), "")
  # Result: "bread-rye" (remove trailing "-digits") - workaround
  
  string_regexreplace_example_3 = replace("hello123world456", "123", "")
  # Result: "helloworld456" (simple replace - Terraform doesn't have direct regex replace)
  
  # For complex regex replacement, you may need to use multiple replace() calls
  # or process in multiple steps
}

# ============================================================================
# Category 5: String Checking Functions
# ============================================================================
# Check if strings contain, start with, or end with certain values

locals {
  # strcontains: Check if string contains substring
  string_strcontains_example_1 = strcontains("hello world", "world")
  # Result: true
  
  string_strcontains_example_2 = strcontains("bread-rye", "wheat")
  # Result: false
  
  string_strcontains_example_3 = strcontains(hw_bread.string_bread_1.kind, "rye")
  # Checks if bread kind contains "rye"
  
  # startswith: Check if string starts with prefix
  string_startswith_example_1 = startswith("hello world", "hello")
  # Result: true
  
  string_startswith_example_2 = startswith("bread-rye", "bread")
  # Result: true
  
  string_startswith_example_3 = startswith(hw_bread.string_bread_1.id, "bread-")
  # Checks if ID starts with "bread-"
  
  # endswith: Check if string ends with suffix
  string_endswith_example_1 = endswith("hello world", "world")
  # Result: true
  
  string_endswith_example_2 = endswith("file.txt", ".txt")
  # Result: true
  
  string_endswith_example_3 = endswith(hw_bread.string_bread_1.id, "-123")
  # Checks if ID ends with "-123"
}

# ============================================================================
# Category 6: Case Conversion Functions
# ============================================================================
# Change string case

locals {
  # upper: Convert to uppercase
  string_upper_example_1 = upper("hello world")
  # Result: "HELLO WORLD"
  
  string_upper_example_2 = upper("bread-rye")
  # Result: "BREAD-RYE"
  
  string_upper_example_3 = upper(hw_bread.string_bread_1.kind)
  # Converts bread kind to uppercase
  
  # lower: Convert to lowercase
  string_lower_example_1 = lower("HELLO WORLD")
  # Result: "hello world"
  
  string_lower_example_2 = lower("BREAD-RYE")
  # Result: "bread-rye"
  
  string_lower_example_3 = lower(hw_bread.string_bread_1.description)
  # Converts description to lowercase
  
  # title: Convert to title case (first letter of each word uppercase)
  string_title_example_1 = title("hello world")
  # Result: "Hello World"
  
  string_title_example_2 = title("fresh rye bread")
  # Result: "Fresh Rye Bread"
  
  string_title_example_3 = title(hw_bread.string_bread_1.description)
  # Converts description to title case
}

# ============================================================================
# Category 7: String Formatting
# ============================================================================
# Format strings with placeholders

locals {
  # format: Format string with placeholders (%s, %d, %f, etc.)
  string_format_example_1 = format("Hello, %s!", "World")
  # Result: "Hello, World!"
  
  string_format_example_2 = format("Bread: %s, Price: $%.2f", "rye", 3.5)
  # Result: "Bread: rye, Price: $3.50"
  
  string_format_example_3 = format("Resource %s has ID %s", "bread", hw_bread.string_bread_1.id)
  # Formats with resource attributes
  
  string_format_example_4 = format("Count: %d, Total: $%.2f", 5, 17.50)
  # Result: "Count: 5, Total: $17.50"
  
  # formatlist: Format each element in a list
  string_formatlist_example_1 = formatlist("Item: %s", ["apple", "banana", "cherry"])
  # Result: ["Item: apple", "Item: banana", "Item: cherry"]
  
  string_formatlist_example_2 = formatlist("%s-%d", ["bread", "meat", "drink"], [1, 2, 3])
  # Result: ["bread-1", "meat-2", "drink-3"]
  
  bread_kinds = [hw_bread.string_bread_1.kind, hw_bread.string_bread_2.kind]
  string_formatlist_example_3 = formatlist("Bread: %s", local.bread_kinds)
  # Formats each bread kind
}

# ============================================================================
# Category 8: Regular Expression Functions
# ============================================================================
# Match and extract using regular expressions

locals {
  # regex: Extract first match from string
  string_regex_example_1 = regex("\\d+", "bread-123-rye")
  # Result: "123" (first sequence of digits)
  
  string_regex_example_2 = regex("bread-(\\w+)", "bread-rye-123")
  # Result: "rye" (captured group)
  
  string_regex_example_3 = regex("^bread-", hw_bread.string_bread_1.id)
  # Matches "bread-" at start
  
  # regexall: Extract all matches from string
  string_regexall_example_1 = regexall("\\d+", "bread-123-rye-456")
  # Result: ["123", "456"] (all sequences of digits)
  
  string_regexall_example_2 = regexall("\\w+", "bread rye sourdough")
  # Result: ["bread", "rye", "sourdough"] (all words)
  
  string_regexall_example_3 = regexall("[A-Z]", "HelloWorld")
  # Result: ["H", "W"] (all capital letters)
  
  # Note: Terraform doesn't have a direct regexreplace function
  # Use replace() for simple replacements, or combine regex() with replace() for patterns
}

# ============================================================================
# Category 9: Other String Functions
# ============================================================================
# Additional useful string operations

locals {
  # chomp: Remove trailing newline characters
  string_chomp_example_1 = chomp("hello\n")
  # Result: "hello"
  
  string_chomp_example_2 = chomp("bread\r\n")
  # Result: "bread"
  
  # indent: Add indentation to each line
  string_indent_example_1 = indent(2, "line1\nline2\nline3")
  # Result: "  line1\n  line2\n  line3" (2 spaces indentation)
  
  string_indent_example_2 = indent(4, "bread\nmeat\ndrink")
  # Result: "    bread\n    meat\n    drink" (4 spaces)
  
  # length: Get string length
  string_length_example_1 = length("hello")
  # Result: 5
  
  string_length_example_2 = length("bread-rye")
  # Result: 9
  
  string_length_example_3 = length(hw_bread.string_bread_1.id)
  # Gets length of resource ID
  
  # reverse: Reverse a string (if supported, otherwise use workaround)
  # Note: Terraform doesn't have a direct reverse function
  # You'd need to use a workaround with split/join or regex
}

# ============================================================================
# Category 10: Practical Combinations
# ============================================================================
# Real-world examples combining multiple string functions

locals {
  # Extract resource type from ID
  bread_id_full = hw_bread.string_bread_1.id
  string_extract_type = split("-", local.bread_id_full)[0]
  # Gets "bread" from "bread-rye-123"
  
  # Normalize resource names (lowercase, replace spaces with dashes)
  raw_name = "Fresh Rye Bread"
  string_normalized_name = replace(lower(local.raw_name), " ", "-")
  # Result: "fresh-rye-bread"
  
  # Validate and clean user input
  user_input = "  BREAD-RYE  "
  string_cleaned_input = trimspace(upper(local.user_input))
  # Result: "BREAD-RYE"
  
  # Extract version from string
  version_string = "app-v1.2.3-release"
  string_extract_version = regex("v(\\d+\\.\\d+\\.\\d+)", local.version_string)
  # Result: "1.2.3"
  
  # Build resource name with validation
  resource_type = "bread"
  resource_name = "rye"
  string_build_resource_name = "${local.resource_type}-${lower(local.resource_name)}"
  # Result: "bread-rye"
  
  # Check if resource ID matches pattern
  string_is_valid_id = startswith(hw_bread.string_bread_1.id, "bread-") && length(hw_bread.string_bread_1.id) > 6
  # Validates ID format
  
  # Extract all numbers from a string
  mixed_string = "bread-123-rye-456-sourdough-789"
  string_all_numbers = regexall("\\d+", local.mixed_string)
  # Result: ["123", "456", "789"]
  
  # Convert camelCase to kebab-case
  camel_case = "freshRyeBread"
  # Workaround: Use replace() for each capital letter pattern
  # Note: This is simplified - full camelCase conversion requires multiple steps
  # For production, you'd need a more complex approach or external tool
  string_to_kebab = lower(replace(replace(local.camel_case, "R", "-r"), "B", "-b"))
  # Result: "fresh-rye-bread" (simplified example - only works for this specific case)
  
  # Pad string to fixed length (workaround using format)
  short_string = "123"
  string_padded = format("%05s", local.short_string)
  # Result: "  123" (padded to 5 characters, but with spaces)
  # For zero-padding numbers: format("%05d", 123) -> "00123"
}

# ============================================================================
# Category 11: String Functions with Conditionals
# ============================================================================
# Using string functions in conditional logic

locals {
  # Conditional string manipulation
  bread_kind = hw_bread.string_bread_1.kind
  string_conditional_format = strcontains(local.bread_kind, "rye") ? upper(local.bread_kind) : lower(local.bread_kind)
  # Uppercase if contains "rye", otherwise lowercase
  
  # Conditional prefix
  string_conditional_prefix = startswith(hw_bread.string_bread_1.id, "bread-") ? hw_bread.string_bread_1.id : "bread-${hw_bread.string_bread_1.id}"
  # Adds prefix if not present
  
  # Extract based on condition
  resource_id = hw_bread.string_bread_1.id
  string_conditional_extract = strcontains(local.resource_id, "-") ? split("-", local.resource_id)[1] : local.resource_id
  # Gets part after first "-" if present
}

# ============================================================================
# String Function Reference
# ============================================================================
#
# TRIMMING:
#   trimprefix(str, prefix)     - Remove prefix from string
#   trimsuffix(str, suffix)     - Remove suffix from string
#   trim(str, cutset)            - Remove characters from start/end
#   trimspace(str)               - Remove leading/trailing whitespace
#
# EXTRACTION:
#   substr(str, start, length)   - Extract substring from string
#   slice(list, start, end)      - Extract elements from list (for lists, not strings)
#
# SPLITTING/JOINING:
#   split(separator, str)        - Split string into list
#   join(separator, list)       - Join list into string
#
# REPLACEMENT:
#   replace(str, old, new)        - Replace all occurrences
#   Note: Terraform doesn't have regexreplace - use replace() or combine regex() with replace()
#
# CHECKING:
#   strcontains(str, substr)    - Check if contains substring
#   startswith(str, prefix)     - Check if starts with prefix
#   endswith(str, suffix)       - Check if ends with suffix
#
# CASE:
#   upper(str)                  - Convert to uppercase
#   lower(str)                  - Convert to lowercase
#   title(str)                  - Convert to title case
#
# FORMATTING:
#   format(format, args...)     - Format string with placeholders
#   formatlist(format, lists...) - Format each element in lists
#
# REGEX:
#   regex(pattern, str)         - Extract first match
#   regexall(pattern, str)      - Extract all matches
#
# OTHER:
#   chomp(str)                  - Remove trailing newlines
#   indent(spaces, str)         - Indent each line
#   length(str)                 - Get string length
#
# COMMON PATTERNS:
#   values(map)[*].attribute    - Get attribute from map values
#   split("-", str)[0]          - Get first part after split
#   replace(lower(str), " ", "-") - Normalize string
#   regex("\\d+", str)         - Extract numbers
#   format("%s-%d", name, num) - Build formatted strings

# ============================================================================
# Outputs: Demonstrating String Functions
# ============================================================================

output "string_trimming_examples" {
  description = "Examples of trimming functions"
  value = {
    trimprefix = local.string_trimprefix_example_1
    trimsuffix = local.string_trimsuffix_example_1
    trim       = local.string_trim_example_1
    trimspace  = local.string_trimspace_example_1
  }
}

output "string_slicing_examples" {
  description = "Examples of substring extraction"
  value = {
    substr     = local.string_substr_example_1
    last_chars = local.string_last_3_chars
  }
}

output "string_split_join_examples" {
  description = "Examples of split and join"
  value = {
    split = local.string_split_example_1
    join  = local.string_join_example_1
    transform = local.string_transform_example
  }
}

output "string_replacement_examples" {
  description = "Examples of replacement functions"
  value = {
    replace      = local.string_replace_example_1
    regexreplace = local.string_regexreplace_example_1
  }
}

output "string_checking_examples" {
  description = "Examples of string checking functions"
  value = {
    strcontains = local.string_strcontains_example_1
    startswith  = local.string_startswith_example_1
    endswith    = local.string_endswith_example_1
  }
}

output "string_case_examples" {
  description = "Examples of case conversion"
  value = {
    upper = local.string_upper_example_1
    lower = local.string_lower_example_1
    title = local.string_title_example_1
  }
}

output "string_formatting_examples" {
  description = "Examples of formatting functions"
  value = {
    format     = local.string_format_example_1
    formatlist = local.string_formatlist_example_1
  }
}

output "string_regex_examples" {
  description = "Examples of regex functions"
  value = {
    regex    = local.string_regex_example_1
    regexall = local.string_regexall_example_1
  }
}

output "string_practical_examples" {
  description = "Practical string function combinations"
  value = {
    normalized_name = local.string_normalized_name
    cleaned_input   = local.string_cleaned_input
    extract_version = local.string_extract_version
    all_numbers     = local.string_all_numbers
  }
}
