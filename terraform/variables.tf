variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "region" {
  description = "GCP region"
  default     = "europe-west1"
}

variable "project_id" {
  description = "GCP project ID"
}

variable "project_name" {
  description = "Project name label"
  default     = "ordinal-thinker"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private1_cidr" {
  default = "10.0.1.0/24"
}

variable "private2_cidr" {
  default = "10.0.2.0/24"
}

variable "az1" {
  default = "eu-west-1a"
}

variable "az2" {
  default = "eu-west-1b"
}

variable "db_name" {
  default = "products_db"
}

variable "db_username" {
  default = "postgres_user"
}

variable "db_password" {
  default = "postgres_pass123!"
}

variable "lambda_dir" {
  description = "Path to lambda source directories"
  default     = "../app/lambdas"
}

variable "flask_dir" {
  description = "Path to Flask app directory"
  default     = "../app/flask"
}

variable "datastream_user" {
  description = "User for Datastream"
}

variable "datastream_password" {
  description = "Password for Datastream"
  sensitive   = true
}

variable "publication" {
  default = "my_publication"
}

variable "replication_slot" {
  default = "my_slot"
}