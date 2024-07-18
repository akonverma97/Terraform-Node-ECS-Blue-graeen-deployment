locals {
  public_subnets = {
    "${var.region_primary}a" = "10.10.101.0/24"
    "${var.region_primary}b" = "10.10.102.0/24"
    "${var.region_primary}c" = "10.10.103.0/24"
  }
  private_subnets = {
    "${var.region_primary}a" = "10.10.201.0/24"
    "${var.region_primary}b" = "10.10.202.0/24"
    "${var.region_primary}c" = "10.10.203.0/24"
  }
  data_subnets = {
    "${var.region_primary}a" = "10.10.204.0/24"
    "${var.region_primary}b" = "10.10.205.0/24"
    "${var.region_primary}c" = "10.10.206.0/24"
  }
}

resource "aws_vpc" "this" {
  cidr_block = "10.10.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.stack}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.stack}-internet-gateway"
  }
}

resource "aws_subnet" "public" {
  count      = length(local.public_subnets)
  cidr_block = element(values(local.public_subnets), count.index)
  vpc_id     = aws_vpc.this.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.public_subnets), count.index)

  tags = {
    Name = "${var.stack}-service-public"
  }
}

resource "aws_subnet" "private" {
  count      = length(local.private_subnets)
  cidr_block = element(values(local.private_subnets), count.index)
  vpc_id     = aws_vpc.this.id

  #map_public_ip_on_launch = true
  availability_zone = element(keys(local.private_subnets), count.index)

  tags = {
    Name = "${var.stack}-service-private"
  }
}

resource "aws_subnet" "data" {
  count      = length(local.data_subnets)
  cidr_block = element(values(local.data_subnets), count.index)
  vpc_id     = aws_vpc.this.id

  #map_public_ip_on_launch = true
  availability_zone = element(keys(local.data_subnets), count.index)

  tags = {
    Name = "${var.stack}-service-data"
  }
}

resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.this.main_route_table_id

  tags = {
    Name = "${var.stack}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = length(local.public_subnets)
  route_table_id         = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_default_route_table.public.id
}


#commented for now private subnets we are not using NAT gateway bcz costly 

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.stack}-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.stack}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.0.id

  tags = {
    Name = "${var.stack}-nat-gw"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}

# data subnets

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "data" {
  count          = length(local.data_subnets)
  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = aws_route_table.data.id
}