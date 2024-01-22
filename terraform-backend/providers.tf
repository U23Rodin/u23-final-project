# Terraform block specifying the required providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }
  }
}

# AWS provider configuration
provider "aws" {
  region = "eu-central-1"
}
