import 'package:drift/drift.dart';

import '../../data/enums/hardware_type.dart';
import '../../data/enums/sell_mode.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_registers_company_updated', columns: {#companyId, #updatedAt})
class Registers extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get code => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get registerNumber => integer().withDefault(const Constant(1))();
  TextColumn get parentRegisterId => text().nullable()();
  BoolColumn get isMain => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get type => textEnum<HardwareType>()();
  BoolColumn get allowCash => boolean().withDefault(const Constant(true))();
  BoolColumn get allowCard => boolean().withDefault(const Constant(true))();
  BoolColumn get allowTransfer => boolean().withDefault(const Constant(true))();
  BoolColumn get allowCredit => boolean().withDefault(const Constant(true))();
  BoolColumn get allowVoucher => boolean().withDefault(const Constant(true))();
  BoolColumn get allowOther => boolean().withDefault(const Constant(true))();
  BoolColumn get allowRefunds => boolean().withDefault(const Constant(false))();
  TextColumn get boundDeviceId => text().nullable()();
  TextColumn get activeBillId => text().nullable()();
  IntColumn get gridRows => integer().withDefault(const Constant(5))();
  IntColumn get gridCols => integer().withDefault(const Constant(8))();
  TextColumn get displayCartJson => text().nullable()();
  TextColumn get sellMode => textEnum<SellMode>().withDefault(Constant(SellMode.gastro.name))();

  @override
  Set<Column> get primaryKey => {id};
}
