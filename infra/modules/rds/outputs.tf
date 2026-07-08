output "db_address" {
  description = "RDS database address."
  value       = aws_db_instance.postgres.address
}

output "db_endpoint" {
  description = "RDS database endpoint."
  value       = aws_db_instance.postgres.endpoint
}

output "db_port" {
  description = "RDS database port."
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "RDS database name."
  value       = aws_db_instance.postgres.db_name
}

output "db_username" {
  description = "RDS master username."
  value       = aws_db_instance.postgres.username
}

output "db_password_secret_arn" {
  description = "Secrets Manager ARN for the RDS password."
  value       = aws_secretsmanager_secret.db_password.arn
}

output "rds_security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.rds.id
}
