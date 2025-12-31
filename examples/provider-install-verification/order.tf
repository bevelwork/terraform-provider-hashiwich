# Get order specifications
data "hw_order" "example" {}

# Create bread based on order
resource "hw_bread" "order_bread" {
  kind        = data.hw_order.example.order.sandwich.bread
  description = "Bread for order: ${data.hw_order.example.order.sandwich.bread}"
}

# Create meat based on order
resource "hw_meat" "order_meat" {
  kind        = data.hw_order.example.order.sandwich.meat
  description = "Meat for order: ${data.hw_order.example.order.sandwich.meat}"
}

# Create sandwich based on order specifications
resource "hw_sandwich" "order_sandwich" {
  bread_id    = hw_bread.order_bread.id
  meat_id     = hw_meat.order_meat.id
  description = "Sandwich from order: ${data.hw_order.example.order.sandwich.name}"
}

# Create drink based on order specifications
resource "hw_drink" "order_drink" {
  kind = data.hw_order.example.order.drink.kind

  dynamic "ice" {
    for_each = data.hw_order.example.order.drink.ice
    content {
      some = ice.value.some
      lots = ice.value.lots
      max  = ice.value.max
    }
  }

  description = "Drink from order: ${data.hw_order.example.order.drink.kind}"
}
