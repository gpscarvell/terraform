# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v4.13.1"
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

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git//."
}

dependencies {
  paths = [
    find_in_parent_folders("_global/network/vpc"),
  ]
}

dependency "vpc" {
  config_path = find_in_parent_folders("_global/network/vpc")
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc_id
  use_name_prefix = true

  # allow outbound
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]
  egress_rules            = ["all-all"]

  tags = {
    # Define custom tags here as key = "value"
  }
}
