#!/usr/bin/env bash
set -euo pipefail

CHANGELOG="docs/CHANGELOG.md"
TYPES=("feat" "fix" "docs" "refactor" "perf" "test" "chore")
TYPE_LABELS=("feat      — new feature" "fix       — bug fix" "docs      — documentation" "refactor  — code refactoring" "perf      — performance" "test      — tests" "chore     — maintenance")
ENTRIES=()

# ── Arrow-key menu ───────────────────────────────────────────────────────────

menu_select() {
  local prompt="$1"
  shift
  local options=("$@")
  local selected=-1
  local count=${#options[@]}

  tput civis 2>/dev/null
  trap 'tput cnorm 2>/dev/null' RETURN

  printf "\n%s\n" "$prompt"

  for i in "${!options[@]}"; do
    printf "   %s\n" "${options[$i]}"
  done

  while true; do
    read -rsn1 key
    case "$key" in
      '')
        # Enter — only accept if something is selected
        [ $selected -ge 0 ] && break
        ;;
      $'\x1b')
        read -rsn2 key
        case "$key" in
          '[A')
            if [ $selected -le 0 ]; then
              selected=$((count - 1))
            else
              ((selected--))
            fi
            ;;
          '[B')
            if [ $selected -lt 0 ] || [ $selected -ge $((count - 1)) ]; then
              selected=0
            else
              ((selected++))
            fi
            ;;
        esac
        ;;
    esac

    printf "\033[%dA" "$count"
    for i in "${!options[@]}"; do
      printf "\033[2K"
      if [ $i -eq $selected ]; then
        printf "  \033[7m %s \033[0m\n" "${options[$i]}"
      else
        printf "   %s\n" "${options[$i]}"
      fi
    done
  done

  tput cnorm 2>/dev/null
  trap - RETURN
  MENU_RESULT=$selected
}

# ── Phase 1: Collect all inputs ──────────────────────────────────────────────

# Commit entries
while true; do
  if [ ${#ENTRIES[@]} -gt 0 ]; then
    menu_options=("── Done ──" "${TYPE_LABELS[@]}")
    menu_select "Select type (or Done):" "${menu_options[@]}"

    if [ $MENU_RESULT -eq 0 ]; then
      break
    fi
    TYPE="${TYPES[$((MENU_RESULT - 1))]}"
  else
    menu_select "Select type:" "${TYPE_LABELS[@]}"
    TYPE="${TYPES[$MENU_RESULT]}"
  fi

  printf "Description: "
  read -r desc

  if [ -z "$desc" ]; then
    echo "Description cannot be empty."
    continue
  fi

  ENTRIES+=("${TYPE}:${desc}")
  echo "  Added: ${TYPE}: ${desc}"
done

# Version bump
CURRENT_VERSION=$(grep -E '^version: ' pubspec.yaml | sed 's/version: //')
IFS='.' read -r V_MAJOR V_MINOR V_PATCH <<< "$CURRENT_VERSION"

BUMP_OPTIONS=(
  "patch  (${CURRENT_VERSION} → ${V_MAJOR}.${V_MINOR}.$((V_PATCH + 1)))"
  "minor  (${CURRENT_VERSION} → ${V_MAJOR}.$((V_MINOR + 1)).0)"
  "major  (${CURRENT_VERSION} → $((V_MAJOR + 1)).0.0)"
  "skip"
)
menu_select "Bump version? (current: ${CURRENT_VERSION})" "${BUMP_OPTIONS[@]}"

NEW_VERSION=""
case "$MENU_RESULT" in
  0) NEW_VERSION="${V_MAJOR}.${V_MINOR}.$((V_PATCH + 1))" ;;
  1) NEW_VERSION="${V_MAJOR}.$((V_MINOR + 1)).0" ;;
  2) NEW_VERSION="$((V_MAJOR + 1)).0.0" ;;
esac

# Push & build
PUSH_OPTIONS=("no" "push only" "push + build")
menu_select "Push to origin?" "${PUSH_OPTIONS[@]}"

DO_PUSH=false
DO_BUILD=false
case "$MENU_RESULT" in
  1) DO_PUSH=true ;;
  2) DO_PUSH=true; DO_BUILD=true ;;
esac

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
