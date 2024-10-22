# Terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Create a DB Subnet Group using the created DB subnets
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids

  lifecycle {
    prevent_destroy = false  # Ensure this is not set to true
  }
}


# RDS Cluster Definition
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = var.cluster_identifier
  engine             = var.engine
  engine_mode        = var.engine_mode
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password
  storage_encrypted  = var.storage_encrypted

  # Scaling configuration for Serverless V2
  dynamic "scaling_configuration" {
    for_each = var.engine_mode == "serverless" ? [1] : []
    content {
      max_capacity = var.max_capacity
      min_capacity = var.min_capacity
      auto_pause   = true
      seconds_until_auto_pause = 300  # 5 minutes
    }
  }

  # Backup and retention settings (optional)
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  
  # VPC and security group settings (optional)
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name 
  
  # Snapshot settings
  skip_final_snapshot     = var.create_final_snapshot ? false : true
  final_snapshot_identifier = var.create_final_snapshot ? "${var.cluster_identifier}-final-snapshot-${var.snapshot_suffix}" : null
  
  # Build dependency
  depends_on = [aws_db_subnet_group.db_subnet_group] 
}

# RDS Cluster Instance Definition
resource "aws_rds_cluster_instance" "rds_cluster_instance" {
  count = var.engine_mode == "provisioned" ? 1 : 0  # Only create instances for provisioned mode
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version
}

# Add a standalone RDS instance for cases where a single instance is needed
resource "aws_db_instance" "rds_instance" {
  count                = var.engine_mode == "provisioned" ? 1 : 0  # Only for provisioned mode
  identifier           = "${var.cluster_identifier}-instance"
  engine               = var.engine
  instance_class       = var.instance_class
  allocated_storage     = var.allocated_storage
  username             = var.master_username
  password             = var.master_password
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az             = var.multi_az
  storage_encrypted    = var.storage_encrypted
  publicly_accessible  = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  
  # Snapshot settings
  skip_final_snapshot     = var.create_final_snapshot ? false : true
  final_snapshot_identifier = var.create_final_snapshot ? "${var.cluster_identifier}-final-snapshot-${var.snapshot_suffix}" : null
}

