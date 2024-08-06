variable "name" {
  description = "KMS key name"
}

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "KMS key deletion window"
}

variable "enable_key_rotation" {
  description = "Tags to apply"
  type        = bool
  default     = false
}

variable "policy" {
  description = "KMS policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
