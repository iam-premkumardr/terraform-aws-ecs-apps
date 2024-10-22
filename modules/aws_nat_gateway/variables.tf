variable "region" {
  description = "The AWS region"
  type        = string
}

# modules/aws_nat_gateway/variables.tf


variable "public_subnet_id" {
  description = "List of public subnet IDs for NAT Gateway"
  type        = list(string)  # Change from string to list(string)
}
