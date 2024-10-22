#Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Create IAM Role with Dynamic Assume Role Policy
resource "aws_iam_role" "iam_role" {
  name = "${var.role_name}-exe-rle"
  
  # Dynamic assume role policy configuration
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : var.assume_role_action,
        "Principal" : {
          "Service" : var.assume_role_principal_service
        },
        "Effect" : var.assume_role_effect
      }
    ]
  })
}

# Attach IAM Policy to the Role using standardized resource name
resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  count      = length(var.policy_arns)
  name       = "${var.role_name}-tsk-ply"
  roles      = [aws_iam_role.iam_role.name]
  policy_arn = var.policy_arns[count.index]
}

# Optionally attach inline policy for ECR access
resource "aws_iam_role_policy" "inline_policy" {
  count  = length(var.inline_policy) > 0 ? 1 : 0
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.iam_role.name
  policy = var.inline_policy
}