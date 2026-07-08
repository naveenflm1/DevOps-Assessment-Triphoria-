#!/usr/bin/env bash
set -euo pipefail

POSTGRES_SERVICE="${POSTGRES_SERVICE:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-hotel}"
POSTGRES_USER="${POSTGRES_USER:-app}"
BACKUP_DIR="${BACKUP_DIR:-backups}"

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "Docker Compose is required but was not found." >&2
    exit 1
  fi
}

wait_for_database() {
  for _ in {1..30}; do
    if compose exec -T "$POSTGRES_SERVICE" pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "PostgreSQL is not ready. Check 'docker compose logs postgres'." >&2
  exit 1
}

mkdir -p "$BACKUP_DIR"
compose up -d "$POSTGRES_SERVICE" >/dev/null
wait_for_database

timestamp="$(date +%Y%m%d_%H%M%S)"
backup_file="$BACKUP_DIR/${POSTGRES_DB}_${timestamp}.dump"

compose exec -T "$POSTGRES_SERVICE" pg_dump \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  --format=custom \
  --no-owner \
  --no-privileges \
  > "$backup_file"

echo "Backup created: $backup_file"
