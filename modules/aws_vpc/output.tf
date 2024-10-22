# Output the created resources
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "List of IDs of the created private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of the created private subnets"
  value       = aws_subnet.public_subnet[*].id
}

# Output the IDs of the created DB subnets
output "db_subnet_ids" {
  description = "List of IDs of the DB subnets"
  value       = aws_subnet.db_subnet[*].id
}

output "private_subnets" {
  description = "Private subnets and their CIDRs"
  value = { for i, subnet in aws_subnet.private_subnet : cidrsubnet(var.cidr_block, 8, i) => subnet.id }
}

output "public_subnets" {
  description = "Private subnets and their CIDRs"
  value = { for i, subnet in aws_subnet.public_subnet : cidrsubnet(var.cidr_block, 8, i) => subnet.id }
}

output "db_subnets" {
  description = "Private subnets and their CIDRs"
  value = { for i, subnet in aws_subnet.db_subnet : cidrsubnet(var.cidr_block, 8, i) => subnet.id }
}

/*
output "public_subnet_map" {
  value = {
    for subnet in aws_subnet.public_subnet : subnet.id => subnet.id
  }
}

output "private_subnet_map" {
  value = {
    for subnet in aws_subnet.private_subnet : subnet.id => subnet.id
  }
}

output "db_subnet_map" {
  value = {
    for subnet in aws_subnet.db_subnet : subnet.id => subnet.id
  }
}
*/