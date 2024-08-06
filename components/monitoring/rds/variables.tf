variable "aws_db_event_subscription_name" {
  default = ""
}

variable "sns_topic" {
  default = ""
}

variable "source_ids" {
  type = list(string)
  default = []
}

variable "event_categories" {
  type = list(string)
  default = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration",
  ]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
