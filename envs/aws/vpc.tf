/************************************************************
VPC
************************************************************/
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc"
  }
}

/************************************************************
Subnet
************************************************************/
resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = "${local.region_name}a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

/************************************************************
Internet Gateway
************************************************************/
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw"
  }
}

/************************************************************
Network ACLs
************************************************************/
resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "nacl"
  }
}

resource "aws_network_acl_rule" "ingress_all" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "egress_all" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "this" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.this.id
}

/************************************************************
Route Table
************************************************************/
resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "rtb-public"
  }
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.this.id
  subnet_id      = aws_subnet.this.id
}

resource "aws_route" "to_igw" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

/************************************************************
Elastic IP
************************************************************/
resource "aws_eip" "this" {
  tags = {
    Name = "ec2-eip"
  }
}

/************************************************************
Security Group
************************************************************/
resource "aws_security_group" "this" {
  vpc_id      = aws_vpc.this.id
  name        = "ec2-sg"
  description = "For EC2"
  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTP From Unrestricted"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "80"
  to_port           = "80"
  tags = {
    Name = "http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTPS From Unrestricted"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "443"
  to_port           = "443"
  tags = {
    Name = "https"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow To Unrestricted"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = {
    Name = "all"
  }
}