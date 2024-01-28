# Automatic Jira Deploy: Terraform-driven AWS Setup

## Description

This project automates the deployment of Atlassian Jira on AWS, utilizing Kubernetes for container orchestration. The core components of the system are provisioned and managed using Terraform, which sets up essential AWS services. Jira itself is deployed through Helm charts, ensuring a streamlined and repeatable installation process.

**AWS Prerequisite Infrastructure**
- **Amazon RDS (Relational Database Service)**: Provides a managed database service for Jira. RDS hosts the database used by Jira, ensuring high availability, backup, and scalability.
- **Amazon EFS (Elastic File System)**: Utilized as a shared storage system for Jira’s home directory, allowing multiple instances to access the same data for consistent configuration and data management.
- **AWS ALB (Application Load Balancer)**: Serves as the entry point for incoming traffic. 
- **Amazon EKS (Elastic Kubernetes Service)**: Offers a managed Kubernetes control plane. EKS handles the orchestration, scaling, and management of Kubernetes clusters, providing a robust foundation for deploying Jira.
-------------------------------------------
**Kubernetes Resources (Deployed via Helm Charts)**:
- **Ingress (ing)**: Routes external HTTP/HTTPS traffic to the Jira application, enabling user access to Jira's interface.
- **Service (svc)**: Exposes the Jira application as a network service within the Kubernetes cluster, creating a stable internal endpoint for the Jira pods.
- **StatefulSet (sts)**: Manages the Jira pods with persistent identities, crucial for Jira's data consistency and state management.
- **Pods (pod)**: Hosts the Jira application instances, serving as the basic operational units within Kubernetes.
- **Persistent Volume Claim (PVC) and Persistent Volume (PV)**: Manages storage for Jira's data, with PVCs requesting and PVs providing persistent storage, backed by EFS.
- **Storage Class (sc)**: Defines the characteristics of the storage used by Jira, ensuring compatibility with EFS for persistent and shared storage needs.

[Infrastructure Diagram: Visualizing the above components ](https://final-project-diagrams.s3.eu-central-1.amazonaws.com/infrastructure-diagram.jpg)

## Features
- **Infrastructure as Code (IaC)**: Utilizes Terraform to create a reproducible, version-controlled infrastructure on AWS, ensuring consistency and reliability in deployments.
- **Kubernetes Integration**: Employs AWS EKS (Elastic Kubernetes Service) for Kubernetes control plane management, facilitating efficient deployment, scaling, and management of Jira on a Kubernetes cluster.
- **CI/CD with GitHub Actions**: Implements Continuous Integration and Continuous Deployment (CI/CD) using GitHub Actions, enabling automated workflows for efficient and reliable deployment processes.
- **Security Checks**: Integrates security scanning tools such as Checkov and Gitleaks to ensure compliance with security best practices and safeguard against accidental exposure of sensitive data in code repositories.
- **Source Control Management**: Manages the project using Git and Github, providing a robust framework for tracking, reviewing, and maintaining changes systematically.
- **Public Cloud Utilization with AWS**: Leverages various AWS cloud services for a scalable and reliable cloud infrastructure, capable of adapting to changing demands and workloads.
- **Immutable Infrastructure Principles**: Emphasizes immutable infrastructure, where infrastructure updates are made by replacing components rather than modifying existing ones, thereby reducing inconsistencies and potential errors during deployments.


### Workflow Configuration
1. Staging branch is used for pushing configuration changes --> triggers "Workflow 1" on push
2. "Workflow 1" runs different checks and creates a terraform plan which is uploaded to S3
3. A PR is created at the end of the workflow for manual review of the plan
4. If the PR is confirmed and merged "Workflow 2" is triggered which applies the terraform plan

[Build Pipeline Diagram](https://final-project-diagrams.s3.eu-central-1.amazonaws.com/build-pipeline.jpg)

## Requirements

### Operational Requirements
For deploying Jira:

- **AWS Account**: An active account on Amazon Web Services. [Create an AWS Account](https://aws.amazon.com/)
- **Terraform**: Required for infrastructure provisioning. Tested with version 1.6.6. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- **Git**: Version control system to clone and manage the repository. [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Development Requirements
For working on the project:
- **kubectl**: The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **Helm**: An application package manager running atop Kubernetes. [Install Helm](https://helm.sh/docs/intro/install/)


## Configuration and Installation

1. [**Install Terraform**](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. [**Set up AWS authentication**](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
3. **Clone the Repository**: `git clone https://github.com/U23Rodin/u23-final-project.git`
4. **Set up the backend**:
	- **To use local backend:**
		1. `cd u23-final-project/terraform`
		2. Edit providers.tf & remove `backend "s3" {}` block or simply run `sed -i '/backend "s3"/,/^  }/d' providers.tf`
	- **To use remote backend (recommended):**
		1. `cd u23-final-project/terraform-backend`
		2. set up a globally unique name for the `s3_bucket_name` variable in terraform.tfvars
		3. 
			```
			terraform init
			terraform validate
			terraform apply
			```
1. **Set up terraform**
	1. `cd u23-final-project/terraform`
	2. **If** using remote backend --> run `sed -i 's/jira-project-state/[your-s3-bucket-name]/g' providers.tf` to set up the correct s3 bucket name
	3. 
		```
		terraform init
		terraform validate
		terraform plan
		terraform apply
		```
## Destruction and Clean-up

**Do not use `terraform destroy` directly!**

**Instead follow the below steps:**
1. `cd terraform/`
2. Run `terraform destroy -target=helm_release.jira` to destroy the Jira deployment first
3. Run `terraform destroy` to destroy the rest of the infrastructure
4. Delete the S3 bucket for state storage manually
5. `cd terraform-backend/`
6. Run `terraform destroy` to destroy the rest of the backend resources

## License

This project is licensed under the [MIT License](LICENSE).
