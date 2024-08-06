resource "kubernetes_namespace" "app" {
  for_each = var.namespaces

  metadata {
    name = each.value
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_secret" "secret" {
  for_each = var.namespaces
  metadata {
    annotations = merge(var.annotations["all"], lookup(var.annotations, each.value, {}))
    labels      = merge(var.labels["all"], lookup(var.labels, each.value, {}))
    name        = var.name
    namespace   = each.value
  }

  type = var.type

  data = { for k, v in var.secret_data : k => v }

  depends_on = [
    kubernetes_namespace.app
  ]
}
