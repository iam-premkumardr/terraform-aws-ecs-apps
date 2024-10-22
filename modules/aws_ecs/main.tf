terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"  # Ensure this matches your root module
    }
  }
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
   setting {
    name  = "containerInsights"
    value = var.ecs_container_insights
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "service"
  network_mode             = var.launch_type == "FARGATE" ? "awsvpc" : "bridge"
  execution_role_arn       = var.execution_role_arn
  # Fargate requires CPU and Memory to be set at the task level
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = contains(["FARGATE"], var.launch_type) ? ["FARGATE"] : ["EC2"]
  container_definitions    = jsonencode([{
    name      = var.container_name
    image     = var.image_url
    cpu       = var.cpu
    memory    = var.memory
    essential = true
    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }
    ]
     # Health check definition
    healthCheck = var.enable_health_check ? {
      command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health.php || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    } : null  # If health check is not enabled, set to null
    runtimePlatform: {
      cpuArchitecture: "X86_64"
      operatingSystemFamily: "LINUX"
    }
  }])

  # Add this condition for placement_constraints only for EC2
  dynamic "placement_constraints" {
    for_each = var.launch_type == "EC2" ? [1] : []
    content {
      type       = "memberOf"
      expression = var.placement_expression
    }
  }
#  lifecycle {
#    create_before_destroy = true
#  }
  depends_on = [ aws_ecs_cluster.ecs_cluster ]
}

# Sleep for a few seconds after creating the task definition because of operation error ECS
resource "time_sleep" "wait_15_seconds" {
  depends_on = [aws_ecs_task_definition.ecs_task_definition]
  create_duration = "15s"
}

# ECS Fargate Service
resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type
   # Conditionally add the health check grace period only if load balancer is being used
  health_check_grace_period_seconds = var.use_load_balancer ? 60 : null

 # Only apply placement strategy if using EC2
  dynamic "ordered_placement_strategy" {
    for_each = var.launch_type == "EC2" ? [1] : []
    content {
      type  = var.placement_strategy_type
      field = var.placement_strategy_field
    }
  }

# Optional load balancer block
  dynamic "load_balancer" {
    for_each = var.use_load_balancer ? [1] : []
    content {
      target_group_arn = var.lb_target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }
  
  # Conditional network configuration, only required for Fargate
  dynamic "network_configuration" {
    for_each = var.launch_type == "FARGATE" ? [1] : []
    content {
      subnets         = var.subnets
      security_groups = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }
   # Conditional placement constraints, only required for EC2
  dynamic "placement_constraints" {
    for_each = var.launch_type == "EC2" ? [1] : []
    content {
      type       = "memberOf"
      expression = var.placement_expression
    }
  }

  deployment_controller {
    type = "ECS"
  }

  # Optional: Capacity provider strategy if you're using EC2 Spot
  dynamic "capacity_provider_strategy" {
    for_each = var.launch_type == "EC2" ? [1] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  }
#  lifecycle {
#    create_before_destroy = true
#  }
  depends_on = [aws_ecs_cluster.ecs_cluster,aws_ecs_task_definition.ecs_task_definition ]
}