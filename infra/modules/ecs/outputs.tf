output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "alb_security_group_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS task security group ID."
  value       = aws_security_group.ecs_tasks.id
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.app.name
}
