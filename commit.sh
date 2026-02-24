#!/usr/bin/env bash
set -euo pipefail

CHANGELOG="docs/CHANGELOG.md"
TYPES=("feat" "fix" "docs" "refactor" "perf" "test" "chore")
ENTRIES=()

# ── Phase 1: Collect all inputs ──────────────────────────────────────────────

# Commit entries
while true; do
  echo ""
  if [ ${#ENTRIES[@]} -eq 0 ]; then
    echo "Select type:"
  else
    echo "Select type (Enter to finish):"
  fi
  echo "  1) feat      3) docs      5) perf      7) chore"
  echo "  2) fix       4) refactor  6) test"
  printf "#? "
  read -r choice

  if [ -z "$choice" ]; then
    if [ ${#ENTRIES[@]} -eq 0 ]; then
      echo "At least one entry is required."
      continue
    fi
    break
  fi

  if ! [[ "$choice" =~ ^[1-7]$ ]]; then
    echo "Invalid choice."
    continue
  fi

  TYPE="${TYPES[$((choice - 1))]}"

  printf "Description: "
  read -r desc

  if [ -z "$desc" ]; then
    echo "Description cannot be empty."
    continue
  fi

  ENTRIES+=("${TYPE}:${desc}")
  echo "Added: ${TYPE}: ${desc}"
done

# Version bump
CURRENT_VERSION=$(grep -E '^version: ' pubspec.yaml | sed 's/version: //')
IFS='.' read -r V_MAJOR V_MINOR V_PATCH <<< "$CURRENT_VERSION"

echo ""
echo "Current version: ${CURRENT_VERSION}"
echo "Bump version?"
echo "  1) major (${CURRENT_VERSION} → $((V_MAJOR + 1)).0.0)"
echo "  2) minor (${CURRENT_VERSION} → ${V_MAJOR}.$((V_MINOR + 1)).0)"
echo "  3) patch (${CURRENT_VERSION} → ${V_MAJOR}.${V_MINOR}.$((V_PATCH + 1)))"
echo "  Enter) skip"
printf "#? "
read -r bump_choice

NEW_VERSION=""
case "$bump_choice" in
  1) NEW_VERSION="$((V_MAJOR + 1)).0.0" ;;
  2) NEW_VERSION="${V_MAJOR}.$((V_MINOR + 1)).0" ;;
  3) NEW_VERSION="${V_MAJOR}.${V_MINOR}.$((V_PATCH + 1))" ;;
esac

# Push
echo ""
printf "Push to origin? [Y/n] "
read -r push_choice
DO_PUSH=false
if [ -z "$push_choice" ] || [[ "$push_choice" =~ ^[Yy]$ ]]; then
  DO_PUSH=true
fi

# Build workflow (only ask if pushing)
DO_BUILD=false
if [ "$DO_PUSH" = true ]; then
  printf "Trigger build workflow? [Y/n] "
  read -r build_choice
  if [ -z "$build_choice" ] || [[ "$build_choice" =~ ^[Yy]$ ]]; then
    DO_BUILD=true
  fi
fi

# ── Phase 2: Execute ─────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════"
echo ""

# Build commit message
COMMIT_MSG=""
for entry in "${ENTRIES[@]}"; do
  TYPE="${entry%%:*}"
  DESC="${entry#*:}"
  if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="${TYPE}: ${DESC}"
  else
    COMMIT_MSG="${COMMIT_MSG}, ${TYPE}: ${DESC}"
  fi
done

# Update changelog
printf '%s\n' "${ENTRIES[@]}" | python3 - "$CHANGELOG" "$NEW_VERSION" <<'PYTHON'
import sys
from datetime import date

changelog_path = sys.argv[1]
version = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else None

entries = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    colon = line.index(":")
    entries.append((line[:colon], line[colon + 1:]))

if not entries:
    sys.exit(0)

type_map = {
    "feat": "Features",
    "fix": "Fixes",
    "docs": "Documentation",
    "refactor": "Refactoring",
    "perf": "Performance",
    "test": "Tests",
    "chore": "Chores",
}

today = date.today().isoformat()
today_prefix = f"## {today}"

if version:
    today_header = f"## {today} — v{version}"
else:
    today_header = today_prefix

with open(changelog_path, "r") as f:
    content = f.read()

lines = content.split("\n")

header_end = 0
for i, line in enumerate(lines):
    if line.startswith("## "):
        header_end = i
        break
else:
    header_end = len(lines)
    while header_end > 0 and lines[header_end - 1].strip() == "":
        header_end -= 1

header_lines = lines[:header_end]
body_lines = lines[header_end:]

# Find existing today section (with or without version suffix)
found_today = False
for i, line in enumerate(body_lines):
    stripped = line.strip()
    if stripped == today_prefix or stripped.startswith(today_prefix + " — v"):
        body_lines[i] = today_header
        found_today = True
        break

if not found_today:
    body_lines = ["", today_header] + body_lines

today_start = None
today_end = None
for i, line in enumerate(body_lines):
    if line.strip() == today_header:
        today_start = i
    elif today_start is not None and line.startswith("## "):
        today_end = i
        break
if today_end is None:
    today_end = len(body_lines)

today_block = body_lines[today_start:today_end]

for commit_type, description in entries:
    section = type_map[commit_type]
    section_header = f"### {section}"

    section_idx = None
    for i, line in enumerate(today_block):
        if line.strip() == section_header:
            section_idx = i
            break

    if section_idx is None:
        insert_at = len(today_block)
        while insert_at > 0 and today_block[insert_at - 1].strip() == "":
            insert_at -= 1
        today_block.insert(insert_at, "")
        today_block.insert(insert_at + 1, section_header)
        today_block.insert(insert_at + 2, f"- {description}")
    else:
        insert_at = section_idx + 1
        while insert_at < len(today_block) and today_block[insert_at].startswith("- "):
            insert_at += 1
        today_block.insert(insert_at, f"- {description}")

body_lines = today_block + body_lines[today_end:]

output = "\n".join(header_lines + body_lines)
output = output.rstrip("\n") + "\n"

with open(changelog_path, "w") as f:
    f.write(output)

for commit_type, description in entries:
    print(f"  [{type_map[commit_type]}] {description}")
PYTHON

echo "Changelog updated."

# Version bump
if [ -n "$NEW_VERSION" ]; then
  sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
  echo "Version bumped: ${CURRENT_VERSION} → ${NEW_VERSION}"
fi

# Commit
git add -A
git commit -m "$COMMIT_MSG"

# Push
if [ "$DO_PUSH" = true ]; then
  git push
  if [ "$DO_BUILD" = true ]; then
    echo "Triggering build workflow..."
    gh workflow run build.yml --ref main
    echo "Build triggered."
  fi
fi
