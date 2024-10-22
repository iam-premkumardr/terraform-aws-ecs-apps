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

resource "aws_kms_key" "kms_key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "AWS": "arn:aws:iam::${var.aws_account_id}:root" },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
         "Principal": {
         "Service": "logs.${var.region}.amazonaws.com"
      },
         "Action": [
         "kms:Encrypt",
         "kms:Decrypt",
         "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
  "Resource": "*"
}

      ]
  })
}

# Create an alias for the KMS key
resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.kms_key.id
  depends_on    = [aws_kms_key.kms_key]
}
