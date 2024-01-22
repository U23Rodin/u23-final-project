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

provider "aws" {
  region = "eu-central-1"
}

provider "kubernetes" {
  #config_path            = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    #config_path = "~/.kube/config"
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

provider "kubernetes" {
  alias                  = "post-eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

