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

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//rds")
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    find_in_parent_folders("_global/network/vpc"),
    find_in_parent_folders("_global/network/sg/rds"),
  ]
}

dependency "vpc" {
  config_path = find_in_parent_folders("_global/network/vpc")
}

dependency "sg" {
  config_path = find_in_parent_folders("_global/network/sg/rds")
}

inputs = {
  identifier = "${local.account.name}-${local.env_name}"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "13.7"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.t3.medium"

  allocated_storage     = 800
  max_allocated_storage = 1000
  storage_encrypted     = true
  #iops                  = 2500
  storage_type          = "gp2" #io1

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  #username               = replace("${local.account.name}${local.env_name}", "-", "")
  username               =  "admin"
#  password               = local.secrets.rds.dev.admin_password
  create_random_password = true

  port = 5432

  provision_db = true

  app_user_password = local.secrets.rds.dev.app_user_password
  app_user_password = ""

  app_db_name   = "or_f2p_${local.env_name}"

  multi_az               = false
  subnet_ids             = dependency.vpc.outputs.private_subnets
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  create_db_subnet_group = true
  availability_zone      = dependency.vpc.outputs.azs[0]
  snapshot_identifier    = "snapshot-kube-build-0823-1"

  maintenance_window              = "Sun:00:00-Sun:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql","upgrade"]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled = false

  tags = {
    "service" = "db"
    "Name"    = "${local.account.name}-${local.env_name}"
  }

  parameters = [
    {
      apply_method = "immediate"
      name         = "log_min_duration_statement"
      value        = "5000"
    },
    {
      apply_method = "immediate"
      name         = "pgaudit.role"
      value        = "rds_pgaudit"
    },
    {
      apply_method = "pending-reboot"
      name         = "shared_preload_libraries"
      value        = "pgaudit,pg_stat_statements"
    }

  ]

}
