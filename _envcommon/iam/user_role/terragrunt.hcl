locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  account = local.account_vars.locals.account
  prefix  = local.account_vars.locals.company.prefix

  name = basename(get_terragrunt_dir())

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v5.9.2"
}

dependencies {
  paths = [
    find_in_parent_folders("policy/${local.name}"),
    find_in_parent_folders("policy/deny_state")
  ]
}

dependency "policy" {
  config_path = find_in_parent_folders("policy/${local.name}")
}

dependency "deny_state_policy" {
  config_path = find_in_parent_folders("policy/deny_state")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  create_role = true

  trusted_role_arns = [
    "arn:aws:iam::916926106625:root", # management account
  ]

  create_role = true

  role_name         = local.name
  role_requires_mfa = false

  custom_role_policy_arns = [
    dependency.policy.outputs.arn,
    dependency.deny_state_policy.outputs.arn
  ]

  tags = {
    # Define custom tags here as key = "value"
  }
}
