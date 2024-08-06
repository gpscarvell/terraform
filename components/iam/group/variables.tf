variable "create_group" {
  description = "Whether to create IAM group"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of IAM group"
  type        = string
  default     = ""
}

variable "assumable_roles" {
  description = "List of IAM roles ARNs which can be assumed by the group"
  type        = list(string)
  default     = []
}

variable "custom_group_policy_arns" {
  description = "List of IAM policies ARNs to attach to IAM group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

