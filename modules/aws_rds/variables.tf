variable "region" {
  description = "AWS region to deploy resources in"
  type = string
  default = "ap-southeast-2"
}

variable "cluster_identifier" {
  description = "Identifier for the RDS cluster"
  type = string
  default = "example-cluster"
}

variable "engine" {
  description = "RDS engine to use"
  type = string
  default = "aurora-postgresql"
}

variable "engine_mode" {
  description = "RDS engine mode (provisioned or serverless)"
  type = string
  default = "provisioned"
}

variable "engine_version" {
  description = "Version of the RDS engine"
  type = string
  default = "13.6"
}

variable "database_name" {
  description = "Database name for the RDS cluster"
  type = string
  default = "dbadb"
}

variable "master_username" {
  description = "Master username for the RDS cluster"
  type = string
  default = "admin"
}

variable "master_password" {
  description = "Master password for the RDS cluster"
  type = string
  sensitive = true
  default = "securepassword"
}

variable "storage_encrypted" {
  description = "Enable storage encryption for RDS"
  type = bool
  default = true
}

variable "instance_class" {
  description = "Instance class for the RDS cluster"
  type = string
  default = "db.serverless"
}

variable "allocated_storage" {
  description = "The amount of storage (in GB) to allocate for the RDS instance"
  type = number
  default = 20
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type = bool
  default = false
}

variable "multi_az" {
  description = "Whether to deploy the RDS instance in multiple availability zones"
  type = bool
  default = false
}

variable "min_capacity" {
  description = "Minimum capacity for Serverless v2 scaling"
  type = number
  default = 0.5
}

variable "max_capacity" {
  description = "Maximum capacity for Serverless v2 scaling"
  type = number
  default = 1.0
}

variable "backup_retention_period" {
  description = "Number of days to retain RDS backups"
  type = number
  default = 7
}

variable "preferred_backup_window" {
  description = "Preferred time range for RDS backups (in UTC)"
  type = string
  default = "07:00-09:00"
}

variable "preferred_maintenance_window" {
  description = "The preferred maintenance window for RDS instances (in UTC)"
  type = string
  default = "Sun:05:00-Sun:06:00"
}

variable "vpc_security_group_ids" {
  description = "List of VPC Security Group IDs to associate with the RDS cluster"
  type = list(string)
}

variable "db_subnet_group_name" {
  description = "The DB subnet group name for the RDS cluster"
  type = string
  default = "your-db-subnet-group"
}

variable "create_final_snapshot" {
  description = "Controls whether a final snapshot is created upon RDS deletion"
  type = bool
  default = true
}

variable "snapshot_suffix" {
  description = "Suffix to append to the final snapshot name (e.g., a timestamp or count)"
  type = string
  default = null
}

variable "db_subnet_ids" {
  description = "List of Subnet IDs"
  type = list(string)
}