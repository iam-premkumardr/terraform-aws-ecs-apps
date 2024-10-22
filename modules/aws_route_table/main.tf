# Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# Create a Route Table
resource "aws_route_table" "route_table" {
  count  = length(var.subnet_ids)
  vpc_id = var.vpc_id
  # Define route based on CIDR and gateway
  route {
    cidr_block = var.cidr_block
    gateway_id = var.gateway_ids[count.index]
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "route_table_association" {
  count         = length(var.subnet_ids)
  subnet_id     = var.subnet_ids[count.index]
  route_table_id = aws_route_table.route_table[count.index].id
}