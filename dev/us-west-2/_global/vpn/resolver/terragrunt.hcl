# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//route53/resolver")
}

# Include all settings from the root terragrunt.hcl file
include {
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
  env_name = local.environment_vars.locals.environment.name
  account  = local.account_vars.locals.account
  prefix   = local.account_vars.locals.company.prefix
  region   = local.region_vars.locals.region
}

dependencies {
  paths = [
    find_in_parent_folders("network/sg/vpn"),
  ]
}

dependency "sg" {
  config_path = find_in_parent_folders("network/sg/vpn")
}

inputs = {
  direction          = "INBOUND"
  name               = "main"
  security_group_ids = [dependency.sg.outputs.security_group_id]

  ip_addresses = [
    {
      subnet_id = "subnet-025919c0bee929146"
    },
    {
      subnet_id = "subnet-054d9ecda832ba777"
    },
  ]

  tags = {
    # Define custom tags here as key = "value"
  }
}
