# terraform import aws_vpc.toshi-root-default-vpc vpc-d7658fb3
resource "aws_vpc" "toshi-root-default-vpc" {
  assign_generated_ipv6_cidr_block = "false"
  tags                             = {
    Name = "tf-toshi-root-default-vpc"
  }
  cidr_block                       = "172.31.0.0/16"
  enable_classiclink               = "false"
  enable_classiclink_dns_support   = "false"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"
}

# terraform import aws_subnet.subnet-apne1-az1 subnet-c5c03c9d
resource "aws_subnet" "subnet-apne1-az1" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.0.0/20"
  map_public_ip_on_launch         = "true"
  vpc_id                          = aws_vpc.toshi-root-default-vpc.id
  lifecycle {
    prevent_destroy = true
  }
}
# terraform import aws_subnet.subnet-apne1-az4 subnet-da5ff7ac
resource "aws_subnet" "subnet-apne1-az4" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.16.0/20"
  map_public_ip_on_launch         = "true"
  vpc_id                          = aws_vpc.toshi-root-default-vpc.id
}
# terraform import aws_subnet.subnet-apne1-az2 subnet-77f2ad5f
resource "aws_subnet" "subnet-apne1-az2" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.32.0/20"
  map_public_ip_on_launch         = "true"
  vpc_id                          = aws_vpc.toshi-root-default-vpc.id
}

resource "aws_internet_gateway" "igw_toshi-root" {
  vpc_id = aws_vpc.toshi-root-default-vpc.id
}

resource "aws_route_table" "rtb_toshi_root_igw" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_toshi-root.id
  }
  vpc_id = aws_vpc.toshi-root-default-vpc.id
}

resource "aws_main_route_table_association" "toshi-root-default-vpc" {
  route_table_id = aws_route_table.rtb_toshi_root_igw.id
  vpc_id         = aws_vpc.toshi-root-default-vpc.id
}

resource "aws_security_group" "staging_sg" {
  description = "staging"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["160.251.204.118/32"]
    from_port   = "0"
    protocol    = "tcp"
    self        = "false"
    to_port     = "65535"
  }

  name = "staging"

  tags = {
    Name = "staging"
  }

  tags_all = {
    Name = "staging"
  }

  vpc_id = aws_vpc.toshi-root-default-vpc.id
}
