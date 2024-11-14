terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.3.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }
  }
}

module "eks-cluster" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-eks.git?ref=v19.10.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_cluster_security_group        = true
  cluster_security_group_name          = var.cluster_security_group_name
  cluster_security_group_description   = "EKS cluster security group."
  create_node_security_group           = true
  node_security_group_name             = var.node_security_group_name
  node_security_group_description      = "Security group for all nodes in the cluster."
  node_security_group_tags             = var.node_security_group_tags
  node_security_group_additional_rules = var.node_security_group_additional_rules

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_addons            = var.cluster_addons
  cluster_enabled_log_types = var.cluster_enabled_log_types


  #ConfigMap aws-auth
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_accounts         = var.aws_auth_accounts
  aws_auth_users            = var.aws_auth_users
  aws_auth_roles            = var.aws_auth_roles

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups

  self_managed_node_groups         = var.self_managed_node_groups
  self_managed_node_group_defaults = var.self_managed_node_group_defaults

  create_cloudwatch_log_group = var.create_cloudwatch_log_group

  create_iam_role  = true
  iam_role_name    = var.iam_role_name
  prefix_separator = ""

  enable_irsa                = true
  cluster_identity_providers = var.cluster_identity_providers
  # cluster_security_group_ids = [aws_security_group.cluster.id]

  tags = var.tags
}

/*
resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region us-east-2 update-kubeconfig --name ${var.cluster_name}"
    }
}

*/