#!/usr/bin/env bash
set -euo pipefail

URL="https://rrnvlsguhkelracusofe.supabase.co/functions/v1/reset-db"
LOCAL_DB_DIR="$HOME/Library/Application Support/com.example.maty"

echo "This will DELETE all company data and auth users from Supabase"
echo "and remove the local SQLite database in $LOCAL_DB_DIR."
echo "Global data (currencies, roles, permissions) will be preserved."
echo ""
printf "Password: "
read -rs SECRET
echo ""

if [ -z "$SECRET" ]; then
  echo "Cancelled."
  exit 0
fi

printf "Are you sure? [y/N] "
read -r confirm

if ! [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "Resetting database..."

response=$(curl -s -w "\n%{http_code}" -X POST "$URL" \
  -H "X-Reset-Secret: $SECRET")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
  echo "$body" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Deleted {data.get('deleted_rows', '?')} rows, {data.get('deleted_users', '?')} auth users.\")
if 'warnings' in data:
    print(f\"Warnings: {len(data['warnings'])}\")
    for w in data['warnings']:
        print(f\"  - {w}\")
print('Done.')
"
else
  echo "Failed (HTTP $http_code):"
  echo "$body"
  exit 1
fi

# Remove local SQLite database (includes WAL/SHM files)
LOCAL_DB="$LOCAL_DB_DIR/maty_database.sqlite"
if [ -f "$LOCAL_DB" ]; then
  rm -f "$LOCAL_DB" "$LOCAL_DB-wal" "$LOCAL_DB-shm"
  echo "Local database deleted: $LOCAL_DB"
else
  echo "Local database not found (already clean)."
fi
