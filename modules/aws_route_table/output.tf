# modules/aws_route_table/outputs.tf

# Output all Route Table IDs as a list
output "route_table_ids" {
  description = "List of Route Table IDs"
  value       = aws_route_table.route_table[*].id  # Collect all Route Table IDs
}
