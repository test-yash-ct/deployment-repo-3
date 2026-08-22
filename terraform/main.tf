terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  type        = string
  description = "Security group of application workloads allowed to reach PostgreSQL"
}

variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_security_group" "platform_db" {
  name        = "healthops-db"
  description = "PostgreSQL for platform services"
  vpc_id      = var.vpc_id

  ingress {
    description     = "postgres from application security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "clinical" {
  name       = "healthops-clinical"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "clinical" {
  identifier                   = "healthops-clinical"
  engine                       = "postgres"
  instance_class               = "db.t3.medium"
  allocated_storage            = 100
  username                     = "dbadmin"
  password                     = var.db_password
  vpc_security_group_ids       = [aws_security_group.platform_db.id]
  db_subnet_group_name         = aws_db_subnet_group.clinical.name
  publicly_accessible          = false
  storage_encrypted            = true
  skip_final_snapshot          = false
  deletion_protection          = true
  backup_retention_period      = 7
  apply_immediately            = false
  performance_insights_enabled = true
}
