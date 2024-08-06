terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"
    }
  }
}

module "sg" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git?ref=v4.0.0"

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  use_name_prefix = var.use_name_prefix

  ingress_cidr_blocks = var.ingress_cidr_blocks
  ingress_rules       = var.ingress_rules

  egress_rules            = var.egress_rules
  egress_cidr_blocks      = var.egress_cidr_blocks
  egress_ipv6_cidr_blocks = var.egress_ipv6_cidr_blocks

  ingress_with_source_security_group_id = var.ingress_with_source_security_group_id

  ingress_with_self = var.ingress_with_self

  tags = var.tags
}
