variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
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
