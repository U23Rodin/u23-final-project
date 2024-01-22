# VPC module for creating the Virtual Private Cloud on AWS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  # Setting up VPC parameters using variables
  name = var.vpc_name
  cidr = var.vpc_cidr

  # Define availability zones and subnet types for the VPC
  azs              = var.vpc_availability_zones
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.vpc_database_subnets
  intra_subnets    = var.vpc_intra_subnets

  # Enable a database subnet group and NAT gateway for outbound traffic
  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true

  # Tagging subnets for identification and management
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

# Security Group module for the database
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  # Basic configuration of the security group
  name        = var.database_sg_name
  description = "Jira database security group"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules for the security group, allowing database access
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

# RDS (Relational Database Service) module for the database backend
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.1"

  # Database configuration using variables
  identifier = var.rds_name

  engine               = var.database_engine
  engine_version       = var.database_engine_version
  family               = var.database_family
  major_engine_version = var.database_major_engine_version
  instance_class       = var.database_instance_class

  allocated_storage     = var.database_allocated_storage
  max_allocated_storage = var.database_max_allocated_storage

  db_name  = var.database_name
  username = var.database_user
  port     = var.database_port

  # High availability and network configuration
  multi_az               = var.database_multi_az
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security-group.security_group_id]

  backup_retention_period = var.database_backup_retention
}

# EFS (Elastic File System) module for persistent storage
module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.4.0"

  # Configuration for the EFS instance
  name           = var.efs_name
  creation_token = var.efs_creation_token

  # Mount targets for the EFS within the VPC
  mount_targets = {
    for index, az in var.vpc_availability_zones : az => { subnet_id = module.vpc.private_subnets[index] }
  }

  # Security group configuration for the EFS
  security_group_description = "Jira EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC subnets"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
}

# Outputting the EFS mount targets for reference
output "efs_mount_targets" {
  description = "The map of mount target definitions for the EFS"
  value       = { for index, az in var.vpc_availability_zones : az => { subnet_id = module.vpc.private_subnets[index] } }
}

# EKS (Elastic Kubernetes Service) module for running Jira in a containerized environment
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  # Basic EKS cluster configuration
  cluster_name                   = var.eks_cluster_name
  cluster_version                = var.eks_cluster_version
  cluster_endpoint_public_access = var.eks_endpoint_public_access

  # Additional cluster configuration including addons and networking
  cluster_addons           = var.eks_cluster_addons
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Configuration for worker nodes in the EKS cluster
  eks_managed_node_groups = {
    eks-worker-node = {
      min_size     = var.eks_managed_node_group_min_size
      max_size     = var.eks_managed_node_group_max_size
      desired_size = var.eks_managed_node_group_desired_size

      instance_types = var.eks_managed_node_group_instance_types
      capacity_type  = var.eks_managed_node_group_capacity_type

      block_device_mappings = {
        xvda = {
          device_name = var.eks_block_device_name
          ebs = {
            volume_size           = var.eks_block_device_volume_size
            volume_type           = var.eks_block_device_type
            iops                  = var.eks_block_device_iops
            throughput            = var.eks_block_device_throughput
            delete_on_termination = var.eks_block_device_delete_on_termination
          }
        }
      }
    }
  }
}

# Fetching information about the EKS cluster (used for updating the Kubernetes provider)
data "aws_eks_cluster" "cluster" {
  depends_on = [
    module.eks
  ]
  name = module.eks.cluster_name
}

# Fetching authentication information for the EKS cluster
data "aws_eks_cluster_auth" "cluster" {
  depends_on = [
    module.eks
  ]
  name = module.eks.cluster_name
}

# Fetching the AWS account identity information
data "aws_caller_identity" "current" {
  depends_on = [module.eks]
}

# Retrieving the RDS database password from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = module.rds.db_instance_master_user_secret_arn
}

# Local values for OIDC provider and database credentials
locals {
  oidc_provider_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_provider_url, "https://", "")}"
  db_credentials    = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)
}

# IAM policy for the load balancer controller in the EKS cluster
resource "aws_iam_policy" "lb_controller_policy" {
  depends_on = [module.eks]

  name   = var.lb_controller_policy_name
  policy = file("${path.module}/${var.lb_controller_policy_filepath}")
}

# IAM role for the load balancer controller in the EKS cluster
resource "aws_iam_role" "lb_controller_role" {
  depends_on = [module.eks]

  name = var.lb_controller_role_name
  assume_role_policy = templatefile("${path.module}/${var.lb_controller_role_tpl_filepath}", {
    oidc_provider_arn = local.oidc_provider_arn
    oidc_provider_url = local.oidc_provider_url
    cluster_name      = module.eks.cluster_name
  })
}

# Attaching the IAM policy to the load balancer controller role
resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}

# Kubernetes service account for AWS load balancer controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  depends_on = [module.eks]
  provider   = kubernetes.post-eks

  metadata {
    name      = var.lb_controller_service_account_name
    namespace = var.lb_controller_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
    }
  }
}

# Helm release for deploying the AWS load balancer controller to the EKS cluster
resource "helm_release" "aws_lb_controller" {
  depends_on = [module.eks]
  name       = var.lb_controller_service_account_name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.lb_controller_service_account_namespace

  # Setting values for the Helm chart
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.lb_controller_service_account_name
  }
}

