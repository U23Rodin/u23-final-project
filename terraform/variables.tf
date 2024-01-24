variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "jira-terraform-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_availability_zones" {
  description = "List of availability zones for VPC"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "vpc_private_subnets" {
  description = "List of private subnets for VPC"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24"]
}

variable "vpc_public_subnets" {
  description = "List of public subnets for VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "vpc_database_subnets" {
  description = "List of database subnets for VPC"
  type        = list(string)
  default     = ["10.1.201.0/24", "10.1.202.0/24"]
}

variable "vpc_intra_subnets" {
  description = "List of intra subnets for VPC"
  type        = list(string)
  default     = ["10.1.151.0/24", "10.1.152.0/24"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "development"
  }
}

variable "database_sg_name" {
  description = "The name of the database SG"
  type        = string
  default     = "jira-database-sg"
}

variable "rds_name" {
  description = "The name of the rds instance"
  type        = string
  default     = "jira-database"
}

variable "database_engine" {
  description = "The engine of the database"
  type        = string
  default     = "postgres"
}

variable "database_engine_version" {
  description = "The engine version of the database"
  type        = string
  default     = "15"
}

variable "database_family" {
  description = "The family of the database"
  type        = string
  default     = "postgres15"
}

variable "database_major_engine_version" {
  description = "The engine major version of the database"
  type        = string
  default     = "15"
}

variable "database_instance_class" {
  description = "The instance class of the database"
  type        = string
  default     = "db.t3.micro"
}

variable "database_allocated_storage" {
  description = "The allocated storage of the database"
  type        = number
  default     = 20
}

variable "database_max_allocated_storage" {
  description = "The maximum allocated storage of the database"
  type        = number
  default     = 50
}

variable "database_name" {
  description = "The name of the database"
  type        = string
  default     = "jiradb"
}

variable "database_user" {
  description = "The username of the database user"
  type        = string
  default     = "jira"
}

variable "database_port" {
  description = "The port of the database"
  type        = number
  default     = 5432
}

variable "database_multi_az" {
  description = "If the database should be multi AZ"
  type        = bool
  default     = false
}

variable "database_backup_retention" {
  description = "The period of retention for the database"
  type        = number
  default     = 0
}

variable "efs_name" {
  description = "The name of the EFS"
  type        = string
  default     = "jira-efs"
}

variable "efs_creation_token" {
  description = "The creation token of the EFS"
  type        = string
  default     = "jira-efs"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "jira-cluster"
}

variable "eks_cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_endpoint_public_access" {
  description = "Whether the EKS should have public access endpoint"
  type        = bool
  default     = true
}

variable "eks_cluster_addons" {
  description = "The addons for the EKS cluster"
  type = map(object({
    most_recent = bool
  }))
  default = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-efs-csi-driver = {
      most_recent = true
    }
  }
}
/*
variable "eks_managed_node_group_name" {
  description = "The name of the managed group"
  type        = string
  default     = "eks-node-group"
}
*/
variable "eks_managed_node_group_min_size" {
  description = "The minimum number of nodes in the managed group"
  type        = number
  default     = 1
}

variable "eks_managed_node_group_max_size" {
  description = "The maximum number of nodes in the managed group"
  type        = number
  default     = 1
}

variable "eks_managed_node_group_desired_size" {
  description = "The desired number of nodes in the managed group"
  type        = number
  default     = 1
}

variable "eks_managed_node_group_instance_types" {
  description = "The instance type of the worker nodes"
  type        = list(string)
  default     = ["m5.large"]
}

variable "eks_managed_node_group_capacity_type" {
  description = "The capacity type of the worker node instance"
  type        = string
  default     = "SPOT"
}

variable "eks_block_device_name" {
  description = "The name of the block device attached to worker nodes"
  type        = string
  default     = "/dev/xvda"
}

variable "eks_block_device_volume_size" {
  description = "The size of the block device attached to worker nodes"
  type        = number
  default     = 100
}

variable "eks_block_device_type" {
  description = "The type of the block device attached to worker nodes"
  type        = string
  default     = "gp3"
}

variable "eks_block_device_iops" {
  description = "The iops of the block device attached to worker nodes"
  type        = number
  default     = 3000
}

variable "eks_block_device_throughput" {
  description = "The throughput of the block device attached to worker nodes"
  type        = number
  default     = 150
}

variable "eks_block_device_delete_on_termination" {
  description = "Whether the device should be deleted on node termination"
  type        = bool
  default     = true
}

variable "lb_controller_role_name" {
  description = "The name of the AWS LoadBalancer Controller role"
  type        = string
  default     = "AWSLoadBalancerControllerRole"
}

variable "lb_controller_role_tpl_filepath" {
  description = "Path to the Load Balancer role trust policy template file"
  type        = string
  default     = "load-balancer-role-trust-policy.json.tpl"
}

variable "lb_controller_policy_name" {
  description = "The name of the AWS LoadBalancer Controller policy"
  type        = string
  default     = "AWSLoadBalancerControllerIAMPolicy"
}

variable "lb_controller_policy_filepath" {
  description = "The path of the AWS LoadBalancer Controller policy json file"
  type        = string
  default     = "iam_policy.json"
}

variable "lb_controller_service_account_name" {
  description = "The name of the Kubernetes service account for the Load Balancer"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "lb_controller_service_account_namespace" {
  description = "The namespace of the Kubernetes service account for the Load Balancer"
  type        = string
  default     = "kube-system"
}

variable "kubernetes_db_secret_name" {
  description = "The name of the secret containing the credentials for the database"
  type        = string
  default     = "dbcreds"
}

variable "kubernetes_pv_name" {
  description = "The name of the persistent volume"
  type        = string
  default     = "efs-pv"
}

variable "kubernetes_pv_storage" {
  description = "The storage size of the PV"
  type        = string
  default     = "5Gi"
}

variable "kubernetes_pv_access_modes" {
  description = "The access mode of the PV"
  type        = list(string)
  default     = ["ReadWriteMany"]
}

variable "kubernetes_pv_volume_reclaim_policy" {
  description = "The volume reclaim policy of the PV"
  type        = string
  default     = "Retain"
}

variable "kubernetes_pv_storage_class_name" {
  description = "The storage class name of the PV"
  type        = string
  default     = "gp2"
}

variable "kubernetes_pv_driver" {
  description = "The driver type of the PV"
  type        = string
  default     = "efs.csi.aws.com"
}

variable "kubernetes_pvc_name" {
  description = "The name of the persistent volume claim"
  type        = string
  default     = "efs-claim"
}

variable "kubernetes_pvc_access_modes" {
  description = "The access mode of the PVC"
  type        = list(string)
  default     = ["ReadWriteMany"]
}

variable "kubernetes_pvc_storage" {
  description = "The storage size of the PVC"
  type        = string
  default     = "5Gi"
}

variable "helm_jira_name" {
  description = "The name of the helm release for Jira"
  type        = string
  default     = "jira-application"
}

variable "helm_jira_repository" {
  description = "The repository url for the jira helm chart"
  type        = string
  default     = "https://atlassian.github.io/data-center-helm-charts"
}

variable "helm_jira_chart" {
  description = "The name of the helm chart for Jira"
  type        = string
  default     = "jira"
}

variable "helm_jira_image_repository" {
  description = "The repository for the Jira docker image"
  type        = string
  default     = "atlassian/jira-software"
}

variable "helm_jira_image_tag" {
  description = "The tag of the Jira image"
  type        = string
  default     = "9.12.1"
}

variable "helm_jira_database_type" {
  description = "The database type for Jira"
  type        = string
  default     = "postgres72"
}

variable "helm_jira_database_driver" {
  description = "The database driver for Jira"
  type        = string
  default     = "org.postgresql.Driver"
}

variable "helm_jira_ingress_create" {
  description = "Whether to create an ingress for Jira"
  type        = bool
  default     = true
}

variable "helm_jira_ingress_className" {
  description = "The class name for the ingress"
  type        = string
  default     = "alb"
}

variable "helm_jira_ingress_nginx" {
  description = "NGINX specific setting for the ingress"
  type        = bool
  default     = false
}

variable "helm_jira_ingress_maxBodySize" {
  description = "The ingress max body size"
  type        = string
  default     = "250m"
}

variable "helm_jira_ingress_proxyConnectTimeout" {
  description = "The ingress proxy connection timeout"
  type        = number
  default     = 300
}

variable "helm_jira_ingress_proxyReadTimeout" {
  description = "The ingress proxy read timeout"
  type        = number
  default     = 300
}

variable "helm_jira_ingress_proxySendTimeout" {
  description = "The ingress proxy send timeout"
  type        = number
  default     = 300
}

variable "helm_jira_ingress_host" {
  description = "The dns host address for Jira"
  type        = string
  default     = ""
}

variable "helm_jira_ingress_path" {
  description = "The ingress path associated for Jira"
  type        = string
  default     = "/"
}

variable "helm_jira_ingress_annotation_scheme" {
  description = "Ingress annotation scheme"
  type        = string
  default     = "internet-facing"
}

variable "helm_jira_ingress_annotation_target-type" {
  description = "Ingress annotation target-type"
  type        = string
  default     = "ip"
}

variable "helm_jira_ingress_annotation_idle-timeout" {
  description = "Ingress annotation idle-timeout"
  type        = string
  default     = "idle_timeout.timeout_seconds=300"
}

variable "helm_jira_ingress_https" {
  description = "Whether the ingress uses https or not"
  type        = bool
  default     = false
}

variable "helm_jira_clustering" {
  description = "Whether jira is cluster or not"
  type        = bool
  default     = false
}

variable "helm_jira_sharedHome_create" {
  description = "Whether jira should create a shared home PVC"
  type        = bool
  default     = false
}

variable "helm_jira_resources_cpu" {
  description = "The minimum available free cpus requirement"
  type        = string
  default     = "1"
}

variable "helm_jira_resources_mem" {
  description = "The minimum available free memory requirement"
  type        = string
  default     = "4Gi"
}

variable "helm_jira_resources_jvm_maxHeap" {
  description = "The maximum heap allocation for JVM"
  type        = string
  default     = "2G"
}

variable "helm_jira_resources_jvm_minHeap" {
  description = "The minimum heap allocation for JVM"
  type        = string
  default     = "384m"
}

variable "helm_jira_resources_jvm_reservedCodeCache" {
  description = "The reserved code cache for JVM"
  type        = string
  default     = "512m"
}

variable "helm_jira_readinessProbe_enabled" {
  description = "Whether the Kubernetes pod readiness probe should be enabled"
  type        = bool
  default     = false
}

variable "kubernetes_jira_namespace" {
  description = "The name of the kubernetes jira application namespace"
  type        = string
  default     = "jira-app"
}
