resource "aws_vpc" "Prod-VPC" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "Prod VPC"
  }
}

resource "aws_vpc" "Pre-Prod-VPC" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "Pre-Prod VPC"
  }
}

resource "aws_vpc" "Network-Service-VPC" {
  cidr_block = "10.3.0.0/16"

  tags = {
    Name = "Network Service VPC"
  }
}

resource "aws_vpc" "Staging-VPC" {
  cidr_block = "10.4.0.0/16"

  tags = {
    Name = "Staging VPC"
  }
}

resource "aws_vpc" "Dev-VPC" {
  cidr_block = "10.5.0.0/16"

  tags = {
    Name = "Dev VPC"
  }
}

resource "aws_subnet" "Prod-Subnet-Private" {
  vpc_id = aws_vpc.Prod-VPC.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Prod Priv Subnet"
  }
}

resource "aws_subnet" "Prod-Subnet-Connectivity-A" {
  vpc_id = aws_vpc.Prod-VPC.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Prod Connectivity Subnet A"
  }
}

resource "aws_subnet" "Prod-Subnet-Connectivity-B" {
  vpc_id = aws_vpc.Prod-VPC.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Prod Connectivity Subnet B"
  }
}

resource "aws_subnet" "Pre-Prod-Subnet-Private" {
  vpc_id = aws_vpc.Pre-Prod-VPC.id
  cidr_block = "10.2.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Pre-Prod Priv Subnet"
  }
}

resource "aws_subnet" "Pre-Prod-Subnet-Connectivity-A" {
  vpc_id = aws_vpc.Pre-Prod-VPC.id
  cidr_block = "10.2.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Pre-Prod Connectivity Subnet A"
  }
}

resource "aws_subnet" "Pre-Prod-Subnet-Connectivity-B" {
  vpc_id = aws_vpc.Pre-Prod-VPC.id
  cidr_block = "10.2.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Pre-Prod Connectivity Subnet B"
  }
}

resource "aws_subnet" "Network-Service-Subnet-Public" {
  vpc_id = aws_vpc.Network-Service-VPC.id
  cidr_block = "10.3.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Network Service Public Subnet"
  }
}

resource "aws_subnet" "Network-Service-Subnet-Private" {
  vpc_id = aws_vpc.Network-Service-VPC.id
  cidr_block = "10.3.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Network Service Priv Subnet"
  }
}

resource "aws_subnet" "Network-Service-Subnet-Connectivity-A" {
  vpc_id = aws_vpc.Network-Service-VPC.id
  cidr_block = "10.3.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Network Service Connectivity Subnet A"
  }
}

resource "aws_subnet" "Network-Service-Subnet-Connectivity-B" {
  vpc_id = aws_vpc.Network-Service-VPC.id
  cidr_block = "10.3.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Network Connectivity Subnet B"
  }
}

resource "aws_subnet" "Staging-Subnet-Private" {
  vpc_id = aws_vpc.Staging-VPC.id
  cidr_block = "10.4.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Staging Priv Subnet"
  }
}

resource "aws_subnet" "Staging-Subnet-Connectivity-A" {
  vpc_id = aws_vpc.Staging-VPC.id
  cidr_block = "10.4.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Stagint Connectivity Subnet A"
  }
}

resource "aws_subnet" "Staging-Subnet-Connectivity-B" {
  vpc_id = aws_vpc.Staging-VPC.id
  cidr_block = "10.4.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Staging Connectivity Subnet B"
  }
}

resource "aws_subnet" "Dev-Subnet-Private" {
  vpc_id = aws_vpc.Dev-VPC.id
  cidr_block = "10.5.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Dev Priv Subnet"
  }
}

resource "aws_subnet" "Dev-Subnet-Connectivity-A" {
  vpc_id = aws_vpc.Dev-VPC.id
  cidr_block = "10.5.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Dev Connectivity Subnet A"
  }
}

resource "aws_subnet" "Dev-Subnet-Connectivity-B" {
  vpc_id = aws_vpc.Dev-VPC.id
  cidr_block = "10.5.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Dev Connectivity Subnet B"
  }
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.Network-Service-VPC.id

    tags = {
        Name = "IGW"
    }
}

resource "aws_eip" "Nat-Eip-A" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "NGW" {
  subnet_id = aws_subnet.Network-Service-Subnet-Public.id
  allocation_id = aws_eip.Nat-Eip-A.id

  tags = {
    Name = "NGW"
  }
}

resource "aws_ec2_transit_gateway" "TGW" {
  default_route_table_propagation = "disable"
  default_route_table_association = "disable"

  tags = {
    Name = "TGW"
  }  
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-1" {
  subnet_ids         = [aws_subnet.Prod-Subnet-Connectivity-A.id,
                        aws_subnet.Prod-Subnet-Connectivity-B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Prod-VPC.id

  tags = {
    Name = "TGW Attachment 1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-2" {
  subnet_ids         = [aws_subnet.Pre-Prod-Subnet-Connectivity-A.id,
                        aws_subnet.Pre-Prod-Subnet-Connectivity-B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Pre-Prod-VPC.id

  tags = {
    Name = "TGW Attachment 2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-3" {
  subnet_ids         = [aws_subnet.Network-Service-Subnet-Connectivity-A.id,
                        aws_subnet.Network-Service-Subnet-Connectivity-B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Network-Service-VPC.id

  tags = {
    Name = "TGW Attachment 3"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-5" {
  subnet_ids         = [aws_subnet.Staging-Subnet-Connectivity-A.id,
                        aws_subnet.Staging-Subnet-Connectivity-B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Staging-VPC.id

  tags = {
    Name = "TGW Attachment 4"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-6" {
  subnet_ids         = [aws_subnet.Dev-Subnet-Connectivity-A.id,
                        aws_subnet.Dev-Subnet-Connectivity-B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Dev-VPC.id

  tags = {
    Name = "TGW Attachment 5"
  }
}

resource "aws_ec2_transit_gateway_route_table" "TGW-Prod-Route-Table" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "TGW Prod Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "TGW-Prod-Route1" {
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Prod-Route-Table.id
}

resource "aws_ec2_transit_gateway_route" "TGW-Prod-Route2" {
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Prod-Route-Table.id
}

resource "aws_ec2_transit_gateway_route" "TGW-Prod-Route3" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Prod-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table" "TGW-Staging-Route-Table" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "TGW Staging Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "TGW-Staging-Route1" {
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-5.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Staging-Route-Table.id
}

resource "aws_ec2_transit_gateway_route" "TGW-Staging-Route2" {
  destination_cidr_block = "10.5.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-6.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Staging-Route-Table.id
}

resource "aws_ec2_transit_gateway_route" "TGW-Staging-Route3" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Staging-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table" "TGW-Network-Service-Route-Table" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "TGW Network Service Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "TGW-Network-Route1" {
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Attachment-3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-Network-Service-Route-Table.id
}

resource "aws_route_table" "Prod-Priv-Route-Table" {
  vpc_id = aws_vpc.Prod-VPC.id
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "Prod Priv Route Table"
  }
}

resource "aws_route_table" "Prod-TGW-Route-Table" {
  vpc_id = aws_vpc.Prod-VPC.id

  tags = {
    Name = "Prod TGW Route Table"
  }
}

resource "aws_route_table" "Pre-Prod-Priv-Route-Table" {
  vpc_id = aws_vpc.Pre-Prod-VPC.id
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "Pre-Prod Priv Route Table"
  }
}

resource "aws_route_table" "Pre-Prod-TGW-Route-Table" {
  vpc_id = aws_vpc.Pre-Prod-VPC.id

  tags = {
    Name = "Pre-Prod TGW Route Table"
  }
}

resource "aws_route_table" "Network-Service-Public-Route-Table" {
  vpc_id = aws_vpc.Network-Service-VPC.id

  tags = {
    Name = "Network Service Public Route Table"
  }
}

resource "aws_route_table" "Network-Service-Priv-Route-Table" {
  vpc_id = aws_vpc.Network-Service-VPC.id
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "Network Service Priv Route Table"
  }
}

resource "aws_route_table" "Network-Service-TGW-Route-Table" {
  vpc_id = aws_vpc.Network-Service-VPC.id

  tags = {
    Name = "Pre-Prod TGW Route Table"
  }  
}

resource "aws_route_table" "Staging-Priv-Route-Table" {
  vpc_id = aws_vpc.Staging-VPC.id
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "Staging Priv Route Table"
  }
}

resource "aws_route_table" "Staging-TGW-Route-Table" {
  vpc_id = aws_vpc.Staging-VPC.id

  tags = {
    Name = "Staging TGW Route Table"
  }
}

resource "aws_route_table" "Dev-Priv-Route-Table" {
  vpc_id = aws_vpc.Dev-VPC.id
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "Dev Priv Route Table"
  }
}

resource "aws_route_table" "Dev-TGW-Route-Table" {
  vpc_id = aws_vpc.Dev-VPC.id

  tags = {
    Name = "Dev TGW Route Table"
  }
}

resource "aws_route" "Network-Service-Public-Route" {
  route_table_id = aws_route_table.Network-Service-Public-Route-Table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.IGW.id
}

resource "aws_route_table_association" "Prod-Priv-RT-Association" {
  subnet_id = aws_subnet.Prod-Subnet-Private.id
  route_table_id = aws_route_table.Prod-Priv-Route-Table.id
}

resource "aws_route_table_association" "Prod-TGW-RT-Association1" {
  subnet_id = aws_subnet.Prod-Subnet-Connectivity-A.id
  route_table_id = aws_route_table.Prod-TGW-Route-Table.id
}

resource "aws_route_table_association" "Prod-TGW-RT-Association2" {
  subnet_id = aws_subnet.Prod-Subnet-Connectivity-B.id
  route_table_id = aws_route_table.Prod-TGW-Route-Table.id
}

resource "aws_route_table_association" "Pre-Prod-Priv-RT-Association" {
  subnet_id = aws_subnet.Pre-Prod-Subnet-Private.id
  route_table_id = aws_route_table.Pre-Prod-Priv-Route-Table.id
}

resource "aws_route_table_association" "Pre-Prod-TGW-RT-Association1" {
  subnet_id = aws_subnet.Pre-Prod-Subnet-Connectivity-A.id
  route_table_id = aws_route_table.Pre-Prod-TGW-Route-Table.id
}

resource "aws_route_table_association" "Pre-Prod-TGW-RT-Association2" {
  subnet_id = aws_subnet.Pre-Prod-Subnet-Connectivity-B.id
  route_table_id = aws_route_table.Pre-Prod-TGW-Route-Table.id
}

resource "aws_route_table_association" "Network-Service-Public-RT-Association" {
  subnet_id = aws_subnet.Network-Service-Subnet-Public.id
  route_table_id = aws_route_table.Network-Service-Public-Route-Table.id
}

resource "aws_route_table_association" "Network-Service-Priv-RT-Association" {
  subnet_id = aws_subnet.Network-Service-Subnet-Private.id
  route_table_id = aws_route_table.Network-Service-Priv-Route-Table.id
}

resource "aws_route_table_association" "Network-Service-TGW-RT-Association1" {
  subnet_id = aws_subnet.Network-Service-Subnet-Connectivity-A.id
  route_table_id = aws_route_table.Network-Service-TGW-Route-Table.id
}

resource "aws_route_table_association" "Network-Service-TGW-RT-Association2" {
  subnet_id = aws_subnet.Network-Service-Subnet-Connectivity-B.id
  route_table_id = aws_route_table.Network-Service-TGW-Route-Table.id
}

resource "aws_route_table_association" "Staging-Priv-RT-Association" {
  subnet_id = aws_subnet.Staging-Subnet-Private.id
  route_table_id = aws_route_table.Staging-Priv-Route-Table.id
}

resource "aws_route_table_association" "Staging-TGW-RT-Association1" {
  subnet_id = aws_subnet.Staging-Subnet-Connectivity-A.id
  route_table_id = aws_route_table.Staging-TGW-Route-Table.id
}

resource "aws_route_table_association" "Staging-TGW-RT-Association2" {
  subnet_id = aws_subnet.Staging-Subnet-Connectivity-B.id
  route_table_id = aws_route_table.Staging-TGW-Route-Table.id
}

resource "aws_route_table_association" "Dev-Priv-RT-Association" {
  subnet_id = aws_subnet.Dev-Subnet-Private.id
  route_table_id = aws_route_table.Dev-Priv-Route-Table.id
}

resource "aws_route_table_association" "Dev-TGW-RT-Association1" {
  subnet_id = aws_subnet.Dev-Subnet-Connectivity-A.id
  route_table_id = aws_route_table.Dev-TGW-Route-Table.id
}

resource "aws_route_table_association" "Dev-TGW-RT-Association2" {
  subnet_id = aws_subnet.Dev-Subnet-Connectivity-B.id
  route_table_id = aws_route_table.Dev-TGW-Route-Table.id
}