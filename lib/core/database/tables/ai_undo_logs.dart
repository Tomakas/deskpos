import 'package:drift/drift.dart';

@TableIndex(name: 'idx_ai_undo_logs_conversation', columns: {#conversationId, #createdAt})
@TableIndex(name: 'idx_ai_undo_logs_message', columns: {#messageId})
class AiUndoLogs extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get conversationId => text()();
  TextColumn get messageId => text()();
  TextColumn get toolCallId => text()();
  TextColumn get operationType => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get snapshotBefore => text().nullable()();
  TextColumn get snapshotAfter => text().nullable()();
  BoolColumn get isUndone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get undoneAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
