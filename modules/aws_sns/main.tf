#Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# AWS provider configuration for primary and secondary regions
provider "aws" {
  alias  = "primary"
  region = var.region
}

provider "aws" {
  alias  = "secondary"
  region = var.region
}

resource "aws_sns_topic" "sns_topic" {
  name          = var.topic_name
  display_name  = var.display_name

  # Conditionally set KMS key based on whether to use AWS-managed or customer-managed key
  kms_master_key_id = var.use_aws_managed_key ? "alias/aws/logs" : (var.kms_key_id != "" ? var.kms_key_id : null)
}

