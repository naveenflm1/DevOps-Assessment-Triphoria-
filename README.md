# DevOps Assessment: Terraform + Database Reliability

This repository is a complete assessment project for designing AWS infrastructure with Terraform and demonstrating practical PostgreSQL backup, restore, and query optimization workflows.

The AWS side is intentionally **plan-only** and can be reviewed with `terraform fmt`, `terraform validate`, and `terraform plan -refresh=false`. The database side runs locally with Docker Compose.

## What is included

| Assessment area | Implementation |
| --- | --- |
| AWS infrastructure design | `infra/modules/network`, `infra/modules/ecs`, `infra/modules/rds` |
| Dev and prod Terraform environments | `infra/envs/dev`, `infra/envs/prod` |
| Backend state configuration | Local backend per environment, plus S3 backend examples |
| GitHub Actions Terraform plan | `.github/workflows/terraform-plan.yml` |
| Local PostgreSQL database | `docker-compose.yml` |
| Migrations and indexes | `db/migrations` |
| Seed data | `db/seeds/001_seed_data.sql` |
| Backup and restore scripts | `scripts/backup.sh`, `scripts/restore.sh` |
| Query verification | `queries/optimized_report.sql`, `queries/explain_optimized_report.sql` |

## Repository layout

```text
.
├── .github/
│   └── workflows/
│       └── terraform-plan.yml
├── db/
│   ├── init/
│   │   └── 001_run_migrations.sh
│   ├── migrations/
│   │   ├── 001_create_tables.sql
│   │   └── 002_add_indexes.sql
│   └── seeds/
│       └── 001_seed_data.sql
├── infra/
│   ├── envs/
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
│       ├── ecs/
│       ├── network/
│       └── rds/
├── queries/
├── scripts/
├── docker-compose.yml
├── Makefile
└── README.md
```

## Prerequisites

Install these tools before running the project:

- Docker and Docker Compose v2
- Terraform 1.5 or newer
- Bash

## Local database setup

Start PostgreSQL:

```bash
docker compose up -d
```

The first startup runs the migration and seed files automatically through `db/init/001_run_migrations.sh`.

Default local database settings are:

| Setting | Value |
| --- | --- |
| Host | `localhost` |
| Port | `5432` |
| Database | `hotel` |
| User | `app` |
| Password | `app_password` |

You can override these values by copying `.env.example` to `.env` and changing the values.

### Verify seed data

```bash
docker compose exec postgres psql -U app -d hotel -c "SELECT COUNT(*) AS bookings FROM hotel_bookings;"
docker compose exec postgres psql -U app -d hotel -c "SELECT COUNT(*) AS events FROM booking_events;"
```

Expected result: at least 150 bookings and many related booking events.

## Query optimization

The target query is:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

The migration `db/migrations/002_add_indexes.sql` adds this index:

```sql
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_org_status
ON hotel_bookings (city, created_at DESC, org_id, status)
INCLUDE (amount);
```

### Why this index

The query has an equality filter on `city`, a range filter on `created_at`, and groups by `org_id` and `status`. Putting `city` first lets PostgreSQL quickly isolate one city. Keeping `created_at` next supports the recent-date range filter. Adding `org_id` and `status` helps the grouped aggregation after filtering. Including `amount` gives the planner the option to satisfy the `SUM(amount)` from the index, which can reduce heap reads when the table is larger and visibility-map conditions allow an index-only scan.

Run the optimized query:

```bash
docker compose exec -T postgres psql -U app -d hotel < queries/optimized_report.sql
```

Run an execution plan:

```bash
docker compose exec -T postgres psql -U app -d hotel < queries/explain_optimized_report.sql
```

## Backup and restore

Create a timestamped compressed PostgreSQL dump:

```bash
./scripts/backup.sh
```

Backups are written to `backups/` and named like:

```text
hotel_20260707_143012.dump
```

Restore the latest backup into a fresh local database named `hotel_restore`:

```bash
./scripts/restore.sh
```

Restore a specific backup:

```bash
./scripts/restore.sh backups/hotel_YYYYMMDD_HHMMSS.dump
```

Restore into a custom database name:

```bash
RESTORE_DB=hotel_restore_test ./scripts/restore.sh backups/hotel_YYYYMMDD_HHMMSS.dump
```

### Verify restore worked

The restore script prints row counts for both tables. You can also verify manually:

```bash
docker compose exec postgres psql -U app -d hotel_restore -c "SELECT COUNT(*) FROM hotel_bookings;"
docker compose exec postgres psql -U app -d hotel_restore -c "SELECT COUNT(*) FROM booking_events;"
```

The counts should match the source database at the time the backup was created.

## Terraform design

The Terraform design models this path:

```text
Internet -> Application Load Balancer -> ECS/Fargate -> private RDS PostgreSQL
```

The main infrastructure choices are:

- VPC with public and private subnets across two Availability Zones.
- Public ALB security group allowing HTTP from the internet.
- ECS/Fargate security group allowing inbound traffic only from the ALB security group.
- RDS security group allowing PostgreSQL traffic only from the ECS/Fargate security group.
- ECS tasks run in private subnets without public IP addresses.
- RDS is private with `publicly_accessible = false`.
- RDS credentials are generated with Terraform and stored in AWS Secrets Manager.
- The ECS task definition references the RDS endpoint and reads the database password from Secrets Manager.

### Environment differences

| Setting | Dev | Prod |
| --- | --- | --- |
| ECS desired count | 1 | 2 |
| ECS task size | 256 CPU / 512 MB | 512 CPU / 1024 MB |
| RDS instance class | `db.t4g.micro` | `db.t4g.small` |
| RDS allocated storage | 20 GB | 50 GB |
| RDS max autoscaled storage | 50 GB | 200 GB |
| RDS backup retention | 1 day | 14 days |
| RDS deletion protection | `false` | `true` |
| RDS Multi-AZ | `false` | `true` |
| Final snapshot on delete | skipped | required |

### Terraform validation commands

Run from the repository root:

```bash
terraform fmt -recursive -check infra
```

Validate and plan dev:

```bash
terraform -chdir=infra/envs/dev init
terraform -chdir=infra/envs/dev validate
terraform -chdir=infra/envs/dev plan -refresh=false
```

Validate and plan prod:

```bash
terraform -chdir=infra/envs/prod init
terraform -chdir=infra/envs/prod validate
terraform -chdir=infra/envs/prod plan -refresh=false
```

### About AWS credentials

The provider files use mock AWS credentials and skip remote account validation so that reviewers can run `terraform plan -refresh=false` without deploying anything or requiring AWS access. This is intentional for assessment review only.

For a real deployment, remove the mock credentials from `providers.tf`, configure AWS credentials through your normal secure method, switch the backend to S3, and run a normal `terraform plan` before applying.

## GitHub Actions

The workflow in `.github/workflows/terraform-plan.yml` runs on pull requests and workflow dispatch. It performs:

1. `terraform fmt -check -recursive infra`
2. `terraform init`
3. `terraform validate`
4. `terraform plan -refresh=false`
5. Uploads the Terraform plan output as a workflow artifact for each environment

## Useful Make targets

```bash
make db-up
make db-query
make db-explain
make db-backup
make db-restore
make tf-fmt
make tf-plan-dev
make tf-plan-prod
```

## Cleanup

Stop the local database:

```bash
docker compose down
```

Remove the local PostgreSQL volume as well:

```bash
docker compose down -v
```
