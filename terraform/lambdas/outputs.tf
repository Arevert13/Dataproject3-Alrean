output "get_products_invoke_arn" {
  value = aws_lambda_function.get_product.invoke_arn
}

output "add_product_invoke_arn" {
  value = aws_lambda_function.add_product.invoke_arn
}

output "buy_product_invoke_arn" {
  value = aws_lambda_function.buy_product.invoke_arn
}
