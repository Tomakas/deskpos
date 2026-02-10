import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_shifts_company_updated', columns: {#companyId, #updatedAt})
class Shifts extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get registerSessionId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get loginAt => dateTime()();
  DateTimeColumn get logoutAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
