output "get_products_invoke_arn" {
  value = aws_lambda_function.get_product.invoke_arn
}

output "get_products_url" {
  value = aws_lambda_function_url.get_product.function_url
}

output "add_product_invoke_arn" {
  value = aws_lambda_function.add_product.invoke_arn
}

output "buy_product_url" {
  value = aws_lambda_function_url.buy_product.function_url
}
output "add_product_url" {
  value = aws_lambda_function_url.add_product.function_url
}
output "buy_product_invoke_arn" {
  value = aws_lambda_function.buy_product.invoke_arn
}
output "get_product_lambda_arn" {
  description = "ARN de la Lambda get-product"
  value       = aws_lambda_function.get_product.arn
}

output "add_product_lambda_arn" {
  description = "ARN de la Lambda add-product"
  value       = aws_lambda_function.add_product.arn
}

output "buy_product_lambda_arn" {
  description = "ARN de la Lambda buy-product"
  value       = aws_lambda_function.buy_product.arn
}

