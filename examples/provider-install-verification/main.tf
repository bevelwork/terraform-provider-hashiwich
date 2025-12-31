terraform {
  required_providers {
    hw = {
      source  = "registry.terraform.io/bevelwork/hashiwich"
      version = "1.0.6"
    }
  }
  required_version = ">= 1"
}
provider "hw" {}

# Get all available deli meats
data "hw_deli_meats" "available" {}

# Create a bread resource to use for all sandwiches
resource "hw_bread" "rye" {
  kind        = "rye"
  description = "Fresh rye bread for all our sandwiches"
}

# Create a meat resource for each type of meat from the data source
resource "hw_meat" "each" {
  for_each = toset(data.hw_deli_meats.available.meats)

  kind        = each.value
  description = "Deli meat: ${each.value}"
}

# Create a sandwich for each meat type
resource "hw_sandwich" "each" {
  for_each = hw_meat.each

  bread_id    = hw_bread.rye.id
  meat_id     = each.value.id
  description = "A delicious ${each.value.kind} sandwich on rye bread"
}

