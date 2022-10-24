resource "aws_vpc"  "abc-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "abc-vpc"
  }
}

resource "aws_subnet"  "abc-public-subnet"  {
  vpc_id     = aws_vpc.abc-vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "abc-public-subnet"
  }
}

resource "aws_subnet"  "abc-private-subnet"  {
  vpc_id     = aws_vpc.abc-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "abc-private-subnet"
  }
}

resource "aws_internet_gateway" "abc-igw" {
  vpc_id = aws_vpc.abc-vpc.id

  tags= {
    Name = "abc-igw"
  }
}

resource "aws_route_table" "abc-public-rtb" {
  vpc_id = aws_vpc.abc-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.abc-igw.id
  }
  tags = {
    Name = "abc-public-rtb"
  }
}

resource "aws_route_table" "abc-private-rtb" {
  vpc_id = aws_vpc.abc-vpc.id
  tags   = {
    Name = "abc-private-rtb"
  }
}

resource "aws_route_table_association" "abc-public-rtb-assoc" {
  route_table_id = aws_route_table.abc-public-rtb.id
  subnet_id = aws_subnet.abc-public-subnet.id
}

resource "aws_route_table_association" "abc-private-rtb-assoc" {
  route_table_id = aws_route_table.abc-public-rtb.id
  subnet_id = aws_subnet.abc-private-subnet.id
}

resource "aws_eip" "abc-nat-eip" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "abc-nat" {
  subnet_id = aws_subnet.abc-public-subnet.id
  allocation_id = aws_eip.abc-nat-eip.id

  tags = {
    Name = "abc-nat"
  }
}

resource "aws_route" "abc-private-nat-route" {
  route_table_id = aws_route_table.abc-private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.abc-nat.id
}
