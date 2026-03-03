import 'package:drift/drift.dart';

import '../../data/enums/ai_message_role.dart';
import '../../data/enums/ai_message_status.dart';

@TableIndex(name: 'idx_ai_messages_conversation', columns: {#conversationId, #createdAt})
class AiMessages extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get conversationId => text()();
  TextColumn get role => textEnum<AiMessageRole>()();
  TextColumn get content => text()();
  TextColumn get toolCalls => text().nullable()();
  TextColumn get toolResults => text().nullable()();
  TextColumn get status => textEnum<AiMessageStatus>()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get tokenCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
