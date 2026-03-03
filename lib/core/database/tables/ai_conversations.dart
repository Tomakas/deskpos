import 'package:drift/drift.dart';

@TableIndex(name: 'idx_ai_conversations_company_user', columns: {#companyId, #userId})
class AiConversations extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get userId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get screenContext => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
