#!/usr/bin/env bash
set -euo pipefail

POSTGRES_SERVICE="${POSTGRES_SERVICE:-postgres}"
POSTGRES_USER="${POSTGRES_USER:-app}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
RESTORE_DB="${RESTORE_DB:-hotel_restore}"
BACKUP_FILE="${1:-}"

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

safe_identifier() {
  [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

latest_backup() {
  find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.dump' -print 2>/dev/null | sort | tail -n 1
}

wait_for_database() {
  for _ in {1..30}; do
    if compose exec -T "$POSTGRES_SERVICE" pg_isready -U "$POSTGRES_USER" -d postgres >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "PostgreSQL is not ready. Check 'docker compose logs postgres'." >&2
  exit 1
}

if ! safe_identifier "$RESTORE_DB"; then
  echo "RESTORE_DB must be a safe PostgreSQL identifier. Received: $RESTORE_DB" >&2
  exit 1
fi

if [[ -z "$BACKUP_FILE" ]]; then
  BACKUP_FILE="$(latest_backup)"
fi

if [[ -z "$BACKUP_FILE" || ! -f "$BACKUP_FILE" ]]; then
  echo "No backup file found. Run ./scripts/backup.sh first or pass a .dump file path." >&2
  exit 1
fi

compose up -d "$POSTGRES_SERVICE" >/dev/null
wait_for_database

echo "Restoring $BACKUP_FILE into fresh database: $RESTORE_DB"

compose exec -T "$POSTGRES_SERVICE" psql \
  -U "$POSTGRES_USER" \
  -d postgres \
  -v ON_ERROR_STOP=1 <<SQL
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '$RESTORE_DB'
  AND pid <> pg_backend_pid();
DROP DATABASE IF EXISTS "$RESTORE_DB";
CREATE DATABASE "$RESTORE_DB" OWNER "$POSTGRES_USER";
SQL

compose exec -T "$POSTGRES_SERVICE" pg_restore \
  -U "$POSTGRES_USER" \
  -d "$RESTORE_DB" \
  --no-owner \
  --no-privileges \
  < "$BACKUP_FILE"

compose exec -T "$POSTGRES_SERVICE" psql \
  -U "$POSTGRES_USER" \
  -d "$RESTORE_DB" \
  -c "SELECT 'hotel_bookings' AS table_name, COUNT(*) AS row_count FROM hotel_bookings UNION ALL SELECT 'booking_events', COUNT(*) FROM booking_events ORDER BY table_name;"

echo "Restore completed successfully."
