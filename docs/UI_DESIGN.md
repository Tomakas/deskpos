# Maty — UI/UX Design System

Tento dokument definuje vizuální jazyk, barevné kódy a layouty aplikace Maty.

---

## 1. Základní principy
- **Pracovní nástroj:** Design optimalizuje pro rychlost a svalovou paměť.
- **Uživatel nečte:** Reaguje vizuálně na barvu a pozici.
- **Touch-first:** Všechny akce jsou navrženy pro prst (min. 44x44px).

---

## 2. Barevný systém

| Role | Barva | Význam |
|------|-------|--------|
| Primary | Modrá | Pokračuji v práci |
| Success | Zelená | Uzavírám / dokončuji |
| Neutral | Šedá | Navigace, doplněk |
| Error | Červená | Ruším / končím |

---

## 3. Layouty obrazovek

### ScreenBills (Hlavní přehled)
Layout: **Left (flex: 4), Right (fixed 290px collapsible)**.

```text
┌──────────────────────────────────────────┬──────────────┐
│ [Vše] [Hl.sál] [Zahrádka]                │ RYCHLÝ ÚČET  │
│                                          │ VYTVOŘIT ÚČET│
│  Stůl │Host│Celkem│Posl.obj│Obsluha      │              │
│ ─────┼────┼──────┼────────┼─────────────│──────────────│
│Stůl 1│Novák│212,- │ 15min  │Karel        │ Datum, čas   │
└──────────────────────────────────────────┴──────────────┘
```

### DialogPayment
Layout: **3-sloupcový Expanded (1:2:1 flex ratio)**.

```text
┌──────────────┬────────────────────────┬──────────────┐
│  JINÁ MĚNA   │       PLATBA           │  HOTOVOST    │
│  TISK ÚČT.   │  B-0001 · Stůl 01     │  KARTA       │
│              │     1 250,00 Kč        │  PŘEVOD      │
└──────────────┴────────────────────────┴──────────────┘
```

---

## 4. Komponenty
- **PosTable:** Automatický ellipsis pro všechny Text widgety uvnitř buněk.
- **PosDialogActions:** Centrální widget pro akční lišty (výška 44px).
- **PosNumpad:** Číselná klávesnice s profily (Large/Compact).
- **Bill Age Color:** Modrá (<15min), Oranžová (15-45min), Červená (>45min).
