import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_session_currency_cash_company_updated', columns: {#companyId, #updatedAt})
class SessionCurrencyCash extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get registerSessionId => text()();
  TextColumn get currencyId => text()();
  IntColumn get openingCash => integer().withDefault(const Constant(0))();
  IntColumn get closingCash => integer().nullable()();
  IntColumn get expectedCash => integer().nullable()();
  IntColumn get difference => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
