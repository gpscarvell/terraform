# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v5.0.0"
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load network-level variables
  network_vars = read_terragrunt_config(find_in_parent_folders("network.hcl"))

  # Extract out common variables for reuse
  env_name   = local.environment_vars.locals.environment.name
  network    = local.network_vars.locals.network
  account    = local.account_vars.locals.account
  prefix     = local.account_vars.locals.company.prefix
  region     = local.region_vars.locals.region

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc"

}

# dependencies {
#   paths = [
#     find_in_parent_folders("global/eks"),
#     find_in_parent_folders("global/network/vpc"),
#     find_in_parent_folders("global/network/sg/public"),
#     find_in_parent_folders("global/network/sg/eks"),
#     find_in_parent_folders("global/iam/role/eks-managed-node")
#   ]
# }

# dependency "eks" {
#   config_path = find_in_parent_folders("global/eks")
# }

# dependency "vpc" {
#   config_path = find_in_parent_folders("global/network/vpc")
# }

# dependency "public_sg" {
#   config_path = find_in_parent_folders("global/network/sg/public")
# }

# dependency "eks_sg" {
#   config_path = find_in_parent_folders("global/network/sg/eks")
# }

# dependency "iam" {
#   config_path = find_in_parent_folders("global/iam/role/eks-managed-node")
# }

inputs = {
  name = "${local.account.name}-vpc-${local.region.alias}"

  cidr = "${local.network.cidr_prefix}.0.0/16"

  azs = [
    "${local.region.aws_region}a",
    "${local.region.aws_region}b",
    "${local.region.aws_region}c"
  ]

  private_subnets = [
    "${local.network.cidr_prefix}.64.0/18",
    "${local.network.cidr_prefix}.128.0/18",
    "${local.network.cidr_prefix}.192.0/18"
  ]

  public_subnets  = [
    "${local.network.cidr_prefix}.0.0/20",
    "${local.network.cidr_prefix}.16.0/20",
    "${local.network.cidr_prefix}.32.0/20"
  ]

  database_subnets = []

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  create_database_subnet_group       = false
  create_database_subnet_route_table = false

  enable_s3_endpoint = false

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true

  tags = {
    # Define custom tags here as key = "value"
  }
}
