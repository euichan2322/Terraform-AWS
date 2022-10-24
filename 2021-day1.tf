resource "aws_vpc" "wsi-vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "wsi-vpc"
  }
}

resource "aws_subnet"  "wsi-public-a"  {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsi-public-a"
  }
}

resource "aws_subnet"  "wsi-public-b"  {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "wsi-public-b"
  }
}

resource "aws_subnet"  "wsi-private-a"  {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsi-private-a"
  }
}

resource "aws_subnet"  "wsi-private-b"  {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "wsi-private-b"
  }
}

resource "aws_internet_gateway" "wsi-igw" {
  vpc_id = aws_vpc.wsi-vpc.id

  tags= {
    Name = "wsi-igw"
  }
}

resource "aws_route_table" "wsi-public-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsi-igw.id
  }
  tags = {
    Name = "wsi-public-rt"
  }
}

resource "aws_route_table_association" "wsi-public-rt-assoc-a" {
  route_table_id = aws_route_table.wsi-public-rt.id
  subnet_id = aws_subnet.wsi-public-a.id
}

resource "aws_route_table_association" "wsi-public-rt-assoc-b" {
  route_table_id = aws_route_table.wsi-public-rt.id
  subnet_id = aws_subnet.wsi-public-b.id
}

resource "aws_route_table" "wsi-private-rt-a" {
  vpc_id = aws_vpc.wsi-vpc.id
  tags   = {
    Name = "wsi-private-rt-a"
  }
}

resource "aws_route_table_association" "wsi-private-rt-a-assoc" {
  route_table_id = aws_route_table.wsi-private-rt-a.id
  subnet_id = aws_subnet.wsi-private-a.id
}

resource "aws_eip" "wsi-nat-eip-a" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "wsi-nat-a" {
  subnet_id = aws_subnet.wsi-public-a.id
  allocation_id = aws_eip.wsi-nat-eip-a.id

  tags = {
    Name = "wsi-nat-a"
  }
}

resource "aws_route" "wsi-private-nat-route-a" {
  route_table_id = aws_route_table.wsi-private-rt-a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.wsi-nat-a.id
}

resource "aws_route_table" "wsi-private-rt-b" {
  vpc_id = aws_vpc.wsi-vpc.id
  tags   = {
    Name = "wsi-private-rt-b"
  }
}

resource "aws_route_table_association" "wsi-private-rt-b-assoc" {
  route_table_id = aws_route_table.wsi-private-rt-b.id
  subnet_id = aws_subnet.wsi-private-b.id
}

resource "aws_eip" "wsi-nat-eip-b" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "wsi-nat-b" {
  subnet_id = aws_subnet.wsi-public-b.id
  allocation_id = aws_eip.wsi-nat-eip-b.id

  tags = {
    Name = "wsi-nat-b"
  }
}

resource "aws_route" "wsi-private-nat-route-b" {
  route_table_id = aws_route_table.wsi-private-rt-b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.wsi-nat-b.id
}
