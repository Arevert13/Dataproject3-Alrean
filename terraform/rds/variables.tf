variable "project_label" {
  type        = string
  description = "Etiqueta del proyecto para nombres y tags"
}

variable "common_tags" {
  type        = map(string)
  description = "Mapa de etiquetas comunes para aplicar a todos los recursos"
}

variable "db_name" {
  type        = string
  description = "Nombre de la base de datos inicial en RDS"
}

variable "db_username" {
  type        = string
  description = "Nombre de usuario de la base de datos"
}

variable "db_password" {
  type        = string
  description = "Contraseña de la base de datos"
  sensitive   = true
}

variable "db_subnet_group_name" {
  type        = string
  description = "Nombre del subnet group de RDS"
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs de subnets privadas donde vive RDS"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Lista de IDs de security groups para la instancia RDS"
}

variable "parameter_group_name" {
  type        = string
  description = "Nombre del parameter group de RDS"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Lambda deployment"
}
