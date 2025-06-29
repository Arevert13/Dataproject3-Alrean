variable "subnet_ids" { type = list(string) }

variable "security_group_ids" {
  description = "List of security group IDs for the Lambda function"
  type        = list(string)
}

variable "db_host" {}

variable "db_name" {}

variable "db_user" {}

variable "db_password" {}

variable "lambda_dir" {}