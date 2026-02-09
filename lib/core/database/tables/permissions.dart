import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

class Permissions extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();

  @override
  Set<Column> get primaryKey => {id};
}
