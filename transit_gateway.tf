resource "aws_ec2_transit_gateway" "main" {
  description                    = "Connects lab VPC A and VPC B"
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${var.name_prefix}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_a" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc_a.vpc_id
  subnet_ids         = module.vpc_a.private_subnet_ids
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_b" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc_b.vpc_id
  subnet_ids         = module.vpc_b.private_subnet_ids
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-tgw-attach"
  }
}

resource "aws_route" "a_to_b" {
  route_table_id         = module.vpc_a.private_route_table_id
  destination_cidr_block = var.vpcs["vpc_b"]
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.vpc_a,
    aws_ec2_transit_gateway_vpc_attachment.vpc_b
  ]
}

resource "aws_route" "b_to_a" {
  route_table_id         = module.vpc_b.private_route_table_id
  destination_cidr_block = var.vpcs["vpc_a"]
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.vpc_a,
    aws_ec2_transit_gateway_vpc_attachment.vpc_b
  ]
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = {
    Name = "${var.name_prefix}-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc_a" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc_b" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_a" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

