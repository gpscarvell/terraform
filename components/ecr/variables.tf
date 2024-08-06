variable "ecr_repos" {
  description = "Map of the ECR repositories"
  type        = any
}

variable "repository_policy" {
  description = "Defines the repository policy"
  type        = string
  default     = ""
}

variable "ecr_lifecycle_policy" {
  description = "Defines the repository lifecycle policy"
  type        = string
  default     = ""
}

variable "create_repository_policy" {
  description = "Whether to create repository policy. Default false"
  type        = bool
  default     = false
}

variable "create_lifecycle_policy" {
  description = "Whether to create repository lifecycle policy. Default false"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
