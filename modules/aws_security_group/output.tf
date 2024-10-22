# outputs.tf

# Output for Security Group Rules
output "security_group_rule_ids" {
  description = "The IDs of the security groups."

  value = {
    cidr_ingress_rule_ids   = [for rule in aws_security_group_rule.cidr_ingress : rule.id]
    cidr_egress_rule_ids    = [for rule in aws_security_group_rule.cidr_egress : rule.id]
    sg_ingress_rule_ids     = [for rule in aws_security_group_rule.sg_ingress : rule.id]
    sg_egress_rule_ids      = [for rule in aws_security_group_rule.sg_egress : rule.id]
  }
}

output "frontend_security_group_id" {
  description = "The ID of the frontend security group."
  value       = aws_security_group.sg.id  # Ensure this matches your security group resource
}

output "backend_security_group_id" {
  description = "The ID of the backend security group."
  value       = aws_security_group.sg.id
}

output "db_security_group_id" {
  description = "The ID of the DB security group."
  value       = aws_security_group.sg.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.sg.id
}
