project_name = "devops-assessment"
environment  = "prod"
aws_region   = "ap-south-1"

vpc_cidr = "10.30.0.0/16"

public_subnets = [
  {
    cidr = "10.30.1.0/24"
    az   = "ap-south-1a"
  },
  {
    cidr = "10.30.2.0/24"
    az   = "ap-south-1b"
  }
]

private_subnets = [
  {
    cidr = "10.30.11.0/24"
    az   = "ap-south-1a"
  },
  {
    cidr = "10.30.12.0/24"
    az   = "ap-south-1b"
  }
]

container_image = "nginx:1.27-alpine"
container_port  = 80

# Slightly larger and more resilient for production.
ecs_desired_count = 2
ecs_task_cpu      = 512
ecs_task_memory   = 1024

rds_database_name            = "hotel"
rds_username                 = "hotel_admin"
rds_engine_version           = "16.3"
rds_instance_class           = "db.t4g.small"
rds_allocated_storage        = 50
rds_max_allocated_storage    = 200
rds_backup_retention_period  = 14
rds_deletion_protection      = true
rds_skip_final_snapshot      = false
rds_multi_az                 = true
