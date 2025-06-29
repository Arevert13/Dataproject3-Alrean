variable "region" {}
variable "project_id" {}
variable "get_products_url" {}
variable "add_product_url" {}
variable "buy_product_url" {}

variable "flask_dir" {
  default = "../app/flask"
}
variable "api_gateway_url" {
  description = "La URL de tu API Gateway para el Flask Frontend"
  type        = string
}
