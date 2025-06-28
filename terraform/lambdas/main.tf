resource "aws_iam_role" "lambda_exec_role" {
  name = "ordinal-thinker-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "null_resource" "package_lambdas" {
  triggers = {
    get_product_hash = filemd5("${var.lambda_dir}/get_product/requirements.txt")
    add_product_hash = filemd5("${var.lambda_dir}/add_product/requirements.txt")
    buy_product_hash = filemd5("${var.lambda_dir}/buy_product/requirements.txt")
  }
  
}

  
locals {
  lambda_env = {
    DB_HOST     = var.db_host
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
  }
}
resource "aws_lambda_function" "get_product" {
  filename         = "${var.lambda_dir}/get_product/function.zip"
  function_name    = "get-product-fn"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("${var.lambda_dir}/get_product/function.zip")

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = local.lambda_env
  }
  
  depends_on = [null_resource.package_lambdas]
}



resource "aws_lambda_function" "add_product" {
  filename         = "${var.lambda_dir}/add_product/function.zip"
  function_name    = "add-product-fn"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("${var.lambda_dir}/add_product/function.zip")

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = local.lambda_env
  }
  depends_on = [null_resource.package_lambdas]
}

resource "aws_lambda_function" "buy_product" {
  filename         = "${var.lambda_dir}/buy_product/function.zip"
  function_name    = "buy-product-fn"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("${var.lambda_dir}/buy_product/function.zip")
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = local.lambda_env
  }
  depends_on = [null_resource.package_lambdas]
}
resource "aws_lambda_function_url" "get_product" {
  function_name      = aws_lambda_function.get_product.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
  }
}

resource "aws_lambda_function_url" "add_product" {
  function_name      = aws_lambda_function.add_product.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
  }
}

resource "aws_lambda_function_url" "buy_product" {
  function_name      = aws_lambda_function.buy_product.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
  }
}
