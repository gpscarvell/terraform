# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source  = "git::git@github.com:terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.10.2"
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
  zone       = local.account_vars.locals.dns_zone
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    find_in_parent_folders("${local.account.aws_profile}/${local.region.aws_region}/_global/network/vpc"),
  ]
}

dependency "vpc" {
  config_path = find_in_parent_folders("${local.account.aws_profile}/${local.region.aws_region}/_global/network/vpc")
}

inputs = {
  zones = {
    "private.${local.zone}" = {
      domain_name = local.zone
      comment     = "Private subdomain for ${local.account.name}"

      vpc = [
        {
          vpc_id     = dependency.vpc.outputs.vpc_id
          vpc_region = local.region.aws_region
        },
        {
          vpc_id     = "vpc-0ac4a6f5455e24838"
          vpc_region = "us-west-2"
        },
      ]

      tags = {
        env = local.account.name
      }
    }
  }
}
