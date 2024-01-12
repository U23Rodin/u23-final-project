terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = "jira-terraform-vpc"
  cidr = "10.1.0.0/16"

  azs              = ["eu-central-1a", "eu-central-1b"]
  private_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]
  public_subnets   = ["10.1.1.0/24", "10.1.2.0/24"]
  database_subnets = ["10.1.201.0/24", "10.1.202.0/24"]

  create_database_subnet_group = true

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "jira-database"
  description = "Jira database security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Database access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.1"

  identifier = "jira-database"

  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50

  db_name  = "jiradb"
  username = "jira"
  port     = 5432

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security-group.security_group_id]

  backup_retention_period = 0
}

