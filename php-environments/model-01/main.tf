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
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

#local variable construction 
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


module "internet_gateway" {
  source    = "../../modules/aws_internet_gateway"
  region    = var.primary_region
  providers = { aws = aws.primary }
  vpc_id    = module.primary_vpc.vpc_id # Pass the VPC ID
  app_name  = var.app_name              # Pass the application name
}

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


# IAM Module Usage with Standardized Resource Names
module "iam_role" {
  source    = "../../modules/aws_iam"
  providers = { aws = aws.primary }
  role_name = "${var.app_name}-ecs-rle"
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # Added to allow ECR access
  ]

  assume_role_action            = "sts:AssumeRole"
  assume_role_principal_service = "ecs-tasks.amazonaws.com"
  assume_role_effect            = "Allow"
}


module "primary_region_backend_ecs_cluster" {
  source       = "../../modules/aws_ecs"
  providers    = { aws = aws.primary }
  region       = var.primary_region
  cluster_name = "${var.app_name}-pri-ecs-cls"
  # ECS Task Definition
  task_family_name     = "${var.app_name}-backend-ecs-task-fmy"
  execution_role_arn   = module.iam_role.iam_role_arn
  cpu                  = 256
  memory               = 512
  container_name       = "${var.app_name}-backend-app-con"
  image_url            = "${var.aws_account_id}.dkr.ecr.ap-southeast-2.amazonaws.com/php-application"
  container_port       = 9000
  placement_expression = "attribute:ecs.availability-zone in [ap-southeast-2a, ap-southeast-2b, ap-southeast-2c]"
  launch_type          = "FARGATE"
  # ECS Service
  service_name             = "${var.app_name}-backend-ecs-service"
  desired_count            = 3
  use_load_balancer        = false
  placement_strategy_type  = "spread"
  placement_strategy_field = "attribute:ecs.availability-zone"
  subnets                  = module.primary_vpc.public_subnet_ids
  security_groups          = [module.primary_backend_security_group.backend_security_group_id]
  assign_public_ip         = true
}

# Primary Backend Security Group
module "primary_backend_security_group" {
  source              = "../../modules/aws_security_group"
  region              = var.primary_region
  providers           = { aws = aws.primary }
  security_group_name = "${var.app_name}-pri-backend-ecs-sg"
  vpc_id              = module.primary_vpc.vpc_id
  description         = "Primary ECS Security Group Back End"
  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"] # Allow traffic from within the VPC
      security_groups = []            # No security group references for this rule
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"] # No CIDR block for this rule
      security_groups = []
    },
    {
      from_port       = 9000
      to_port         = 9000
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"] # No CIDR block for this rule
      security_groups = []
    }
  ]
  egress_rules = var.backend_egress_rules
}
