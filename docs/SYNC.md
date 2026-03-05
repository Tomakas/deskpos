# Maty — Synchronization Engine

Detailní popis offline-first architektury, synchronizace dat a vnitřní logiky backendu.

---

## 1. Přehled architektury

Aplikace používá čtyři kanály pro komunikaci:
1. **Push (Outbox):** Klient → Ingest Edge Function → PostgreSQL.
2. **Realtime:** Server → Realtime Service → Klienti (Broadcast from Database).
3. **Pull (Watermark):** Server → Sync Service → Klient (30s polling).
4. **Display:** Pokladna → Display Channel → Zákaznický displej.

---

## 2. Sync Lifecycle (Kompletní proces)

1. **Initial Push:** Po přihlášení `InitialSync` projde všechny tabulky v FK-respektujícím pořadí a zařadí existující lokální řádky do `sync_queue`.
2. **Drain Loop:** Processor v cyklu (max 50 iterací x 500 záznamů) vyprázdní frontu před spuštěním realtime služeb.
3. **Realtime Start:** Outbox (5s), Polling (30s) a Broadcast (<2s) běží paralelně.
4. **Reconnect:** Při obnově spojení okamžitý `pullAll` pro doplnění ztracených změn.

---

## 3. Ingest & Demo Logic

### Ingest Edge Function
- **Auth:** Validace JWT a lookup `companies.auth_user_id` dle `sub` claimu.
- **Zápis:** Přes `service_role` (obchází RLS).
- **Audit:** Zápis do write-only tabulky `audit_log`.
- **FK Rejection:** Pokud PostgreSQL vrátí chybu 23503, EF vrací `transient` error pro automatický retry po syncu rodiče.

### Create-Demo-Data Flow
1. Ověří JWT, získá `auth_user_id`.
2. Volá RPC `create_demo_company` (PL/pgSQL, ~1700 řádků).
3. Generuje 90denní historii (sessions, shifts, bills, payments).
4. Označí firmu jako `is_demo = true` s expirací 24h.

---

## 4. Conflict Resolution (LWW)

*   **Server-side:** Trigger `enforce_lww` na 42 tabulkách porovnává `client_updated_at`. Starší zápisy jsou odmítnuty s chybou `LWW_CONFLICT`.
*   **Pull-side:** Pokud entita existuje na obou stranách, novější `updatedAt` přepisuje starší lokální verzi.
*   **Outbox rejection:** Pokud server odmítne push (konflikt), záznam se označí jako dokončený a počká se na Pull.

---

## 5. Supabase Deployment Requirements

Při nasazení na nový projekt je nutné provést tyto kroky:
- `ALTER TYPE cash_movement_type ADD VALUE 'handover';`
- Nasadit broadcast triggery na 38 tabulkách.
- Nasadit RPC funkce `lookup_display_device_by_code` a `get_my_company_ids`.
- Konfigurace `pg_cron` pro hourly hard-delete expired demo firem.
- Povolit Anonymous sign-ins v Dashboardu.
