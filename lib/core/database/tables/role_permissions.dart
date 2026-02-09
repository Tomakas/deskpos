import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

class RolePermissions extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get roleId => text()();
  TextColumn get permissionId => text()();

  @override
  Set<Column> get primaryKey => {id};
}
