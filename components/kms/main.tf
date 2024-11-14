locals {
  alias_name = "alias/alkami/${var.name}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

resource "aws_kms_key" "key" {
  description             = var.name
  deletion_window_in_days = var.deletion_window_in_days
  tags                    = var.tags
  policy                  = var.policy
  enable_key_rotation     = var.enable_key_rotation
}

resource "aws_kms_alias" "alias" {
  name          = local.alias_name
  target_key_id = aws_kms_key.key.key_id
}
