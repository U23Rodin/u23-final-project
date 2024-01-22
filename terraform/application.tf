resource "kubernetes_secret" "dbcreds" {
  provider = kubernetes.post-eks

  metadata {
    name = var.kubernetes_db_secret_name
  }

  data = {
    "username" = "${local.db_credentials["username"]}"
    "password" = "${local.db_credentials["password"]}"
  }
}

resource "kubernetes_persistent_volume" "efs_pv" {
  provider = kubernetes.post-eks
  depends_on = [
    module.eks,
    module.efs
  ]

  metadata {
    name = var.kubernetes_pv_name
  }

  spec {
    capacity = {
      storage = var.kubernetes_pv_storage
    }

    access_modes                     = var.kubernetes_pv_access_modes
    persistent_volume_reclaim_policy = var.kubernetes_pv_volume_reclaim_policy
    storage_class_name               = var.kubernetes_pv_storage_class_name

    persistent_volume_source {
      csi {
        driver        = var.kubernetes_pv_driver
        volume_handle = module.efs.id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "efs_claim" {
  provider   = kubernetes.post-eks
  depends_on = [kubernetes_persistent_volume.efs_pv]

  metadata {
    name = var.kubernetes_pvc_name
  }

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

resource "helm_release" "jira" {
  depends_on = [
    module.eks,
    module.efs,
    module.rds,
    helm_release.aws_lb_controller
  ]

  name       = var.helm_jira_name
  repository = var.helm_jira_repository
  chart      = var.helm_jira_chart

  set {
    name  = "image.repository"
    value = var.helm_jira_image_repository
  }

  set {
    name  = "image.tag"
    value = var.helm_jira_image_tag
  }

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

  set {
    name  = "ingress.create"
    value = var.helm_jira_ingress_create
  }

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

  set {
    name  = "jira.clustering.enabled"
    value = var.helm_jira_clustering
  }

  set {
    name  = "volumes.sharedHome.persistentVolumeClaim.create"
    value = var.helm_jira_sharedHome_create
  }

  set {
    name  = "volumes.sharedHome.customVolume.persistentVolumeClaim.claimName"
    value = var.kubernetes_pvc_name
  }

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

  set {
    name  = "jira.readinessProbe.enabled"
    value = var.helm_jira_readinessProbe_enabled
  }
}

