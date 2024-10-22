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

provider "aws" {
  alias  = "secondary"
  region = var.region
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.app_name}-internet-gateway"
  }
}
