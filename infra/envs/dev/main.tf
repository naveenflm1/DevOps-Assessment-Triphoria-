locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Assessment  = "terraform-database-reliability"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix     = local.name_prefix
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  aws_region         = var.aws_region
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  container_image = var.container_image
  container_port  = var.container_port
  desired_count   = var.ecs_desired_count
  cpu             = var.ecs_task_cpu
  memory          = var.ecs_task_memory

  db_host                = module.rds.db_address
  db_port                = module.rds.db_port
  db_name                = module.rds.db_name
  db_username            = module.rds.db_username
  db_password_secret_arn = module.rds.db_password_secret_arn

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id

  db_name        = var.rds_database_name
  db_username    = var.rds_username
  engine_version = var.rds_engine_version

  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.rds_backup_retention_period
  deletion_protection     = var.rds_deletion_protection
  skip_final_snapshot     = var.rds_skip_final_snapshot
  multi_az                = var.rds_multi_az

  tags = local.common_tags
}
