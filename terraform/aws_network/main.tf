# AWS NETWORKING INFRASTRUCTURE FOR PROJECT
#############################################

# Main VPC
resource "aws_vpc" "network" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Purpose = "Primary VPC for ${var.project_label}"
  })
}

# Internet Gateway for public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.network.id

  tags = merge(var.common_tags, {
    Purpose = "Internet Access for ${var.project_label}"
  })
}

# Public subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_cidr_blocks)

  vpc_id                  = aws_vpc.network.id
  cidr_block              = var.public_cidr_blocks[count.index]
  availability_zone       = var.aws_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.project_label}-pub-subnet-${count.index + 1}"
  })
}

# Private subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_cidr_blocks)

  vpc_id            = aws_vpc.network.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = var.aws_availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.project_label}-priv-subnet-${count.index + 1}"
  })
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_label}-public-rt"
  })
}

# Public Route Table Associations
resource "aws_route_table_association" "public_associations" {
  count = length(var.public_cidr_blocks)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

#############################################
# Security Groups
#############################################

# RDS Security Group
resource "aws_security_group" "sg_rds" {
  name_prefix = "${var.project_label}-sg-rds-"
  vpc_id      = aws_vpc.network.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Purpose = "Database Access for ${var.project_label}"
  })
}

# Lambda Security Group
resource "aws_security_group" "sg_lambda" {
  name_prefix = "${var.project_label}-sg-lambda-"
  vpc_id      = aws_vpc.network.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Purpose = "Lambda Outbound for ${var.project_label}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

#############################################
# DB Subnet Groups
#############################################

# Private Subnet Group for RDS
resource "aws_db_subnet_group" "rds_private" {
  name       = "${var.project_label}-rds-private-subnets"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = merge(var.common_tags, {
    Purpose = "RDS Private Subnets for ${var.project_label}"
  })
}

# Public Subnet Group for Datastream
resource "aws_db_subnet_group" "rds_public_datastream" {
  name       = "${var.project_label}-rds-public-datastream"
  subnet_ids = aws_subnet.public_subnets[*].id

  tags = merge(var.common_tags, {
    Purpose = "Datastream Access for ${var.project_label}"
  })
}

#############################################
# Parameter Group for Logical Replication
#############################################

resource "aws_db_parameter_group" "pg_logical" {
  family = "postgres15"
  name   = "${var.project_label}-pg-logical-replication"

  parameter {
    name         = "max_replication_slots"
    value        = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_wal_senders"
    value        = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
}
