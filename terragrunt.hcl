# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
#
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name   = local.account_vars.locals.account.name
  jurisdiction   = local.account_vars.locals.jurisdiction
  account_id     = local.account_vars.locals.account.aws_account_id
  company_prefix = local.account_vars.locals.company.prefix
  aws_profile    = local.account_vars.locals.account.aws_profile
  aws_region     = local.region_vars.locals.region.aws_region
  state_region   = local.region_vars.locals.region.state_region

  environment = local.environment_vars.locals.environment.name
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.aws_profile}"
  

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  skip_metadata_api_check = true

  default_tags {
    tags = {
      "account"     = format("%s", "${local.account_name}"),
      "Terraform"   = "true",
      # billing tags
      "jurisdiction" = format("%s", "${local.jurisdiction}"),
      "environment"  = format("%s", "${local.environment}"),
    }
  }
}
EOF
}

# Generate an AWS provider block in us-east-1 - required for certificates for cloudfront
generate "provider2" {
  path      = "provider2.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "${local.aws_profile}"
  # version = ">=2.23.0, < 4.480.0"
  #version = ">=2.23.0, < 3.0.0



  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  skip_metadata_api_check = true

  default_tags {
    tags = {
      "Account"     = format("%s", "${local.account_name}"),
      "Environment" = format("%s", "${local.environment}"),
      "Terraform"   = "true"
    }
  }
}
EOF
}

generate "inputs" {
  path      = "inputs.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "environment" {
  type = map(string)
}

variable "account" {
  type = map(string)
}

variable "region" {
  type = map(string)
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", "")}${local.company_prefix}-tf-state-${local.account_name}-${local.state_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
    profile        = local.aws_profile

    skip_bucket_accesslogging = true
    skip_metadata_api_check   = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)

# Version constraints
terraform_version_constraint  = "= 1.3.3"
terragrunt_version_constraint = "= 0.55.2"

# For the run-all commands to skip the root level terragrunt.hcl
# The root level terragrunt.hcl file is solely used to DRY up Terraform configuration
# by being included in the other terragrunt.hcl files.
skip = true
