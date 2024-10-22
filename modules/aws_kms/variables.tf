variable "region" {
  description = "The AWS region"
  type        = string
  default = "ap-southeast-2"
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "KMS key for encrypting application resources"
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days, before the KMS key is deleted"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "The alias name for the KMS key"
  type        = string
  default     = "my-key-alias"
}

variable "aws_account_id" {
  description = "AWS Account ID for the root user"
  type        = string
  sensitive = true
  default = "985651899636"
}

variable "allowed_principals" {
  description = "List of IAM role or user ARNs that are allowed to use the KMS key"
  type        = list(string)
  default     = ["arn:aws:iam::985651899636:user/ecs-user","arn:aws:iam::985651899636:role/ecs-user"]
}
