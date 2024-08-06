locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env_name = local.environment_vars.locals.environment.name
  account  = local.account_vars.locals.account
  prefix   = local.account_vars.locals.company.prefix
  dns_zone = local.account_vars.locals.dns_zone
  region   = local.region_vars.locals.region


  cluster_name    = local.account.name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//msk")
}

dependencies {
  paths = [
    find_in_parent_folders("_global/network/vpc"),
  ]
}

dependency "vpc" {
  config_path = find_in_parent_folders("_global/network/vpc")
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_name        = local.cluster_name  
  vpc_id              = dependency.vpc.outputs.vpc_id
  client_subnets   = dependency.vpc.outputs.private_subnets
  instance_type       = "kafka.m5.large"
  kafka_version       = "3.4.0"
  number_of_nodes     = 3
}
