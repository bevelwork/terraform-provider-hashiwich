terraform {
  required_providers {
    hw = {
      source  = "hashicorp.com/edu/hashiwich"
      version = ">= 0.0.1"
    }
  }
}

provider "hw" {}
