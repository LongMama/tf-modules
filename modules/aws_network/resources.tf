locals {
  env = var.common_tags["Enviroment"]
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.common_tags, { Name = "${local.env}-VPC" })
}

#----------Public Subnet----------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "${local.env}-IGW" })
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.common_tags, { Name = "${local.env}-public subnet-${count.index + 1}" })
}

resource "aws_route_table" "public_subnets_routes" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.common_tags, { Name = "${local.env}-public routes" })
}

resource "aws_route_table_association" "public_subnets_association" {
  count          = length(aws_subnet.public_subnets[*].id)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets_routes.id
}

#----------Private Subnet----------

resource "aws_eip" "nat_ips" {
  count = length(var.private_subnet_cidrs)
  vpc   = true
  tags  = merge(var.common_tags, { Name = "${local.env}-IP-${count.index} + 1" })
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat_ips[count.index].id
  subnet_id     = element(aws_subnet.private_subnets[*].id, count.index)
  tags          = merge(var.common_tags, { Name = "${local.env}-NAT-${count.index} + 1" })
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.common_tags, { Name = "${local.env}-private subnet-${count.index + 1}" })
}

resource "aws_route_table" "private_subnets_routes" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(var.common_tags, { Name = "${local.env}-private routes-${count.index + 1}" })
}

resource "aws_route_table_association" "private_subnets_association" {
  count          = length(aws_subnet.private_subnets[*].id)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_subnets_routes[count.index].id
}

#----------Database Subnet----------

resource "aws_subnet" "database_subnets" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.database_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.common_tags, { Name = "${local.env}-database subnet-${count.index + 1}" })
}
