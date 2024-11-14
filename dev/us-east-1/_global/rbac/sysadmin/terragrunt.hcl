# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
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

  name = basename(get_terragrunt_dir())
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//rbac")
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
  cluster_id             = dependency.eks.outputs.cluster_name
  cluster_endpoint       = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(dependency.eks.outputs.cluster_certificate_authority_data)

  create_cluster_role = false
  cluster_role_name   = "cluster-admin"

  cluster_role_binding_name     = local.name
  cluster_role_binding_subjects = [
    {
      kind     = "User"
      name     = local.name # Name is case sensitive
      apiGroup = "rbac.authorization.k8s.io"
    }
  ]

  tags = {
    # Define custom tags here as key = "value"
  }
}
