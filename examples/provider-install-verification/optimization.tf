# Example demonstrating optimization: Maximize customers per hour within a budget
# Scenario: You have a fixed budget and need to maximize store capacity
# This demonstrates resource dependencies, cost calculations, and optimization strategies

# ============================================================================
# Budget Constraint
# ============================================================================
# Set your budget - try different values to see how it affects optimization

variable "store_budget" {
  description = <<-EOT
    Total budget available for the store setup.
    
    See variables.tf for detailed information about using .tfvars files.
    
    QUICK EXAMPLES:
    - terraform apply -var="store_budget=5000"
    - Create terraform.tfvars: store_budget = 5000.00
    - export TF_VAR_store_budget=4000 && terraform apply
  EOT
  type        = number
  default     = 3000.00
}

# ============================================================================
# Resource Definitions - Component Options
# ============================================================================
# We'll create different options and calculate which gives best customers_per_hour

# Option 1: Budget-Friendly Configuration
# Focus on lower costs, may have lower capacity

resource "hw_oven" "budget_oven" {
  type        = "standard" # $500
  description = "Standard oven for budget configuration"
}

resource "hw_cook" "budget_cook_1" {
  name        = "Cook 1"
  experience  = "junior" # $120/day
  description = "Junior cook for budget configuration"
}

resource "hw_tables" "budget_tables" {
  quantity    = 4
  size        = "small" # $50/table, 2 seats each = 8 total seats
  description = "Small tables for budget configuration"
}

resource "hw_chairs" "budget_chairs" {
  quantity    = 8
  style       = "basic" # $20/chair
  description = "Basic chairs for budget configuration"
}

resource "hw_fridge" "budget_fridge" {
  size        = "small" # $300
  description = "Small fridge for budget configuration"
}

# Calculate total cost for budget configuration
locals {
  opt_budget_oven_cost   = hw_oven.budget_oven.cost
  opt_budget_cook_cost   = hw_cook.budget_cook_1.cost
  opt_budget_tables_cost = hw_tables.budget_tables.cost
  opt_budget_chairs_cost = hw_chairs.budget_chairs.cost
  opt_budget_fridge_cost = hw_fridge.budget_fridge.cost

  opt_budget_total_cost = (
    local.opt_budget_oven_cost +
    local.opt_budget_cook_cost +
    local.opt_budget_tables_cost +
    local.opt_budget_chairs_cost +
    local.opt_budget_fridge_cost
  )
}

# Option 2: Balanced Configuration
# Mix of cost and capacity

resource "hw_oven" "balanced_oven" {
  type        = "commercial" # $1200
  description = "Commercial oven for balanced configuration"
}

resource "hw_cook" "balanced_cook_1" {
  name        = "Cook 1"
  experience  = "experienced" # $160/day
  description = "Experienced cook for balanced configuration"
}

resource "hw_cook" "balanced_cook_2" {
  name        = "Cook 2"
  experience  = "junior" # $120/day
  description = "Junior cook for balanced configuration"
}

resource "hw_tables" "balanced_tables" {
  quantity    = 5
  size        = "medium" # $100/table, 4 seats each = 20 total seats
  description = "Medium tables for balanced configuration"
}

resource "hw_chairs" "balanced_chairs" {
  quantity    = 20
  style       = "comfortable" # $35/chair
  description = "Comfortable chairs for balanced configuration"
}

resource "hw_fridge" "balanced_fridge" {
  size        = "medium" # $500
  description = "Medium fridge for balanced configuration"
}

locals {
  opt_balanced_oven_cost   = hw_oven.balanced_oven.cost
  opt_balanced_cook_cost   = hw_cook.balanced_cook_1.cost + hw_cook.balanced_cook_2.cost
  opt_balanced_tables_cost = hw_tables.balanced_tables.cost
  opt_balanced_chairs_cost = hw_chairs.balanced_chairs.cost
  opt_balanced_fridge_cost = hw_fridge.balanced_fridge.cost

  opt_balanced_total_cost = (
    local.opt_balanced_oven_cost +
    local.opt_balanced_cook_cost +
    local.opt_balanced_tables_cost +
    local.opt_balanced_chairs_cost +
    local.opt_balanced_fridge_cost
  )
}

# Option 3: High-Capacity Configuration
# Maximize customers_per_hour, may exceed budget

resource "hw_oven" "capacity_oven" {
  type        = "high-capacity" # $2000
  description = "High-capacity oven for maximum throughput"
}

resource "hw_cook" "capacity_cook_1" {
  name        = "Cook 1"
  experience  = "expert" # $200/day
  description = "Expert cook for high capacity"
}

resource "hw_cook" "capacity_cook_2" {
  name        = "Cook 2"
  experience  = "experienced" # $160/day
  description = "Experienced cook for high capacity"
}

resource "hw_tables" "capacity_tables" {
  quantity    = 6
  size        = "large" # $150/table, 6 seats each = 36 total seats
  description = "Large tables for high capacity"
}

resource "hw_chairs" "capacity_chairs" {
  quantity    = 36
  style       = "premium" # $50/chair
  description = "Premium chairs for high capacity"
}

resource "hw_fridge" "capacity_fridge" {
  size        = "large" # $800
  description = "Large fridge for high capacity"
}

locals {
  opt_capacity_oven_cost   = hw_oven.capacity_oven.cost
  opt_capacity_cook_cost   = hw_cook.capacity_cook_1.cost + hw_cook.capacity_cook_2.cost
  opt_capacity_tables_cost = hw_tables.capacity_tables.cost
  opt_capacity_chairs_cost = hw_chairs.capacity_chairs.cost
  opt_capacity_fridge_cost = hw_fridge.capacity_fridge.cost

  opt_capacity_total_cost = (
    local.opt_capacity_oven_cost +
    local.opt_capacity_cook_cost +
    local.opt_capacity_tables_cost +
    local.opt_capacity_chairs_cost +
    local.opt_capacity_fridge_cost
  )
}

# ============================================================================
# Store Configurations
# ============================================================================
# Create stores with each configuration to see customers_per_hour

resource "hw_store" "budget_store" {
  name        = "Budget Store"
  oven_id     = hw_oven.budget_oven.id
  cook_ids    = [hw_cook.budget_cook_1.id]
  tables_id   = hw_tables.budget_tables.id
  chairs_id   = hw_chairs.budget_chairs.id
  fridge_id   = hw_fridge.budget_fridge.id
  description = "Budget-optimized store configuration"
}

resource "hw_store" "balanced_store" {
  name        = "Balanced Store"
  oven_id     = hw_oven.balanced_oven.id
  cook_ids    = [hw_cook.balanced_cook_1.id, hw_cook.balanced_cook_2.id]
  tables_id   = hw_tables.balanced_tables.id
  chairs_id   = hw_chairs.balanced_chairs.id
  fridge_id   = hw_fridge.balanced_fridge.id
  description = "Balanced cost and capacity store"
}

resource "hw_store" "capacity_store" {
  name        = "Capacity Store"
  oven_id     = hw_oven.capacity_oven.id
  cook_ids    = [hw_cook.capacity_cook_1.id, hw_cook.capacity_cook_2.id]
  tables_id   = hw_tables.capacity_tables.id
  chairs_id   = hw_chairs.capacity_chairs.id
  fridge_id   = hw_fridge.capacity_fridge.id
  description = "Maximum capacity store configuration"
}

# ============================================================================
# Optimization Analysis
# ============================================================================
# Compare configurations to find the best value

locals {
  # Check which configurations are within budget
  opt_budget_within_budget   = local.opt_budget_total_cost <= var.store_budget
  opt_balanced_within_budget = local.opt_balanced_total_cost <= var.store_budget
  opt_capacity_within_budget = local.opt_capacity_total_cost <= var.store_budget

  # Calculate cost per customer per hour (efficiency metric)
  opt_budget_efficiency = local.opt_budget_within_budget ? (
    local.opt_budget_total_cost / hw_store.budget_store.customers_per_hour
  ) : null

  opt_balanced_efficiency = local.opt_balanced_within_budget ? (
    local.opt_balanced_total_cost / hw_store.balanced_store.customers_per_hour
  ) : null

  opt_capacity_efficiency = local.opt_capacity_within_budget ? (
    local.opt_capacity_total_cost / hw_store.capacity_store.customers_per_hour
  ) : null

  # Find the best configuration within budget
  # Best = highest customers_per_hour that fits budget
  opt_valid_configs = {
    budget = local.opt_budget_within_budget ? {
      cost             = local.opt_budget_total_cost
      customers_per_hr = hw_store.budget_store.customers_per_hour
      efficiency       = local.opt_budget_efficiency
    } : null
    balanced = local.opt_balanced_within_budget ? {
      cost             = local.opt_balanced_total_cost
      customers_per_hr = hw_store.balanced_store.customers_per_hour
      efficiency       = local.opt_balanced_efficiency
    } : null
    capacity = local.opt_capacity_within_budget ? {
      cost             = local.opt_capacity_total_cost
      customers_per_hr = hw_store.capacity_store.customers_per_hour
      efficiency       = local.opt_capacity_efficiency
    } : null
  }

  # Determine optimal configuration
  # (In real scenario, you'd use more sophisticated logic)
  opt_optimal_config = (local.opt_balanced_within_budget && hw_store.balanced_store.customers_per_hour > hw_store.budget_store.customers_per_hour) ? "balanced" : "budget"
}

# ============================================================================
# Outputs: Optimization Results
# ============================================================================

output "budget_constraint" {
  description = "The budget constraint for optimization"
  value       = var.store_budget
}

output "budget_configuration" {
  description = "Budget-friendly configuration details"
  value = {
    total_cost         = local.opt_budget_total_cost
    customers_per_hour = hw_store.budget_store.customers_per_hour
    within_budget      = local.opt_budget_within_budget
    cost_per_customer  = local.opt_budget_efficiency
    components = {
      oven   = hw_oven.budget_oven.cost
      cooks  = local.opt_budget_cook_cost
      tables = local.opt_budget_tables_cost
      chairs = local.opt_budget_chairs_cost
      fridge = local.opt_budget_fridge_cost
    }
  }
}

output "balanced_configuration" {
  description = "Balanced configuration details"
  value = {
    total_cost         = local.opt_balanced_total_cost
    customers_per_hour = hw_store.balanced_store.customers_per_hour
    within_budget      = local.opt_balanced_within_budget
    cost_per_customer  = local.opt_balanced_efficiency
    components = {
      oven   = hw_oven.balanced_oven.cost
      cooks  = local.opt_balanced_cook_cost
      tables = local.opt_balanced_tables_cost
      chairs = local.opt_balanced_chairs_cost
      fridge = local.opt_balanced_fridge_cost
    }
  }
}

output "capacity_configuration" {
  description = "High-capacity configuration details"
  value = {
    total_cost         = local.opt_capacity_total_cost
    customers_per_hour = hw_store.capacity_store.customers_per_hour
    within_budget      = local.opt_capacity_within_budget
    cost_per_customer  = local.opt_capacity_efficiency
    components = {
      oven   = hw_oven.capacity_oven.cost
      cooks  = local.opt_capacity_cook_cost
      tables = local.opt_capacity_tables_cost
      chairs = local.opt_capacity_chairs_cost
      fridge = local.opt_capacity_fridge_cost
    }
  }
}

output "optimization_summary" {
  description = "Summary of optimization results"
  value = {
    budget_constraint = var.store_budget
    valid_configs     = local.opt_valid_configs
    optimal_config    = local.opt_optimal_config
    recommendation    = local.opt_balanced_within_budget ? "Balanced configuration provides best customers_per_hour within budget" : "Budget configuration is the only option within budget"
  }
}

output "best_configuration" {
  description = "Best configuration for maximizing customers per hour within budget"
  value = (local.opt_balanced_within_budget && hw_store.balanced_store.customers_per_hour > hw_store.budget_store.customers_per_hour) ? {
    name              = "Balanced Store"
    total_cost        = local.opt_balanced_total_cost
    customers_per_hr  = hw_store.balanced_store.customers_per_hour
    cost_per_customer = local.opt_balanced_efficiency
    within_budget     = true
    } : {
    name              = "Budget Store"
    total_cost        = local.opt_budget_total_cost
    customers_per_hr  = hw_store.budget_store.customers_per_hour
    cost_per_customer = local.opt_budget_efficiency
    within_budget     = true
  }
}

# ============================================================================
# Optimization Challenge
# ============================================================================
# Try these exercises:
#
# 1. Adjust the budget variable to see how it affects which configurations are valid
#    terraform apply -var="store_budget=2500"
#    terraform apply -var="store_budget=5000"
#
# 2. Create your own optimized configuration that maximizes customers_per_hour
#    within your budget constraint
#
# 3. Experiment with different combinations:
#    - More cooks vs better oven
#    - Larger tables vs more tables
#    - Premium chairs vs more basic chairs
#
# 4. Calculate the cost per customer per hour for each configuration
#    (Lower is better - more efficient)
#
# 5. Find the sweet spot: What's the minimum budget needed to support
#    30 customers per hour? 40? 50?
