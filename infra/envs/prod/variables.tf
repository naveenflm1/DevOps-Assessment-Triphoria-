variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDRs and Availability Zones."
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnet CIDRs and Availability Zones."
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "container_image" {
  description = "Application container image."
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "container_port" {
  description = "Application container port."
  type        = number
  default     = 80
}

variable "ecs_desired_count" {
  description = "Desired ECS service task count."
  type        = number
}

variable "ecs_task_cpu" {
  description = "Fargate task CPU units."
  type        = number
}

variable "ecs_task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
}

variable "rds_database_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "hotel"
}

variable "rds_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "hotel_admin"
}

variable "rds_engine_version" {
  description = "PostgreSQL RDS engine version."
  type        = string
  default     = "16.3"
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
}

variable "rds_max_allocated_storage" {
  description = "RDS maximum autoscaled storage in GB."
  type        = number
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention period in days."
  type        = number
}

variable "rds_deletion_protection" {
  description = "Whether RDS deletion protection is enabled."
  type        = bool
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final RDS snapshot on destroy."
  type        = bool
}

variable "rds_multi_az" {
  description = "Whether RDS should run in Multi-AZ mode."
  type        = bool
}
