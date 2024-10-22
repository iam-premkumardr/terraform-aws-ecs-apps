# Output VPC and subnet information from both regions
output "primary_vpc_id" {
  description = "VPC ID of the primary region"
  value       = module.primary_vpc.vpc_id
}
output "public_subnet_ids" {
  description = "VPC ID of the primary region"
  value       = module.primary_vpc.public_subnet_ids
}

output "create_final_snapshot_value" {
  value = var.create_final_snapshot
}


output "private_subnet_ids" {
  value = module.primary_vpc.private_subnet_ids
}


# Output for Security Group IDs
# Output for Security Group IDs in the root module
output "security_group_ids" {
  description = "The IDs of the security groups."

  value = {

    frontend_security_group_id = [module.primary_frontend_security_group.frontend_security_group_id]

    # ALB Security Group Rule IDs
    alb_cidr_ingress_rule_ids = module.primary_alb_security_group.security_group_rule_ids.cidr_ingress_rule_ids
    alb_cidr_egress_rule_ids  = module.primary_alb_security_group.security_group_rule_ids.cidr_egress_rule_ids
    alb_sg_ingress_rule_ids   = module.primary_alb_security_group.security_group_rule_ids.sg_ingress_rule_ids
    alb_sg_egress_rule_ids    = module.primary_alb_security_group.security_group_rule_ids.sg_egress_rule_ids

    cidr_ingress_rule_ids = module.primary_frontend_security_group.security_group_rule_ids.cidr_ingress_rule_ids
    cidr_egress_rule_ids  = module.primary_frontend_security_group.security_group_rule_ids.cidr_egress_rule_ids
    sg_ingress_rule_ids   = module.primary_frontend_security_group.security_group_rule_ids.sg_ingress_rule_ids
    sg_egress_rule_ids    = module.primary_frontend_security_group.security_group_rule_ids.sg_egress_rule_ids

  }
}

