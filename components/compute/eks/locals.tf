locals {
  oidc_url = replace(module.eks-cluster.cluster_oidc_issuer_url, "https://", "")

  k8s_cluster_autoscaler_account_namespace = "kube-system"
  k8s_cluster_autoscaler_account_name      = "cluster-autoscaler"
}
