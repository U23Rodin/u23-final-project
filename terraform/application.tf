# Resource for creating a Kubernetes secret to store database credentials
resource "kubernetes_secret" "dbcreds" {
  provider = kubernetes.post-eks

  # Metadata for the secret, including the name
  metadata {
    name      = var.kubernetes_db_secret_name
    namespace = var.kubernetes_jira_namespace
  }

  # Data for the secret, pulling credentials from local variables
  data = {
    "username" = "${local.db_credentials["username"]}"
    "password" = "${local.db_credentials["password"]}"
  }
}

# Resource to create a Kubernetes Persistent Volume for EFS
resource "kubernetes_persistent_volume" "efs_pv" {
  provider = kubernetes.post-eks
  depends_on = [
    module.eks,
    module.efs
  ]

  # Metadata for the persistent volume
  metadata {
    name = var.kubernetes_pv_name
  }

  # Specification of the persistent volume, including capacity and access modes
  spec {
    capacity = {
      storage = var.kubernetes_pv_storage
    }

    access_modes                     = var.kubernetes_pv_access_modes
    persistent_volume_reclaim_policy = var.kubernetes_pv_volume_reclaim_policy
    storage_class_name               = var.kubernetes_pv_storage_class_name

    # Persistent volume source configuration for EFS using CSI driver
    persistent_volume_source {
      csi {
        driver        = var.kubernetes_pv_driver
        volume_handle = module.efs.id
      }
    }
  }
}

# Resource to create a Kubernetes Persistent Volume Claim for EFS
resource "kubernetes_persistent_volume_claim" "efs_claim" {
  provider   = kubernetes.post-eks
  depends_on = [kubernetes_persistent_volume.efs_pv]

  # Metadata for the persistent volume claim
  metadata {
    name      = var.kubernetes_pvc_name
    namespace = var.kubernetes_jira_namespace
  }

  # Specification of the persistent volume claim
  spec {
    access_modes = var.kubernetes_pvc_access_modes
    resources {
      requests = {
        storage = var.kubernetes_pvc_storage
      }
    }
    volume_name = var.kubernetes_pv_name
  }
}

# Helm release resource for deploying Jira
resource "helm_release" "jira" {
  depends_on = [
    module.eks,
    module.efs,
    module.rds,
    helm_release.aws_lb_controller
  ]

  name       = var.helm_jira_name
  namespace  = var.kubernetes_jira_namespace
  repository = var.helm_jira_repository
  chart      = var.helm_jira_chart

  # Setting various values for the Jira Helm chart, including image, database configuration, ingress settings, and resource requests
  set {
    name  = "image.repository"
    value = var.helm_jira_image_repository
  }

  set {
    name  = "image.tag"
    value = var.helm_jira_image_tag
  }

  # Database configuration for Jira
  set {
    name  = "database.type"
    value = var.helm_jira_database_type
  }

  set {
    name  = "database.url"
    value = "jdbc:postgresql://${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
  }

  set {
    name  = "database.driver"
    value = var.helm_jira_database_driver
  }

  set {
    name  = "database.credentials.secretName"
    value = var.kubernetes_db_secret_name
  }

  set {
    name  = "database.credentials.usernameSecretKey"
    value = "username"
  }

  set {
    name  = "database.credentials.passwordSecretKey"
    value = "password"
  }

  # Ingress configuration for Jira
  set {
    name  = "ingress.create"
    value = var.helm_jira_ingress_create
  }

  # Additional ingress settings such as class, annotations, and timeouts
  set {
    name  = "ingress.className"
    value = var.helm_jira_ingress_className
  }

  set {
    name  = "ingress.nginx"
    value = var.helm_jira_ingress_nginx
  }

  set {
    name  = "ingress.maxBodySize"
    value = var.helm_jira_ingress_maxBodySize
  }

  set {
    name  = "ingress.proxyConnectTimeout"
    value = var.helm_jira_ingress_proxyConnectTimeout
  }

  set {
    name  = "ingress.proxyReadTimeout"
    value = var.helm_jira_ingress_proxyReadTimeout
  }

  set {
    name  = "ingress.proxySendTimeout"
    value = var.helm_jira_ingress_proxySendTimeout
  }

  set {
    name  = "ingress.host"
    value = var.helm_jira_ingress_host
  }

  set {
    name  = "ingress.path"
    value = var.helm_jira_ingress_path
  }

  # Important annotations for the ingress which allow the controller to properly manage it
  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = var.helm_jira_ingress_className
  }

  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = var.helm_jira_ingress_annotation_scheme
  }

  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = var.helm_jira_ingress_annotation_target-type
  }

  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-attributes"
    value = var.helm_jira_ingress_annotation_idle-timeout
  }

  set {
    name  = "ingress.https"
    value = var.helm_jira_ingress_https
  }

  # Clustering settings for Jira
  set {
    name  = "jira.clustering.enabled"
    value = var.helm_jira_clustering
  }

  # Configuration for shared home volume using the EFS PVC
  set {
    name  = "volumes.sharedHome.persistentVolumeClaim.create"
    value = var.helm_jira_sharedHome_create
  }

  set {
    name  = "volumes.sharedHome.customVolume.persistentVolumeClaim.claimName"
    value = var.kubernetes_pvc_name
  }

  # Resource requests for the Jira container and JVM settings
  set {
    name  = "jira.resources.container.requests.cpu"
    value = var.helm_jira_resources_cpu
  }

  set {
    name  = "jira.resources.container.requests.memory"
    value = var.helm_jira_resources_mem
  }

  set {
    name  = "jira.resources.jvm.maxHeap"
    value = var.helm_jira_resources_jvm_maxHeap
  }

  set {
    name  = "jira.resources.jvm.minHeap"
    value = var.helm_jira_resources_jvm_minHeap
  }

  set {
    name  = "jira.resources.jvm.reservedCodeCache"
    value = var.helm_jira_resources_jvm_reservedCodeCache
  }

  # Configuration for Jira readiness probe (disabled on initial startup)
  set {
    name  = "jira.readinessProbe.enabled"
    value = var.helm_jira_readinessProbe_enabled
  }
}

