# Manuální testovací skripty — Maty

Kompletní sada testovacích scénářů pro manuální testování POS aplikace.

**Konvence:**
- ✅ = očekávaný výsledek (ověření)
- ⚠️ = edge case / negativní scénář
- Každý test má unikátní ID ve formátu `OBL-NN` (oblast-číslo)
- Předpoklady jsou uvedeny na začátku každého testu

---

## Obsah

1. [Onboarding a první spuštění](#1-onboarding-a-první-spuštění)
2. [Autentizace a bezpečnost](#2-autentizace-a-bezpečnost)
3. [Správa směny a pokladny](#3-správa-směny-a-pokladny)
4. [Účty](#4-účty)
5. [Prodejní obrazovka](#5-prodejní-obrazovka)
6. [Objednávky a stavy](#6-objednávky-a-stavy)
7. [Platby](#7-platby)
8. [Pokročilé operace s účty](#8-pokročilé-operace-s-účty)
9. [Věrnostní program a vouchery](#9-věrnostní-program-a-vouchery)
10. [Katalog](#10-katalog)
11. [Skladové hospodářství](#11-skladové-hospodářství)
12. [Rezervace](#12-rezervace)
13. [Nastavení](#13-nastavení)
14. [KDS (Kuchyňský displej)](#14-kds-kuchyňský-displej)
15. [Zákaznický displej](#15-zákaznický-displej)
16. [Reporty a uzávěrky](#16-reporty-a-uzávěrky)
17. [Synchronizace a offline](#17-synchronizace-a-offline)
18. [Oprávnění](#18-oprávnění)

---

## 1. Onboarding a první spuštění

### ONB-01: Vytvoření nové firmy (happy path)

**Předpoklady:** Čistá instalace, žádná lokální databáze.

1. Spusťte aplikaci.
2. ✅ Zobrazí se loading obrazovka, poté onboarding.
3. ✅ Na obrazovce jsou tři volby: „Nová firma", „Připojit se k firmě", „Zákaznický displej".
4. Klepněte na „Nová firma".
5. ✅ Spustí se wizard — krok 1: cloud registrace (e-mail + heslo).
6. Vyplňte platný e-mail a heslo (min. 6 znaků). Potvrďte.
7. ✅ Krok 2: informace o firmě (název firmy). Vyplňte název.
8. ✅ Krok 3: vytvoření admin uživatele (jméno, username, PIN).
9. Vyplňte jméno, username, PIN (4–6 číslic), potvrzení PINu.
10. Potvrďte.
11. ✅ Aplikace vytvoří firmu, uživatele, seed data (sekce, stoly, daňové sazby, platební metody, sklad).
12. ✅ Přesměrování na `/login`.
13. ✅ Na login obrazovce je vidět vytvořený uživatel.

### ONB-02: Připojení k existující firmě (happy path)

**Předpoklady:** Na Supabase existuje firma s daty. Máte přihlašovací údaje (e-mail + heslo).

1. Spusťte čistou instalaci.
2. Klepněte na „Připojit se k firmě".
3. ✅ Zobrazí se obrazovka `/connect-company` s krokovým průvodcem.
4. Vyplňte e-mail a heslo. Potvrďte.
5. ✅ Probíhá Supabase signIn.
6. ✅ Aplikace najde firmu podle auth user ID.
7. ✅ Stáhne se všech 36 tabulek v pořadí FK závislostí.
8. ✅ Výběr pokladny (registru) — zobrazí se seznam dostupných pokladen.
9. Vyberte pokladnu.
10. ✅ Přesměrování na `/login` s kompletními daty.

### ONB-03: Zákaznický displej — spárování

**Předpoklady:** Na jiném zařízení běží POS s aktivní směnou.

1. Spusťte čistou instalaci.
2. Klepněte na „Zákaznický displej".
3. ✅ Zobrazí se obrazovka s 6místným párovacím kódem (`/display-code`).
4. Na POS zařízení se zobrazí modální dialog s žádostí o spárování.
5. Potvrďte spárování na POS.
6. ✅ Displej přejde do idle režimu (název firmy + uvítací text).

### ⚠️ ONB-04: Neplatné přihlašovací údaje při připojení

**Předpoklady:** Čistá instalace.

1. Klepněte na „Připojit se k firmě".
2. Vyplňte neplatný e-mail nebo špatné heslo.
3. Potvrďte.
4. ✅ Zobrazí se chybová hláška. Zůstáváte na přihlašovacím kroku.
5. ✅ Lze opravit údaje a zkusit znovu.

### ⚠️ ONB-05: Připojení bez internetového připojení

**Předpoklady:** Čistá instalace, odpojený internet.

1. Klepněte na „Připojit se k firmě".
2. Vyplňte údaje a potvrďte.
3. ✅ Zobrazí se chyba o nedostupnosti sítě.
4. ✅ Aplikace nepadne, lze se vrátit na onboarding.

---

## 2. Autentizace a bezpečnost

### AUT-01: Přihlášení PINem (happy path)

**Předpoklady:** Existuje firma s uživatelem (PIN = např. 1234).

1. Na login obrazovce (`/login`) ověřte:
   - ✅ Nadpis „Přihlášení".
   - ✅ Seznam uživatelů jako tlačítka (celé jméno).
   - ✅ Vpravo sekce „Režim" s volbami „Pokladna" a „Objednávkový displej".
2. Klepněte na uživatele.
3. ✅ Zobrazí se numpad pro zadání PINu, jméno uživatele jako nadpis.
4. Zadejte správný PIN (např. 1-2-3-4).
5. ✅ Po 4. číslici se automaticky ověří PIN (bez tlačítka potvrzení).
6. ✅ Úspěšné přihlášení — přesměrování na `/bills`.
7. ✅ V info panelu je vidět jméno přihlášeného uživatele jako „Aktivní obsluha".

### AUT-02: Přihlášení do KDS režimu

**Předpoklady:** Existuje uživatel.

1. Na login obrazovce vyberte režim „Objednávkový displej" (radio button vpravo).
2. Klepněte na uživatele a zadejte PIN.
3. ✅ Po úspěšném přihlášení se přesměruje na `/kds` (ne `/bills`).
4. ✅ Zobrazí se kuchyňský displej s živými hodinami v AppBar.

### AUT-03: Více přihlášených uživatelů

**Předpoklady:** Existují alespoň 2 uživatelé (např. „Jan" PIN 1234, „Petr" PIN 5678).

1. Přihlaste se jako Jan.
2. ✅ Jan je „Aktivní obsluha" v info panelu.
3. Klepněte na „Zamknout / Přepnout" (vlevo dole na `/bills`).
4. ✅ Zobrazí se lock overlay s numpadem.
5. Zadejte PIN Petra (5678).
6. ✅ Petr se stane aktivní obsluhou.
7. ✅ V „Další přihlášení" jsou vidět oba uživatelé.
8. Opět klepněte „Zamknout / Přepnout" a zadejte PIN Jana.
9. ✅ Jan je opět aktivní. Oba zůstávají přihlášeni.

### AUT-04: Odhlášení jednoho uživatele

**Předpoklady:** Přihlášeni Jan i Petr (Jan je aktivní).

1. Klepněte na „Odhlásit" (vpravo dole).
2. ✅ Jan je odhlášen.
3. ✅ Petr zůstává přihlášen a stává se aktivní obsluhou.
4. ✅ Zůstáváte na `/bills` (ne redirect na login).

### AUT-05: Odhlášení posledního uživatele

**Předpoklady:** Přihlášen pouze jeden uživatel.

1. Klepněte na „Odhlásit".
2. ✅ Přesměrování na `/login`.
3. ✅ Žádný uživatel není přihlášen.

### ⚠️ AUT-06: Neplatný PIN

**Předpoklady:** Uživatel s PINem 1234.

1. Klepněte na uživatele.
2. Zadejte špatný PIN: 1-1-1-1.
3. ✅ Po 4. číslici se zkontroluje — nezobrazí se nic (neúplný PIN).
4. Pokračujte: 1-1 (celkem 6 číslic: 111111).
5. ✅ Při 6. číslici se zobrazí „Neplatný PIN".
6. ✅ Vstupní pole se vyčistí, lze zadat znovu.

### ⚠️ AUT-07: Brute-force lockout (postupné zamykání)

**Předpoklady:** Uživatel s PINem 1234.

1. Zadejte 3× špatný 6místný PIN.
2. ✅ Pokusy 1–3 projdou bez omezení (jen „Neplatný PIN").
3. Zadejte 4. špatný PIN.
4. ✅ Zobrazí se „Příliš mnoho pokusů. Zkuste znovu za 5 s."
5. ✅ Numpad je zablokován po dobu 5 sekund.
6. Počkejte 5 s, zadejte 5. špatný PIN.
7. ✅ Lockout 30 s.
8. Po dalším špatném pokusu: ✅ lockout 5 min.
9. Po dalším: ✅ lockout 60 min.

### ⚠️ AUT-08: Lockout reset po restartu aplikace

**Předpoklady:** Uživatel je v lockout stavu.

1. Zavřete a znovu otevřete aplikaci.
2. ✅ Lockout se resetoval (in-memory stav zmizel).
3. ✅ Lze se přihlásit bez čekání.

### AUT-09: Automatické zamčení po nečinnosti

**Předpoklady:** V nastavení zabezpečení nastavte „Automatické zamčení po nečinnosti" na „1 min".

1. Přihlaste se.
2. Nedělejte nic po dobu 1 minuty (žádný dotyk/klik).
3. ✅ Zobrazí se LockOverlay přes celou obrazovku s numpadem.
4. Zadejte PIN libovolného přihlášeného uživatele.
5. ✅ Overlay zmizí, aplikace je odemčená.

### AUT-10: PIN při přepnutí obsluhy

**Předpoklady:** V nastavení zapněte „Vyžadovat PIN při přepínání obsluhy". Přihlášeni 2 uživatelé.

1. Klepněte na „Zamknout / Přepnout".
2. ✅ Zobrazí se numpad (ne seznam uživatelů).
3. Zadejte PIN druhého uživatele.
4. ✅ Přepnuto na druhého uživatele.

---

## 3. Správa směny a pokladny

### SME-01: Zahájení směny (happy path)

**Předpoklady:** Přihlášen uživatel, žádná aktivní směna.

1. Na obrazovce `/bills` ověřte:
   - ✅ Vpravo dole tlačítko „Zahájit prodej".
   - ✅ Stav pokladny: „Offline" v info panelu.
   - ✅ Tlačítka „Rychlý účet" a „Vytvořit účet" jsou neaktivní (nebo nefunkční bez směny).
2. Klepněte na „Zahájit prodej".
3. ✅ Zobrazí se dialog „Počáteční hotovost" s numpadem.
4. ✅ Pod nadpisem text: „Zadejte stav hotovosti v pokladně před zahájením prodeje."
5. Zadejte částku, např. 5000 (numpadem: 5-0-0-0).
6. ✅ V zobrazeném poli se formátuje jako „5 000 Kč" (nebo odpovídající měna).
7. Klepněte na „Potvrdit".
8. ✅ Dialog se zavře.
9. ✅ Stav pokladny se změní na „Směna aktivní".
10. ✅ Tlačítko se změní na „Uzávěrka".
11. ✅ „Rychlý účet" a „Vytvořit účet" jsou nyní aktivní.

### SME-02: Zahájení směny s nulovou hotovostí

**Předpoklady:** Žádná aktivní směna.

1. Klepněte na „Zahájit prodej".
2. V dialogu „Počáteční hotovost" nezadávejte nic (ponechte 0).
3. Klepněte na „Potvrdit".
4. ✅ Směna se úspěšně otevře s počáteční hotovostí 0 Kč.

### SME-03: Zrušení zahájení směny

**Předpoklady:** Žádná aktivní směna.

1. Klepněte na „Zahájit prodej".
2. V dialogu klepněte na „Zrušit".
3. ✅ Dialog se zavře. Směna se neotevřela.
4. ✅ Stav zůstává „Offline", tlačítko stále „Zahájit prodej".

### SME-04: Předvyplnění z předchozí uzávěrky

**Předpoklady:** Byla uzavřena předchozí směna s konečným stavem hotovosti 7500 Kč.

1. Klepněte na „Zahájit prodej".
2. ✅ Dialog „Počáteční hotovost" má předvyplněnou hodnotu 7500 z předchozí uzávěrky.
3. Hodnotu lze změnit nebo potvrdit.

### SME-05: Uzávěrka směny (happy path)

**Předpoklady:** Aktivní směna, provedeno několik prodejů (hotovost + karta), žádné otevřené účty.

1. Klepněte na „Uzávěrka".
2. ✅ Zobrazí se dialog „Uzávěrka" se sekcemi:
   - **Přehled směny:** Začátek (datum+čas), Otevřel (jméno), Trvání, Zaplacené účty (počet).
   - **Tržba dle plateb:** Řádky pro každý typ platby (název, částka, počet×), řádek „Celkem" (tučně).
   - **Stav hotovosti:** Počáteční hotovost, Tržba hotovost, Očekávaná hotovost (tučně).
3. Do pole „Skutečný stav hotovosti" zadejte skutečnou částku (např. stejnou jako očekávaná).
4. ✅ Pod polem se zobrazí „Rozdíl" — při shodě = 0 (neutrální barva).
5. ✅ Tlačítko „Uzavřít směnu" se aktivuje.
6. Klepněte na „Uzavřít směnu".
7. ✅ Směna se uzavře. Tlačítko se změní zpět na „Zahájit prodej".
8. ✅ Stav pokladny: „Offline".

### SME-06: Uzávěrka s rozdílem (manko/přebytek)

**Předpoklady:** Aktivní směna s prodeji.

1. Otevřete dialog „Uzávěrka".
2. Zadejte „Skutečný stav hotovosti" nižší než „Očekávaná hotovost" (např. očekávaná 5000, skutečná 4800).
3. ✅ „Rozdíl" zobrazí zápornou hodnotu červeně (manko).
4. Zadejte vyšší částku (např. 5200).
5. ✅ „Rozdíl" zobrazí kladnou hodnotu zeleně (přebytek).
6. V obou případech lze směnu uzavřít.

### SME-07: Uzávěrka s poznámkou

**Předpoklady:** Aktivní směna.

1. Otevřete dialog „Uzávěrka".
2. Klepněte na tlačítko „Poznámka".
3. ✅ Otevře se subdialog „Poznámka k uzávěrce" s textovým polem (hint: „Poznámky k uzávěrce...").
4. Napište poznámku, klepněte „Uložit".
5. ✅ Subdialog se zavře. Na tlačítku „Poznámka" se zobrazí ikona fajfky (✓).
6. Vyplňte skutečnou hotovost a uzavřete směnu.
7. ✅ Poznámka je uložena se směnou.

### ⚠️ SME-08: Uzávěrka s otevřenými účty

**Předpoklady:** Aktivní směna, existuje alespoň 1 otevřený (nezaplacený) účet.

1. Klepněte na „Uzávěrka".
2. ✅ Zobrazí se varovný dialog „Otevřené účty": „Na konci prodeje je {N} otevřených účtů v celkové hodnotě {částka}."
3. Klepněte „Zrušit".
4. ✅ Varovný dialog se zavře, uzávěrka se neprovede.
5. Znovu klepněte „Uzávěrka" a tentokrát „Pokračovat".
6. ✅ Zobrazí se standardní dialog uzávěrky.
7. ✅ V sekci „Přehled směny" je vidět řádek „Otevřené účty" s počtem a hodnotou.

### ⚠️ SME-09: Uzávěrka bez vyplnění skutečné hotovosti

**Předpoklady:** Aktivní směna.

1. Otevřete dialog „Uzávěrka".
2. ✅ Tlačítko „Uzavřít směnu" je neaktivní (disabled).
3. Pole „Skutečný stav hotovosti" je prázdné.
4. ✅ Dokud se nevyplní parsovatelné číslo, tlačítko zůstává disabled.

### SME-10: Vklad hotovosti

**Předpoklady:** Aktivní směna.

1. Klepněte na „Pokladní deník" na obrazovce `/bills`.
2. ✅ Zobrazí se dialog „Hotovost v pokladně" s aktuálním zůstatkem (velké číslo nahoře).
3. ✅ Filtrové čipy: „Vklady" (vybraný), „Výběry" (vybraný), „Prodeje" (nevybraný), „Zapsat změnu" (zelené tlačítko).
4. Klepněte na „Zapsat změnu".
5. ✅ Zobrazí se dialog „Změna stavu hotovosti" s numpadem a dvěma velkými tlačítky „Vklad" a „Výběr".
6. ✅ Obě tlačítka „Vklad" i „Výběr" jsou neaktivní (částka = 0).
7. Zadejte numpadem částku 1000.
8. ✅ Tlačítka „Vklad" a „Výběr" se aktivují.
9. Klepněte na „Vklad".
10. ✅ Dialog se zavře. Vrátíte se do pokladního deníku.
11. ✅ Zůstatek se zvýšil o 1000 Kč.
12. ✅ V tabulce je nový záznam: Typ „Vklad", Částka 1000 (zelená).

### SME-11: Výběr hotovosti

**Předpoklady:** Aktivní směna, zůstatek > 0.

1. Otevřete „Pokladní deník" → „Zapsat změnu".
2. Zadejte částku, klepněte na „Výběr" (červené tlačítko).
3. ✅ Zůstatek se snížil o zadanou částku.
4. ✅ V tabulce: Typ „Výběr", Částka záporná (červená).

### SME-12: Pohyb s poznámkou

**Předpoklady:** Aktivní směna.

1. Otevřete „Zapsat změnu".
2. Klepněte na „Poznámka" (dole).
3. ✅ Subdialog „Poznámka ke změně hotovosti" s hintem „Důvod pohybu...".
4. Napište důvod, klepněte „Uložit".
5. ✅ Ikona fajfky na tlačítku „Poznámka".
6. Zadejte částku a proveďte Vklad.
7. ✅ V pokladním deníku u záznamu je vidět poznámka.

### SME-13: Pokladní deník — filtry

**Předpoklady:** Aktivní směna s vklady, výběry i prodeji.

1. Otevřete „Pokladní deník".
2. ✅ Ve výchozím stavu jsou vybrány „Vklady" a „Výběry". Prodeje nejsou.
3. Klepněte na „Prodeje" (zapnout).
4. ✅ V tabulce se zobrazí i záznamy typu „Prodej" (primární barva).
5. Odznačte „Vklady".
6. ✅ Záznamy typu „Vklad" zmizí z tabulky.
7. ✅ Zůstatek nahoře se nemění (je vždy aktuální celkový).

### SME-14: Počáteční stav v deníku

**Předpoklady:** Směna otevřena s počáteční hotovostí > 0, filter „Vklady" aktivní.

1. Otevřete „Pokladní deník".
2. ✅ První záznam v tabulce je syntetický vklad s poznámkou „Počáteční stav".

---

## 4. Účty

### UCT-01: Vytvoření stolového účtu (happy path)

**Předpoklady:** Aktivní směna, existují sekce a stoly.

1. Klepněte na „Vytvořit účet".
2. ✅ Dialog „Nový účet:" se zobrazí s poli:
   - Výběr sekce (dropdown, předvybraná výchozí sekce).
   - Stůl (dropdown, první položka „Bez stolu", pak aktivní stoly v sekci).
   - Počet hostů (zobrazení + tlačítka +/−, výchozí = 1).
   - Zákazník (neaktivní pole + ikona lupy).
3. Vyberte sekci, stůl, nastavte hosty na 3.
4. Klepněte na „ULOŽIT".
5. ✅ Účet se vytvoří a zobrazí v seznamu účtů.
6. ✅ V tabulce účtů je vidět: název stolu, 3 hosté, celkem 0 Kč.

### UCT-02: Vytvoření účtu a přechod na objednávku

**Předpoklady:** Aktivní směna.

1. Klepněte na „Vytvořit účet".
2. Vyplňte sekci a stůl.
3. Klepněte na „OBJEDNAT" (místo „ULOŽIT").
4. ✅ Účet se vytvoří a rovnou přejde na `/sell/:billId`.
5. ✅ Prodejní obrazovka zobrazuje prázdný košík s číslem účtu.

### UCT-03: Vytvoření účtu bez stolu

**Předpoklady:** Aktivní směna.

1. Klepněte na „Vytvořit účet".
2. V dropdown Stůl ponechte „Bez stolu".
3. Klepněte „ULOŽIT".
4. ✅ Účet se vytvoří. V seznamu účtů ve sloupci „Stůl" je prázdné nebo „Bez stolu".

### UCT-04: Vytvoření účtu se zákazníkem

**Předpoklady:** Existuje zákazník v databázi.

1. Klepněte na „Vytvořit účet".
2. Klepněte na ikonu lupy u pole „Zákazník".
3. ✅ Otevře se dialog „Hledat zákazníka" (viz test VER-xx).
4. Vyberte zákazníka.
5. ✅ Jméno zákazníka se zobrazí v poli „Zákazník".
6. Klepněte „ULOŽIT".
7. ✅ Účet má přiřazeného zákazníka.

### UCT-05: Rychlý účet (happy path)

**Předpoklady:** Aktivní směna, v gridu existují produkty.

1. Klepněte na „Rychlý účet".
2. ✅ Přejde na `/sell` (bez billId).
3. ✅ Prodejní obrazovka bez čísla účtu.
4. Přidejte položky do košíku (viz testy SELL-xx).
5. Klepněte na „Zaplatit" (tlačítko na celou šířku dole).
6. ✅ Automaticky se vytvoří účet (is_takeaway=true), objednávka a otevře se platební dialog.
7. Zaplaťte (viz test PAY-xx).
8. ✅ Po zaplacení návrat na `/bills`.

### ⚠️ UCT-06: Rychlý účet — zrušení

**Předpoklady:** Aktivní směna.

1. Klepněte na „Rychlý účet", přidejte položky.
2. Klepněte na „Zrušit" (červený outline vlevo dole).
3. ✅ Návrat na `/bills` bez vytvoření účtu/objednávky.

### UCT-07: Seznam účtů — filtry stavů

**Předpoklady:** Existují otevřené, zaplacené a stornované účty.

1. Na `/bills` dole v seznamu účtů ověřte filtrové čipy: „Otevřené", „Zaplacené", „Stornované".
2. ✅ Ve výchozím stavu jsou vidět otevřené účty.
3. Klepněte na „Zaplacené".
4. ✅ Zobrazí se zaplacené účty.
5. Klepněte na „Stornované".
6. ✅ Zobrazí se stornované účty.
7. ✅ Lze kombinovat filtry (multi-select).

### UCT-08: Seznam účtů — řazení

**Předpoklady:** Několik otevřených účtů.

1. Klepněte na čip „Řazení".
2. ✅ Volby: „Stůl", „Celkem", „Posl. objednávka".
3. Vyberte „Celkem".
4. ✅ Účty se seřadí podle celkové částky.
5. Vyberte „Posl. objednávka".
6. ✅ Účty se seřadí podle času poslední objednávky.

### UCT-09: Detail účtu — zobrazení

**Předpoklady:** Existuje otevřený účet s objednávkami.

1. Klepněte na účet v seznamu.
2. ✅ Zobrazí se dialog s nadpisem „Účet {číslo}" nebo „Rychlý účet".
3. ✅ Záhlaví: stůl (nebo „Bez stolu"), datum vytvoření, poslední objednávka, zákazník.
4. ✅ Levá strana: historie objednávek (položky s cenami, stavy, poznámkami).
5. ✅ Pravá strana: vertikální sloupec tlačítek — „Zákazník", „Stůl", „Sloučit", „Rozdělit", „Sleva", „Uplatnit body", „Voucher", „Zák. displej".
6. ✅ Dole: „Zavřít", „Tisk", „Storno účtu", „Zaplatit", „Objednat".

### UCT-10: Detail účtu — přepnutí sumář/historie

**Předpoklady:** Účet s více objednávkami.

1. Otevřete detail účtu.
2. ✅ Ve výchozím stavu se zobrazuje „Historie objednávek".
3. Klepněte na nadpis „Historie objednávek".
4. ✅ Přepne se na „Sumář" (agregované položky).
5. Klepněte znovu na „Sumář".
6. ✅ Přepne zpět na „Historie objednávek".

### UCT-11: Storno účtu

**Předpoklady:** Otevřený účet.

1. Otevřete detail účtu.
2. Klepněte na „Storno účtu".
3. ✅ Potvrzovací dialog: „Opravdu chcete stornovat tento účet?"
4. Klepněte „Ne".
5. ✅ Dialog se zavře, účet zůstává otevřený.
6. Znovu klepněte „Storno účtu", tentokrát „Ano".
7. ✅ Účet se stornuje. Zmizí ze seznamu otevřených (zobrazí se ve filtr „Stornované").

### UCT-12: Mapa stolů — zobrazení a interakce

**Předpoklady:** Aktivní směna, na mapě jsou rozmístěny stoly.

1. Klepněte na „Mapa" (místo „Seznam") v pravém panelu.
2. ✅ Zobrazí se interaktivní mapa 32×20 se stoly jako grafickými prvky.
3. ✅ Stoly s otevřenými účty jsou vizuálně odlišeny (kolečko s částkou).
4. Klepněte na prázdný stůl.
5. ✅ Otevře se dialog „Nový účet" s předvybraným stolem.
6. Klepněte na stůl s otevřeným účtem.
7. ✅ Otevře se detail účtu (DialogBillDetail).
8. Klepněte na „Seznam" pro návrat do tabulkového zobrazení.
9. ✅ Zobrazí se opět seznam účtů.

---

## 5. Prodejní obrazovka

### SELL-01: Navigace v gridu — kategorie a produkty

**Předpoklady:** V gridu jsou rozmístěny kategorie a produkty (viz Nastavení pokladny).

1. Na sell obrazovce ověřte mřížku produktů (levá strana).
2. ✅ Grid zobrazuje buňky s názvy kategorií/produktů.
3. Klepněte na kategorii.
4. ✅ Grid se přepne na obsah kategorie (podkategorie nebo produkty).
5. ✅ V toolbaru se zobrazí čip „Zpět".
6. Klepněte na „Zpět".
7. ✅ Grid se vrátí na předchozí úroveň.

### SELL-02: Přidání produktu do košíku

**Předpoklady:** Na sell obrazovce, grid obsahuje produkty.

1. Klepněte na produkt v gridu.
2. ✅ Produkt se přidá do košíku (pravá strana).
3. ✅ V košíku: název, 1×, cena.
4. ✅ „Celkem" dole se aktualizuje.
5. Klepněte na stejný produkt znovu.
6. ✅ Množství se zvýší na 2× (ne nový řádek).
7. ✅ Celková cena položky = 2× jednotková cena.

### SELL-03: Úprava položky v košíku

**Předpoklady:** V košíku je alespoň 1 položka.

1. Klepněte na položku v košíku.
2. ✅ Zobrazí se dialog s názvem položky, polem „Poznámka" a tlačítky.
3. ✅ Tlačítko „+1" pro zvýšení množství.
4. Napište poznámku (např. „bez cibule").
5. Klepněte „Uložit".
6. ✅ U položky v košíku se zobrazí ikona poznámky.

### SELL-04: Odebrání položky z košíku

**Předpoklady:** V košíku je položka s množstvím 1.

1. Klepněte na položku v košíku.
2. ✅ Dialog obsahuje tlačítko pro snížení množství nebo odebrání.
3. Snižte množství na 0 nebo použijte odebrání.
4. ✅ Položka zmizí z košíku.
5. ✅ „Celkem" se přepočítá.

### SELL-05: Odeslání objednávky (stolový účet)

**Předpoklady:** Sell obrazovka s billId, v košíku jsou položky.

1. ✅ Dole jsou tlačítka „Zrušit" (červený outline) a „Objednat".
2. Klepněte na „Objednat".
3. ✅ Objednávka se vytvoří (status = created).
4. ✅ Návrat na `/bills`.
5. ✅ Na účtu je vidět nová objednávka. Celkem se aktualizoval.

### SELL-06: Oddělovač objednávek

**Předpoklady:** Sell obrazovka s billId.

1. Přidejte 2 produkty do košíku.
2. Klepněte na čip „Oddělit" v toolbaru.
3. ✅ V košíku se zobrazí oddělovač: „--- Další objednávka ---".
4. Přidejte další 2 produkty.
5. Klepněte „Objednat".
6. ✅ Vytvoří se 2 samostatné objednávky (ne jedna).
7. ✅ V detailu účtu jsou vidět 2 objednávky s různými čísly.

### SELL-07: Vyhledávání produktů

**Předpoklady:** Sell obrazovka, v katalogu existují produkty.

1. Klepněte na ikonu lupy v toolbaru.
2. ✅ Zobrazí se vyhledávací pole s hintem „Vyhledat".
3. Zadejte část názvu produktu.
4. ✅ Grid se přefiltruje — zobrazí pouze odpovídající produkty.
5. Klepněte na nalezený produkt.
6. ✅ Produkt se přidá do košíku.

### SELL-08: Poznámka k objednávce

**Předpoklady:** Sell obrazovka.

1. Klepněte na čip „Poznámka" v toolbaru.
2. ✅ Dialog „Poznámka" s textovým polem (hint: „Poznámka").
3. Napište poznámku, klepněte „Uložit".
4. ✅ Čip „Poznámka" je vizuálně odlišen (selected).

### SELL-09: Přiřazení zákazníka na sell obrazovce

**Předpoklady:** Sell obrazovka.

1. Klepněte na čip „Zákazník".
2. ✅ Otevře se dialog pro vyhledání zákazníka.
3. Vyberte zákazníka.
4. ✅ Čip se změní na jméno zákazníka.

### SELL-10: Uložení na účet (quick sale)

**Předpoklady:** Quick sale (`/sell` bez billId), v košíku jsou položky.

1. ✅ Dole jsou tlačítka „Zrušit", „Uložit" a „Zaplatit" (na celou šířku).
2. Klepněte na „Uložit".
3. ✅ Vytvoří se účet + objednávka, ale neotevře se platba.
4. ✅ Návrat na `/bills`. Nový účet je v seznamu.

### ⚠️ SELL-11: Prázdný košík — odeslání

**Předpoklady:** Sell obrazovka, košík je prázdný.

1. ✅ Text „Košík je prázdný" v oblasti košíku.
2. ✅ Tlačítko „Objednat" / „Zaplatit" je neaktivní nebo nereaguje.

---

## 6. Objednávky a stavy

### OBJ-01: Životní cyklus objednávky (happy path)

**Předpoklady:** Účet s objednávkou ve stavu „Vytvořené" (created).

1. Přejděte na `/orders`.
2. ✅ Obrazovka „Objednávky" zobrazuje kartičky objednávek.
3. ✅ Ve výchozím filtru „Vytvořené" + „Hotové" (multi-select).
4. Najděte objednávku — ✅ barevná tečka stavu, číslo objednávky, název stolu, čas.
5. Klepněte na tlačítko posunu stavu na kartičce (→ ready).
6. ✅ Objednávka se přesune do stavu „Hotové" (ready).
7. Klepněte znovu na posun stavu (→ delivered).
8. ✅ Objednávka se přesune do stavu „Doručené" (delivered).

### OBJ-02: Stav jednotlivé položky

**Předpoklady:** Objednávka s více položkami.

1. Na `/orders` najděte objednávku.
2. ✅ Každá položka má vlastní stavovou tečku a tlačítka posunu.
3. Posuňte jednu položku na „Hotové", ostatní ponechte.
4. ✅ Položka se vizuálně odliší, objednávka jako celek zůstává „Vytvořené".

### OBJ-03: Storno položky z objednávky

**Předpoklady:** Otevřený účet, objednávka s položkami.

1. Otevřete detail účtu.
2. Klepněte na položku objednávky.
3. ✅ Dialog s názvem položky, pole „Poznámka", tlačítka „Sleva", „Storno", „Zrušit", „Uložit".
4. Klepněte na „Storno".
5. ✅ Potvrzovací dialog: „Opravdu chcete stornovat tuto položku?"
6. Klepněte „Ano".
7. ✅ Vytvoří se storno objednávka (číslo X-XXXX).
8. ✅ Celková částka účtu se sníží o cenu stornované položky.
9. ✅ V historii objednávek je vidět storno záznam.

### OBJ-04: Filtrování objednávek

**Předpoklady:** Existují objednávky v různých stavech.

1. Na `/orders` dole jsou filtrové čipy: „Vytvořené", „Hotové", „Doručené", „Stornované".
2. Odznačte vše, zaškrtněte pouze „Stornované".
3. ✅ Zobrazí se pouze stornované objednávky s červeným okrajem a prefixem „STORNO".
4. Přepněte na „Doručené".
5. ✅ Pouze doručené objednávky.

### OBJ-05: Přepínání rozsahu (Session / Vše)

**Předpoklady:** Existují objednávky z aktuální i předchozích směn.

1. Na `/orders` ověřte toggle: „Session" / „Vše".
2. ✅ „Session" zobrazuje pouze objednávky z aktuální směny.
3. Přepněte na „Vše".
4. ✅ Zobrazí se objednávky ze všech směn.

### OBJ-06: Barevné kódování urgence

**Předpoklady:** Objednávky různého stáří.

1. Na `/orders` sledujte barvu časového údaje na kartičkách:
   - ✅ Zelená: objednávka mladší než 5 minut.
   - ✅ Oranžová: 5–10 minut.
   - ✅ Červená: starší než 10 minut.

---

## 7. Platby

### PAY-01: Platba hotovostí (happy path)

**Předpoklady:** Otevřený účet s objednávkami, celkem > 0.

1. Otevřete detail účtu, klepněte „Zaplatit".
2. ✅ Dialog „PLATBA" se zobrazí.
3. ✅ Nadpis: „Účet {číslo} - {stůl}".
4. ✅ Vlevo: „Upravit částku", „Zrušit" a 2 neaktivní položky („Jiná měna", „EET").
5. ✅ Vpravo: tlačítka platebních metod (VELKÝMI PÍSMENY, např. „HOTOVOST", „KARTA").
6. ✅ Vpravo nahoře: „Jiná platba" (neaktivní).
7. Klepněte na „HOTOVOST".
8. ✅ Platba se provede. Dialog se zavře.
9. ✅ Účet změní stav na „Zaplacený".
10. ✅ V seznamu účtů se přesune do filtru „Zaplacené".

### PAY-02: Platba kartou

**Předpoklady:** Účet k zaplacení, pokladna má povolenu kartu (allow_card).

1. Otevřete platební dialog.
2. Klepněte na „KARTA".
3. ✅ Platba se provede kartou. Účet zaplacen.

### PAY-03: Splitovaná platba (více metod)

**Předpoklady:** Účet s celkem 500 Kč.

1. Otevřete platební dialog.
2. Klepněte na „Upravit částku" (vlevo).
3. ✅ Dialog „Upravit částku" s numpadem a quick-pick tlačítky.
4. ✅ „Původní částka: 500 Kč" zobrazena.
5. Změňte částku na 300 (např. vymazat a zadat 300).
6. Klepněte „OK".
7. ✅ Vrátíte se do platebního dialogu. Zobrazená částka = 300 Kč.
8. Klepněte na „HOTOVOST".
9. ✅ Provede se částečná platba 300 Kč hotovostí.
10. ✅ Dialog zůstává otevřený. Zbývající částka = 200 Kč.
11. Klepněte na „KARTA".
12. ✅ Doplatek 200 Kč kartou. Účet plně zaplacen. Dialog se zavře.

### PAY-04: Přeplatek a spropitné

**Předpoklady:** Účet s celkem 450 Kč.

1. Otevřete platební dialog.
2. Klepněte na „Upravit částku".
3. Zadejte 500 Kč (o 50 Kč více). Potvrďte „OK".
4. Klepněte na „HOTOVOST".
5. ✅ Platba se provede. Přeplatek 50 Kč se uloží jako spropitné.
6. ✅ Zobrazí se „Spropitné: 50 Kč".

### PAY-05: Quick-pick tlačítka v „Upravit částku"

**Předpoklady:** Účet s celkem 347 Kč.

1. Otevřete „Upravit částku".
2. ✅ Quick-pick tlačítka zobrazují zaokrouhlené částky nad celkem: 350, 400, 500, 1000 (příklady).
3. Klepněte na 500.
4. ✅ Hodnota v poli se změní na 500.

### PAY-06: Tisk dokladu

**Předpoklady:** Účet k zaplacení.

1. Otevřete platební dialog.
2. ✅ Dole je vidět „Tisk dokladu: ANO".
3. Zaplaťte.
4. ✅ Po zaplacení se generuje PDF účtenka a otevře v systémovém prohlížeči.

### ⚠️ PAY-07: Zrušení platby

**Předpoklady:** Účet k zaplacení.

1. Otevřete platební dialog.
2. Klepněte na „Zrušit".
3. ✅ Dialog se zavře. Účet zůstává otevřený.

### ⚠️ PAY-08: Platba nedostupnou metodou

**Předpoklady:** Pokladna má zakázanou kartu (allow_card = false).

1. Otevřete platební dialog.
2. ✅ Tlačítko „KARTA" chybí nebo je neaktivní.
3. ✅ Lze platit pouze povolenými metodami.

---

## 8. Pokročilé operace s účty

### POK-01: Sleva na účet — absolutní (Kč)

**Předpoklady:** Otevřený účet s celkem 500 Kč.

1. Otevřete detail účtu → „Sleva".
2. ✅ Dialog „Sleva" s numpadem a třemi tlačítky dole.
3. Zadejte 100.
4. ✅ Levé tlačítko: „-100 Kč". Pravé tlačítko: „100% / -500 Kč" (přepočet).
5. Klepněte na „-100 Kč".
6. ✅ Sleva 100 Kč se aplikuje. Celkem = 400 Kč.
7. ✅ V detailu účtu je vidět sleva.

### POK-02: Sleva na účet — procentuální

**Předpoklady:** Účet s celkem 500 Kč.

1. Otevřete „Sleva", zadejte 10.
2. Klepněte na pravé tlačítko „10% / -50 Kč".
3. ✅ Sleva 10% = 50 Kč. Celkem = 450 Kč.

### ⚠️ POK-03: Sleva větší než celkem

**Předpoklady:** Účet s celkem 500 Kč.

1. Otevřete „Sleva", zadejte 600.
2. ✅ Absolutní sleva je zastropována na 500 Kč (ne záporný celkem).
3. Klepněte na „-500 Kč".
4. ✅ Celkem = 0 Kč. Nelze jít do záporu.

### ⚠️ POK-04: Sleva přes 100 %

1. Otevřete „Sleva", zadejte 150.
2. ✅ Procentuální sleva je zastropována na 100 % (10000 basis points).

### POK-05: Sleva na položku

**Předpoklady:** Otevřený účet s objednávkou.

1. V detailu účtu klepněte na položku objednávky.
2. V dialogu klepněte na „Sleva".
3. ✅ Otevře se stejný dialog „Sleva" jako pro účet, ale referenční částka = cena položky.
4. Aplikujte slevu.
5. ✅ Sleva se zobrazí u dané položky, celkem účtu se přepočítá.

### POK-06: Sloučení účtů

**Předpoklady:** 2 otevřené účty (A s objednávkami, B prázdný nebo s objednávkami).

1. Otevřete detail účtu A → „Sloučit".
2. ✅ Dialog „Sloučit účet" s popisem: „Objednávky z tohoto účtu budou přesunuty na vybraný účet. Aktuální účet bude zrušen."
3. ✅ Seznam otevřených účtů (bez aktuálního): název stolu, číslo účtu, celkem.
4. Klepněte na účet B.
5. ✅ Objednávky z A se přesunou na B. Účet A se stornuje.
6. ✅ V seznamu účtů: A je stornovaný, B má všechny objednávky.

### ⚠️ POK-07: Sloučení — žádný cílový účet

**Předpoklady:** Pouze 1 otevřený účet.

1. Otevřete detail → „Sloučit".
2. ✅ Dialog zobrazí „Žádné otevřené účty k sloučení".
3. Klepněte „Zrušit".

### POK-08: Rozdělení účtu — na nový účet

**Předpoklady:** Účet s objednávkou obsahující 3+ položky.

1. Otevřete detail → „Rozdělit".
2. ✅ Dialog „Rozdělit účet" s instrukcí „Vyberte položky k rozdělení".
3. ✅ Checkboxy u každé položky (množství×, název, cena).
4. ✅ Tlačítka „Rozdělit a zaplatit" a „Rozdělit na nový účet" jsou neaktivní.
5. Zaškrtněte 1-2 položky.
6. ✅ Obě tlačítka se aktivují.
7. Klepněte na „Rozdělit na nový účet".
8. ✅ Vybrané položky se přesunou na nový účet.
9. ✅ V seznamu účtů je nový účet s vybranými položkami.
10. ✅ Původní účet má jen zbývající položky.

### POK-09: Rozdělení účtu — rozdělit a zaplatit

**Předpoklady:** Účet s položkami.

1. Otevřete „Rozdělit", vyberte položky.
2. Klepněte „Rozdělit a zaplatit".
3. ✅ Položky se oddělí a rovnou se otevře platební dialog pro nový účet.

### POK-10: Přesun účtu (změna stolu)

**Předpoklady:** Účet přiřazený ke stolu.

1. Otevřete detail → „Stůl".
2. ✅ Dialog „Nový účet" (ale ve variantě pro přesun — bez tlačítka „OBJEDNAT").
3. Vyberte jinou sekci/stůl.
4. Klepněte „ULOŽIT".
5. ✅ Účet je nyní přiřazen k novému stolu. V seznamu se aktualizuje.

### POK-11: Refund celého účtu

**Předpoklady:** Zaplacený účet.

1. Otevřete detail zaplaceného účtu.
2. ✅ Dole je tlačítko „REFUND" (místo „Zaplatit" a „Objednat").
3. Klepněte „REFUND".
4. ✅ Dialog: „Opravdu chcete refundovat celý účet?" s „Ne" / „Ano".
5. Klepněte „Ano".
6. ✅ Vytvoří se záporné platby (refund).
7. ✅ Automaticky se vytvoří CashMovement (pokud hotovostní platba).
8. ✅ Pokud byl zákazník s věrnostním programem — body se vrátí.

### POK-12: Refund jedné položky

**Předpoklady:** Zaplacený účet s více položkami.

1. Otevřete detail zaplaceného účtu.
2. Klepněte na položku.
3. ✅ Dialog: „Opravdu chcete refundovat tuto položku?" s „Ne" / „Ano".
4. Klepněte „Ano".
5. ✅ Refund pouze vybrané položky.

### POK-13: Přiřazení zákazníka k účtu

**Předpoklady:** Otevřený účet, existuje zákazník v databázi.

1. Otevřete detail → „Zákazník".
2. ✅ Dialog „Hledat zákazníka" se zobrazí.
3. Vyhledejte a vyberte zákazníka.
4. ✅ V detailu účtu: „Zákazník: {jméno}".
5. ✅ Pokud má zákazník předchozí útratu: „Celková útrata: {částka}".

### POK-14: Odebrání zákazníka z účtu

**Předpoklady:** Účet s přiřazeným zákazníkem.

1. Otevřete detail → „Zákazník".
2. ✅ Dialog „Hledat zákazníka" má navíc tlačítko „Odebrat zákazníka".
3. Klepněte „Odebrat zákazníka".
4. ✅ Zákazník je odebrán. Detail: „Zákazník nepřiřazen".

---

## 9. Věrnostní program a vouchery

### VER-01: Uplatnění věrnostních bodů

**Předpoklady:** Účet s celkem 500 Kč, přiřazený zákazník s 200 body, hodnota 1 bodu = 1 Kč.

1. Otevřete detail účtu → „Uplatnit body".
2. ✅ Dialog „Uplatnit body" zobrazuje:
   - „Dostupné body: 200"
   - „Hodnota: 1/bod"
3. Zadejte 100 numpadem.
4. ✅ Náhled: „100 bodů = sleva 100 Kč" (zelená).
5. ✅ Tlačítko „Max: 200" umožňuje zadat maximum.
6. Klepněte „Zaplatit".
7. ✅ Sleva 100 Kč se aplikuje na účet. Celkem = 400 Kč.
8. ✅ Zákazníkovi se odečte 100 bodů.

### ⚠️ VER-02: Body přesahující celkem účtu

**Předpoklady:** Účet s celkem 100 Kč, zákazník s 500 body (1 bod = 1 Kč).

1. Otevřete „Uplatnit body".
2. ✅ „Max" tlačítko ukazuje 100 (ne 500), protože sleva nemůže přesáhnout celkem.
3. Zadejte 500.
4. ✅ Validace zabrání uplatnění — tlačítko „Zaplatit" je neaktivní nebo hodnota se zastropuje.

### ⚠️ VER-03: Uplatnění bodů bez zákazníka

**Předpoklady:** Účet bez přiřazeného zákazníka.

1. Otevřete detail → „Uplatnit body".
2. ✅ Dialog buď neukazuje body (0 bodů), nebo není možné uplatnit.

### VER-04: Vytvoření dárkového voucheru

**Předpoklady:** Přihlášen, aktivní směna.

1. Přejděte na `/vouchers` (Další → Vouchery).
2. Klepněte „+ Vytvořit voucher" v AppBar.
3. ✅ Dialog „Vytvořit voucher" s výběrem typu: „Dárkový", „Zálohový", „Slevový".
4. Vyberte „Dárkový".
5. Zadejte hodnotu 500 numpadem.
6. ✅ Tlačítko „Prodat 500 Kč" se aktivuje.
7. Nastavte datum platnosti.
8. Klepněte „Prodat 500 Kč".
9. ✅ Vytvoří se účet + objednávka a otevře se platební dialog.
10. Zaplaťte.
11. ✅ Voucher se vytvoří s unikátním kódem, hodnotou 500, stavem „Aktivní".
12. ✅ V seznamu voucherů je vidět nový voucher.

### VER-05: Vytvoření slevového voucheru

1. Dialog „Vytvořit voucher" → „Slevový".
2. ✅ Zobrazí se výběr rozsahu: „Celý účet", „Produkt", „Kategorie".
3. Vyberte „Celý účet".
4. Zadejte hodnotu 10 (procent — přepněte % tlačítkem vlevo dole na numpad).
5. ✅ Zobrazuje se jako procentuální sleva.
6. Nastavte „Max. použití" pomocí +/- (např. 5).
7. Klepněte „Vytvořit voucher".
8. ✅ Voucher se vytvoří přímo (bez platby) s kódem, slevou 10 %, max 5 použití.

### VER-06: Uplatnění voucheru na účet

**Předpoklady:** Existuje aktivní dárkový voucher s hodnotou 500 Kč. Účet s celkem 300 Kč.

1. Otevřete detail účtu → „Voucher".
2. ✅ Dialog „Voucher" s polem „Zadejte kód voucheru" (autofocus, uppercase).
3. Zadejte kód voucheru.
4. Klepněte „Uplatnit".
5. ✅ Voucher se aplikuje na účet — sleva odpovídající hodnotě (max do výše celku).

### ⚠️ VER-07: Neplatný kód voucheru

1. Otevřete „Voucher" na účtu.
2. Zadejte neexistující kód.
3. Klepněte „Uplatnit".
4. ✅ Chyba — voucher nenalezen nebo neplatný.

### ⚠️ VER-08: Expirovaný voucher

**Předpoklady:** Voucher s prošlou platností.

1. Zkuste uplatnit expirovaný voucher.
2. ✅ Chyba — voucher je neplatný (expirovaný).

### VER-09: Filtrování voucherů

**Předpoklady:** Existují vouchery různých typů a stavů.

1. Na `/vouchers` ověřte filtrové čipy:
   - Typ: „Všechny", „Dárkový", „Zálohový", „Slevový".
   - Stav: „Všechny", „Aktivní", „Uplatněný", „Expirovaný".
2. Klepněte na „Dárkový".
3. ✅ Zobrazí se pouze dárkové vouchery.
4. Klepněte na „Expirovaný".
5. ✅ Zobrazí se pouze expirované vouchery.

### VER-10: Zrušení aktivního voucheru

1. Na `/vouchers` klepněte na aktivní voucher.
2. ✅ Dialog s detaily voucheru.
3. Klepněte „Zrušit voucher" (červené tlačítko).
4. ✅ Voucher se deaktivuje. Stav se změní.

---

## 10. Katalog

### KAT-01: Vytvoření produktu (happy path)

**Předpoklady:** Existuje alespoň 1 kategorie a 1 daňová sazba.

1. Přejděte na `/catalog`, tab „Produkty".
2. Klepněte „+ Přidat".
3. ✅ Dialog s poli: Název, Cena, Kategorie, Daň. sazba, Typ, a další.
4. Vyplňte:
   - Název: „Espresso"
   - Cena: 55
   - Kategorie: vyberte existující
   - Daň. sazba: ✅ předvybrána výchozí (kde isDefault=true)
   - Typ: „Produkt"
5. Klepněte „Uložit".
6. ✅ Produkt se zobrazí v tabulce.
7. ✅ Sloupce: Název, Kategorie, Cena (55 Kč), Daň. sazba, Typ (Produkt), Aktivní (ano).

### KAT-02: Editace produktu

1. Klepněte na řádek produktu v tabulce.
2. ✅ Otevře se edit dialog s předvyplněnými hodnotami.
3. Změňte cenu na 60.
4. Klepněte „Uložit".
5. ✅ Cena v tabulce se aktualizuje na 60 Kč.

### KAT-03: Smazání produktu

1. Klepněte na ikonu koše u produktu.
2. ✅ Dialog: „Opravdu chcete smazat tuto položku?" + „Ne" / „Ano".
3. Klepněte „Ano".
4. ✅ Produkt zmizí z tabulky.

### KAT-04: Filtrování produktů

**Předpoklady:** Produkty různých typů, kategorií, stavů.

1. Na tab „Produkty" klepněte na ikonu filtru.
2. ✅ Dialog s filtry: Typ, Kategorie, Aktivní, V prodeji, Sledování skladu, Dodavatel, Výrobce.
3. Nastavte filtr „Aktivní" na „Ne".
4. Klepněte „Zavřít".
5. ✅ Tabulka zobrazuje pouze neaktivní produkty.
6. ✅ Ikona filtru je zvýrazněna (filtry aktivní).
7. Otevřete filtry → „Resetovat".
8. ✅ Všechny filtry se resetují.

### KAT-05: Vyhledávání produktů

1. Do vyhledávacího pole (hint „Hledat...") zadejte část názvu.
2. ✅ Tabulka se přefiltruje v reálném čase.

### ⚠️ KAT-06: Produkt s prázdným názvem

1. Klepněte „+ Přidat", ponechte název prázdný.
2. Klepněte „Uložit".
3. ✅ Uložení se tiše přeskočí (dialog zůstane otevřený nebo se ignoruje).

### KAT-07: Kategorie — hierarchie

**Předpoklady:** Tab „Kategorie".

1. Vytvořte kategorii „Nápoje" (bez nadřazené).
2. Vytvořte kategorii „Teplé nápoje" s nadřazenou = „Nápoje".
3. ✅ V tabulce: „Teplé nápoje" má ve sloupci „Nadřazená kategorie" hodnotu „Nápoje".
4. ✅ Hierarchie může mít až 3 úrovně.

### KAT-08: Dodavatelé — CRUD

1. Tab „Dodavatelé" → „+ Přidat".
2. ✅ Pole: Název dodavatele, Kontaktní osoba, E-mail, Telefon.
3. Vyplňte a uložte.
4. ✅ Dodavatel v tabulce.
5. Klepněte na řádek → editace. Změňte kontakt → „Uložit".
6. ✅ Aktualizováno.
7. Klepněte koš → potvrďte smazání.
8. ✅ Dodavatel smazán.

### KAT-09: Výrobci — CRUD

1. Tab „Výrobci" → „+ Přidat".
2. ✅ Pole: Název.
3. Vyplňte „Illy", uložte.
4. ✅ V tabulce.

### KAT-10: Receptury

**Předpoklady:** Existují produkty typu „Receptura" a „Ingredience".

1. Tab „Receptury" → „+ Přidat".
2. ✅ Pole: Nadřazený produkt (dropdown — jen typ Receptura).
3. Vyberte produkt.
4. Klepněte „+ Přidat složku".
5. ✅ Nový řádek: dropdown složky + pole „Požadované množství".
6. Vyberte ingredienci, zadejte množství (např. 0.3).
7. Přidejte další složku.
8. Klepněte „Uložit".
9. ✅ Receptura v tabulce: nadřazený produkt + počet složek.

### ⚠️ KAT-11: Receptura bez složek

1. Vytvořte recepturu, vyberte produkt, ale nepřidejte žádnou složku.
2. ✅ Tlačítko „Uložit" je neaktivní (disabled).

### KAT-12: Zákazníci — CRUD

1. Tab „Zákazníci" → „+ Přidat".
2. ✅ Pole: Jméno, Příjmení, E-mail, Telefon, Adresa, Body, Kredit.
3. Vyplňte jméno + příjmení, uložte.
4. ✅ Zákazník v tabulce se sloupci: Jméno, Příjmení, E-mail, Telefon, Body, Kredit, Poslední návštěva.

### KAT-13: Zákaznický kredit

**Předpoklady:** Existuje zákazník.

1. Editujte zákazníka → klepněte na ikonu peněženky u pole „Kredit".
2. ✅ Dialog „Zákaznický kredit" s jménem zákazníka, zůstatkem, numpadem.
3. Zadejte 500, klepněte „Nabít kredit" (zelené).
4. ✅ Zůstatek se zvýší o 500 Kč.
5. ✅ V historii transakcí je vidět +500.
6. Zadejte 200, klepněte „Odečíst kredit" (červené).
7. ✅ Zůstatek se sníží o 200. Nový zůstatek = 300 Kč.

### ⚠️ KAT-14: Odečtení kreditu přesahujícího zůstatek

**Předpoklady:** Zákazník se zůstatkem 100 Kč.

1. V dialogu kreditu zadejte 200.
2. ✅ Tlačítko „Odečíst kredit" je neaktivní (částka > zůstatek).

---

## 11. Skladové hospodářství

### SKL-01: Zobrazení stavu zásob

**Předpoklady:** Existují produkty se sledováním skladu (stock_tracking = true) a nenulové zásoby.

1. Přejděte na `/inventory`, tab „Zásoby".
2. ✅ Tabulka: Položka, Jednotka, Množství, Min. množství, Nákupní cena, Celková hodnota.
3. ✅ Položky pod minimálním množstvím mají množství zobrazeno červeně a tučně.
4. ✅ Dole: „Celková hodnota skladu: {částka}".

### SKL-02: Příjemka (happy path)

1. Klepněte na „Příjemka" (nad tabulkou).
2. ✅ Dialog s poli: Dodavatel (dropdown), Strategie nákupní ceny (dropdown), Poznámka.
3. ✅ Strategie: „Přepsat", „Ponechat", „Průměr", „Vážený průměr".
4. Vyberte dodavatele, strategii „Přepsat".
5. Klepněte „+ Přidat položku".
6. ✅ Vyhledávací dialog — hledání produktů se sledováním skladu.
7. Vyberte produkt.
8. ✅ Přidán řádek: název, pole „Množství", pole „Nákupní cena".
9. Zadejte množství 10, cenu 50.
10. Přidejte další položku.
11. Klepněte „Uložit doklad".
12. ✅ Doklad se vytvoří. V tab „Doklady": typ „Příjemka", datum, dodavatel, celkem.
13. ✅ V tab „Zásoby": množství se zvýšilo o 10.

### SKL-03: Výdejka (odpis/odpad)

1. Klepněte na „Výdejka".
2. ✅ Dialog bez dodavatele a strategie. Jen poznámka + položky.
3. Přidejte položku, zadejte množství 2.
4. Uložte.
5. ✅ V tab „Zásoby": množství se snížilo o 2.
6. ✅ V tab „Doklady": typ „Výdejka".

### SKL-04: Oprava stavu

1. Klepněte na „Oprava".
2. Přidejte položku, zadejte množství (kladné = přidání, záporné = odebrání).
3. Uložte.
4. ✅ Stav se upraví. Doklad typu „Oprava".

### SKL-05: Inventura (fyzická kontrola)

1. Klepněte na „Inventura".
2. ✅ Dialog „Inventura" s tabulkou: Položka, Jednotka, Množství (systémové), Skutečný stav (editovatelné), Rozdíl.
3. ✅ Pole „Skutečný stav" jsou prázdná. „Rozdíl" zobrazuje „-".
4. U položky se systémovým množstvím 10 zadejte skutečný stav 8.
5. ✅ „Rozdíl" = -2 (červeně).
6. U jiné položky zadejte stav 12 (systémové 10).
7. ✅ „Rozdíl" = +2 (zeleně).
8. Klepněte „Uložit inventuru".
9. ✅ Vytvoří se doklad typu „Inventura" s pohyby odpovídajícími rozdílům.
10. ✅ V tab „Zásoby" jsou množství aktualizována na skutečné stavy.

### ⚠️ SKL-06: Inventura bez rozdílů

1. Otevřete „Inventura".
2. U všech položek zadejte stejné hodnoty jako systémové množství.
3. Klepněte „Uložit inventuru".
4. ✅ Dialog se zavře bez vytvoření dokladu (žádné rozdíly).

### ⚠️ SKL-07: Doklad bez položek

1. Otevřete „Příjemka", nepřidejte žádnou položku.
2. ✅ Tlačítko „Uložit doklad" je neaktivní (disabled).

### SKL-08: Automatický odpis při prodeji

**Předpoklady:** Produkt se sledováním skladu, množství = 10.

1. Vytvořte objednávku s tímto produktem (qty 2).
2. ✅ Po odeslání objednávky se stav skladu sníží na 8.
3. Stornujte položku.
4. ✅ Stav skladu se vrátí na 10.

---

## 12. Rezervace

### REZ-01: Vytvoření rezervace (happy path)

1. Na `/bills` klepněte „Rezervace" (v pravém panelu).
2. ✅ Dialog „Rezervace" s tabulkou a datovým rozsahem (dnes → +7 dní).
3. Klepněte „+ Nová rezervace".
4. ✅ Dialog „Nová rezervace" s poli:
   - Jméno (povinné)
   - Telefon
   - Tlačítko „Propojit zákazníka"
   - Datum (výchozí: dnes) + Čas (výchozí: 18:00)
   - Počet osob (výchozí: 2)
   - Stůl (dropdown, první = „-")
   - Poznámka
5. Vyplňte jméno „Novák", telefon, datum, čas 19:00, osoby 4, vyberte stůl.
6. Klepněte „Uložit".
7. ✅ Rezervace se zobrazí v tabulce: datum, čas 19:00, Novák, telefon, 4 osob, stůl.

### REZ-02: Editace a změna stavu rezervace

**Předpoklady:** Existuje rezervace ve stavu „Vytvořena".

1. V seznamu rezervací klepněte na řádek rezervace.
2. ✅ Dialog „Upravit rezervaci" s předvyplněnými hodnotami.
3. ✅ Segmentový přepínač stavu: „Vytvořena" (vybrán), „Potvrzena", „Usazeni", „Zrušena".
4. Přepněte na „Potvrzena".
5. Klepněte „Uložit".
6. ✅ Stav v tabulce se změní. Barva: „Potvrzena" = primární barva.

### REZ-03: Propojení se zákazníkem

1. Vytvořte novou rezervaci.
2. Klepněte „Propojit zákazníka".
3. ✅ Otevře se dialog hledání zákazníka.
4. Vyberte zákazníka.
5. ✅ Jméno a telefon se automaticky vyplní z dat zákazníka.
6. ✅ Zobrazí se čip „Zákazník" s ikonou ×.
7. Klepněte × na čipu.
8. ✅ Propojení se odstraní, jméno a telefon zůstanou.

### REZ-04: Smazání rezervace

1. Otevřete editaci existující rezervace.
2. Klepněte „Smazat" (červený text).
3. ✅ Rezervace se smaže. Zmizí ze seznamu.

### REZ-05: Filtrování rezervací dle data

1. V dialogu „Rezervace" změňte datový rozsah (klepněte na datum).
2. ✅ Otevře se date picker.
3. Vyberte jiný rozsah (např. příští týden).
4. ✅ Tabulka se přefiltruje na vybraný rozsah.

### ⚠️ REZ-06: Prázdný rozsah

1. Nastavte datový rozsah, kde nejsou žádné rezervace.
2. ✅ Tabulka zobrazí „Žádné rezervace".

---

## 13. Nastavení

### NAST-01: Nastavení firmy — základní údaje

1. Další → Nastavení firmy → tab „Firma".
2. ✅ Sekce „Informace o firmě": Název firmy, IČO, DIČ, Adresa, Telefon, E-mail.
3. Změňte název firmy.
4. Klepněte „Uložit".
5. ✅ Změna se uloží.
6. ✅ Sekce „Jazyk aplikace" s čipy „Čeština" / „English".
7. ✅ Sekce „Výchozí měna".
8. ✅ Sekce „Věrnostní program" s poli „Bodů za {měna}" a „Hodnota 1 bodu".

### ⚠️ NAST-02: Prázdný název firmy

1. Smažte název firmy, klepněte „Uložit".
2. ✅ Validační chyba: „Název firmy je povinný".

### NAST-03: Správa uživatelů

1. Tab „Uživatelé".
2. ✅ Tabulka: Název, Username, Role, Aktivní, Akce.
3. Klepněte „+ Přidat".
4. ✅ Dialog: Celé jméno, Uživatelské jméno, PIN (4–6 číslic), Potvrzení PINu, Role (dropdown), Aktivní (switch).
5. Vyplňte: „Jana Nová", „jana", PIN 1234, potvrzení 1234, Role „Obsluha".
6. Klepněte „Uložit".
7. ✅ Uživatel v tabulce. Na login obrazovce se zobrazí.

### ⚠️ NAST-04: Validace uživatele

1. Zkuste uložit uživatele bez jména → ✅ „Celé jméno je povinné".
2. Bez username → ✅ „Uživatelské jméno je povinné".
3. Bez PINu (nový uživatel) → ✅ „PIN je povinný".
4. PIN 3 číslice → ✅ „PIN musí mít 4–6 číslic".
5. PIN neodpovídá potvrzení → ✅ „PINy se neshodují".
6. ✅ Při editaci existujícího uživatele je PIN volitelný (label: „PIN (4–6 číslic) (Upravit)").

### NAST-05: Role a oprávnění

1. Editujte uživatele, změňte roli na „Pomocník".
2. Klepněte „Uložit".
3. ✅ Role se změní. Uživatel má omezenou sadu oprávnění.
4. ✅ Role: Pomocník (6 oprávnění), Obsluha (11), Administrátor (16).

### NAST-06: Zabezpečení — nastavení

1. Tab „Zabezpečení".
2. ✅ Switch: „Vyžadovat PIN při přepínání obsluhy".
3. ✅ Dropdown: „Automatické zamčení po nečinnosti" s hodnotami „Vypnuto", „1 min", „2 min", „5 min", „10 min", „15 min", „30 min".
4. Zapněte PIN při přepnutí, nastavte zamčení na 5 min.
5. ✅ Nastavení se automaticky uloží.

### NAST-07: Cloud — odpojení a připojení

1. Tab „Cloud".
2. **Připojený stav:**
   - ✅ Ikona cloudu, „Připojeno jako {email}".
   - Klepněte „Odpojit".
   - ✅ Stav se změní na „Odpojeno" s ikonou cloud_off.
3. **Odpojený stav:**
   - ✅ Pole E-mail a Heslo + tlačítko „Přihlásit".
   - Vyplňte údaje, klepněte „Přihlásit".
   - ✅ Přihlásí se a zobrazí „Připojeno".

### ⚠️ NAST-08: Cloud — neplatné přihlášení

1. V odpojeném stavu zadejte špatné heslo.
2. Klepněte „Přihlásit".
3. ✅ Zobrazí se chyba. Stav zůstává „Odpojeno".

### NAST-09: Daňové sazby

1. Tab „Daň. sazby" → „+ Přidat".
2. ✅ Pole: Název, Typ (dropdown: „Běžná", „Bez DPH", „Konstantní", „Smíšená"), Sazba (%), Výchozí.
3. Vytvořte sazbu „DPH 21 %" s typem Běžná, sazbou 21, výchozí = ano.
4. ✅ Sazba v tabulce. Ostatní sazby ztratí příznak „Výchozí".

### NAST-10: Platební metody

1. Tab „Plat. metody" → „+ Přidat".
2. ✅ Pole: Název, Typ (dropdown: „Hotovost", „Karta", „Převod", „Kredit", „Ostatní"), Aktivní.
3. Vytvořte „Stravenky" typu „Ostatní", aktivní.
4. ✅ Metoda v tabulce. Zobrazí se jako tlačítko v platebním dialogu.

### NAST-11: Sekce a stoly

1. Další → Nastavení provozovny → tab „Sekce".
2. Vytvořte sekci „Terasa", barva zelená, aktivní, výchozí.
3. ✅ Sekce v tabulce. Předchozí výchozí sekce ztratí příznak.
4. Tab „Stoly" → „+ Přidat".
5. Vytvořte stůl „T1", sekce „Terasa", kapacita 4.
6. ✅ Stůl v tabulce s vazbou na sekci.

### NAST-12: Mapa — editor

1. Tab „Mapa".
2. ✅ Grid 32×20 s existujícími stoly/prvky.
3. Klepněte na prázdnou buňku.
4. ✅ Dialog „Přidat stůl na mapu" s volbou „Stůl" / „Prvek".
5. Vyberte „Stůl", nastavte šířku 2, výšku 2, tvar, barvu.
6. Klepněte „Uložit".
7. ✅ Stůl se zobrazí na mapě ve zvolené pozici a velikosti.
8. Podržte stůl a přetáhněte (long-press drag).
9. ✅ Stůl se přesune na novou pozici.
10. Dvakrát klepněte na stůl.
11. ✅ Dialog „Upravit pozici stolu" s tlačítkem „Odebrat z mapy".

### NAST-13: Pokladny — správa

1. Tab „Pokladny".
2. ✅ Tabulka pokladen se sloupci: Název, Typ, Toto zařízení, Akce.
3. Klepněte „+ Pokladna".
4. ✅ Dialog: Název, Typ (Stacionární/Mobilní/Virtuální), Hlavní, Aktivní, platební přepínače (Hotovost, Karta, Převod, Refundy).
5. Vytvořte „Pokladna 2", stacionární, neaktivní.
6. ✅ Pokladna v tabulce.

### NAST-14: Svázání zařízení s pokladnou

**Předpoklady:** Žádná aktivní směna, existuje nesvázaná pokladna.

1. V tab „Pokladny" u nesvázané pokladny klepněte „Svázat".
2. ✅ Pokladna se sváže s tímto zařízením. Sloupec se změní na „Toto zařízení".

### ⚠️ NAST-15: Svázání během aktivní směny

**Předpoklady:** Aktivní směna.

1. ✅ Banner: „Nelze změnit svázání během aktivní směny."
2. ✅ Tlačítko „Svázat" je neaktivní.

### NAST-16: Nastavení pokladny — grid

1. Další → Nastavení pokladny → tab „Nastavení pokladny".
2. ✅ Dropdown „Řádky gridu" (1–10) a „Sloupce gridu" (1–12).
3. Změňte hodnoty. ✅ Grid na sell obrazovce se přizpůsobí.
4. Klepněte na „Automatické rozmístění".
5. ✅ Dialog auto-arrange s volbami směru rozmístění.

---

## 14. KDS (Kuchyňský displej)

### KDS-01: Zobrazení objednávek

**Předpoklady:** Přihlášení v režimu KDS, existují aktivní objednávky.

1. ✅ Obrazovka `/kds` zobrazuje grid kartiček objednávek.
2. ✅ AppBar: hamburger menu, živé hodiny (datum + čas + sekundy).
3. ✅ Kartičky: číslo objednávky, stůl, uplynulý čas, položky se stavy.

### KDS-02: Bump objednávky (celé)

**Předpoklady:** Objednávka ve stavu „Vytvořené".

1. Klepněte na kartičku objednávky (tlačítko posunu stavu).
2. ✅ Všechny položky se posunou na „Hotové" (ready).
3. Klepněte znovu.
4. ✅ Všechny se posunou na „Doručené" (delivered).
5. ✅ Kartička zmizí z aktivního filtru.

### KDS-03: Bump jednotlivé položky

1. Klepněte na konkrétní položku v kartičce.
2. ✅ Pouze tato položka se posune na další stav.

### KDS-04: Filtrování na KDS

1. ✅ Dole filtrové čipy: „Vytvořené", „Hotové", „Doručené" (bez „Stornované").
2. Odznačte „Vytvořené", nechte jen „Hotové".
3. ✅ Zobrazí se pouze objednávky s alespoň jednou „Hotovou" položkou.

### KDS-05: Prázdný stav

1. Bump-ujte všechny objednávky na „Doručené", odznačte „Doručené".
2. ✅ Zobrazí se „Žádné objednávky k přípravě".

### KDS-06: Odhlášení z KDS

1. Otevřete hamburger menu (vlevo nahoře).
2. Klepněte „Odhlásit".
3. ✅ Navigace na `/login`.

### ⚠️ KDS-07: Ochrana proti dvojitému klepnutí

1. Rychle dvakrát klepněte na kartičku objednávky.
2. ✅ Stav se posune jen o 1 krok (ne přeskočení created → delivered).
3. ✅ Guard `_isBumping` zabrání race condition.

---

## 15. Zákaznický displej

### DISP-01: Idle stav

**Předpoklady:** Spárovaný zákaznický displej.

1. ✅ Displej zobrazuje název firmy a uvítací text.
2. ✅ Žádná interaktivní tlačítka pro zákazníka.

### DISP-02: Náhled košíku

**Předpoklady:** POS prodává na spárované pokladně.

1. Na POS přidejte položky do košíku.
2. ✅ Zákaznický displej přepne na náhled košíku — zobrazuje položky a celkem.

### DISP-03: Poděkování po platbě

1. Na POS zaplaťte účet.
2. ✅ Displej zobrazí „Děkujeme" stav na 5 sekund.
3. ✅ Po 5 sekundách se vrátí na idle.

### DISP-04: Odpárování (skrytá akce)

1. Na zákaznickém displeji 3× rychle klepněte na uvítací text.
2. ✅ Displej se odpáruje a vrátí na onboarding.

---

## 16. Reporty a uzávěrky

### REP-01: Z-Report — zobrazení

**Předpoklady:** Existuje uzavřená směna s prodeji.

1. Další → Reporty.
2. ✅ Dialog „Přehled uzávěrek" s tabulkou: Datum, Čas, Pokladna, Uživatel, Tržba, Rozdíl.
3. ✅ Datový rozsah: posledních 7 dní.
4. Klepněte na řádek uzávěrky.
5. ✅ Dialog „Z-Report" s detaily:
   - Informace o směně (Pokladna, Začátek, Konec, Trvání, Otevřel).
   - Tržba dle plateb (řádky + Celkem).
   - DPH (tabulka: Sazba, Základ, DPH, Celkem) — pokud existuje.
   - Spropitné celkem (pokud > 0) + rozpad dle obsluhy.
   - Slevy celkem (pokud > 0).
   - Počty účtů (zaplacené, stornované, refundované, otevřené).
   - Stav hotovosti (Počáteční, Tržba, Vklady, Výběry, Očekávaná, Konečný stav, Rozdíl).

### REP-02: Z-Report — tisk PDF

1. V dialogu Z-Report klepněte „Tisk".
2. ✅ Vygeneruje se PDF a otevře v systémovém prohlížeči.

### REP-03: Report provozovny

**Předpoklady:** Více uzavřených směn na různých pokladnách.

1. V „Přehled uzávěrek" klepněte „Report provozovny".
2. ✅ Dialog „Report provozovny" s agregovanými daty za celou provozovnu.
3. ✅ Sekce „Rozpad dle pokladen" s daty per pokladna.

### REP-04: Filtrování uzávěrek dle data

1. V „Přehled uzávěrek" klepněte na datum v rozsahu.
2. ✅ Otevře se date picker.
3. Vyberte jiný rozsah.
4. ✅ Tabulka se přefiltruje.

### REP-05: Přehled směn

1. Další → Směny.
2. ✅ Dialog „Přehled směn" s tabulkou: Datum, Obsluha, Přihlášení, Odhlášení, Trvání.
3. ✅ Aktivní směna zobrazuje „probíhá" (primární barva, tučně) místo času odhlášení.
4. ✅ Trvání se počítá i pro probíhající směny (now − loginAt).

### ⚠️ REP-06: Prázdný rozsah

1. Nastavte datový rozsah, kde nebyly žádné uzávěrky.
2. ✅ Zobrazí se „Žádné uzávěrky".

---

## 17. Synchronizace a offline

### SYNC-01: Základní sync po přihlášení

**Předpoklady:** Cloud přihlášen, internet dostupný.

1. Přihlaste se.
2. ✅ V info panelu se zobrazí „Připojeno" u synchronizace.
3. ✅ Sync se automaticky spustí — initial push + drain loop.
4. Vytvořte produkt v katalogu.
5. ✅ Data se synchronizují do Supabase (ověřit v Supabase dashboard nebo na druhém zařízení).

### SYNC-02: Offline režim — lokální operace

**Předpoklady:** Přihlášen, aktivní směna, poté odpojte internet.

1. ✅ Info panel: „Nepřipojeno".
2. Vytvořte účet, objednejte, zaplaťte.
3. ✅ Všechny operace fungují lokálně bez chyb.
4. ✅ Data se ukládají do lokální DB.

### SYNC-03: Reconnect — doplnění dat

**Předpoklady:** Provedli jste operace offline (SYNC-02).

1. Znovu připojte internet.
2. ✅ Info panel: „Připojeno".
3. ✅ Outbox processor automaticky odešle čekající záznamy.
4. ✅ Data se doplní na Supabase.

### SYNC-04: Cross-device sync

**Předpoklady:** 2 zařízení připojená ke stejné firmě.

1. Na zařízení A vytvořte nový produkt.
2. ✅ Na zařízení B se produkt objeví (Realtime < 2s, polling fallback ≤ 5 min).

### ⚠️ SYNC-05: Konflikt LWW

**Předpoklady:** 2 zařízení.

1. Na obou zařízeních odpojte internet.
2. Na zařízení A změňte název produktu na „Produkt A".
3. Na zařízení B změňte název téhož produktu na „Produkt B".
4. Připojte obě zařízení.
5. ✅ Vyhraje ta změna, která má novější `updatedAt` timestamp (Last Write Wins).

### ⚠️ SYNC-06: Sync při vypnutém cloudu

**Předpoklady:** Cloud je odpojený (tab Cloud → Odpojit).

1. ✅ Aplikace funguje plně lokálně.
2. ✅ Sync se nespouští. Žádné chyby.
3. ✅ V info panelu: „Nepřipojeno".

---

## 18. Oprávnění

### OPR-01: Administrátor — plný přístup

**Předpoklady:** Přihlášen uživatel s rolí „Administrátor".

1. ✅ Přístup ke všem obrazovkám: `/bills`, `/sell`, `/orders`, `/catalog`, `/inventory`, `/vouchers`.
2. ✅ Přístup do nastavení: `/settings/company`, `/settings/venue`, `/settings/register`.
3. ✅ Všechna tlačítka aktivní (storno, refund, slevy atd.).

### OPR-02: Obsluha — omezení nastavení

**Předpoklady:** Přihlášen uživatel s rolí „Obsluha".

1. ✅ Přístup na `/bills`, `/sell`, `/orders`.
2. Zkuste přejít na `/settings/company`.
3. ✅ Redirect zpět na `/bills` (nemá oprávnění `settings.manage`).
4. ✅ V menu „Další" chybí položky nastavení nebo jsou neaktivní.

### OPR-03: Pomocník — minimální oprávnění

**Předpoklady:** Přihlášen uživatel s rolí „Pomocník" (6 oprávnění).

1. ✅ Přístup na `/bills`, `/sell`.
2. Zkuste přejít na `/orders`.
3. ✅ Redirect zpět (nemá `orders.view`).
4. Zkuste přejít na `/catalog`, `/inventory`, `/vouchers`.
5. ✅ Redirect zpět (nemá `settings.manage`).

### OPR-04: Chráněné akce bez oprávnění

**Předpoklady:** Přihlášen uživatel bez příslušného oprávnění.

1. Zkuste provést akci vyžadující oprávnění (např. storno účtu bez `bills.cancel`).
2. ✅ Akce je buď skrytá (tlačítko chybí) nebo se zobrazí „Nemáte oprávnění pro tuto akci".

### OPR-05: Změna role za běhu

**Předpoklady:** Přihlášen uživatel A (obsluha), admin B je přihlášen na jiném zařízení.

1. Na zařízení B změňte roli uživatele A na „Pomocník".
2. ✅ Po sync (Realtime < 2s) se oprávnění uživatele A aktualizují.
3. ✅ Uživatel A ztratí přístup k dříve dostupným obrazovkám.

---

## Kontrolní seznam prostředí

Před spuštěním testů ověřte:

- [ ] Aplikace je nainstalována a spustitelná
- [ ] Supabase projekt je dostupný (pro sync testy)
- [ ] Existují testovací data (produkty, kategorie, daňové sazby, platební metody)
- [ ] Existují alespoň 2 uživatelé s různými rolemi
- [ ] Existují sekce a stoly
- [ ] Pro offline testy: možnost odpojit/připojit internet
- [ ] Pro cross-device testy: 2 zařízení připojená ke stejné firmě
- [ ] Pro KDS/display testy: druhé zařízení nebo instance
