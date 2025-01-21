terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  student_map = { for idx, student in var.students : idx => student }
  subnets = flatten([
    for student_id, student_name in local.student_map : [
      {
        id          = student_id
        name        = student_name
        index       = 1
        cidr_offset = student_id * 2
        az          = "us-east-2a"
        # az_identifer = "a"
      },
      {
        id          = student_id
        name        = student_name
        index       = 2
        cidr_offset = student_id * 2 + 1
        az          = "us-east-2b"
        # az_identifer = "b"
      }
    ]
  ])
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
  for_each = { for idx, subnet in local.subnets : idx => subnet }
  name        = "student-default-sg-${each.value.name}"
  description = "Allow SSH ingress from the internet and all egress"
  vpc_id      = aws_vpc.student_vpc.id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "student-default-sg-${each.value.name}"
    Owner = each.value.name
  }
}


resource "aws_subnet" "student_subnet" {
  for_each = { for idx, subnet in local.subnets : idx => subnet }

  vpc_id            = aws_vpc.student_vpc.id
  cidr_block        = "10.0.${each.value.cidr_offset}.0/27"
  availability_zone = each.value.az

  tags = {
    Name = "student-cohort-${each.value.name}-${each.value.index}"
  }
}

resource "aws_route_table_association" "student_route_table_association" {
  for_each = aws_subnet.student_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.student_route_table.id
}

# resource "aws_subnet" "student_subnet" {
#   for_each = { for idx, subnet in local.subnets : idx => subnet }

#   vpc_id            = aws_vpc.student_vpc.id
#   cidr_block        = "10.0.${each.value.cidr_offset}.0/24"
#   availability_zone = each.value.az

#   tags = {
#     Name = "student-cohort-${each.value.name}-${each.value.index}"
#   }
# }



# resource "aws_route_table_association" "student_route_table_association" {
#   for_each = aws_subnet.student_subnet
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.student_route_table.id
# }