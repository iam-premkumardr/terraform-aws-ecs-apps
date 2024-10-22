# modules/aws_nat_gateway/outputs.tf

# Output all NAT Gateway IDs as a list
output "nat_gateway_ids" {
  description = "The list of NAT Gateway IDs"
  value       = aws_nat_gateway.nat_gateway[*].id  # Output the list of NAT Gateway resource IDs
}


output "eip_ids" {
  value = aws_eip.nat_gateway_eip[*].id
}

