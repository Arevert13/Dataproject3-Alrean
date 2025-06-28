variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
  
}

variable "project_id" {
  description = "GCP project ID"
  type = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_cidr_blocks" {
  type = list(string)
}

variable "private_cidr_blocks" {
  type = list(string)
}

variable "aws_availability_zones" {
  type = list(string)
}

variable "project_label" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "project_name" {
  description = "Name of the GCP project"
  type        = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "lambda_dir" {
  description = "Path to lambda source directories"
  default     = "../app/lambdas"
}


variable "flask_dir" {
  type = string
}

variable "datastream_user" {
  description = "User for Datastream"
  type        = string
}

variable "datastream_password" {
  description = "Password for Datastream"
  type        = string
  sensitive   = true
}

variable "publication" {
  type = string
}

variable "replication_slot" {
  type = string
}
variable "get_product_lambda_arn" {
  description = "ARN de la lambda get-product"
  type        = string
}

variable "add_product_lambda_arn" {
  description = "ARN de la lambda add-product"
  type        = string
}

variable "buy_product_lambda_arn" {
  description = "ARN de la lambda buy-product"
  type        = string

}

