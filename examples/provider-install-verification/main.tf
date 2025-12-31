terraform {
  required_providers {
    hw = {
      source  = "registry.terraform.io/bevelwork/hashiwich"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1"
}

provider "hw" {}


resource "hw_meat" "bologna" {
  kind = "bologna"
}

resource "hw_bread" "rye" {
  kind = "rye"
}

resource "hw_sandwich" "zach" {
  bread_id = hw_bread.rye.id
  meat_id  = hw_meat.bologna.id
}

