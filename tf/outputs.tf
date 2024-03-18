output "security_group_ids" {
  value = [module.eks.node_security_group_id, module.eks.cluster_primary_security_group_id]
}

output "prometheus_endpoint" {
  value = module.observability.prometheus_endpoint
}
