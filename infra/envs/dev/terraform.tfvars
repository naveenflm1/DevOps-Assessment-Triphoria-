project_name = "devops-assessment"
environment  = "dev"
aws_region   = "ap-south-1"

vpc_cidr = "10.20.0.0/16"

public_subnets = [
  {
    cidr = "10.20.1.0/24"
    az   = "ap-south-1a"
  },
  {
    cidr = "10.20.2.0/24"
    az   = "ap-south-1b"
  }
]

private_subnets = [
  {
    cidr = "10.20.11.0/24"
    az   = "ap-south-1a"
  },
  {
    cidr = "10.20.12.0/24"
    az   = "ap-south-1b"
  }
]

container_image = "nginx:1.27-alpine"
container_port  = 80

# Small and cost-conscious for development.
ecs_desired_count = 1
ecs_task_cpu      = 256
ecs_task_memory   = 512

rds_database_name            = "hotel"
rds_username                 = "hotel_admin"
rds_engine_version           = "16.3"
rds_instance_class           = "db.t4g.micro"
rds_allocated_storage        = 20
rds_max_allocated_storage    = 50
rds_backup_retention_period  = 1
rds_deletion_protection      = false
rds_skip_final_snapshot      = true
rds_multi_az                 = false
