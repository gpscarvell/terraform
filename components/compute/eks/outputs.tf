output "cluster_version" {
  value = module.eks-cluster.cluster_version
}

output "cluster_name" {
  value = module.eks-cluster.cluster_name
}

output "oidc_provider" {
  value = module.eks-cluster.oidc_provider
}

output "oidc_provider_arn" {
  value = module.eks-cluster.oidc_provider_arn
}

output "cluster_endpoint" {
  value = module.eks-cluster.cluster_endpoint
}

output "cluster_primary_security_group_id" {
  value = module.eks-cluster.cluster_primary_security_group_id
}

output "node_security_group_id" {
  value = module.eks-cluster.node_security_group_id
}

output "cluster_certificate_authority_data" {
  value     = module.eks-cluster.cluster_certificate_authority_data
  sensitive = true
}
