# Define Role Name variable
variable "role_name" {
  description = "Name prefix for IAM role"
  type        = string
}

# Define Policy ARN variable
variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
}

# Define dynamic Assume Role Action
variable "assume_role_action" {
  description = "The action field in the assume role policy statement"
  type        = string
  default     = "sts:AssumeRole"
}

# Define dynamic Assume Role Principal Service
variable "assume_role_principal_service" {
  description = "The service principal for the assume role policy"
  type        = string
  default     = "ecs-tasks.amazonaws.com"
}

# Define dynamic Assume Role Effect
variable "assume_role_effect" {
  description = "The effect field in the assume role policy statement"
  type        = string
  default     = "Allow"
}

variable "inline_policy" {
  description = "Optional inline policy for the IAM role"
  type        = string
  default     = ""
}
