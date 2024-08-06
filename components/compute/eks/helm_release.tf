resource "helm_release" "main" {
  for_each = var.helm_charts

  repository = lookup(each.value, "repository", null)
  chart      = lookup(each.value, "chart", null)
  version    = lookup(each.value, "version", null)

  create_namespace = lookup(each.value, "create_namespace", true)
  namespace        = lookup(each.value, "namespace", lookup(each.value, "name", null))
  name             = lookup(each.value, "name", null)

  description           = lookup(each.value, "description", null)
  timeout               = lookup(each.value, "timeout", 300)
  disable_webhooks      = lookup(each.value, "disable_webhooks", false)
  force_update          = lookup(each.value, "force_update", false)
  recreate_pods         = lookup(each.value, "recreate_pods", false)
  cleanup_on_fail       = lookup(each.value, "cleanup_on_fail", false)
  render_subchart_notes = lookup(each.value, "render_subchart_notes", true)
  wait                  = lookup(each.value, "wait", true)

  values = lookup(each.value, "values", [])

  dynamic "set" {
    iterator = item
    for_each = lookup(each.value, "set", {})

    content {
      name  = item.value.name
      value = item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = item
    for_each = lookup(each.value, "set_sensitive", {})

    content {
      name  = item.value.path
      value = item.value.value
    }
  }

}
