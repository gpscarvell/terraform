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
  zone_name  = local.account_vars.locals.dns_zone

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy"
}

dependencies {
  paths = [
    find_in_parent_folders("_global/eks"),
  ]
}

dependency "eks" {
  config_path = find_in_parent_folders("_global/eks")
}

inputs = {
  name        = "${local.account.name}-${local.env_name}-api"
  path        = "/"
  description = "Allow access to AWS resources"

  tags = {
    # Define custom tags here as key = "value"
  }
}
