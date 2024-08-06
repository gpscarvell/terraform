# terraform-aws-client-vpn

This terraform module installs a client vpn.

The following resources will be created:
 - VPN Endpoint - Provides an AWS Client VPN endpoint for OpenVPN clients.
 - Provides network associations for AWS Client VPN endpoints
 - Generate AWS Certificate Manager(ACM) certificates

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 4.44.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | > 2.2.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | > 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | > 4.44.0 |
| <a name="provider_local"></a> [local](#provider\_local) | > 2.2.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | > 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.ca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_ec2_client_vpn_authorization_rule.all_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_authorization_rule.specific_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_route.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |
| [local_file.vpn_client_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_cert_request.root](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_cert_request.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.root](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.root](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_access_groups"></a> [allowed\_access\_groups](#input\_allowed\_access\_groups) | Map of Access group IDs to allow access. Leave empty to allow all groups | `map(map(string))` | `{}` | no |
| <a name="input_allowed_cidr_ranges"></a> [allowed\_cidr\_ranges](#input\_allowed\_cidr\_ranges) | List of CIDR ranges from which access is allowed | `list(string)` | `[]` | no |
| <a name="input_authentication_saml_provider_arn"></a> [authentication\_saml\_provider\_arn](#input\_authentication\_saml\_provider\_arn) | (Optional) The ARN of the IAM SAML identity provider if type is federated-authentication. | `any` | `null` | no |
| <a name="input_authentication_self_service_saml_provider_arn"></a> [authentication\_self\_service\_saml\_provider\_arn](#input\_authentication\_self\_service\_saml\_provider\_arn) | (Optional) The ARN of the IAM SAML identity provider for the self service portal if type is federated-authentication. | `any` | `null` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | The type of client authentication to be used. Specify certificate-authentication to use certificate-based authentication, directory-service-authentication to use Active Directory authentication, or federated-authentication to use Federated Authentication via SAML 2.0. | `string` | `"certificate-authentication"` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | Network CIDR to use for clients | `any` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS Servers | `list(string)` | `[]` | no |
| <a name="input_enable_self_service_portal"></a> [enable\_self\_service\_portal](#input\_enable\_self\_service\_portal) | Specify whether to enable the self-service portal for the Client VPN endpoint | `bool` | `false` | no |
| <a name="input_logs_retention"></a> [logs\_retention](#input\_logs\_retention) | Retention in days for CloudWatch Log Group | `number` | `365` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for the resources of this stack | `any` | n/a | yes |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Name of organization to use in private certificate | `string` | `"ACME, Inc"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups to use | `list(string)` | `[]` | no |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | With split\_tunnel false, all client traffic will go through the VPN. | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet ID to associate clients (each subnet passed will create an VPN association - costs involved) | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags to attach to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id to create resources | `string` | n/a | yes |
| <a name="input_vpn_routes"></a> [vpn\_routes](#input\_vpn\_routes) | Extra routes | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_ca_cert"></a> [vpn\_ca\_cert](#output\_vpn\_ca\_cert) | n/a |
| <a name="output_vpn_ca_key"></a> [vpn\_ca\_key](#output\_vpn\_ca\_key) | n/a |
| <a name="output_vpn_client_cert"></a> [vpn\_client\_cert](#output\_vpn\_client\_cert) | n/a |
| <a name="output_vpn_client_key"></a> [vpn\_client\_key](#output\_vpn\_client\_key) | n/a |
| <a name="output_vpn_endpoint_id"></a> [vpn\_endpoint\_id](#output\_vpn\_endpoint\_id) | n/a |
| <a name="output_vpn_server_cert"></a> [vpn\_server\_cert](#output\_vpn\_server\_cert) | n/a |
| <a name="output_vpn_server_key"></a> [vpn\_server\_key](#output\_vpn\_server\_key) | n/a |

<!--- END_TF_DOCS --->
