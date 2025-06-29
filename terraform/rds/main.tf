##############################
# 1. DB Subnet Group Privado
##############################

# resource "aws_db_subnet_group" "rds" {
#   name        = var.db_subnet_group_name
#   description = "RDS subnet group in private subnets"
#   subnet_ids  = var.vpc_subnet_ids

#   tags = merge(var.common_tags, {
#     Purpose = "RDS Private Subnets for ${var.project_label}"
#   })
# }

############################################
# 2. Instancia RDS Postgres
############################################

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_label}-postgres"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true

  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = true
  parameter_group_name   = var.parameter_group_name

  apply_immediately      = true

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [parameter_group_name]
  }
}

############################################
# 3. Archive Lambda ZIP with schema.sql
############################################

# data "archive_file" "seed_lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/seed-lambda"
#   output_path = "${path.module}/seed-lambda.zip"
# }

############################################
# 4. IAM Role for Lambda
############################################
resource "aws_iam_role" "seed_lambda_role" {
  name = "${var.project_label}-seed-lambda-role"

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



resource "aws_iam_policy" "lambda_vpc_access" {
  name = "${var.project_label}-lambda-vpc-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attach" {
  role       = aws_iam_role.seed_lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
}


resource "aws_iam_role_policy_attachment" "seed_lambda_basic" {
  role       = aws_iam_role.seed_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

############################################
# 5. Security Group for Lambda
############################################

resource "aws_security_group" "seed_lambda_sg" {
  name_prefix = "${var.project_label}-seed-lambda-"
  vpc_id      = var.vpc_id

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.vpc_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Purpose = "Lambda seeding schema"
  })
}

############################################
# 6. Lambda Function to seed DB
############################################

# resource "aws_lambda_function" "seed_schema" {
#   filename         = data.archive_file.seed_lambda_zip.output_path
#   function_name    = "${var.project_label}-seed-schema"
#   handler          = "handler.lambda_handler"
#   runtime          = "python3.10"
#   role             = aws_iam_role.seed_lambda_role.arn
#   timeout          = 300
#   memory_size      = 512

#   source_code_hash = data.archive_file.seed_lambda_zip.output_base64sha256

#   environment {
#     variables = {
#       DB_HOST     = aws_db_instance.postgres.address
#       DB_NAME     = var.db_name
#       DB_USER     = var.db_username
#       DB_PASSWORD = var.db_password
#     }
#   }

#   vpc_config {
#     subnet_ids         = var.vpc_subnet_ids
#     security_group_ids = [aws_security_group.seed_lambda_sg.id]
#   }

#   depends_on = [aws_db_instance.postgres]
# }

############################################
# 7. Invoke the Lambda once after creation
############################################

# resource "null_resource" "invoke_seed_lambda" {
#   depends_on = [aws_lambda_function.seed_schema]

#   provisioner "local-exec" {
#     command = "aws lambda invoke --function-name ${aws_lambda_function.seed_schema.function_name} out.json"
#   }
# }
