terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.5.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }
}

module "rds" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-rds.git?ref=v5.1.1"

  identifier = var.identifier

  replicate_source_db = var.replicate_source_db

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family # DB parameter group
  major_engine_version = var.major_engine_version         # DB option group
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id
  iops                  = var.iops

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  port                   = var.port
  create_random_password = var.create_random_password
  random_password_length = var.random_password_length

  multi_az               = var.multi_az
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  create_db_subnet_group = var.create_db_subnet_group
  availability_zone      = var.availability_zone
  snapshot_identifier    = var.snapshot_identifier

  maintenance_window                     = var.maintenance_window
  backup_window                          = var.backup_window
  create_cloudwatch_log_group            = true
  enabled_cloudwatch_logs_exports        = var.enabled_cloudwatch_logs_exports
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  copy_tags_to_snapshot                  = true

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  create_monitoring_role                = var.create_monitoring_role
  monitoring_interval                   = var.monitoring_interval

  parameters = var.parameters

  apply_immediately = var.apply_immediately

  tags = var.tags
}

provider "postgresql" {
  host             = module.rds.db_instance_address
  port             = module.rds.db_instance_port
  username         = module.rds.db_instance_username
  password         = module.rds.db_instance_password
  sslmode          = "require"
  superuser        = false
  expected_version = "12.11"
}

# Create App User
resource "postgresql_role" "application_role" {
  count               = var.provision_db ? 1 : 0
  name                = var.app_user_name
  login               = true
  password            = var.app_user_password
  encrypted_password  = true
  create_database     = true
  create_role         = true
  roles               = ["rds_superuser"]

  depends_on = [
    module.rds,
  ]
}
# Create Database
resource "postgresql_database" "db" {
  count             = var.provision_db ? 1 : 0
  name              = var.app_db_name
  owner             = postgresql_role.application_role[0].name
  connection_limit  = -1
  allow_connections = true

  depends_on = [
    module.rds,
  ]
}

resource "postgresql_grant" "application_role_database" {
  count       = var.provision_db ? 1 : 0
  database    = postgresql_database.db[0].name
  role        = postgresql_role.application_role[0].name
  schema      = "public"
  object_type = "database"
  privileges  = ["CONNECT", "CREATE", "TEMPORARY"]

  depends_on = [
    module.rds,
  ]
}

resource "postgresql_grant" "application_role_schema" {
  count       = var.provision_db ? 1 : 0
  database    = postgresql_database.db[0].name
  role        = postgresql_role.application_role[0].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]

  depends_on = [
    module.rds,
  ]
}

resource "postgresql_grant" "application_role_table" {
  count       = var.provision_db ? 1 : 0
  database    = postgresql_database.db[0].name
  role        = postgresql_role.application_role[0].name
  schema      = "public"
  object_type = "table"
  privileges  = ["DELETE", "INSERT", "REFERENCES", "SELECT", "TRIGGER", "TRUNCATE", "UPDATE"]

  depends_on = [
    module.rds,
  ]
}
