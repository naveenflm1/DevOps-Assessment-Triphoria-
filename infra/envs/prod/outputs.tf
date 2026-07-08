output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Private RDS PostgreSQL endpoint."
  value       = module.rds.db_endpoint
}

output "rds_security_group_id" {
  description = "RDS security group ID."
  value       = module.rds.rds_security_group_id
}

output "db_password_secret_arn" {
  description = "Secrets Manager secret ARN for the database password."
  value       = module.rds.db_password_secret_arn
}
