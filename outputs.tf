output "vpc_a_id" {
  value = aws_vpc.this["vpc_a"].id
}

output "vpc_b_id" {
  value = aws_vpc.this["vpc_b"].id
}

output "vpc_a_public_subnet_id" {
  value = aws_subnet.public.id
}

output "vpc_a_private_subnet_id" {
  value = aws_subnet.private.id
}

output "vpc_b_public_subnet_id" {
  value = aws_subnet.public_b.id
}

output "vpc_b_private_subnet_id" {
  value = aws_subnet.private_b.id
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

output "vpc_a_public_subnet_2_id" {
  value = aws_subnet.public_2.id
}

output "vpc_a_private_subnet_2_id" {
  value = aws_subnet.private_2.id
}

output "vpc_b_public_subnet_2_id" {
  value = aws_subnet.public_b_2.id
}

output "vpc_b_private_subnet_2_id" {
  value = aws_subnet.private_b_2.id
}