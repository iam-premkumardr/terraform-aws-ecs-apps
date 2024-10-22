# General Configuration Variables
variable "region" {
  description = "AWS region for ECS deployment"
  type        = string
  default     = "ap-southeast-2"
}

# Variables for ALB Module
variable "app_name" {
  description = "Application name to be used for ALB resources"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal or external"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the ALB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the ALB and Target Group"
  type        = string
}

variable "target_group_port" {
  description = "The port for the Target Group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "The protocol for the Target Group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "The type of target for the Target Group"
  type        = string
  default     = "ip"
}

variable "health_check_interval" {
  description = "Interval for health checks"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "health_check_timeout" {
  description = "Timeout for health checks"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy threshold for health checks"
  type        = number
  default     = 5
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold for health checks"
  type        = number
  default     = 2
}

variable "listeners" {
  description = "List of listeners to create"
  type = list(object({
    port               = number
    protocol           = string
    default_action_type = string
    certificate_arn    = optional(string)
  }))
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listeners (optional)"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "public_ip" {
  default = "false"
  type = bool
  description = "PUBLIC IP "
}