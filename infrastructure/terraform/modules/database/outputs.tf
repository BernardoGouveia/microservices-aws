# Saídas do módulo de base de dados (endpoint e metadados de ligação).

output "endpoint" {
  description = "Connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname of the database."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Database port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username."
  value       = aws_db_instance.this.username
}

output "security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.db.id
}

output "instance_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}
