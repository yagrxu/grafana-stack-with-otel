resource "kubernetes_service_account" "adot-collector" {
  depends_on = [
    kubernetes_namespace.observability
  ]

  metadata {
    name      = "adot-collector"
    namespace = var.collectors_namespace
    labels = {
      "app.kubernetes.io/instance" = "adot-collector"
      "app.kubernetes.io/name"     = "adot-collector"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_adot_collector.iam_role_arn
    }
  }
}

resource "kubernetes_secret" "adot-collector" {
  depends_on = [
    kubernetes_namespace.observability
  ]
  metadata {
    name      = "serviceaccount-token-secret"
    namespace = var.collectors_namespace
    annotations = {
      "kubernetes.io/service-account.namespace" = var.collectors_namespace
      "kubernetes.io/service-account.name"      = kubernetes_service_account.adot-collector.metadata.0.name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
