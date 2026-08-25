variable "public_subnet_cidr" {
  description = "CIDR block for VPC A's public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for VPC A's private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for VPC B's public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for VPC B's private subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "availability_zone" {
  description = "AZ to deploy subnets into"
  type        = string
  default     = "us-east-1a"
}

variable "name_prefix" {
  description = "Prefix used for resource naming/tags"
  type        = string
  default     = "lab"
}

variable "vpcs" {
  description = "Map of VPC key to CIDR block"
  type        = map(string)
  default = {
    vpc_a = "10.0.0.0/16"
    vpc_b = "10.1.0.0/16"
  }
}
