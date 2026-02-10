import 'package:drift/drift.dart';

import '../../data/enums/cash_movement_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_cash_movements_company_updated', columns: {#companyId, #updatedAt})
class CashMovements extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get registerSessionId => text()();
  TextColumn get userId => text()();
  IntColumn get type => intEnum<CashMovementType>()();
  IntColumn get amount => integer()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
