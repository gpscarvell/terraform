terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.44.0"
    }
  }
}

resource "aws_route53_resolver_endpoint" "resolver_endpoint" {
  direction          = upper(var.direction)
  security_group_ids = var.security_group_ids
  name               = var.name
  tags               = var.tags

  dynamic "ip_address" {
    for_each = var.ip_addresses

    content {
      ip        = lookup(ip_address.value, "ip", null)
      subnet_id = ip_address.value.subnet_id
    }
  }

}
