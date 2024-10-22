variable "region" {
  description = "The AWS region for the VPC"
  type        = string
}

variable "api_gateway_rest_api_name" {
  description = "The name for the API Gateway REST API"
  type        = string
}

variable "load_balancer_url" {
  description = "The URL of the load balancer to proxy requests to"
  type        = string
}


variable "api_gateway_vpc_link_name" {
  description = "The name for the API Gateway REST API"
  type        = string
}

variable "is_public_alb" {
  description = "Set to true if using a public ALB, false if using a private ALB"
  type        = bool
  default     = true  # By default, it's a public ALB
}

variable "load_balancer_arn" {
  description = "The ARN of the load balancer."
  type        = string
}


/*
variable "api_domain_name" {
  description = "Custom domain name for the API Gateway"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the custom domain"
  type        = string
  default     = ""
}
*/