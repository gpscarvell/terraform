terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.33"
    }
  }
}

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "1.4.0"

  # Workspace
  name                      = var.name
  associate_license         = var.associate_license
  description               = var.description
  account_access_type       = var.account_access_type
  authentication_providers  = var.authentication_providers
  permission_type           = var.permission_type
  data_sources              = var.data_sources
  notification_destinations = var.notification_destinations
  stack_set_name            = var.stack_set_name

  # Workspace IAM role
  create_iam_role                = var.create_iam_role
  iam_role_name                  = var.iam_role_name
  use_iam_role_name_prefix       = var.use_iam_role_name_prefix
  iam_role_description           = var.iam_role_description
  iam_role_path                  = var.iam_role_path
  iam_role_force_detach_policies = var.iam_role_force_detach_policies
  iam_role_max_session_duration  = var.iam_role_max_session_duration
  iam_role_tags                  = var.iam_role_tags

  role_associations = var.role_associations
}
