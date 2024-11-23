terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

  }
  required_version = ">= 1.0"
}
