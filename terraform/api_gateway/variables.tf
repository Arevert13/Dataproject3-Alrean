variable "region" {
  description = "AWS region for the Lambda integration URIs"
  type        = string
}

variable "get_product_lambda_arn" {
  description = "ARN of the get_product Lambda function"
  type        = string
}

variable "add_product_lambda_arn" {
  description = "ARN of the add_product Lambda function"
  type        = string
}

variable "buy_product_lambda_arn" {
  description = "ARN of the buy_product Lambda function"
  type        = string
}
