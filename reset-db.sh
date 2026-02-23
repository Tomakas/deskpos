#!/usr/bin/env bash
set -euo pipefail

URL="https://rrnvlsguhkelracusofe.supabase.co/functions/v1/reset-db"

LOCAL_DB="$HOME/Documents/epos_database.sqlite"

echo "This will DELETE all company data and auth users from Supabase"
echo "and remove the local SQLite database ($LOCAL_DB)."
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

# Remove local SQLite database
if [ -f "$LOCAL_DB" ]; then
  rm -f "$LOCAL_DB"
  echo "Local database deleted: $LOCAL_DB"
else
  echo "Local database not found (already clean)."
fi