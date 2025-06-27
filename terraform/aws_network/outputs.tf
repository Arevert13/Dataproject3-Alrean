output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.network.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}


output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.sg_rds.id
}

output "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.sg_lambda.id
}

output "private_db_subnet_group_name" {
  description = "Name of the private DB subnet group for RDS"
  value       = aws_db_subnet_group.rds_private.name
}

output "public_db_subnet_group_name" {
  description = "Name of the public DB subnet group for Datastream"
  value       = aws_db_subnet_group.rds_public_datastream.name
}

output "parameter_group_name" {
  description = "Name of the parameter group for logical replication"
  value       = aws_db_parameter_group.pg_logical.name
}
