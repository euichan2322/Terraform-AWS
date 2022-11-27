  resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = {
      Name = "skills-vpc"
    }
  }

  resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
      Name = "skills-private-a"
  } 
  }

  resource "aws_subnet" "private-subnet-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
      Name = "skills-private-b"
  } 
  }

  resource "aws_subnet" "private-subnet-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
      Name = "skills-private-c"
  } 
  }

  resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
      Name = "skills-public-a"
  } 
  }

  resource "aws_subnet" "public-subnet-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
      Name = "skills-public-b"
  } 
  }

  resource "aws_subnet" "public-subnet-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
      Name = "skills-public-c"
  } 
  }

  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags= {
      Name = "IGW"
    }
  }   

  resource "aws_eip" "eip-ngw" {
    vpc = true
    lifecycle {
      create_before_destroy = true
    }
  }

  resource "aws_nat_gateway" "ngw" {
    subnet_id     = aws_subnet.public-subnet-a.id
    allocation_id = aws_eip.eip-ngw.id

    tags = {
      Name = "NGW"
    }
  }

  resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "skills-public-rt"
    }
  }

  resource "aws_route_table" "private-rt-a" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngw.id
    }

    tags   = {
      Name = "skills-private-a-rt"
    }
  }

  resource "aws_route_table" "private-rt-b" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngw.id
    }

    tags   = {
      Name = "skills-private-b-rt"
    }
  }

  resource "aws_route_table" "private-rt-c" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngw.id
    }

    tags   = {
      Name = "skills-private-c-rt"
    }
  }

  resource "aws_route_table_association" "public-rt-association-a" {
    route_table_id = aws_route_table.public-rt.id
    subnet_id      = aws_subnet.public-subnet-a.id
  }

  resource "aws_route_table_association" "public-rt-association-b" {
    route_table_id = aws_route_table.public-rt.id
    subnet_id      = aws_subnet.public-subnet-b.id
  }

  resource "aws_route_table_association" "public-rt-association-c" {
    route_table_id = aws_route_table.public-rt.id
    subnet_id      = aws_subnet.public-subnet-c.id
  }

  resource "aws_route_table_association" "private-rt-association-a" {
    route_table_id = aws_route_table.private-rt-a.id
    subnet_id      = aws_subnet.private-subnet-a.id
  }

  resource "aws_route_table_association" "private-rt-association-b" {
    route_table_id = aws_route_table.private-rt-b.id
    subnet_id      = aws_subnet.private-subnet-b.id
  }

  resource "aws_route_table_association" "private-rt-association-c" {
    route_table_id = aws_route_table.private-rt-c.id
    subnet_id      = aws_subnet.private-subnet-c.id
  }
