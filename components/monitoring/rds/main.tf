terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"
    }
  }
}

resource "aws_db_event_subscription" "default" {
  name      = var.aws_db_event_subscription_name
  sns_topic = var.sns_topic

  source_type = "db-instance"
  source_ids  = var.source_ids

  event_categories = var.event_categories

  tags = var.tags
}
