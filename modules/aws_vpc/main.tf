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


resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create private subnets for the application within the VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-pri-subnet-${count.index}"
  }
}

# Create private subnets for the application within the VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-pub-subnet-${count.index}"
  }
}

# Create private subnets for the database within the VPC
resource "aws_subnet" "db_subnet" {
  count             = length(var.db_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.db_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false  # DB subnets are private
  tags = {
    Name = "${var.vpc_name}-db-subnet-${count.index}"
  }
}


