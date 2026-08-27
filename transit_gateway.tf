resource "aws_ec2_transit_gateway" "main" {
  description = "Connects lab VPC A and VPC B"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.name_prefix}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_a" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id              = aws_vpc.this["vpc_a"].id
  subnet_ids          = [aws_subnet.private.id, aws_subnet.private_2.id]
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_b" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id              = aws_vpc.this["vpc_b"].id
  subnet_ids          = [aws_subnet.private_b.id, aws_subnet.private_b_2.id]
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-tgw-attach"
  }
}

resource "aws_route" "a_to_b" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.vpcs["vpc_b"]
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.vpc_a,
    aws_ec2_transit_gateway_vpc_attachment.vpc_b
  ]
}

resource "aws_route" "b_to_a" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = var.vpcs["vpc_a"]
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.vpc_a,
    aws_ec2_transit_gateway_vpc_attachment.vpc_b
  ]
}
