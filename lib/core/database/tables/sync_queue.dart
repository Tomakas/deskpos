import 'package:drift/drift.dart';

@TableIndex(name: 'idx_sync_queue_company_status', columns: {#companyId, #status})
@TableIndex(name: 'idx_sync_queue_entity', columns: {#entityType, #entityId})
@TableIndex(name: 'idx_sync_queue_created', columns: {#createdAt})
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastErrorAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get processedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
