variable "project_id" {}
variable "region" {}
variable "project_name" {}
variable "rds_host" {}
variable "datastream_user" {}
variable "datastream_password" {}
variable "db_name" {}
variable "publication" {}
variable "replication_slot" {}

variable "db_init_dep" {
  description = "ID of DB initialization resource"
  type        = any
}