variable "region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the endpoints will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the endpoints will be associated"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the endpoints"
  type        = list(string)
}

variable "endpoints" {
  description = "Map of service names and types to create VPC Endpoints"
  type = map(object({
    vpc_endpoint_type = string
  }))
  default = {
    "ecr.api" = {
      vpc_endpoint_type = "Interface"
    }
    "ecr.dkr" = {
      vpc_endpoint_type = "Interface"
    }
  "logs" = {
      vpc_endpoint_type = "Interface"
    }
  }
}