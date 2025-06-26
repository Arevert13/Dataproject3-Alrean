resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ordinal-thinker-vpc"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private1_cidr
  availability_zone = var.az1

  tags = {
    Name = "ordinal-thinker-private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private2_cidr
  availability_zone = var.az2

  tags = {
    Name = "ordinal-thinker-private-subnet-2"
  }
}