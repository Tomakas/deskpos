# Changelog

## 2026-02-09

### Features — Etapa 2: Základní prodej

- **M2.1 Bill creation**: DialogNewBill (three-step wizard: type → table → guests), DialogBillDetail (bill header, order list, footer actions), BillRepository (createBill, updateTotals, cancelBill, generateBillNumber, watchByCompany with section filtering)
- **M2.2 Orders & Items**: ScreenSell (left cart panel + right product grid), OrderRepository (createOrderWithItems in transaction, status transitions), OrderItemInput class, ATT tax calculation
- **M2.3 Payment**: DialogPayment (payment method selection, amount entry), recordPayment (creates payment record, updates bill paidAmount/status)
- **M2.4 Grid editor**: LayoutItemRepository (watchByRegister, setCell, clearCell), edit mode in ScreenSell with GridEditDialog for assigning item/category/clear to grid cells
- **M2.5 Register session**: RegisterSessionRepository (openSession, closeSession, watchActiveSession, incrementOrderCounter), RegisterRepository, dynamic session toggle button on ScreenBills
- **ScreenBills integration**: Bills table with live data from DB, status filter (opened/paid/cancelled), section filter, bill row click opens DialogBillDetail, "Vytvořit účet" and "Rychlý účet" buttons wired to bill creation, register session gate (bill creation disabled without active session)

### Repositories

- Added: BillRepository, OrderRepository, RegisterRepository, RegisterSessionRepository, LayoutItemRepository
- Added `getById()` to TaxRateRepository
- Fixed missing `drift` import in RegisterRepository

### Providers

- Added: billRepositoryProvider, orderRepositoryProvider, registerRepositoryProvider, registerSessionRepositoryProvider, layoutItemRepositoryProvider
- Added: activeRegisterProvider (FutureProvider), activeRegisterSessionProvider (StreamProvider)

### Localization

- Added ~70 Czech strings for all Stage 2 UI: DialogNewBill, DialogBillDetail, ScreenSell, payment, prep statuses, grid editor, register session

### Routing

- Added `/sell/:billId` route to app_router.dart

