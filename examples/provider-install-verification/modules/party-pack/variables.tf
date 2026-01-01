variable "sides" {
  description = "List of sides to include in the party pack (e.g., ['soup', 'salad', 'cookie'])"
  type        = list(string)
  default     = []
}

variable "include_napkins" {
  description = "Whether to include napkins in the party pack"
  type        = bool
  default     = false
}

variable "napkin_quantity" {
  description = "Number of napkins to include if include_napkins is true"
  type        = number
  default     = 20
}

variable "drink_kind" {
  description = "Kind of drink to include with each sandwich"
  type        = string
  default     = "cola"
}

variable "sandwich_bread" {
  description = "Bread type for all sandwiches"
  type        = string
  default     = "rye"
}

variable "sandwich_meat" {
  description = "Meat type for all sandwiches"
  type        = string
  default     = "turkey"
}
