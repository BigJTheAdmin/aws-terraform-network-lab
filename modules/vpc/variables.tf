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

variable "inspection_vpc_cidr" {
  default = "10.2.0.0/16"
}
variable "inspection_subnet_cidr" {
  default = "10.2.1.0/24"
}
variable "inspection_subnet_cidr_2" {
  default = "10.2.2.0/24"
}