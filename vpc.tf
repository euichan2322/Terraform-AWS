resource "aws_vpc" "Spoke-VPC-A" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "Spoke VPC A"
  }
}

resource "aws_subnet" "Workload-Subnet-A" {
  vpc_id = aws_vpc.Spoke-VPC-A.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Workload Subnet Spoke A"
  }
}

resource "aws_subnet" "TGW-Subnet-A" {
  vpc_id = aws_vpc.Spoke-VPC-A.id
  cidr_block = "10.1.0.0/28"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "TGW Subnet Spoke A"
  }
}

resource "aws_vpc" "Spoke-VPC-B" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "Spoke VPC B" 
    }
}

resource "aws_subnet" "Workload-Subnet-B" {
  vpc_id = aws_vpc.Spoke-VPC-B.id
  cidr_block = "10.2.1.0/24"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "Workload Subnet Spoke B"
  }
}

resource "aws_subnet" "TGW-Subnet-B" {
  vpc_id = aws_vpc.Spoke-VPC-B.id
  cidr_block = "10.2.0.0/28"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "TGW Subnet Spoke B"
  }
}

resource "aws_vpc" "Inspection-VPC" {
  cidr_block = "100.64.0.0/16"

  tags = {
    Name = "Inspection VPC"
  }
}

resource "aws_subnet" "TGW-Subnet-Inspection" {
  vpc_id = aws_vpc.Inspection-VPC.id
  cidr_block = "100.64.0.0/28"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "TGW Subnet Inspection"
  }
}

resource "aws_subnet" "Firewall-Subnet" {
  vpc_id = aws_vpc.Inspection-VPC.id
  cidr_block = "100.64.0.16/28"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Firewall Subnet Inspection"
  }
}

resource "aws_vpc" "Central-Egress-VPC" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Central Egress VPC"
  }
}

resource "aws_subnet" "TGW-Subnet-Central-Egress" {
  vpc_id = aws_vpc.Central-Egress-VPC.id
  cidr_block = "10.10.0.0/28"

  tags = {
    Name = "TGW Subnet Central Egress"
  }
}

resource "aws_subnet" "Public-Subnet-Central-Egress" {
  vpc_id = aws_vpc.Central-Egress-VPC.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "Public-Subnet"
  }  
}

resource "aws_networkfirewall_firewall_policy" "firewall-policy" {
  name = "test-firewall-policy"
  
  firewall_policy {
    stateless_default_actions = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
}

resource "aws_networkfirewall_firewall" "firewall" {
  name = "firewall-746563457" 
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall-policy.arn
  vpc_id = aws_vpc.Inspection-VPC.id
  subnet_mapping {
    subnet_id = aws_subnet.Firewall-Subnet.id
  }
}

resource "aws_networkfirewall_logging_configuration" "firewall-logging-ALERT" {
  firewall_arn = aws_networkfirewall_firewall.firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.cloudwatch-log-group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.cloudwatch-log-group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.Central-Egress-VPC.id

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
  subnet_id = aws_subnet.Public-Subnet-Central-Egress.id
  allocation_id = aws_eip.Nat-Eip-A.id

  tags = {
    Name = "NGW"
  }
}

resource "aws_route_table" "Spoke-A-Route-Table" {
  vpc_id = aws_vpc.Spoke-VPC-A.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }  

  tags = {
    Name = "Spoke A Route Table"
  }
}

resource "aws_route_table_association" "Workload-A-RT-association" {
  subnet_id = aws_subnet.Workload-Subnet-A.id
  route_table_id = aws_route_table.Spoke-A-Route-Table.id
}

resource "aws_route_table_association" "TGW-Subnet-A-RT-association" {
  subnet_id = aws_subnet.TGW-Subnet-A.id
  route_table_id = aws_route_table.Spoke-A-Route-Table.id
}

resource "aws_route_table" "Spoke-B-Route-Table" {
  vpc_id = aws_vpc.Spoke-VPC-B.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }  

  tags = {
    Name = "Spoke B Route Table"
  }
}

resource "aws_route_table_association" "Workload-B-RT-association" {
  subnet_id = aws_subnet.Workload-Subnet-B.id
  route_table_id = aws_route_table.Spoke-B-Route-Table.id
}

resource "aws_route_table_association" "TGW-Subnet-B-RT-association" {
  subnet_id = aws_subnet.TGW-Subnet-B.id
  route_table_id = aws_route_table.Spoke-B-Route-Table.id
}

data "aws_vpc_endpoint" "firewall-endpoint" {
  filter {
    name = "vpc-endpoint-type"
    values = ["GatewayLoadBalancer"]
  }  
}

output "vpc-endpoint" {
    value = data.aws_vpc_endpoint.firewall-endpoint.id
}

resource "aws_route_table" "Inspection-TGW-Table" {
  vpc_id = aws_vpc.Inspection-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = data.aws_vpc_endpoint.firewall-endpoint.id
  }  

  tags = {
    Name = "Inspection TGW Route Table"
  }
}

resource "aws_route_table_association" "TGW-Subnet-Inspection-RT-association" {
  subnet_id = aws_subnet.TGW-Subnet-Inspection.id
  route_table_id = aws_route_table.Inspection-TGW-Table.id
}



resource "aws_route_table" "Inspection-Firewall-Route-Table" {
  vpc_id = aws_vpc.Inspection-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }  

  tags = {
    Name = "Inspection Firewall Route Table"
  }
}

resource "aws_route_table_association" "Inspection-Firewall-RT-association" {
  subnet_id = aws_subnet.Firewall-Subnet.id
  route_table_id = aws_route_table.Inspection-Firewall-Route-Table.id
}

resource "aws_route_table" "Central-Egress-TGW-Route-Table" {
  vpc_id = aws_vpc.Central-Egress-VPC.id

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }  

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "Central Egress TGW Route Table"
  }
}

resource "aws_route_table_association" "Central-Egress-TGW-RT-association" {
  subnet_id = aws_subnet.TGW-Subnet-Central-Egress.id
  route_table_id = aws_route_table.Central-Egress-TGW-Route-Table.id
}

resource "aws_route_table" "Central-Egress-Public-Route-Table" {
  vpc_id = aws_vpc.Central-Egress-VPC.id
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "Central Egress Public Route Table"
  }
}

resource "aws_route_table_association" "Central-Egress-Public-RT-association" {
  subnet_id = aws_subnet.Public-Subnet-Central-Egress.id
  route_table_id = aws_route_table.Central-Egress-Public-Route-Table.id
}