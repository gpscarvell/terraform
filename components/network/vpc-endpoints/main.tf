terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

module "vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.14.2"

  vpc_id             = var.vpc_id
  endpoints          = var.endpoints
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  tags = var.tags
}
