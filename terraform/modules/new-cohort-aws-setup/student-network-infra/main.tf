terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  student_map = { for idx, student in var.students : idx => student }
}

resource "aws_vpc" "student_vpc" {
  cidr_block = "10.0.0.0/16" # TODO: Does this eventually need variablized? I don't think so since it's a new account

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "student-vpc"
    Environment = "Student Cohort"
  }
}

resource "aws_internet_gateway" "student_igw" {
  vpc_id = aws_vpc.student_vpc.id

  tags = {
    Name = "student-igw"
  }
}

resource "aws_route_table" "student_route_table" {
  vpc_id = aws_vpc.student_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.student_igw.id
  }

  tags = {
    Name = "student-vpc-route-table"
  }
}


resource "aws_security_group" "student_sg" {
  name        = "student-security-group"
  description = "Allow SSH ingress from the internet and all egress"
  vpc_id      = aws_vpc.student_vpc.id

  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "student-sg"
  }
}

resource "aws_subnet" "student_subnet" {
  for_each = local.student_map
  vpc_id            = aws_vpc.student_vpc.id
  cidr_block        = "10.0.${each.key + 1}.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "student-cohort-${each.value}"
  }
}

resource "aws_route_table_association" "student_route_table_association" {
  for_each = aws_subnet.student_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.student_route_table.id
}