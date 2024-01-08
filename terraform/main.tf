provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "postgress_database" {
  metadata {
    name = "postgress-database"
  }
}

resource "helm_release" "jira_postgresql" {
  name       = "jira-postgress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "12.12.10"

  namespace = "postgress-database"

  set {
    name  = "global.postgresql.auth.database"
    value = "jiradb"
  }

  set {
    name  = "global.postgresql.auth.username"
    value = "jira"
  }

  set {
    name  = "global.postgresql.auth.password"
    value = "Def12345"
  }
}

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace = "ingress-nginx"

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
}

resource "kubernetes_namespace" "jira_application" {
  metadata {
    name = "jira-application"
  }
}

resource "kubernetes_manifest" "jira_nfs_pv" {
  manifest = yamldecode(file("${path.module}/nfs-pv.yaml"))
}

resource "kubernetes_manifest" "jira_nfs_pvc" {
  manifest = yamldecode(file("${path.module}/nfs-pvc.yaml"))
}

