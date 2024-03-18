resource "aws_cloudwatch_log_group" "prom_log" {
  name = "${var.cluster_name}_prom_log"
}

resource "aws_prometheus_workspace" "prom" {
  alias = "grafana-demo"
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prom_log.arn}:*"
  }
}

resource "kubernetes_cluster_role" "otel-prometheus-role" {
  metadata {
    name = "otel-prometheus-role"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "pods", "services", "endpoints", "nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }

}


resource "kubernetes_cluster_role_binding" "otel-prometheus-role-binding" {
  metadata {
    name = "otel-prometheus-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "otel-prometheus-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "adot-collector"
    namespace = var.collectors_namespace
  }

  depends_on = [
    kubernetes_namespace.observability
  ]
}


resource "aws_iam_role_policy_attachment" "adot_amp" {
  role       = module.iam_assumable_role_adot_collector.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}
