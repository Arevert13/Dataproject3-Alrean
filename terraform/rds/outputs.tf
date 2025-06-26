output "address" {
  value = aws_db_instance.postgres.address
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "username" {
  value = aws_db_instance.postgres.username
}

output "password" {
  value = aws_db_instance.postgres.password
}

output "security_group_id" {
  value = aws_security_group.rds.id
}