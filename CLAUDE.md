# CLAUDE.md

AI-specific working guide for this codebase.

---

## 1. Purpose of This File

This file instructs AI agents how to work safely with this codebase.

- `CLAUDE.md` defines boundaries, assumptions, and safe defaults for AI agents.
- `PROJECT.md` is the authoritative DESIGN reference.
- "Authoritative" means intended behavior, not guaranteed correctness.
- The current implementation may contain bugs or incomplete features.
- This file does NOT replace or duplicate `PROJECT.md`.

---

## 2. Primary Documentation Reference

**Authoritative design document:** `PROJECT.md`

This document represents the intended architecture and behavior.

### Discrepancy Rules

When documentation and code disagree:

1. Do NOT assume the documentation is wrong.
2. Do NOT assume the code is correct.
3. Do NOT auto-fix either side.
4. Clearly describe the mismatch.
5. STOP.
6. Ask for explicit instructions before proceeding.

---

## 3. How Claude Should Work in This Project

### Core Principles

- **Feature-first approach:** Changes serve user-facing features.
- **Offline-first mindset:** Local database is the source of truth for the client.

### Mandatory Patterns

Strict respect required for:

- **Repository pattern:** All data access through repositories.
- **Outbox pattern:** All mutations queued for sync.
- **Last Write Wins (LWW):** Conflict resolution strategy.

### Architectural Boundaries

- No business logic in UI.
- No direct database access outside repositories.
- No direct network access outside repositories.

---

## 4. Read-Only Exploration Policy

### Pre-Approved Operations

All READ-ONLY operations are explicitly pre-approved and encouraged:

- Reading project source code
- Inspecting repositories, models, providers, services
- Reading Drift (SQLite) schemas and generated SQL
- Reading Supabase (PostgreSQL) schemas, enums, triggers, RLS policies
- Executing or proposing SELECT-only SQL queries

### Scope

Applies to:

- Local Drift database
- Supabase server database

Read-only operations do NOT require confirmation.

### Forbidden Without Approval

- INSERT, UPDATE, DELETE statements
- Schema migrations
- Trigger or RLS changes
- Data backfills or fixes
- Any operation that mutates state

---

## 5. Explicit Do / Do Not Rules

### DO NOT

- Invent new architecture layers.
- Restructure `lib/core` or `lib/features`.
- Introduce alternative state management.
- Bypass repositories, sync engine, or permission checks.
- Hardcode UI strings.
- Add notifications, snackbars, toasts, or any user-facing messages/alerts. The project intentionally has none.
- Add features, functions, screens, UI elements, or any functionality not explicitly requested.
- Assume something was "forgotten" and silently add it.

### DO

- Respect existing conventions even if verbose.
- Follow patterns established in `PROJECT.md`.
- Reference existing implementations before creating new ones.

---

## 6. Safe Defaults for Changes

- Prefer minimal and incremental changes.
- Prefer extending existing patterns over new abstractions.

### STOP AND ASK Before Touching

- Database schema or migrations
- Sync engine or outbox
- Authentication or encryption
- Permission system
- Application initialization flow

---

## 7. Handling Ambiguity & Clarification Policy

If a request contains ambiguity or multiple interpretations:

1. Claude MUST ask clarifying questions BEFORE writing code.
2. Claude must not guess intent.
3. Questions should be minimal and decision-focused.
4. Proceed only after intent is clarified or approved.

### No Feature Invention

Claude MUST implement **only** what was explicitly requested. If Claude believes the user omitted something (a feature, function, validation, UI element, edge case handling, etc.), Claude MUST:

1. Point out what seems to be missing.
2. Ask whether it should be added.
3. Wait for approval before implementing.

Claude MUST NOT fill in perceived gaps on its own. The user decides scope — Claude executes it.

---

## 8. Change Impact Self-Check (MANDATORY)

Before any change, Claude MUST self-check impact on:

- [ ] Database schema or data
- [ ] Synchronization (outbox, LWW, pull)
- [ ] Permissions
- [ ] Offline behavior
- [ ] Backward compatibility

If impact is non-trivial, STOP and ask.

---

## 9. No Silent Behavior Change

Any change affecting the following MUST be explicitly described (what / why / who):

- Business logic
- User-visible behavior
- Sync timing or conflict resolution
- Permission enforcement

---

## 10. Analysis First, Code Second

For analysis or investigation tasks:

- Do NOT write or modify code unless explicitly asked.
- Default to reading, explaining, and outlining options.

---

## 11. Reference Before Creation

Before creating any new:

- Repository
- Provider
- Service
- Screen
- Widget
- Sync flow

Claude MUST find and reference an existing similar implementation.

---

## 12. Production Safety Bias

Prefer:

- Safer over cleaner
- Explicit over clever
- Verbose over implicit
- Backward-compatible over breaking

---

## 13. Documentation & Changelog Responsibilities

After every SUCCESSFUL and MERGED logical change:

### PROJECT.md Updates

If the change affects architecture, data flow, sync, auth, UI flows, or developer workflow:

- Update `PROJECT.md` accordingly.
- Keep updates minimal, factual, and consistent in tone.

### CHANGELOG.md Updates

Append an entry to `docs/CHANGELOG.md`:

- Grouped by date (YYYY-MM-DD + optional context, e.g. "(evening)")
- Structured by sections (e.g. Features, Sync, Auth, Documentation)
- Written in concise, factual bullet points
- Matching the existing changelog style

---

## 14. Git & Commit Policy

- Claude MUST NEVER create a git commit.
- Claude MUST NEVER run git commit commands.

Instead, Claude MUST provide a ready-to-copy commit message:

- Using Conventional Commits format
- Describing the change clearly and concisely
- Suitable for direct paste into `git commit -m`
- Do NOT include "Co-Authored-By" trailer

---

## 15. Language, Style & Conventions

- **Code, comments, logs:** English only.
- **UI text:** Localization only via `context.l10n`.
- **Naming conventions:** Follow `PROJECT.md`.
- **Logging:** Use `AppLogger`, never `print()`.

---

## 16. UI Patterns

### Responsive Chip/Button Bars (Default)

Horizontal rows of buttons, filters, or tabs MUST fill the full available width by default.

**Pattern:**

```dart
Row(
  children: [
    for (final item in items) ...[
      if (notFirst) const SizedBox(width: 8),
      Expanded(
        child: SizedBox(
          height: 40,
          child: FilterChip(
            label: SizedBox(
              width: double.infinity,
              child: Text(item.label, textAlign: TextAlign.center),
            ),
            selected: item.isSelected,
            onSelected: ...,
          ),
        ),
      ),
    ],
  ],
)
```

**Rules:**

- Each chip/button wrapped in `Expanded` so they share width equally.
- Label uses `SizedBox(width: double.infinity)` for full-width text.
- Text is centered (`textAlign: TextAlign.center`).
- When text overflows, it clips naturally (no ellipsis) — the chip's rounded edge creates a soft fade effect.
- Fixed `SizedBox(height: ...)` ensures uniform height.
- Applies to: toolbar buttons, filter bars, section tabs, grid tiles, category buttons.

### Touch-First

- PIN entry uses numpad (not TextField).
- Buttons must be large enough for touch interaction (minimum 40px height).

---

## 17. Database Guidelines (Drift)

### Development Mode

- **Žádné migrace** — při změně schématu smazat lokální DB soubor a restartovat aplikaci
- **Indexy** — definovat přes `@TableIndex` anotace (ne manuální SQL)
- **Migrace pro produkci** — budou přidány až při reálném nasazení

### Změna schématu (development)

```bash
# 1. Upravit definici tabulky v lib/core/database/tables/
# 2. Regenerovat Drift kód
dart run build_runner build --delete-conflicting-outputs
# 3. Smazat lokální DB (umístěna v ~/Documents, ne v kořenu projektu)
rm -f ~/Documents/epos_database.sqlite
# 4. Spustit aplikaci
```
