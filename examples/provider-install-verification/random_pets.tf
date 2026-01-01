# Example demonstrating the use of random_pet resource
# Creates 100 randomly named pets and a dog treat for each
# This demonstrates: count, resource dependencies, and the random provider

# ============================================================================
# Provider Configuration
# ============================================================================
# The random provider is configured in main.tf
# This file uses random_pet to generate pet names
#
# NOTE: Run 'terraform init' to install the random provider before using this file
# The random provider will be downloaded from the Terraform registry

# ============================================================================
# Create 100 Random Pets
# ============================================================================
# Use random_pet to generate 100 unique pet names
# random_pet generates names like: "happy-lion", "funny-dog", etc.

resource "random_pet" "pets" {
  count = 100

  # Each pet gets a unique name
  # Names are in format: adjective-noun (e.g., "happy-lion", "funny-dog")
  length    = 2
  separator = "-"

  # Keep names consistent (don't regenerate on every apply)
  keepers = {
    index = count.index
  }
}

# ============================================================================
# Create Dog Treats for Each Pet
# ============================================================================
# Create an hw_dogtreat resource for each random pet
# Each treat is associated with a pet name

resource "hw_dogtreat" "pet_treats" {
  count = 100

  # All pets are good dogs, so they get large treats ($2.00)
  is_good_dog = true

  description = "Treat for ${random_pet.pets[count.index].id}"
}

# ============================================================================
# Alternative: Using for_each Instead of count
# ============================================================================
# You could also use for_each with random_pet, but count is simpler here
# since we want exactly 100 pets

# Example with for_each (commented out):
# resource "random_pet" "pets_for_each" {
#   for_each = toset([for i in range(100) : tostring(i)])
#   
#   length    = 2
#   separator = "-"
#   
#   keepers = {
#     index = each.key
#   }
# }
#
# resource "hw_dogtreat" "pet_treats_for_each" {
#   for_each = random_pet.pets_for_each
#   
#   is_good_dog = true
#   description = "Treat for ${each.value.id}"
# }

# ============================================================================
# Outputs: Random Pets and Their Treats
# ============================================================================

output "random_pets_count" {
  description = "Total number of random pets created"
  value       = length(random_pet.pets)
}

output "random_pets_names" {
  description = "List of all random pet names"
  value       = [for pet in random_pet.pets : pet.id]
}

output "dog_treats_count" {
  description = "Total number of dog treats created"
  value       = length(hw_dogtreat.pet_treats)
}

output "pet_treat_mapping" {
  description = "Mapping of pet names to their treat IDs"
  value = {
    for i in range(100) : random_pet.pets[i].id => hw_dogtreat.pet_treats[i].id
  }
}

output "total_treat_cost" {
  description = "Total cost of all dog treats (100 large treats at $2.00 each)"
  value       = sum([for treat in hw_dogtreat.pet_treats : treat.price])
}

# ============================================================================
# Example: Pet-Treat Pairs
# ============================================================================
# Show a sample of pet-treat pairs

output "sample_pet_treats" {
  description = "Sample of first 5 pet-treat pairs"
  value = {
    for i in range(min(5, length(random_pet.pets))) : random_pet.pets[i].id => {
      treat_id    = hw_dogtreat.pet_treats[i].id
      treat_price = hw_dogtreat.pet_treats[i].price
      treat_size  = hw_dogtreat.pet_treats[i].size
    }
  }
}

# ============================================================================
# Statistics and Analysis
# ============================================================================

locals {
  # Count treats by size
  large_treats_count = length([for treat in hw_dogtreat.pet_treats : treat if treat.size == "large"])
  small_treats_count = length([for treat in hw_dogtreat.pet_treats : treat if treat.size == "small"])

  # Calculate average treat price
  total_treat_price   = sum([for treat in hw_dogtreat.pet_treats : treat.price])
  average_treat_price = local.total_treat_price / length(hw_dogtreat.pet_treats)

  # Find unique pet name patterns (first word)
  pet_name_prefixes = distinct([
    for pet in random_pet.pets : split("-", pet.id)[0]
  ])
}

output "treat_statistics" {
  description = "Statistics about the dog treats"
  value = {
    total_treats    = length(hw_dogtreat.pet_treats)
    large_treats    = local.large_treats_count
    small_treats    = local.small_treats_count
    total_cost      = local.total_treat_price
    average_cost    = local.average_treat_price
    unique_prefixes = length(local.pet_name_prefixes)
  }
}

# ============================================================================
# Conditional Example: Different Treats for Different Pets
# ============================================================================
# Example of giving different treats based on pet name characteristics

locals {
  # Determine if pet name contains certain words
  special_pets = [
    for i, pet in random_pet.pets : i
    if strcontains(lower(pet.id), "dog") || strcontains(lower(pet.id), "puppy")
  ]
}

# Create special treats for pets with "dog" or "puppy" in their name
# (This is just an example - all treats are the same in the main example)
output "special_pets" {
  description = "Pets with 'dog' or 'puppy' in their name (get special treatment)"
  value = [
    for i in local.special_pets : {
      pet_name = random_pet.pets[i].id
      treat_id = hw_dogtreat.pet_treats[i].id
    }
  ]
}

# ============================================================================
# Grouping Example: Group Pets by Name Prefix
# ============================================================================
# Group pets by the first part of their name

locals {
  # Group pets by prefix (first word before hyphen)
  pets_by_prefix = {
    for prefix in local.pet_name_prefixes : prefix => [
      for i, pet in random_pet.pets : {
        name     = pet.id
        treat_id = hw_dogtreat.pet_treats[i].id
      }
      if split("-", pet.id)[0] == prefix
    ]
  }
}

output "pets_grouped_by_prefix" {
  description = "Pets grouped by name prefix (first word)"
  value       = local.pets_by_prefix
}

# ============================================================================
# Usage Notes
# ============================================================================
# 
# 1. Random names are generated once and stored in state
#    - Names won't change on subsequent applies (due to keepers)
#    - To regenerate, use: terraform taint random_pet.pets[0] (or delete state)
#
# 2. Each random_pet creates a unique name
#    - Format: adjective-noun (e.g., "happy-lion", "funny-dog")
#    - Names are URL-safe and lowercase
#
# 3. The count parameter creates 100 instances
#    - Each instance gets a unique index (0-99)
#    - Resources are created in parallel when possible
#
# 4. Dependencies are automatically handled
#    - hw_dogtreat resources depend on random_pet resources
#    - Terraform creates pets first, then treats
#
# 5. To see all pet names:
#    terraform output random_pets_names
#
# 6. To see the mapping:
#    terraform output pet_treat_mapping
#
# 7. To regenerate all names:
#    terraform apply -replace=random_pet.pets[0]
#    (Or delete and recreate the resources)
