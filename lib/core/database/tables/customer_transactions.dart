import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_customer_transactions_company_updated', columns: {#companyId, #updatedAt})
class CustomerTransactions extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get customerId => text()();
  IntColumn get pointsChange => integer()();
  IntColumn get creditChange => integer()();
  TextColumn get orderId => text().nullable()();
  TextColumn get processedByUserId => text()();

  @override
  Set<Column> get primaryKey => {id};
}
