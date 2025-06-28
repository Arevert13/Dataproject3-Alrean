terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.project_id
  region  = var.region
}


module "aws_network" {
  source                 = "./aws_network"
  vpc_cidr_block         = var.vpc_cidr_block
  public_cidr_blocks     = var.public_cidr_blocks
  private_cidr_blocks    = var.private_cidr_blocks
  aws_availability_zones = var.aws_availability_zones
  project_label          = var.project_label
  common_tags            = var.common_tags
}

module "rds" {
  source                  = "./rds"
  vpc_id                  = module.aws_network.vpc_id
  subnet_ids              = module.aws_network.public_subnet_ids
  vpc_security_group_ids  = [module.aws_network.rds_security_group_id]
  db_subnet_group_name    = module.aws_network.private_db_subnet_group_name
  parameter_group_name    = module.aws_network.parameter_group_name

  db_name   = var.db_name
  username  = var.db_username
  password  = var.db_password
}



module "lambdas" {
  source            = "./lambdas"
  subnet_ids        = module.aws_network.private_subnet_ids
security_group_ids = [module.aws_network.lambda_security_group_id]

  db_host     = module.rds.address
  db_name     = module.rds.db_name
  db_user     = module.rds.username
  db_password = module.rds.password
  lambda_dir  = var.lambda_dir
}


module "cloud_run" {
  source           = "./cloud_run"
  region           = var.region
  project_id       = var.project_id
  flask_dir        = var.flask_dir
  get_products_url = module.lambdas.get_products_url
  add_product_url  = module.lambdas.add_product_url
  buy_product_url  = module.lambdas.buy_product_url
}

module "bigquery" {
  source              = "./bigquery"
  project_id          = var.project_id
  region              = var.region
  project_name        = var.project_name
  rds_host            = module.rds.address
  datastream_user     = var.datastream_user
  datastream_password = var.datastream_password
  db_name             = var.db_name
  publication         = var.publication
  replication_slot    = var.replication_slot
}
module "api_gateway" {
  source = "./api_gateway"

  get_product_lambda_arn = module.lambdas.get_product_lambda_arn
  add_product_lambda_arn = module.lambdas.add_product_lambda_arn
  buy_product_lambda_arn = module.lambdas.buy_product_lambda_arn
  region                 = var.aws_region
}

