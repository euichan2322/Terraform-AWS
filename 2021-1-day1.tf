resource "aws_vpc" "vpc-skills-ap" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-skills-ap"
  }
}

resource "aws_subnet"  "skills-pub-a"  {
  vpc_id     = aws_vpc.vpc-skills-ap.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsi-public-a"
  }
}

resource "aws_subnet"  "skills-pub-b"  {
  vpc_id     = aws_vpc.vpc-skills-ap.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "skills-pub-b"
  }
}

resource "aws_subnet"  "skills-priv-a"  {
  vpc_id     = aws_vpc.vpc-skills-ap.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "vpc-skills-a"
  }
}

resource "aws_subnet"  "skills-priv-b"  {
  vpc_id     = aws_vpc.vpc-skills-ap.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "skills-priv-b"
  }
}

resource "aws_internet_gateway" "skills-igw" {
  vpc_id = aws_vpc.vpc-skills-ap.id

  tags= {
    Name = "skills-igw"
  }
}

resource "aws_route_table" "skills-public-rt" {
  vpc_id = aws_vpc.vpc-skills-ap.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.skills-igw.id
  }
  tags = {
    Name = "skills-public-rt"
  }
}

resource "aws_route_table_association" "skills-public-rt-assoc-a" {
  route_table_id = aws_route_table.skills-public-rt.id
  subnet_id = aws_subnet.skills-pub-a.id
}

resource "aws_route_table_association" "skills-public-rt-assoc-b" {
  route_table_id = aws_route_table.skills-public-rt.id
  subnet_id = aws_subnet.skills-pub-b.id
}

resource "aws_route_table" "skills-private-a-rt" {
  vpc_id = aws_vpc.vpc-skills-ap.id
  tags   = {
    Name = "skills-private-a-rt"
  }
}

resource "aws_route_table_association" "skills-private-a-rt-assoc" {
  route_table_id = aws_route_table.skills-private-a-rt.id
  subnet_id = aws_subnet.skills-priv-a.id
}

resource "aws_eip" "skills-nat-eip-a" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "skills-nat-a" {
  subnet_id = aws_subnet.skills-pub-a.id
  allocation_id = aws_eip.skills-nat-eip-a.id

  tags = {
    Name = "skills-nat-a"
  }
}

resource "aws_route" "skills-private-nat-route-a" {
  route_table_id = aws_route_table.skills-private-a-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.skills-nat-a.id
}

resource "aws_route_table" "skills-private-b-rt" {
  vpc_id = aws_vpc.vpc-skills-ap.id
  tags   = {
    Name = "skills-private-b-rt"
  }
}

resource "aws_route_table_association" "skills-private-b-rt-assoc" {
  route_table_id = aws_route_table.skills-private-b-rt.id
  subnet_id = aws_subnet.skills-priv-b.id
}

resource "aws_eip" "skills-nat-eip-b" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "skills-nat-b" {
  subnet_id = aws_subnet.skills-pub-b.id
  allocation_id = aws_eip.skills-nat-eip-b.id

  tags = {
    Name = "skills-nat-b"
  }
}

resource "aws_route" "skills-private-nat-route-b" {
  route_table_id = aws_route_table.skills-private-b-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.skills-nat-b.id
}
