import 'package:drift/drift.dart';

class SyncMetadata extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get entityTableName => text().named('table_name')();
  TextColumn get lastPulledAt => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
