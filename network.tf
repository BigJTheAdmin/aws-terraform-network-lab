locals {
  vpc_names = {
    vpc_a = "${var.name_prefix}-a"
    vpc_b = "${var.name_prefix}-b"
  }
}

module "vpc_a" {
  source = "./modules/vpc"

  name = local.vpc_names["vpc_a"]
  cidr = var.vpcs["vpc_a"]

  public_subnets = [
    { cidr = var.public_subnet_cidr, az = var.availability_zone },
    { cidr = var.public_subnet_cidr_2, az = var.availability_zone_2 },
  ]
  private_subnets = [
    { cidr = var.private_subnet_cidr, az = var.availability_zone },
    { cidr = var.private_subnet_cidr_2, az = var.availability_zone_2 },
  ]
}

module "vpc_b" {
  source = "./modules/vpc"

  name = local.vpc_names["vpc_b"]
  cidr = var.vpcs["vpc_b"]

  public_subnets = [
    { cidr = var.public_subnet_cidr_b, az = var.availability_zone },
    { cidr = var.public_subnet_cidr_b_2, az = var.availability_zone_2 },
  ]
  private_subnets = [
    { cidr = var.private_subnet_cidr_b, az = var.availability_zone },
    { cidr = var.private_subnet_cidr_b_2, az = var.availability_zone_2 },
  ]
}

module "vpc_inspection" {
  source = "./modules/vpc"
  name   = "${var.name_prefix}-inspection"
  cidr   = var.inspection_vpc_cidr

  public_subnets  = []
  private_subnets = [
    { cidr = var.inspection_subnet_cidr,   az = var.availability_zone },
    { cidr = var.inspection_subnet_cidr_2, az = var.availability_zone_2 },
  ]
}