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
    #find_in_parent_folders("secret"),
  ]
}

dependency "eks" {
  config_path = find_in_parent_folders("_global/eks")
}

inputs = {
  cluster_id             = dependency.eks.outputs.cluster_name
  cluster_endpoint       = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(dependency.eks.outputs.cluster_certificate_authority_data)

  role_name      = local.name
  role_namespace = "${local.account_vars.locals.alias}-${local.env_name}"
  role_rules = [
    {
      api_groups = [""]
      verbs      = ["list"]
      resources  = ["secrets", "pods", "configmaps", "deployments", "jobs", "services", "namespace", "logs"]
    },

    {
      api_groups = [""]
      verbs      = ["get", "watch", "list"]
      resources  = ["pods", "pods/log", "deployments", "jobs", "services"]
    },
    {
      api_groups = [""]
      verbs      = ["delete", "watch", "patch", "exec"]
      resources  = ["pods"]
    },
    {
      api_groups = ["extensions"]
      verbs      = ["get", "list", "watch", "patch"]
      resources  = ["*"]
    },
    {
      api_groups = ["apps"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
      resources  = ["*"]
    },
    {
      api_groups = ["networking.k8s.io"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
      resources  = ["*"]
    }
  ]

  # This role binding allows "jane" to read pods in the "default" namespace.
  # You need to already have a Role named "pod-reader" in that namespace.
  role_binding_name = local.name
  role_binding_subjects = [
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
