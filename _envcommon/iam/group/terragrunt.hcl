locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  account = local.account_vars.locals.account
  prefix  = local.account_vars.locals.company.prefix

  name = basename(get_terragrunt_dir())
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//iam/group")
}

# dependencies {
#   paths = [
#     find_in_parent_folders("policy/change_password")
#   ]
# }

# dependency "change_password_policy" {
#   config_path = find_in_parent_folders("policy/change_password")
# }

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  name = local.name

  assumable_roles = [
    "arn:aws:iam::916926106625:role/${local.name}", # dev
    "arn:aws:iam::304674821297:role/${local.name}", # qa
    "arn:aws:iam::516357051515:role/${local.name}", # staging
    "arn:aws:iam::023932916467:role/${local.name}", # production
  ]

  # custom_group_policy_arns = [
  #   dependency.change_password_policy.outputs.arn
  # ]

  tags = {
    # Define custom tags here as key = "value"
  }
}
