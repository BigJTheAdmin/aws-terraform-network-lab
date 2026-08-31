output "vpc_a_id" {
  value = module.vpc_a.vpc_id
}

output "vpc_b_id" {
  value = module.vpc_b.vpc_id
}

output "vpc_a_public_subnet_ids" {
  value = module.vpc_a.public_subnet_ids
}

output "vpc_a_private_subnet_ids" {
  value = module.vpc_a.private_subnet_ids
}

output "vpc_b_public_subnet_ids" {
  value = module.vpc_b.public_subnet_ids
}

output "vpc_b_private_subnet_ids" {
  value = module.vpc_b.private_subnet_ids
}

output "tgw_id" {
  value = aws_ec2_transit_gateway.main.id
}

output "tgw_attachment_a_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.vpc_a.id
}

output "tgw_attachment_b_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.vpc_b.id
}