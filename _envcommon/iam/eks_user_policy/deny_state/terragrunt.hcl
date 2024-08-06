# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v5.9.2"
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

  company_prefix = local.account_vars.locals.company.prefix

  name = basename(get_terragrunt_dir())

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy"
}

inputs = {
  name        = "deny_terraform_state_access"
  path        = "/"
  description = "Deny access to terraform state bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Deny",
      "Resource":  "arn:aws:s3:::${get_env("TG_BUCKET_PREFIX", "")}${local.prefix}-tf-state-${local.account.name}*"
    }
  ]
}
EOF


  tags = {
    # Define custom tags here as key = "value"
  }
}
