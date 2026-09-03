variable "name" {
  description = "Name prefix for this VPC and its resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets, each with its own CIDR and AZ"
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "List of private subnets, each with its own CIDR and AZ"
  type = list(object({
    cidr = string
    az   = string
  }))
}
