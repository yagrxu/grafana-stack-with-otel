locals {
  loki_role_name = "${var.cluster_name}-loki-role"
  loki_storage = <<EOT
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${var.account_id}:role/${var.cluster_name}-loki-role
loki:
  auth_enabled: false
  storage:
    bucketNames:
      chunks: ${var.cluster_name}-loki-yagr
      ruler: ${var.cluster_name}-loki-yagr
      admin: ${var.cluster_name}-loki-yagr
    type: s3
    s3:
      region: ${var.region}
  storage_config:
    aws:
      s3: s3://${var.region}/${var.cluster_name}-loki-yagr
      sse_encryption: true
EOT
}
      # s3: ${aws_s3_bucket.loki.bucket}
      # endpoint: s3.${var.region}.amazonaws.com
      # s3ForcePathStyle: false
      # insecure: false
#   secretAccessKey: ${data.external.env.result["secretAccessKey"]}
#   accessKeyId: ${data.external.env.result["accessKeyId"]}
# data "external" "env" {
#   program = ["sh", "${path.module}/env.sh"]
# }

resource "kubernetes_namespace" "logs" {
  metadata {
    name = var.log_namespace
  }
}

resource "aws_s3_bucket" "loki" {
  bucket        = "${var.cluster_name}-loki-yagr"
  force_destroy = true
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = var.log_namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  # version    = "5.10.0"

  values     = [local.loki_storage]
  depends_on = [kubernetes_namespace.logs]
}

resource "helm_release" "fluentbit" {
  name      = "fluentbit"
  namespace = var.log_namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "fluent-bit"

  set {
    name  = "loki.serviceName"
    value = "loki-write.default.svc.cluster.local"
  }
  depends_on = [kubernetes_namespace.logs]
}

module "iam_assumable_role_loki" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "5.37.1"
  create_role = true
  role_name   = local.loki_role_name
  # force_detach_policies         = true
  provider_url                  = var.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:logs:loki"]
}


resource "aws_iam_role_policy_attachment" "loki_s3" {
  role       = module.iam_assumable_role_loki.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "kubernetes_ingress_v1" "loki_read_ingress" {
  metadata {
    name      = "loki-read-ingress"
    namespace = "default"

    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internal"

      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "loki-read"

              port {
                number = 3100
              }
            }
          }
        }
      }
    }
  }
}

