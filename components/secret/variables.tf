variable "secret_data" {
  type        = any
  description = "Secret data"
}

variable "type" {
  type        = string
  description = "Kubernetes type of secret"
  default     = "Opaque"
}

variable "name" {
  type        = string
  description = "Name of the secret"
}

variable "namespaces" {
  type        = set(string)
  description = "Namespace to create the secret"
  default     = ["default"]
}

variable "labels" {
  type        = map(map(string))
  description = "Labels for the secret"
  default = {
    all = {}
  }
}

variable "annotations" {
  type        = map(map(string))
  description = "Annotations for the secret"
  default = {
    all = {}
  }
}

variable "cluster_id" {
  description = "EKS cluster id"
  type        = string
  default     = null
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
  default     = null
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
  default     = null
}
