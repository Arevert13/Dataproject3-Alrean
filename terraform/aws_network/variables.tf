variable "vpc_cidr_block" {}

variable "public_cidr_blocks" {
  type = list(string)
}

variable "private_cidr_blocks" {
  type = list(string)
}

variable "aws_availability_zones" {
  type = list(string)
}

variable "project_label" {}

variable "common_tags" {
  type = map(string)
}
