# Output the CloudWatch alarm names
output "cloudwatch_alarm_names" {
  description = "The names of all CloudWatch alarms created"
  value       = [for alarm in aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm : alarm.alarm_name]
}

# Output the CloudWatch alarm ARNs
output "cloudwatch_alarm_arns" {
  description = "The ARNs of all CloudWatch alarms created"
  value       = [for alarm in aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm : alarm.arn]
}

# Output the CloudWatch Log Group Name
output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.cloudwatch_log_group.name
}

# Output the CloudWatch Log Group ARN
output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.cloudwatch_log_group.arn
}

output "kms_key_used" {
  value = var.use_aws_managed_key ? "alias/aws/logs" : (var.kms_key_id != "" ? var.kms_key_id : "No Key Specified")
}
