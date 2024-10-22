# Output the KMS key ARN
output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.kms_key.arn
}

# Output the KMS key ID
output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.kms_key.id
}
