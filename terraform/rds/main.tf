resource "aws_db_instance" "postgres" {
  identifier          = "ordinal-thinker-postgres"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = var.db_name
  username            = var.username
  password            = var.password
  skip_final_snapshot = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = true
  parameter_group_name   = var.parameter_group_name
}

resource "null_resource" "init_schema" {
  depends_on = [aws_db_instance.postgres]

  provisioner "local-exec" {
    command = <<EOT
export PGPASSWORD=${var.password}
for i in {1..30}; do
  psql "host=${aws_db_instance.postgres.address} port=5432 user=${var.username} dbname=${var.db_name} sslmode=require" -f ${path.module}/schema.sql && exit 0
  sleep 10
done
echo "Failed to apply schema" >&2
exit 1
EOT
  }


  
}
resource "null_resource" "init_rds_schema" {
  # se ejecuta sólo después de que cambie parameter_group_name o la dirección
  depends_on = [ aws_db_instance.postgres ]

  triggers = {
    pg_name = var.parameter_group_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      export PGPASSWORD='${var.password}'
      psql \
        --host='${aws_db_instance.postgres.address}' \
        --username='${var.username}' \
        --dbname='${var.db_name}' \
        --file='${path.module}/../scripts/schema.sql'
    EOT
  }
}