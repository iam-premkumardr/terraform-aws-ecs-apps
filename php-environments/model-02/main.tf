# Terraform providers
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
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# Local variable construction 
locals {
  task_family_name = "${var.app_name}-ecs-tsk-fmy"
}

# Create VPC in the primary region
module "primary_vpc" {
  source             = "../../modules/aws_vpc"
  region             = var.primary_region
  providers          = { aws = aws.primary }
  app_name           = var.app_name
  vpc_name           = "${var.app_name}-vpc"
  cidr_block         = var.primary_cidr_block
  private_subnets    = var.primary_private_subnets
  public_subnets     = var.primary_public_subnets
  db_subnets         = var.primary_db_private_subnets
  availability_zones = var.primary_availability_zones
}

# Primary ALB Security Group
module "primary_alb_security_group" {
  source              = "../../modules/aws_security_group"
  region              = var.primary_region
  providers           = { aws = aws.primary }
  security_group_name = "${var.app_name}-pri-lb-sg"
  vpc_id              = module.primary_vpc.vpc_id
  description         = "Primary LB Security Group"
  ingress_rules = [
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
    },
     {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    # Allow all outbound traffic (to forward requests to ECS containers)
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Private subnets
    }
  ]
}

# Application Load Balancers for Primary 
module "primary_alb" {
  source                = "../../modules/aws_alb"
  providers             = { aws = aws.primary }
  app_name              = var.app_name
  internal              = false                                                      # True for Internal ALB
  security_group_ids    = [module.primary_alb_security_group.alb_security_group_id] # Reference the correct output
  subnet_ids            = module.primary_vpc.public_subnet_ids                      # Use public subnets
  vpc_id                = module.primary_vpc.vpc_id
  target_group_port     = 8000
  target_group_protocol = "HTTP"
  target_type           = "ip"
  health_check_interval = 30
  health_check_path     = "/"
  health_check_timeout  = 5
  healthy_threshold     = 5
  unhealthy_threshold   = 2
  public_ip             = true
  listeners = [ 
    # Listener configuration for port 80 (HTTP)
     {
      port     = 80
      protocol = "HTTP"
      default_action_type = "forward"
      },
     # Listener for port 8000
    {
      port     = 8000
      protocol = "HTTP"
      default_action_type = "forward"
    }
  ]
}
    # Optional listener for port 443 (HTTPS)
    /*{
      port     = 443
      protocol = "HTTPS"
      ssl_policy = "ELBSecurityPolicy-2016-08"
      certificate_arn = var.ssl_certificate_arn  # Provide a valid ACM certificate ARN
      default_action = {
        default_action_type = "forward"
      }*/

module "internet_gateway" {
  source    = "../../modules/aws_internet_gateway"
  region    = var.primary_region
  providers = { aws = aws.primary }
  vpc_id    = module.primary_vpc.vpc_id # Pass the VPC ID
  app_name  = var.app_name              # Pass the application name
}

# Call the NAT Gateway module
module "nat_gateway" {
  source           = "../../modules/aws_nat_gateway"
  region           = var.primary_region
  providers        = { aws = aws.primary }
  public_subnet_id = module.primary_vpc.public_subnet_ids
}


# Public Route Table
module "public_route_table" {
  count       = length(module.primary_vpc.public_subnet_ids)
  source      = "../../modules/aws_route_table"
  region      = var.primary_region
  providers   = { aws = aws.primary }
  vpc_id      = module.primary_vpc.vpc_id
  gateway_ids = [module.internet_gateway.internet_gateway_id]
  cidr_block  = "0.0.0.0/0"
  subnet_ids  = [module.primary_vpc.public_subnet_ids[count.index]]
}

# Private Route Table
module "private_route_table" {
  count       = length(module.primary_vpc.private_subnet_ids)
  source      = "../../modules/aws_route_table"
  region      = var.primary_region
  providers   = { aws = aws.primary }
  vpc_id      = module.primary_vpc.vpc_id
  gateway_ids = [module.nat_gateway.nat_gateway_ids[0]]
  cidr_block  = "0.0.0.0/0"
  subnet_ids  = [module.primary_vpc.private_subnet_ids[count.index]]
}


module "common_vpc_endpoint" {
  source     = "../../modules/aws_vpc_endpoint"
  vpc_id     = module.primary_vpc.vpc_id
  region     = var.primary_region
  providers  = { aws = aws.primary }
  subnet_ids = module.primary_vpc.private_subnet_ids # Shared private subnets
  security_group_ids = [
    module.primary_frontend_security_group.frontend_security_group_id
  ]

  endpoints = {
    "ecr.api" = {
      vpc_endpoint_type = "Interface"
    }
    "ecr.dkr" = {
      vpc_endpoint_type = "Interface"
    }
    "logs" = {
      vpc_endpoint_type = "Interface"
    }
    "s3" = {
      vpc_endpoint_type = "Gateway"
    }
  }
  depends_on = [module.primary_vpc, module.primary_vpc.public_subnets, module.primary_vpc.private_subnets, module.primary_frontend_security_group]
}



# Call to the API Gateway module
module "api_gateway" {
  source                    = "../../modules/aws_api_gateway"  # Path to your module
  region                    = var.primary_region
  providers                 = { aws = aws.primary }
  api_gateway_rest_api_name = "${var.app_name}-api-gtw"
  load_balancer_url         = module.primary_alb.alb_dns_name
  load_balancer_arn         = module.primary_alb.alb_arn  # Correct reference
  api_gateway_vpc_link_name = "${var.app_name}-apigtw-alb-lnk"
  is_public_alb             = true 
}


# IAM Module Usage with Standardized Resource Names
module "iam_role" {
  source    = "../../modules/aws_iam"
  providers = { aws = aws.primary }
  role_name = "${var.app_name}-ecs-rle"

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # ECR access
  ]
  assume_role_action            = "sts:AssumeRole"
  assume_role_principal_service = "ecs-tasks.amazonaws.com"
  assume_role_effect            = "Allow"

  # Inline policy for VPC Endpoint access
  inline_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateVpcEndpoint",
          "ec2:DescribeVpcEndpoints",
          "ec2:ModifyVpcEndpoint",
          "ec2:DeleteVpcEndpoints",
          "ec2:DescribeVpcEndpointServiceConfigurations",
          "ec2:DescribeVpcEndpointServices",
          "ec2:DescribeVpcEndpointConnections"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}


# Primary Security Group Frontend
module "primary_frontend_security_group" {
  source              = "../../modules/aws_security_group"
  region              = var.primary_region
  providers           = { aws = aws.primary }
  security_group_name = "${var.app_name}-pri-frontend-ecs-sg"
  vpc_id              = module.primary_vpc.vpc_id
  description         = "Primary ECS Security Group Front End"
  ingress_rules = [
    # Allow HTTP traffic to the frontend service on port 8000
    {
      from_port       = 8000
      to_port         = 8000
      protocol        = "tcp"
      security_groups = [module.primary_alb_security_group.alb_security_group_id] # Correct reference to ALB SG ID
    },
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.primary_alb_security_group.alb_security_group_id]
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [module.primary_alb_security_group.alb_security_group_id]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"  # All protocols
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  depends_on = [module.primary_alb_security_group]
}


# ECS Modules for Frontend
module "primary_region_frontend_ecs" {
  source       = "../../modules/aws_ecs"
  providers    = { aws = aws.primary }
  depends_on   = [module.primary_alb]
  region       = var.primary_region
  cluster_name = "${var.app_name}-pri-ecs-cls"
  # ECS Task Definition
  task_family_name     = "${var.app_name}-frontend-ecs-task-fmy"
  execution_role_arn   = module.iam_role.iam_role_arn
  cpu                  = 256
  memory               = 512
  container_name       = "${var.app_name}-frontend-app-con"
  image_url            = "${var.aws_account_id}.dkr.ecr.ap-southeast-2.amazonaws.com/laravel-app"
  container_port       = 8000
  placement_expression = "attribute:ecs.availability-zone in [ap-southeast-2a, ap-southeast-2b, ap-southeast-2c]"
  launch_type          = "FARGATE"
  # ECS Service
  service_name             = "${var.app_name}-frontend-ecs-service"
  desired_count            = 3
  use_load_balancer        = true
  lb_target_group_arn      = module.primary_alb.target_group_arn
  placement_strategy_type  = "spread"
  placement_strategy_field = "attribute:ecs.availability-zone"
  subnets                  = module.primary_vpc.private_subnet_ids 
  security_groups          = [module.primary_frontend_security_group.frontend_security_group_id] # Correct reference
  assign_public_ip         = false # change it false for private subnets
  enable_health_check      = false
}


# Call the KMS module
module "primary_customer_managed_kms_cloudwatch" {
  source                  = "../../modules/aws_kms"
  region                  = var.primary_region
  providers               = { aws = aws.primary }
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  alias_name              = "cloudwatch"
  aws_account_id          = var.aws_account_id
  allowed_principals      = var.allowed_principals
}

# Create the SNS Topic in the Primary Region
module "primary_sns" {
  source            = "../../modules/aws_sns"
  region            = var.primary_region
  providers         = { aws = aws.primary }
  topic_name        = "${var.app_name}-pri-alerts"
  display_name      = "${var.app_name} Primary Alerts"
  kms_key_id = "alias/aws/sns"
  use_aws_managed_key = true
}


# CloudWatch Module for Primary Region using AWS Managed KMS key
module "primary_cloudwatch" {
  source         = "../../modules/aws_cloudwatch"
  region         = var.primary_region
  providers      = { aws = aws.primary }
  log_group_name = "/aws/ecs/${var.app_name}-pri-ecs-cls"
  retention_days = 30
  kms_key_id     =  module.primary_customer_managed_kms_cloudwatch.kms_key_arn
  use_aws_managed_key = false # Not available for this region
  alarm_configs = {
    high_cpu = {
      service_name        = "${var.app_name}-frontend-ecs-service"
      cluster_name        = "${var.app_name}-pri-ecs-cls"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      threshold           = 75
      period              = 60
      statistic           = "Average"
      alarm_description   = "Alarm when CPU utilization exceeds 75% in the primary region"
      sns_topic_arn       = module.primary_sns.sns_topic_arn
    }

    high_memory = {
      service_name        = "${var.app_name}-frontend-ecs-service"
      cluster_name        = "${var.app_name}-pri-ecs-cls"
      metric_name         = "MemoryUtilization"
      namespace           = "AWS/ECS"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      threshold           = 80
      period              = 60
      statistic           = "Average"
      alarm_description   = "Alarm when memory utilization exceeds 80% in the primary region"
      sns_topic_arn       = module.primary_sns.sns_topic_arn
    }
  }
}