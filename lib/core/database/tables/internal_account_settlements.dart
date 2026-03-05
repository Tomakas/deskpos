import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_internal_account_settlements_company_updated', columns: {#companyId, #updatedAt})
class InternalAccountSettlements extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get internalAccountId => text()();
  TextColumn get settledByUserId => text()();
  DateTimeColumn get settledAt => dateTime()();
  IntColumn get totalAmount => integer().withDefault(const Constant(0))();
  IntColumn get settledAmount => integer().withDefault(const Constant(0))();
  IntColumn get forgivenAmount => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
