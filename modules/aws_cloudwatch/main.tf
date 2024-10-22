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


resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_days

  # Conditionally set KMS key based on whether to use AWS-managed or customer-managed key
 kms_key_id = var.use_aws_managed_key ? "alias/aws/logs" : (var.kms_key_id != "" ? var.kms_key_id : null)
}


# Dynamically create CloudWatch alarms using the for_each loop
resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_alarm" {
  for_each            = var.alarm_configs
  alarm_name          = format("%s-%s", each.value.service_name, each.value.metric_name)
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/ECS"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions = {
    ClusterName = each.value.cluster_name
    ServiceName = each.value.service_name
  }
  alarm_actions = [each.value.sns_topic_arn]
  depends_on = [aws_cloudwatch_log_group.cloudwatch_log_group]
}
