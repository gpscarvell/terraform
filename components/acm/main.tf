terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 1.0.1. In other words, we are setting the
  # required_version property of the terraform block to "= 1.0.1".
  required_version = "= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"
    }
  }
}

module "common_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.2"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  zone_id                   = var.zone_id

  tags = var.tags
}
