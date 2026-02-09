import 'package:drift/drift.dart';

import '../../data/enums/role_name.dart';
import 'sync_columns_mixin.dart';

class Roles extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get name => textEnum<RoleName>()();

  @override
  Set<Column> get primaryKey => {id};
}
