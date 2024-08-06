


data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_name

  depends_on = [
  module.eks-cluster,
  ]

}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_name
}

# Kubernetes provider is needed to manage aws auth
provider "kubernetes" {
  host                   = module.eks-cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = module.eks-cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


# Helm provider is needed to install helm charts
provider "helm" {
  kubernetes {
    host                   = module.eks-cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


