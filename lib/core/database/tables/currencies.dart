import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

class Currencies extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get symbol => text()();
  TextColumn get name => text()();
  IntColumn get decimalPlaces => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
