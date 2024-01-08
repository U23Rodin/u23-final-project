resource "kubernetes_secret" "dbcreds" {
  metadata {
    name      = "dbcreds"
    namespace = "jira-application"
  }

  data = {
    "username" = "jira"
    "password" = "Def12345"
  }
}

resource "helm_release" "jira" {
  depends_on = [
    helm_release.jira_postgresql,
    helm_release.nginx_ingress
  ]
  name       = "jira-application"
  repository = "https://atlassian.github.io/data-center-helm-charts"
  chart      = "jira"
  namespace  = "jira-application"

  set {
    name  = "image.repository"
    value = "atlassian/jira-software"
  }

  set {
    name  = "image.tag"
    value = "9.12.1"
  }

  #set {
  #  name  = "database.type"
  #  value = "postgres72"
  #}

  #set {
  #  name  = "database.url"
  #  value = "jdbc:postgresql://jira-postgress-postgresql.postgress-database.svc.cluster.local:5432/jiradb"
  #}

  #set {
  #  name  = "database.driver"
  #  value = "org.postgresql.Driver"
  #}

  #set {
  #  name  = "database.credentials.secretName"
  #  value = "dbcreds"
  #}

  #set {
  #  name  = "database.credentials.usernameSecretKey"
  #  value = "username"
  #}

  #set {
  #  name  = "database.credentials.passwordSecretKey"
  #  value = "password"
  #}

  set {
    name  = "ingress.create"
    value = "true"
  }

  set {
    name  = "ingress.className"
    value = "nginx"
  }

  set {
    name  = "ingress.nginx"
    value = "true"
  }

  set {
    name  = "ingress.host"
    value = "jira.localtest.me"
  }

  set {
    name  = "ingress.path"
    value = "/"
  }

  set {
    name  = "ingress.https"
    value = "false"
  }

  set {
    name  = "volumes.sharedHome.persistentVolumeClaim.create"
    value = "false"
  }

  set {
    name  = "volumes.sharedHome.customVolume.persistentVolumeClaim.claimName"
    value = "jira-nfs-pvc"
  }

  set {
    name  = "jira.clustering.enabled"
    value = "false"
  }

}

