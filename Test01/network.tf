
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc_test01" {
  cidr_block = "10.5.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
      Name = "VPC by terraform"
  }
}

resource "aws_internet_gateway" "internet_gw_test01" {
  vpc_id = "${aws_vpc.vpc_test01.id}"

  tags {
    Name = "Internet gateway za Test01 VPC"
  }
}

resource "aws_route_table" "route_table01" {
  vpc_id = "${aws_vpc.vpc_test01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw_test01.id}"
  }

  tags {
    Name = "Routing tabela 01"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.vpc_test01.id}"
  route_table_id = "${aws_route_table.route_table01.id}"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.vpc_test01.id}"
  cidr_block = "10.5.1.0/24"
  availability_zone = "eu-central-1a"
  tags {
    Name = "Prvi subnet"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.vpc_test01.id}"
  cidr_block = "10.5.2.0/24"
  availability_zone = "eu-central-1b"
  tags {
    Name = "Drugi subnet"
  }
}

resource "aws_security_group" "sg_test01" {
  name        = "SG_Test01"
  description = "Allow tcp/22,80 and ICMP from all"
  vpc_id      = "${aws_vpc.vpc_test01.id}"

  tags {
    Name = "Dozvoli SSH i HTTP pristup"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

