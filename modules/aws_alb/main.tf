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


# Create the Application Load Balancer
resource "aws_lb" "lb" {
  name               = "${var.app_name}-alb"
  internal           = var.public_ip
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# Create the Target Group
resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-tg"
  port        = var.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

   health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }


  tags = {
    Name = "${var.app_name}-tg"
  }
}


# Resource to create a listener for ALB
resource "aws_lb_listener" "listener" {
  count             = length(var.listeners) # Dynamic count based on input
  load_balancer_arn = aws_lb.lb.arn
  port              = var.listeners[count.index].port
  protocol          = var.listeners[count.index].protocol

  # Set the default action to forward requests to the target group
  default_action {
    type             = var.listeners[count.index].default_action_type
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  # Add certificate_arn and ssl_policy only if the protocol is HTTPS
  certificate_arn = var.listeners[count.index].protocol == "HTTPS" ? var.listeners[count.index].certificate_arn : null
  ssl_policy      = var.listeners[count.index].protocol == "HTTPS" ? var.ssl_policy : null
}




/*
resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = ["/index.php", "/service/*"]
    }
  }
}*/
