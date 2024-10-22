variable "region" {
  description = "The AWS region"
  type        = string
}

# modules/aws_route_table/variables.tf

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the route."
  type        = string
}

variable "gateway_ids" {
  description = "List of NAT Gateway IDs"
  type        = list(string)  # Change from string to list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the route table."
  type        = list(string)
}
