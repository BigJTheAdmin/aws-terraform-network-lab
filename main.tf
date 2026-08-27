locals {
  vpc_names = {
    vpc_a = "${var.name_prefix}-a"
    vpc_b = "${var.name_prefix}-b"
  }
}

resource "aws_vpc" "this" {
  for_each   = var.vpcs
  cidr_block = each.value
  tags = {
    Name = local.vpc_names[each.key]
  }
}

# --- VPC A: subnets, IGW, route tables ---

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this["vpc_a"].id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this["vpc_a"].id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.this["vpc_a"].id
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this["vpc_a"].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this["vpc_a"].id
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# --- VPC B: subnets, IGW, route tables ---

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this["vpc_b"].id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-public-subnet"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this["vpc_b"].id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = var.availability_zone
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-private-subnet"
  }
}

resource "aws_internet_gateway" "b" {
  vpc_id = aws_vpc.this["vpc_b"].id
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-igw"
  }
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.this["vpc_b"].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.b.id
  }
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-public-rt"
  }
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.this["vpc_b"].id
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-private-rt"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.this["vpc_a"].id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-public-subnet-2"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this["vpc_a"].id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = var.availability_zone_2
  tags = {
    Name = "${local.vpc_names["vpc_a"]}-private-subnet-2"
  }
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "public_b_2" {
  vpc_id                  = aws_vpc.this["vpc_b"].id
  cidr_block              = var.public_subnet_cidr_b_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-public-subnet-2"
  }
}

resource "aws_subnet" "private_b_2" {
  vpc_id            = aws_vpc.this["vpc_b"].id
  cidr_block        = var.private_subnet_cidr_b_2
  availability_zone = var.availability_zone_2
  tags = {
    Name = "${local.vpc_names["vpc_b"]}-private-subnet-2"
  }
}

resource "aws_route_table_association" "public_b_2" {
  subnet_id      = aws_subnet.public_b_2.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route_table_association" "private_b_2" {
  subnet_id      = aws_subnet.private_b_2.id
  route_table_id = aws_route_table.private_b.id
}