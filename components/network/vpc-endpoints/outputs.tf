output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = module.vpc-endpoints.endpoints
}
