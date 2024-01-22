# Terraform block specifying the required providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

# AWS provider configuration
provider "aws" {
  region = "eu-central-1"
}

# Kubernetes provider basic configuration
provider "kubernetes" {
  #config_path            = "~/.kube/config"    # Path to the kubeconfig file, uncomment if using a local kubeconfig
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    #config_path = "~/.kube/config"   # Uncomment to use a local kubeconfig file for Helm
    host                   = data.aws_eks_cluster.cluster.endpoint                       # EKS cluster endpoint for Helm
    token                  = data.aws_eks_cluster_auth.cluster.token                     # Token for authentication with the EKS cluster
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) # Cluster CA certificate for secure communication
  }
}

# Additional Kubernetes provider configuration for operations after EKS creation
provider "kubernetes" {
  alias                  = "post-eks"                                                  # Alias to distinguish this instance of the Kubernetes provider
  host                   = data.aws_eks_cluster.cluster.endpoint                       # EKS cluster endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token                     # Token for authentication with the EKS cluster
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) # Cluster CA certificate for secure communication
}

