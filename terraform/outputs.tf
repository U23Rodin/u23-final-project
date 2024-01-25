output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "The port on which the RDS instance is listening"
  value       = module.rds.db_instance_port
  sensitive   = true
}

output "efs_file_system_id" {
  description = "The ID of the EFS file system"
  value       = module.efs.id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

