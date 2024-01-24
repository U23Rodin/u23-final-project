# Automatic Jira Deploy: Terraform-driven AWS Setup

## Description

This project automates the deployment of Atlassian Jira on AWS, utilizing Kubernetes for container orchestration. The core components of the system are provisioned and managed using Terraform, which sets up essential AWS services like RDS, EFS, VPC, EKS, and ELB. Jira itself is deployed through Helm charts, ensuring a streamlined and repeatable installation process.

## Features
- **Infrastructure as Code**: Terraform scripts create a reproducible and version-controlled infrastructure setup.
- **Kubernetes Integration**: Utilizes Kubernetes for deploying and managing Jira, facilitating easy scaling and management.
- **Automated Workflows**: Includes CI/CD pipelines for automatic execution of Terraform code, enhancing the efficiency and reliability of deployments.
- **Security Checks**: Incorporates security scanning tools like gitleaks and checkov, ensuring the infrastructure adheres to security best practices.
- **Source Control Management**: The entire project is managed through a version control system, ensuring that changes to the codebase are tracked, reviewed, and maintained systematically.
- **Public Cloud Utilization**: Leveraging AWS cloud services provides scalable and reliable cloud infrastructure, capable of adapting to changing demands and workloads.
- **Immutable Infrastructure**: Emphasizing on immutable infrastructure principles, where changes are made by replacing infrastructure rather than altering existing setups. This reduces inconsistencies and potential errors during deployments.

## Requirements

- AWS Account
- Terraform installed (Tested with v1.6.6)

## Configuration and Installation

1. [**Install Terraform**](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. [**Set up AWS authentication**](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
3. **Clone the Repository**: `git clone https://github.com/U23Rodin/u23-final-project.git`
4. **Set up the backend**:
	1. `cd terraform-backend`
	2. set up a globally unique name for the `s3_bucket_name` variable
	4. `terraform init`
	5. `terraform validate`
	6. `terraform apply`
5. **Set up terraform**
	1. `cd terraform`
	2. set up the same s3 bucket name for the backend in the providers.tf file
	3. `terraform init`
	4. `terraform validate`
	5. `terraform plan&apply`
