variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will run."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Only this ECS security group is allowed to reach the database."
  type        = string
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GB."
  type        = number
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when destroying the DB instance."
  type        = bool
}

variable "multi_az" {
  description = "Whether RDS should run in Multi-AZ mode."
  type        = bool
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
