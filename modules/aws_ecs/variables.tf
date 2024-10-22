# General Configuration Variables
variable "region" {
  description = "AWS region for ECS deployment"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
  default     = "my-app-cluster"
}

variable "task_family_name" {
  description = "ECS Task family name"
  type        = string
  default     = "my-app-task-family"
}

# ECS Cluster Configuration Variables
variable "ecs_container_insights" {
  description = "Enable or disable container insights for the ECS Cluster"
  type        = string
  default     = "enabled"
}


# ECS Task Definition Configuration Variables
variable "execution_role_arn" {
  description = "IAM Role ARN for ECS Task execution"
  type        = string
  default     = ""
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "my-app-container"
}

variable "image_url" {
  description = "Container image URL"
  type        = string
  default     = "amazon/amazon-ecs-sample"
}

variable "cpu" {
  description = "CPU units for the ECS task definition"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory allocation for the ECS task definition"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8000
}

# ECS Service Configuration Variables
variable "desired_count" {
  description = "Desired count of ECS service tasks"
  type        = number
  default     = 1
}

variable "iam_role" {
  description = "IAM role for the ECS service"
  type        = string
  default     = ""
}

variable "lb_target_group_arn" {
  description = "Target group ARN for the ECS service to use with a load balancer"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "ECS service name"
  type        = string
  default     = "my-app-service"
}

variable "launch_type" {
  description = "Launch type for ECS service"
  type        = string
  default     = "FARGATE"
}

variable "placement_strategy_type" {
  description = "Type of placement strategy (e.g., binpack, spread)"
  type        = string
  default     = "spread"
}

variable "placement_strategy_field" {
  description = "Field for the placement strategy (e.g., cpu, memory)"
  type        = string
  default     = "attribute:ecs.availability-zone"
}

variable "container_port_service" {
  description = "Port for the container used in the ECS service"
  type        = number
  default     = 8000
}

# ECS Placement Constraints Variables
variable "placement_expression" {
  description = "Placement expression for ECS tasks and services"
  type        = string
  default     = "attribute:ecs.availability-zone in [ap-southeast-2a, ap-southeast-2b, ap-southeast-2c]"
}

variable "subnets" {
  description = "List of private subnet IDs for ECS service."
  type        = list(string)
  default     = []
}


variable "security_groups"{
  description = "List of Security Groups for ECS service."
  type        = list(string)
  default     = []
}

variable "use_load_balancer" {
  description = "Set to true to use a load balancer, false to disable it"
  type        = bool
  default     = false
}

variable "assign_public_ip" {
 description = "Assign Public IP"
 type = bool
 default = true
}

variable "enable_health_check" {
  description = "Whether to enable health checks for the ECS service."
  type        = bool
  default     = true  # Set default to true or false as needed
}
