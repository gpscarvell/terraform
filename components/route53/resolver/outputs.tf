output "ip_addresses" {
  description = "Resolver IP addresses"
  value       = [for obj in aws_route53_resolver_endpoint.resolver_endpoint.ip_address : obj.ip]
}
