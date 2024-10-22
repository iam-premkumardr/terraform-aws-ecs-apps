variable "region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to associate with the Internet Gateway"
  type        = string
}

variable "app_name" {
  description = "The name of the application, used to tag the Internet Gateway"
  type        = string
}
