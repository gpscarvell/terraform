# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v5.8.0"
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
  alias      = local.account_vars.locals.alias
  account    = local.account_vars.locals.account
  prefix     = local.account_vars.locals.company.prefix
  region     = local.region_vars.locals.region

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks"
}

dependencies {
  paths = [
    find_in_parent_folders("_global/eks"),
    find_in_parent_folders("policy"),
  ]
}

dependency "eks" {
  config_path = find_in_parent_folders("_global/eks")
}

dependency "policy" {
  config_path = find_in_parent_folders("policy")
}

inputs = {
  role_name = "${local.account.name}-${local.env_name}-api"

  oidc_providers = {
    one = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["${local.alias}-${local.env_name}:boomi"]
    }
  }

  role_policy_arns = {
    api = dependency.policy.outputs.arn
  }

  tags = {
    # Define custom tags here as key = "value"
  }
}
