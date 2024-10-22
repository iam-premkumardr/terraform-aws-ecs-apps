# Output VPC and subnet information from both regions
output "primary_vpc_id" {
  description = "VPC ID of the primary region"
  value       = module.primary_vpc.vpc_id
}

output "create_final_snapshot_value" {
  value = var.create_final_snapshot
}

