variable "region" {
  description = "The AWS region"
  type        = string
}

# modules/aws_sns/variables.tf

variable "topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "The display name for the SNS topic"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "The KMS key ID to use for encrypting messages"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the SNS topic"
  type        = map(string)
  default     = {}
}

variable "use_aws_managed_key" {
  default = true
}
