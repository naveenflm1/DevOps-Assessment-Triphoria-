variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS resources will run."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Fargate tasks."
  type        = list(string)
}


variable "aws_region" {
  description = "AWS region used by the awslogs driver."
  type        = string
}

variable "container_image" {
  description = "Container image to run."
  type        = string
}

variable "container_port" {
  description = "Container port exposed through the ALB target group."
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Desired ECS service task count."
  type        = number
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
}

variable "health_check_path" {
  description = "ALB health check path."
  type        = string
  default     = "/"
}

variable "db_host" {
  description = "RDS hostname passed to the task as DB_HOST."
  type        = string
}

variable "db_port" {
  description = "RDS port passed to the task as DB_PORT."
  type        = number
}

variable "db_name" {
  description = "Database name passed to the task as DB_NAME."
  type        = string
}

variable "db_username" {
  description = "Database username passed to the task as DB_USER."
  type        = string
}

variable "db_password_secret_arn" {
  description = "Secrets Manager secret ARN containing the database password."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
