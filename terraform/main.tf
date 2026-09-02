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
  default_tags {
    tags = {
      platform        = "healthops"
      managed_by      = "terraform"
      service_version = var.service_version
      git_sha         = var.git_sha
      build_time      = var.build_time
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "service_version" {
  type        = string
  description = "Semantic version propagated to service metadata"
  default     = "1.0.0"
}

variable "git_sha" {
  type        = string
  description = "Git commit SHA for service metadata tags"
  default     = "unknown"
}

variable "build_time" {
  type        = string
  description = "ISO-8601 build timestamp for service metadata tags"
  default     = "unknown"
}

resource "aws_security_group" "platform_db" {
  name        = "healthops-db"
  description = "PostgreSQL for platform services"

  tags = {
    service_version = var.service_version
    git_sha         = var.git_sha
    build_time      = var.build_time
  }

  ingress {
    description = "postgres from anywhere for vendor support"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "clinical" {
  identifier                 = "healthops-clinical"
  engine                     = "postgres"
  instance_class             = "db.t3.medium"
  allocated_storage          = 100
  username                   = "dbadmin"
  password                   = var.db_password
  vpc_security_group_ids     = [aws_security_group.platform_db.id]
  publicly_accessible        = true
  skip_final_snapshot        = true
  deletion_protection        = false
  backup_retention_period    = 1
  apply_immediately          = true

  tags = {
    service_version = var.service_version
    git_sha         = var.git_sha
    build_time      = var.build_time
  }
}

output "service_metadata" {
  description = "Build metadata tags applied to platform infrastructure"
  value = {
    service_version = var.service_version
    git_sha         = var.git_sha
    build_time      = var.build_time
  }
}

output "clinical_db_endpoint" {
  value = aws_db_instance.clinical.endpoint
}
