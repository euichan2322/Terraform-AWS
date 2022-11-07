resource "aws_ec2_transit_gateway" "TGW" {
  default_route_table_propagation = "disable"
  default_route_table_association = "disable"

  tags = {
    Name = "TGW"
  }  
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Spoke-A-attachment" {
  subnet_ids         = [aws_subnet.TGW-Subnet-A.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Spoke-VPC-A.id

  tags = {
    Name = "Spoke A VPC attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Spoke-B-attachment" {
  subnet_ids         = [aws_subnet.TGW-Subnet-B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Spoke-VPC-B.id

  tags = {
    Name = "Spoke B VPC attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Inspection-attachment" {
  subnet_ids         = [aws_subnet.TGW-Subnet-Inspection.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Inspection-VPC.id

  tags = {
    Name = "Inspection VPC attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Central-Egress-attachment" {
  subnet_ids         = [aws_subnet.TGW-Subnet-Central-Egress.id]  
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Central-Egress-VPC.id

  tags = {
    Name = "Central Egress attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table" "Spoke-Inspection-TGW-Route-Table" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id  
  tags = {
    Name = "Spoke Inspection Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "Spoke-Inspection-TGW-Route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Inspection-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Spoke-Inspection-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "Spoke-A-TGW-Association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Spoke-A-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Spoke-Inspection-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "Spoke-B-TGW-Association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Spoke-B-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Spoke-Inspection-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table" "Firewall-TGW-Route-Table" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "Firewall Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "Firewall-TGW-Route1" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Central-Egress-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Firewall-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route" "Firewall-TGW-Route2" {
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Spoke-A-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Firewall-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route" "Firewall-TGW-Route3" {
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Spoke-B-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Firewall-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "Inspection-TGW-Association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Inspection-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Firewall-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table" "Central-Egress-TGW-Route-Table" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id  
  tags = {
    Name = "Central Egress Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "Central-Egress-TGW-Route" {
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Inspection-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Central-Egress-TGW-Route-Table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "Central-Egress-TGW-Association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-Central-Egress-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Central-Egress-TGW-Route-Table.id
}
