variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDRs and Availability Zones."
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnet CIDRs and Availability Zones."
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
