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

resource "aws_security_group" "platform_db" {
  name        = "healthops-db"
  description = "PostgreSQL for platform services"

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
  password                   = "changeme-placeholder"
  vpc_security_group_ids     = [aws_security_group.platform_db.id]
  publicly_accessible        = true
  skip_final_snapshot        = true
  deletion_protection        = false
  backup_retention_period    = 1
  apply_immediately          = true
}
