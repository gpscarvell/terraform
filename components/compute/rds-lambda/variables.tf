variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = ""
}

variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of your Lambda Function (or Layer)"
  type        = string
  default     = ""
}

variable "database_id" {
  description = "Database id"
  type        = string
  default     = ""
}

variable "database_arn" {
  description = "Database arn"
  type        = string
  default     = ""
}

variable "work_period_start" {
  description = "Cron expression when to start DB instance"
  type        = string
  default = "0 6 ? * MON *" # Run at 6:00 am (UTC) every Monday
}

variable "work_period_end" {
  description = "Cron expression when to stop DB instance"
  type        = string
  default     = "0 19 ? * FRI *" # Run at 7:00 pm (UTC) every Friday
}

variable "lambda_region" {
  description = "AWS region where function runs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
