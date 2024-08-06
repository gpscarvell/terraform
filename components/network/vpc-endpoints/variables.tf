variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
  default     = null
}

variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type        = any
  default     = {}
}

variable "security_group_ids" {
  description = "Default security group IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Default subnets IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
