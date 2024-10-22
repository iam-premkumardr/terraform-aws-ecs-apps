variable "region" {
  description = "The AWS region"
  type        = string
}

variable "app_name"{
   description = "App Name"
  type        = string
}
# Variables for configuring the VPC
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
}

variable "db_subnets" {
  description = "List of private subnets for the database"
  type        = list(string)
}
