# Maty — Technical Architecture

Detailní popis technologického stacku, vrstev aplikace a struktury zdrojového kódu.

---

## 1. Technologický Stack (Kompletní)
- **Flutter / Dart** — UI toolkit, multiplatformní (desktop + mobile).
- **Riverpod** — State management a dependency injection.
- **Freezed** — Code generation pro immutable modely.
- **Drift** — Reaktivní persistence nad SQLite.
- **Supabase** — Backend: Auth, Realtime, Database, Storage.
- **uuid (v7)** — Chronologické unikátní identifikátory.
- **go_router** — Deklarativní routing a navigace.
- **intl** — Formátování a lokalizace.
- **pdf & printing** — Generování a tisk PDF.
- **crypto** — Hashování PINů (SHA-256).
- **path_provider** — Přístup k systémovým adresářům.

---

## 2. Architektura vrstev

Projekt využívá hybridní architekturu: centralizovaná data + feature-first UI.

### 2.1 UI Layer (Presentation)
- **Komponenty:** Obrazovky (`Screen`), Widgety, Dialogy.
- **Odpovědnost:** Vykreslování stavu a zachytávání vstupů.
- **Pravidlo:** Žádná business logika v UI. UI pouze volá metody z notifierů.
- **Bez notifikací:** Žádné snackbary. Stav se zobrazuje přímo v UI komponentách.

### 2.2 Business Logic Layer (Application)
- **Komponenty:** `ConsumerStatefulWidget` s lokálním `setState()` pro UI stav, core providery pro sdílený stav.
- **Error Handling:** Použití typu `Result<T>` (`Success` / `Failure`) pro návratové hodnoty.

### 2.3 Data Layer (Domain/Data)
- **Odpovědnost:** Abstrakce zdroje dat, "Offline-first" logika.
- **Result Pattern:** Mutační operace vracejí `Success` nebo `Failure` místo throwování výjimek.
- **BaseCompanyScopedRepository:** CRUD metody s automatickým company scope.

---

## 3. Struktura projektu (lib/)

```text
lib/
├── main.dart                          # Supabase init + runApp
├── app.dart                           # MaterialApp.router
├── core/                              # Globální jádro
│   ├── auth/                          # PIN, sessions, hashing
│   ├── data/                          # Enums, mappers, modely, repositories, providers
│   ├── database/                      # Drift DB, tables
│   ├── widgets/                       # PosTable, PosNumpad, PosDialogShell, LockOverlay
│   ├── utils/                         # Formátování a pomocné funkce
│   ├── printing/                      # PDF buildeři a PrintingService
│   ├── routing/                       # GoRouter + auth guard
│   ├── network/                       # Supabase konfigurace
│   ├── sync/                          # Outbox, Realtime, Pull, Lifecycle
│   ├── theme/                         # Sémantické barvy
│   └── logging/                       # AppLogger
└── features/                          # Funkční moduly (UI)
    ├── auth/                          # Login
    ├── bills/                         # Účty, platba, cash management
    ├── catalog/                       # Správa entit
    ├── inventory/                     # Doklady, pohyby, inventury
    ├── onboarding/                    # Wizard
    ├── sell/                          # Grid + košík
    ├── settings/                      # Unified settings
    └── statistics/                    # Dashboard + grafy
```
