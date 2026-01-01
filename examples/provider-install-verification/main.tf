terraform {
  required_providers {
    hw = {
      source = "registry.terraform.io/bevelwork/hashiwich"
      # version = "~> 1.0"  # Commented out for local development with dev_overrides
    }
    # random = {
    #   source  = "hashicorp/random"
    #   # version = "~> 3.0"  # Commented out for local development - will use latest available
    # }
  }
  required_version = ">= 1"
}
provider "hw" {}

# Get all available deli meats
data "hw_deli_meats" "main_available" {}

# Create a bread resource to use for all sandwiches
resource "hw_bread" "main_rye" {
  kind        = "rye"
  description = "Fresh rye bread for all our sandwiches"
}

# Create a meat resource for each type of meat from the data source
resource "hw_meat" "main_each" {
  for_each = toset(data.hw_deli_meats.main_available.meats)

  kind        = each.value
  description = "Deli meat: ${each.value}"
}

# Create a sandwich for each meat type
resource "hw_sandwich" "main_each" {
  for_each = hw_meat.main_each

  bread_id    = hw_bread.main_rye.id
  meat_id     = each.value.id
  description = "A delicious ${each.value.kind} sandwich on rye bread"
}

