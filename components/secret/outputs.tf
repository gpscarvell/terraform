output "name" {
  value       = [for r in kubernetes_secret.secret : r.metadata[0].name][0]
  description = "Secret's name"
}

output "namespaces" {
  value       = [for r in kubernetes_secret.secret : r.metadata[0].namespace]
  description = "Secret's namespaces"
}

/**
 * Safe to use. Keys of .data should not be a secret, and allow to retrieve
 * secret values from another resources
 */
output "keys" {
  value       = [for r in kubernetes_secret.secret : keys(nonsensitive(r.data))][0]
  description = "List of keys for the Kubernetes secret"
}
