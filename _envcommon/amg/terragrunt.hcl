# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v1.4.0"
}

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
  region   = local.region_vars.locals.region

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-managed-service-grafana.git//."
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name                      = "${local.prefix}-${local.account.name}-amg"
  associate_license         = false
  description               = "AWS Managed Grafana service for ${local.account.name}"
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["PROMETHEUS"]
  notification_destinations = []
  stack_set_name            = "${local.prefix}-${local.account.name}-amg"

  create_iam_role                = true
  iam_role_name                  = "${local.prefix}-${local.account.name}-amg"
  use_iam_role_name_prefix       = true
  iam_role_description           = "IAM role for AMG"
  iam_role_path                  = "/grafana/"
  iam_role_force_detach_policies = true
  iam_role_max_session_duration  = 7200
  iam_role_tags                  = { }

  # AWS SSO groups created manually
  # Terraform AWS provider does not support AWS SSO yet:
  # Ref: https://github.com/aws/aws-sdk/issues/25
  # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/18812

  # Role association does not currently work:
  # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/24166
  # Groups need to be assigned manually


  tags = {
    # Define custom tags here as key = "value"
  }
}
