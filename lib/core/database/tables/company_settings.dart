import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_company_settings_company_updated', columns: {#companyId, #updatedAt})
class CompanySettings extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  BoolColumn get requirePinOnSwitch => boolean().withDefault(const Constant(true))();
  IntColumn get autoLockTimeoutMinutes => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
