# Outputs for ALB Module
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.lb.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.lb.arn
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.target_group.arn
}