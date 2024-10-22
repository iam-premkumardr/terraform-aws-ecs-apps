# Output Role Name and ARN
output "iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.iam_role.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.iam_role.arn
}

# Output IAM Policy Attachment Name
output "iam_policy_attachment_name" {
  description = "The name of the IAM policy attachment"
  value       = aws_iam_policy_attachment.iam_policy_attachment[*].name
}
