#Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


/*
# Security group for ECS tasks
resource "aws_security_group" "sg" {
  name        = var.security_group_name
  vpc_id      = var.vpc_id
  description = var.description
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
        # Use lookup to safely access cidr_blocks and security_groups
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", [])
      security_groups = lookup(ingress.value, "security_groups", [])
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks     = lookup(egress.value, "cidr_blocks", [])
      security_groups = lookup(egress.value, "security_groups", [])
    }
  }
}
*/
# Define the security group itself
resource "aws_security_group" "sg" {
  name        = var.security_group_name
  vpc_id      = var.vpc_id
  description = var.description
}

# Create ingress rules with CIDR blocks
resource "aws_security_group_rule" "cidr_ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule if length(rule.cidr_blocks) > 0 }
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.sg.id
   depends_on = [
    aws_security_group.sg  # Ensure the main SG is created before adding rules
  ]
}

# Create egress rules with CIDR blocks
resource "aws_security_group_rule" "cidr_egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule if length(rule.cidr_blocks) > 0 }
  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.sg.id
   depends_on = [
    aws_security_group.sg  # Ensure the main SG is created before adding rules
  ]
}

# Create separate security group ingress rules
resource "aws_security_group_rule" "sg_ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule if length(rule.security_groups) > 0 }
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.security_groups[0]  # Reference other security groups
  security_group_id        = aws_security_group.sg.id
   depends_on = [
    aws_security_group.sg  # Ensure the main SG is created before adding rules
  ]
}

# Create separate security group egress rules
resource "aws_security_group_rule" "sg_egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule if length(rule.security_groups) > 0 }
  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.security_groups[0]  # Reference other security groups
  security_group_id        = aws_security_group.sg.id
   depends_on = [
    aws_security_group.sg  # Ensure the main SG is created before adding rules
  ]
}
