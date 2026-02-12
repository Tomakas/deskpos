import 'package:drift/drift.dart';

import '../../data/enums/prep_status.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_orders_company_updated', columns: {#companyId, #updatedAt})
class Orders extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get billId => text()();
  TextColumn get registerId => text().nullable()();
  TextColumn get createdByUserId => text()();
  TextColumn get orderNumber => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => textEnum<PrepStatus>()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
  IntColumn get subtotalGross => integer().withDefault(const Constant(0))();
  IntColumn get subtotalNet => integer().withDefault(const Constant(0))();
  IntColumn get taxTotal => integer().withDefault(const Constant(0))();
  BoolColumn get isStorno => boolean().withDefault(const Constant(false))();
  TextColumn get stornoSourceOrderId => text().nullable()();
  DateTimeColumn get prepStartedAt => dateTime().nullable()();
  DateTimeColumn get readyAt => dateTime().nullable()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
