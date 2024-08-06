# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.base_source_url}?ref=v4.2.0"
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
  zone_name  = local.account_vars.locals.dns_zone

  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-acm.git//."
}

dependencies {
  paths = [
    find_in_parent_folders("_global/dns/main"),
  ]
}

dependency "zone" {
  config_path = find_in_parent_folders("_global/dns/main")
}

inputs = {
  domain_name               = "${local.env_name}.${local.zone_name}"
  subject_alternative_names = [
    "*.${local.env_name}.${local.zone_name}"
  ]

  zone_id = dependency.zone.outputs.route53_zone_zone_id[local.zone_name]

  tags = {
    # Define custom tags here as key = "value"
  }
}
