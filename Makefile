SHELL := /usr/bin/env bash

.PHONY: db-up db-down db-reset db-query db-explain db-backup db-restore tf-fmt tf-plan-dev tf-plan-prod

db-up:
	docker compose up -d

db-down:
	docker compose down

db-reset:
	docker compose down -v
	docker compose up -d

db-query:
	docker compose exec -T postgres psql -U $${POSTGRES_USER:-app} -d $${POSTGRES_DB:-hotel} < queries/optimized_report.sql

db-explain:
	docker compose exec -T postgres psql -U $${POSTGRES_USER:-app} -d $${POSTGRES_DB:-hotel} < queries/explain_optimized_report.sql

db-backup:
	./scripts/backup.sh

db-restore:
	./scripts/restore.sh

tf-fmt:
	terraform fmt -recursive infra

tf-plan-dev:
	terraform -chdir=infra/envs/dev init
	terraform -chdir=infra/envs/dev validate
	terraform -chdir=infra/envs/dev plan -refresh=false

tf-plan-prod:
	terraform -chdir=infra/envs/prod init
	terraform -chdir=infra/envs/prod validate
	terraform -chdir=infra/envs/prod plan -refresh=false
