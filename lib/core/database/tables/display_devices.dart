import 'package:drift/drift.dart';

import '../../data/enums/display_device_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_display_devices_company_updated', columns: {#companyId, #updatedAt})
class DisplayDevices extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get parentRegisterId => text().nullable()();
  TextColumn get code => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get welcomeText => text().withDefault(const Constant(''))();
  TextColumn get type => textEnum<DisplayDeviceType>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
