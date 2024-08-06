# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//secret")
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
  alias      = local.account_vars.locals.alias

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
  name        = "app-secrets"
  namespaces  = ["${local.alias}-${local.env_name}"]
  secret_data = local.app_secrets

  cluster_id             = dependency.eks.outputs.cluster_name
  cluster_endpoint       = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(dependency.eks.outputs.cluster_certificate_authority_data)

  tags = {
    # Define custom tags here as key = "value"
  }
}
