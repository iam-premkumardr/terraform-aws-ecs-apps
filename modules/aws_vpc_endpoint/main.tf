terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = var.endpoints
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type  = each.value.vpc_endpoint_type

  # Include subnet_ids only for Interface or GatewayLoadBalancer endpoints
  subnet_ids         = each.value.vpc_endpoint_type == "Interface" ? var.subnet_ids : null
  security_group_ids = each.value.vpc_endpoint_type == "Interface" ? var.security_group_ids : null

  tags = {
    Name = "${each.key}-vpc-endpoint"
  }
}
