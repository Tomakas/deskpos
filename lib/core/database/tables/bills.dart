import 'package:drift/drift.dart';

import '../../data/enums/bill_status.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_bills_company_updated', columns: {#companyId, #updatedAt})
class Bills extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get tableId => text().nullable()();
  TextColumn get openedByUserId => text()();
  TextColumn get billNumber => text()();
  IntColumn get numberOfGuests => integer().withDefault(const Constant(0))();
  BoolColumn get isTakeaway => boolean().withDefault(const Constant(false))();
  TextColumn get status => textEnum<BillStatus>()();
  TextColumn get currencyId => text()();
  IntColumn get subtotalGross => integer().withDefault(const Constant(0))();
  IntColumn get subtotalNet => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get taxTotal => integer().withDefault(const Constant(0))();
  IntColumn get totalGross => integer().withDefault(const Constant(0))();
  IntColumn get roundingAmount => integer().withDefault(const Constant(0))();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
