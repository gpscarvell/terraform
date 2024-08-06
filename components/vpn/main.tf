terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.44.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
  }
}

locals {
  self_service_portal = var.enable_self_service_portal == true ? "enabled" : "disabled"
}

####
## acm-certificate-ca
####

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "${var.name}.vpn.ca"
    organization = var.organization_name
  }

  validity_period_hours = 87600
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "aws_acm_certificate" "ca" {
  private_key      = tls_private_key.ca.private_key_pem
  certificate_body = tls_self_signed_cert.ca.cert_pem
}

####
## acm-certificate-root
####

resource "tls_private_key" "root" {
  algorithm = "RSA"
}

resource "tls_cert_request" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name  = "${var.name}.vpn.client"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "root" {
  cert_request_pem   = tls_cert_request.root.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "tls_locally_signed_cert" "additional" {
  count              = var.additional_client_certs
  cert_request_pem   = tls_cert_request.root.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "tls_locally_signed_cert" "cert" {
  for_each           = toset(var.client_certs)
  cert_request_pem   = tls_cert_request.root.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "aws_acm_certificate" "root" {
  private_key       = tls_private_key.root.private_key_pem
  certificate_body  = tls_locally_signed_cert.root.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

####
## acm-certificate-server
####

resource "tls_private_key" "server" {
  algorithm = "RSA"
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "${var.name}.vpn.server"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

####
## vpn-endpoint
####

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = var.name
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.cidr
  split_tunnel           = var.split_tunnel
  dns_servers            = var.dns_servers
  self_service_portal    = local.self_service_portal
  security_group_ids     = var.security_group_ids
  vpc_id                 = var.vpc_id

  authentication_options {
    type                           = var.authentication_type
    root_certificate_chain_arn     = var.authentication_type != "certificate-authentication" ? null : aws_acm_certificate.root.arn
    saml_provider_arn              = var.authentication_saml_provider_arn
    self_service_saml_provider_arn = var.authentication_self_service_saml_provider_arn
  }

  connection_log_options {
    enabled               = false
    # cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    # cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }

  tags = merge(
    var.tags,
    tomap({
      "Name" = "${var.name}",
    })
  )
}

resource "aws_ec2_client_vpn_network_association" "default" {
  count                  = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  subnet_id              = element(var.subnet_ids, count.index)
}

resource "aws_ec2_client_vpn_authorization_rule" "all_groups" {
  count                  = length(var.allowed_access_groups) > 0 ? 0 : length(var.allowed_cidr_ranges)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = var.allowed_cidr_ranges[count.index]
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "specific_groups" {
  for_each               = var.allowed_access_groups
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  description            = each.key
  target_network_cidr    = each.value.cidr
  access_group_id        = each.value.group_id
}

resource "aws_ec2_client_vpn_route" "additional" {
  for_each               = var.vpn_routes
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  destination_cidr_block = each.value
  description            = each.key
  target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.default[0].subnet_id
}

resource "local_file" "vpn_client_key" {
  content  = tls_private_key.root.private_key_pem
  filename = "${path.module}/vpn_client_key"
}

resource "local_file" "vpn_config" {
  for_each = toset(var.client_certs)
  filename = "${path.module}/${var.name}/${replace(each.key, "@", "_")}.ovpn"

  content  = templatefile(
    "${path.module}/config.ovpn.tmpl",
    {
      # https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/troubleshooting.html#resolve-host-name
      endpoint        = replace(aws_ec2_client_vpn_endpoint.default.dns_name, "*", "asdf")
      vpn_ca_cert     = tls_self_signed_cert.ca.cert_pem
      vpn_client_cert = tls_locally_signed_cert.cert[each.key].cert_pem
      vpn_client_key  = tls_private_key.root.private_key_pem
    }
  )
}
