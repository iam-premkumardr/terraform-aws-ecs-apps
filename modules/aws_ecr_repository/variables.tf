variable "region" {
  description = "The AWS region"
  type        = string
  default = "ap-southeast-2"
}

# Variables for the ECR Repository Module
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned on push"
  type        = bool
  default     = true
}

variable "replication_region" {
  description = "Region to replicate the ECR repository to (secondary region)"
  type        = string
}

variable "replication_account_id" {
  description = "AWS Account ID to replicate the ECR images to (optional)"
  type        = string
  default     = "1232456789012"
}