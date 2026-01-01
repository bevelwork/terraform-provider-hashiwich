# Get order specifications
data "hw_order" "order_example" {}

# Create bread based on order
resource "hw_bread" "order_bread" {
  kind        = data.hw_order.order_example.sandwich.bread
  description = "Bread for order: ${data.hw_order.order_example.sandwich.bread}"
}

# Create meat based on order
resource "hw_meat" "order_meat" {
  kind        = data.hw_order.order_example.sandwich.meat
  description = "Meat for order: ${data.hw_order.order_example.sandwich.meat}"
}

# Create sandwich based on order specifications
resource "hw_sandwich" "order_sandwich" {
  bread_id    = hw_bread.order_bread.id
  meat_id     = hw_meat.order_meat.id
  description = "Sandwich from order: ${data.hw_order.order_example.sandwich.name}"
}

# Create drink based on order specifications
resource "hw_drink" "order_drink" {
  kind = data.hw_order.order_example.drink.kind

  # Only include ice if "hot" is not in the drink kind
  dynamic "ice" {
    for_each = strcontains(lower(data.hw_order.order_example.drink.kind), "hot") ? [] : data.hw_order.order_example.drink.ice
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Drink from order: ${data.hw_order.order_example.drink.kind}"
}
