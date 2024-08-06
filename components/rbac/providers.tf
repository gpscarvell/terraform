
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

# Kubernetes provider is needed to manage aws auth
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.cluster.token
}
