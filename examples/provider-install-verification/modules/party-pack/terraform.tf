terraform {
  required_providers {
    hw = {
      source = "registry.terraform.io/bevelwork/hashiwich"
      # No version constraint - inherits from parent or uses dev override
    }
  }
}
