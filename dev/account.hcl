# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account = {
    name           = "jbondo"
    aws_account_id = "818396592856"
    aws_profile    = "dev"
  }
  company = {
    prefix = "dev"
  }
  jurisdiction = "or"
  alias        = "or"
  dns_zone     = "gscarvell.com"
}

#iam_role = "arn:aws:iam::${local.account.aws_account_id}:role/OrganizationAccountAccessRole"
