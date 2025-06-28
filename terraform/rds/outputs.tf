output "address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.postgres.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "Database master username"
  value       = aws_db_instance.postgres.username
}

output "password" {
  description = "Database master password"
  value       = var.password
}
output "init_schema_id" {
  description = "ID of the schema initialization resource"
  value       = null_resource.init_schema.id
}

