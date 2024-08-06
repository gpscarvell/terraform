# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v19.10.0"
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env_name   = local.environment_vars.locals.environment.name
  account    = local.account_vars.locals.account
  prefix     = local.account_vars.locals.company.prefix
  region     = local.region_vars.locals.region

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-eks.git//modules/eks-managed-node-group"
}

dependencies {
  paths = [
    find_in_parent_folders("_global/eks"),
    find_in_parent_folders("_global/network/vpc"),
    find_in_parent_folders("_global/network/sg/public"),
    find_in_parent_folders("_global/network/sg/eks"),
    find_in_parent_folders("_global/iam/role/eks-managed-node")
  ]
}

dependency "eks" {
  config_path = find_in_parent_folders("_global/eks")
}

dependency "vpc" {
  config_path = find_in_parent_folders("_global/network/vpc")
}

dependency "public_sg" {
  config_path = find_in_parent_folders("_global/network/sg/public")
}

dependency "eks_sg" {
  config_path = find_in_parent_folders("_global/network/sg/eks")
}

dependency "iam" {
  config_path = find_in_parent_folders("_global/iam/role/eks-managed-node")
}

inputs = {
  use_name_prefix = true

  ami_type            = "AL2_x86_64"
  ami_release_version = "1.24.10-20230304"

  name = "${local.account_vars.locals.alias}-${local.env_name}"

  cluster_name    = dependency.eks.outputs.cluster_name
  cluster_version = dependency.eks.outputs.cluster_version

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = [dependency.vpc.outputs.private_subnets[0]]

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  cluster_primary_security_group_id = dependency.eks.outputs.cluster_primary_security_group_id
  cluster_security_group_id         = dependency.eks.outputs.node_security_group_id

  vpc_security_group_ids = [
    dependency.public_sg.outputs.security_group_id,
    dependency.eks_sg.outputs.security_group_id
  ]

  iam_role_attach_cni_policy = true

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 50
        volume_type           = "gp3"
        delete_on_termination = true
      }
    }
  }

  create_iam_role = false
  iam_role_arn    = dependency.iam.outputs.iam_role_arn

  create_security_group = false

  labels = {
    Environment = "${local.account_vars.locals.alias}-${local.env_name}"
  }

  taints = [
    {
      key    = "dedicated"
      value  = "${local.account_vars.locals.alias}-${local.env_name}"
      effect = "NO_SCHEDULE"
    }
  ]

  update_config = {
    max_unavailable_percentage = 100 # or set `max_unavailable`
  }

  launch_template_tags = {
    "account"      = local.account.name
    "jurisdiction" = local.account_vars.locals.jurisdiction
    "environment"  = local.env_name
    "Terraform"    = true
  }
}
