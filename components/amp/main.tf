terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.1"
    }
  }
}

resource "aws_prometheus_workspace" "this" {
  alias = var.workspace_alias
  tags  = local.tags
}

resource "aws_prometheus_alert_manager_definition" "this" {
  count = var.create_alert_manager_definition ? 1 : 0

  workspace_id = aws_prometheus_workspace.this.id
  definition   = var.alert_manager_definition
}

resource "aws_prometheus_rule_group_namespace" "this" {
  for_each = var.rule_group_namespaces

  name         = each.value.name
  workspace_id = aws_prometheus_workspace.this.id
  data         = each.value.data
}
