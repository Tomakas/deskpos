import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_register_sessions_company_updated', columns: {#companyId, #updatedAt})
class RegisterSessions extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get registerId => text()();
  TextColumn get openedByUserId => text()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get orderCounter => integer().withDefault(const Constant(0))();
  IntColumn get openingCash => integer().nullable()();
  IntColumn get closingCash => integer().nullable()();
  IntColumn get expectedCash => integer().nullable()();
  IntColumn get difference => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
