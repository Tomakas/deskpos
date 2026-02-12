import 'package:drift/drift.dart';

import '../../data/enums/hardware_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_registers_company_updated', columns: {#companyId, #updatedAt})
class Registers extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get code => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get registerNumber => integer().withDefault(const Constant(1))();
  TextColumn get parentRegisterId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get type => textEnum<HardwareType>()();
  BoolColumn get allowCash => boolean().withDefault(const Constant(true))();
  BoolColumn get allowCard => boolean().withDefault(const Constant(true))();
  BoolColumn get allowTransfer => boolean().withDefault(const Constant(true))();
  BoolColumn get allowRefunds => boolean().withDefault(const Constant(false))();
  IntColumn get gridRows => integer().withDefault(const Constant(5))();
  IntColumn get gridCols => integer().withDefault(const Constant(8))();

  @override
  Set<Column> get primaryKey => {id};
}
