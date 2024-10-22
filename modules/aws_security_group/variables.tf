variable "region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "security_group_name" {
  description = "security group name"
  type        = string
}

variable "description" {
  description = "security group description"
  type        = string
}

# Ingress rules variable
variable "ingress_rules" {
  description = "List of ingress rules for the security group."
  type = list(
    object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])  # Optional CIDR blocks for ingress
      security_groups = optional(list(string), [])  # Optional security group IDs for ingress
    })
  )
  default = []
}

# Egress rules variable
variable "egress_rules" {
  description = "List of egress rules for the security group."
  type = list(
    object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])  # Optional CIDR blocks for egress
      security_groups = optional(list(string), [])  # Optional security group IDs for egress
    })
  )
  default = []
}