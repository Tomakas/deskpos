# Maty — Development Guide

Detailní příručka pro vývojáře, standardy, buildy a přehled infrastruktury.

---

## 1. Build příkazy

```bash
# Spuštění v Debug módu
flutter run

# Build pro produkci
flutter build macos --release    # macOS
flutter build linux --release    # Linux
flutter build windows --release  # Windows

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Instalace závislostí
flutter pub get
```

---

## 2. Windows distribuce (Inno Setup)

Windows build se distribuuje jako instalátor, který automaticky nainstaluje **VC++ Redistributable**.
- `windows/installer/maty.iss` — Inno Setup skript.
- `windows/installer/download-vcredist.ps1` — Skript pro stažení závislostí.
- **CI/CD:** GitHub Actions workflow (`build.yml`) automatizuje tvorbu release.

---

## 3. Logování (AppLogger)

Vždy používejte `lib/core/logging/app_logger.dart`.
- Implementace: `developer.log` (pro DevTools) + `debugPrint` (pro konzoli).
- Pravidla: Nevypisovat citlivá data. Logy pouze v angličtině. Debug/Info jsou v release vypnuty.

---

## 4. Coding Standards

### Jazyková pravidla
- **Identifikátory:** Angličtina.
- **Komentáře a TODO:** Angličtina.
- **UI Texty:** Lokalizované přes ARB soubory. Čeština je primární.
- **ARB klíče:** Angličtina (camelCase).

### Naming Conventions
- **Třídy:** `PascalCase`.
- **Soubory:** `snake_case.dart`.
- **Proměnné:** `camelCase`.
- **Konstanty:** `UPPER_SNAKE_CASE`.

---

## 5. Dependency Injection (Riverpod)

Kompletní seznam globálních providerů (v `core/data/providers/`):
- **database_provider.dart:** `appDatabaseProvider`.
- **auth_providers.dart:** `sessionManagerProvider`, `authServiceProvider`, `seedServiceProvider`, `deviceIdProvider`, `activeUserProvider`, `loggedInUsersProvider`, `companyStreamProvider`, `currentCompanyProvider`, `appInitProvider`, `activeRegisterProvider`, `activeRegisterSessionProvider`.
- **permission_providers.dart:** `userPermissionCodesProvider`, `hasPermissionProvider`, `hasAnyPermissionInGroupProvider`.
- **repository_providers.dart:** Providery pro všech **42 repozitářů**.
- **sync_providers.dart:** `supabaseAuthServiceProvider`, `outboxProcessorProvider`, `syncServiceProvider`, `realtimeServiceProvider`, `syncLifecycleManagerProvider`.
- **printing_providers.dart:** `printingServiceProvider`.
- **theme_providers.dart:** `themeModeProvider`, `accentColorProvider`.

---

## 6. Git Workflow

1. **Větev:** `feature/nazev` nebo `fix/popis`.
2. **Commit:** Conventional Commits.
3. **PR:** Code review vyžadováno před merge do main.
