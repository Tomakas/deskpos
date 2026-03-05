# Maty — Authentication & Sessions

Tento dokument popisuje proces přihlašování, správu sessions a bezpečnostní ochranu PINů.

---

## 1. PIN Flow

1.  **Výběr uživatele:** Obrazovka `ScreenLogin` zobrazí seznam aktivních zaměstnanců.
2.  **Zadání PINu:** Numpad s podporou fyzické klávesnice. Znaky jsou maskovány (`*`).
3.  **Ověření:** PIN se ověřuje automaticky od 4. číslice. Shoda = okamžitý vstup.
4.  **Hashing:** PINy se ukládají jako solený hash (Salted SHA-256 + 128-bit náhodná sůl).
    -   **Formát:** `hex_salt:hex_hash`.
    -   **Sync:** Sloupec `pin_hash` se synchronizuje, což umožňuje přihlášení na všech zařízeních firmy.

---

## 2. Multi-session Model

Na jednom zařízení může být přihlášeno více uživatelů současně, ale aktivní je vždy jen jeden.
-   **Aktivní uživatel:** Právě pracující obsluha, které se připisují akce.
-   **Přepnutí:** Rychlý dialog bez nutnosti kompletního odhlášení (vyžaduje PIN).
-   **Logout:** Odhlásí pouze aktivního uživatele.
-   **Volatile:** Sessions jsou drženy pouze v RAM (`SessionManager`). Při restartu aplikace je nutné se znovu přihlásit PINem.

---

## 3. Brute-Force Ochrana

Progresivní lockout chrání proti hádání PINu:

| Neúspěšný pokus | Lockout (blokování) |
|-----------------|---------------------|
| 1–3 | Žádný (tolerance překlepů) |
| 4 | 5 sekund |
| 5 | 30 sekund |
| 6 | 5 minut |
| 7+ | 60 minut |

*Stav lockoutu se drží v paměti a resetuje se při úspěšném přihlášení nebo restartu aplikace.*

---

## 4. Cloud Auth

-   **SignUp:** Probíhá v onboarding wizardu při zakládání nové firmy.
-   **Anonymous Sign-in:** Používá se pro Demo firmy (nevyžaduje email).
-   **JWT:** Synchronizace vyžaduje platný Supabase session (ověřuje se v RLS politikách).
