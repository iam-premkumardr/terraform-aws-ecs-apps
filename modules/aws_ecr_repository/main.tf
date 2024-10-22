#Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# AWS provider configuration for primary and secondary regions
provider "aws" {
  alias  = "primary"
  region = var.region
}


# ECR Repository Resource
resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_replication_configuration" "ecr_replication" {
  count = var.replication_account_id != "" ? 1 : 0
  replication_configuration {
    rule {
      destination {
        region      = var.replication_region
        registry_id = var.replication_account_id
      }
    }
  }
}