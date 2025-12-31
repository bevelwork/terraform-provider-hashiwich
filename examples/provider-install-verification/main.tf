terraform {
  required_providers {
    hashiwich = {
      source  = "bevelwork/hashiwich"
      version = "~> 1"
    }
  }
  required_version = ">= 1"
}

provider "hashiwich" {}
