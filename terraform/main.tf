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

module "network" {
  source        = "./aws_network"
  vpc_cidr      = var.vpc_cidr
  private1_cidr = var.private1_cidr
  private2_cidr = var.private2_cidr
  az1           = var.az1
  az2           = var.az2
}

module "rds" {
  source     = "./rds"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  db_name    = var.db_name
  username   = var.db_username
  password   = var.db_password
}

module "lambdas" {
  source            = "./lambdas"
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = module.rds.security_group_id
  db_host           = module.rds.address
  db_name           = module.rds.db_name
  db_user           = module.rds.username
  db_password       = module.rds.password
  lambda_dir        = var.lambda_dir
}

module "cloud_run" {
  source           = "./cloud_run"
  region           = var.region
  project_id       = var.project_id
  flask_dir        = var.flask_dir
  get_products_url = module.lambdas.get_product_invoke_arn
  add_product_url  = module.lambdas.add_product_invoke_arn
  buy_product_url  = module.lambdas.buy_product_invoke_arn
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