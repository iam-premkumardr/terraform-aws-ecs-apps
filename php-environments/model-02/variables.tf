# General Variables
variable "app_name" {
  description = "Application name to be used as a prefix for resources"
  type        = string
  default     = "php"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "ap-southeast-1"
}


variable "region" {
  description = "Primary AWS region"
  type        = string
  default     = "ap-southeast-2"
}

# VPC Module Variables
variable "primary_cidr_block" {
  description = "CIDR block for the primary region VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "primary_private_subnets" {
  description = "List of private subnets for the primary region"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "primary_public_subnets" {
  description = "List of public subnets for the primary region"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "primary_db_private_subnets" {
  description = "List of private subnets for the primary region"
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

variable "primary_availability_zones" {
  description = "List of availability zones for the primary region"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

# ALB Security Group Variables
variable "alb_ingress_rules" {
  description = "List of ingress rules for the ALB Security Group."
  type = list(
    object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })
  )
  default = [
    # Allow HTTP traffic on port 80
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Optionally, allow HTTPS traffic on port 443
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "alb_egress_rules" {
  description = "List of egress rules for the ALB Security Group."
  type = list(
    object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })
  )
  default = [
    # Allow all outbound traffic (to forward requests to ECS containers)
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # Or you can specify the private subnet CIDR if internal
    }
  ]
}
# Security Group Rules
variable "frontend_ingress_rules" {
  description = "List of ingress rules for the ECS Security Group."
  type = list(
    object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      security_groups = optional(list(string), []) # Optional security group IDs
    })
  )
  default = [
    # Allow HTTP traffic to the frontend service on port 8000
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "frontend_egress_rules" {
  description = "List of egress rules for the ECS Security Group."
  type = list(
    object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })
  )
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "backend_ingress_rules" {
  description = "Ingress rules for the Backend ECS Security Group."
  type = list(
    object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), []) # Optional CIDR blocks
      security_groups = optional(list(string), []) # Optional security group IDs
    })
  )
  default = [
    # Allow internal traffic from frontend service to backend service on port 9000
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Optionally, allow HTTPS traffic on port 443
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "backend_egress_rules" {
  description = "List of egress rules for the Backend Security Group."
  type = list(
    object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      security_groups = optional(list(string), []) # Optional security group IDs
    })
  )
  default = [
    # Allow all outbound traffic (if needed)
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp" # -1 for all protocols
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}



# DB Security Group Variables
variable "db_ingress_rules" {
  description = "List of ingress rules for the DB Security Group."
  type = list(
    object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      security_groups = optional(list(string), []) # Optional security group IDs
    })
  )
  default = [
    {
      from_port   = 3306 # Port for MySQL (or adjust as needed)
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # Allow traffic from the application VPC CIDR
    }
  ]
}

variable "db_egress_rules" {
  description = "List of egress rules for the DB Security Group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
    }
  ]
}


# Primary ALB Module Variables
variable "primary_target_group_port" {
  description = "Port number for the primary target group"
  type        = number
  default     = 80
}

variable "primary_target_group_protocol" {
  description = "Protocol for the primary target group"
  type        = string
  default     = "HTTP"
}

variable "primary_target_type" {
  description = "Target type for the primary target group (instance or ip)"
  type        = string
  default     = "ip"
}

variable "primary_health_check_interval" {
  description = "Interval in seconds for health checks in the primary region"
  type        = number
  default     = 30
}

variable "primary_health_check_path" {
  description = "The destination path for the health check in the primary region"
  type        = string
  default     = "/"
}

variable "primary_health_check_timeout" {
  description = "Timeout for health checks in the primary region"
  type        = number
  default     = 5
}

variable "primary_healthy_threshold" {
  description = "Number of consecutive health checks successes for the primary target to be considered healthy"
  type        = number
  default     = 5
}

variable "primary_unhealthy_threshold" {
  description = "Number of consecutive health check failures for the primary target to be considered unhealthy"
  type        = number
  default     = 2
}

variable "primary_listener_port" {
  description = "Port number for the listener in the primary ALB"
  type        = number
  default     = 80
}

variable "primary_listener_protocol" {
  description = "Protocol for the listener in the primary ALB"
  type        = string
  default     = "HTTP"
}

# DB Snapshot Variables
variable "snapshot_suffix" {
  description = "Suffix to append to the final snapshot name (e.g., a timestamp or count)"
  type        = string
  default     = null # No default value since the function will be called elsewhere
}

variable "create_final_snapshot" {
  description = "Final snapshot"
  type        = bool
  default     = false
}

variable "is_public_alb" {
  description = "Whether the ALB is public or private"
  type        = bool
  default     = true # Set this to false for private ALB
}

# KMS Module Variables
variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "KMS key for encrypting application resources"
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days, before the KMS key is deleted"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "The alias name for the KMS key"
  type        = string
  default     = "my-key-alias"
}

variable "aws_account_id" {
  description = "AWS Account ID for the root user"
  type        = string
  default     = "985651899636"
  sensitive   = true
}

variable "allowed_principals" {
  description = "List of IAM role or user ARNs that are allowed to use the KMS key"
  type        = list(string)
  default = [
    "arn:aws:iam::985651899636:user/ec2-user",
    "arn:aws:iam::985651899636:role/ec2-user"
  ]
}