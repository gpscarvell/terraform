# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source  = "git::git@github.com:terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.9.0"
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  account    = local.account_vars.locals.account
  prefix     = local.account_vars.locals.company.prefix
  region     = local.region_vars.locals.region
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  zones = {
    "acme.com" = {
      comment = "Subdomain for CA"
      tags = {
        env = "dev"
      }
    }
  }
}
