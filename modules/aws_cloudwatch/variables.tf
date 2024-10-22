# AWS Region Variable
variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

# CloudWatch Log Group Name
variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}

# Retention days for CloudWatch logs
variable "retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

#KMS Key ID
variable "kms_key_id" {
  description = "KMS Key ID for encrypting CloudWatch log group. If empty, no encryption is applied."
  type        = string
  default     = ""
}

# Alarm Configurations
variable "alarm_configs" {
  description = "A map of ECS CloudWatch alarm configurations. Each alarm should include the necessary parameters."
  type = map(object({
    service_name   = string                     # ECS Service Name
    cluster_name   = string                     # ECS Cluster Name
    metric_name        = string                     # CloudWatch Metric Name (e.g., CPUUtilization, MemoryUtilization)
    comparison_operator = string                    # Comparison operator for the alarm (e.g., GreaterThanThreshold)
    evaluation_periods  = number                    # Number of evaluation periods
    threshold          = number                     # Threshold value for the metric
    period             = number                     # Period in seconds (e.g., 60 seconds)
    statistic          = string                     # Statistic to apply (e.g., Average, Sum)
    alarm_description  = string                     # Description for the CloudWatch alarm
    sns_topic_arn      = string                     # SNS Topic ARN for alarm notifications
  }))
  default = {
    # High CPU Utilization Alarm
    high_cpu = {
      service_name   = "laravel-app-service"
      cluster_name   = "laravel-cluster"
      metric_name        = "CPUUtilization"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      threshold          = 75
      period             = 60
      statistic          = "Average"
      alarm_description  = "Alarm when CPU utilization exceeds 75%"
      sns_topic_arn      = "arn:aws:sns:us-west-2:123456789012:HighCPUAlarm"
    }

    # High Memory Utilization Alarm
    high_memory = {
      service_name   = "laravel-app-service"
      cluster_name   = "laravel-cluster"
      metric_name        = "MemoryUtilization"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      threshold          = 80
      period             = 60
      statistic          = "Average"
      alarm_description  = "Alarm when memory utilization exceeds 80%"
      sns_topic_arn      = "arn:aws:sns:us-west-2:123456789012:HighMemoryAlarm"
    }

    # High Disk Usage Alarm
    high_disk = {
      service_name   = "laravel-app-service"
      cluster_name   = "laravel-cluster"
      metric_name        = "DiskReadBytes"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      threshold          = 100000000
      period             = 60
      statistic          = "Average"
      alarm_description  = "Alarm when disk read bytes exceed 100,000,000"
      sns_topic_arn      = "arn:aws:sns:us-west-2:123456789012:HighDiskAlarm"
    }

    # Unhealthy Task Count Alarm
    unhealthy_task_count = {
      service_name   = "laravel-app-service"
      cluster_name   = "laravel-cluster"
      metric_name        = "UnhealthyHostCount"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      threshold          = 1
      period             = 60
      statistic          = "Average"
      alarm_description  = "Alarm when unhealthy task count is greater than zero"
      sns_topic_arn      = "arn:aws:sns:us-west-2:123456789012:UnhealthyTaskAlarm"
    }
  }
}

variable "use_aws_managed_key" {
  default = true
}
