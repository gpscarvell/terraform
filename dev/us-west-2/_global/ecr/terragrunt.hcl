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

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${get_parent_terragrunt_dir()}/components//ecr"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  ecr_repos = {
     arbonne = {
      name = "arbonne"
    }
  }

  create_lifecycle_policy  = false
  create_repository_policy = true

  repository_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "Allow pull",
            "Effect": "Allow",
            "Principal" : {
                "AWS": [
                    "8122xxxxx",
                    "516xxxxxx",
                    "023xxxxxx",
                    "304xxxxxx",
                    "arn:aws:iam::xxxx:user/gscarvell",
                    "arn:aws:iam::xxxxxx:root",
                    "arn:aws:iam::xxxxxx:root",
                    "arn:aws:iam::xxxxxx:root"
                ]
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF

  tags = {
    # Define custom tags here as key = "value"
  }
}
