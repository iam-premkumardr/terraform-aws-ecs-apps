#Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# modules/aws_nat_gateway/main.tf

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  count = length(var.public_subnet_id)  # One EIP per public subnet
}
# Create a NAT Gateway for each public subnet (one per AZ)
resource "aws_nat_gateway" "nat_gateway" {
  count        = length(var.public_subnet_id)  # One NAT Gateway per public subnet
  allocation_id = aws_eip.nat_gateway_eip[count.index].id  # Corresponding EIP
  subnet_id     = var.public_subnet_id[count.index]  # Corresponding public subnet
  depends_on    = [aws_eip.nat_gateway_eip]
}