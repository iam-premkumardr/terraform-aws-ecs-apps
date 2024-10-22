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


resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  provider    = aws.primary
  name        = var.api_gateway_rest_api_name
  description = "API Gateway for the Laravel App"
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  path_part   = "service"
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_vpc_link" "api_gateway_vpc_link" {
  count = var.is_public_alb ? 0 : 1
  name = "${var.api_gateway_rest_api_name}-vpc-link"
  target_arns = [var.load_balancer_arn] # The ALB ARN inside the VPC
}


# ALB integration (with and without vpc_link_id)
resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  type        = "HTTP_PROXY"
  
  # Load balancer URL to proxy requests to
  #uri                     = "https://${var.load_balancer_url}/index.php"
  # Directly set vpc_link_id without using a dynamic block
  uri = var.is_public_alb ? "https://${var.load_balancer_url}/index.php" : "https://${aws_api_gateway_vpc_link.api_gateway_vpc_link[0].id}/index.php"
  integration_http_method = "ANY"
  
  # Connection type based on whether the ALB is public or private
  connection_type         = var.is_public_alb ? "INTERNET" : "VPC_LINK"

}


# Deploy the API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
    depends_on = [
    aws_api_gateway_method.api_gateway_method,  # Ensure it's dependent on the method being created
    aws_api_gateway_integration.api_gateway_integration,
    aws_api_gateway_account.api_gateway_account  # CloudWatch role dependency
  ]
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
}

resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "/aws/apigateway/${var.api_gateway_rest_api_name}"
  retention_in_days = 30  # You can adjust retention as needed
}

/*
resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  stage_name  = "prod"
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format          = jsonencode({
      requestId       = "$context.requestId"
      sourceIp        = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      resourcePath    = "$context.resourcePath"
      status          = "$context.status"
      protocol        = "$context.protocol"
    })
  }
   lifecycle {
    ignore_changes = [deployment_id]
  }
  depends_on = [aws_api_gateway_rest_api.api_gateway_rest_api,aws_api_gateway_deployment.api_deployment,aws_cloudwatch_log_group.api_gateway_log_group,aws_cloudwatch_log_group.api_gateway_log_group]
}
*/
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "APIGatewayCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  role = aws_iam_role.api_gateway_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}

/*
# Conditional block to create the domain name and base path mapping only if both domain_name and certificate_arn are provided
resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
  count           = var.api_domain_name != "" && var.certificate_arn != "" ? 1 : 0
  domain_name     = var.api_domain_name
  certificate_arn = var.certificate_arn
}

resource "aws_api_gateway_base_path_mapping" "base_path" {
  count       = var.api_domain_name != "" && var.certificate_arn != "" ? 1 : 0
  domain_name = aws_api_gateway_domain_name.api_gateway_domain_name[0].domain_name
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  stage_name  = aws_api_gateway_deployment.api_gateway_deployment.stage_name
}
*/