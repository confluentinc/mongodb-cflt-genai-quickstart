terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.11.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.21.4"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {
  region = var.aws_region
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}
