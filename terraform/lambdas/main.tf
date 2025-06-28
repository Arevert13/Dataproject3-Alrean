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
data "archive_file" "get_product_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_dir}/get_product"
  output_path = "${path.module}/get_product.zip"
}

data "archive_file" "add_product_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_dir}/add_product"
  output_path = "${path.module}/add_product.zip"
}

data "archive_file" "buy_product_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_dir}/buy_product"
  output_path = "${path.module}/buy_product.zip"
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
  filename         = data.archive_file.get_product_zip.output_path
  function_name    = "get-product-fn"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = data.archive_file.get_product_zip.output_base64sha256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = local.lambda_env
  }
}

resource "aws_lambda_function" "add_product" {
  filename         = data.archive_file.add_product_zip.output_path
  function_name    = "add-product-fn"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = data.archive_file.add_product_zip.output_base64sha256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = local.lambda_env
  }
}

resource "aws_lambda_function" "buy_product" {
  filename         = data.archive_file.buy_product_zip.output_path
  function_name    = "buy-product-fn"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = data.archive_file.buy_product_zip.output_base64sha256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = local.lambda_env
  }
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
