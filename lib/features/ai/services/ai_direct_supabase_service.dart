import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/enums/ai_message_role.dart';
import '../../../core/data/enums/ai_message_status.dart';
import '../../../core/data/models/ai_conversation_model.dart';
import '../../../core/data/models/ai_message_model.dart';
import '../../../core/data/models/ai_undo_log_model.dart';
import '../../../core/database/app_database.dart';
import '../../../core/logging/app_logger.dart';

/// Direct Supabase service for AI data.
///
/// AI tables bypass the outbox/sync system entirely.
/// Supabase is the source of truth; local Drift is a read cache only.
class AiDirectSupabaseService {
  AiDirectSupabaseService({
    required SupabaseClient supabaseClient,
    required AppDatabase db,
  })  : _supabase = supabaseClient,
        _db = db;

  final SupabaseClient _supabase;
  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  Future<AiConversationModel> createConversation({
    required String id,
    required String companyId,
    required String userId,
    String? screenContext,
  }) async {
    final now = DateTime.now();
    final row = {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'screen_context': screenContext,
      'is_archived': false,
      'created_at': now.toUtc().toIso8601String(),
      'updated_at': now.toUtc().toIso8601String(),
    };

    await _supabase.from('ai_conversations').upsert(row);

    final model = AiConversationModel(
      id: id,
      companyId: companyId,
      userId: userId,
      screenContext: screenContext,
      createdAt: now,
      updatedAt: now,
    );

    // Cache locally
    await _cacheConversation(model);
    return model;
  }

  Future<void> updateConversationTitle(String id, String title) async {
    final now = DateTime.now();
    await _supabase.from('ai_conversations').update({
      'title': title,
      'updated_at': now.toUtc().toIso8601String(),
    }).eq('id', id);

    // Update local cache
    await (_db.update(_db.aiConversations)..where((t) => t.id.equals(id)))
        .write(AiConversationsCompanion(
      title: Value(title),
      updatedAt: Value(now),
    ));
  }

  Future<void> archiveConversation(String id) async {
    final now = DateTime.now();
    await _supabase.from('ai_conversations').update({
      'is_archived': true,
      'updated_at': now.toUtc().toIso8601String(),
    }).eq('id', id);

    await (_db.update(_db.aiConversations)..where((t) => t.id.equals(id)))
        .write(AiConversationsCompanion(
      isArchived: const Value(true),
      updatedAt: Value(now),
    ));
  }

  Future<List<AiConversationModel>> fetchConversations({
    required String companyId,
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _supabase
        .from('ai_conversations')
        .select()
        .eq('company_id', companyId)
        .eq('user_id', userId)
        .eq('is_archived', false)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final models = rows.map(_conversationFromJson).toList();

    // Cache locally
    for (final m in models) {
      await _cacheConversation(m);
    }
    return models;
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  Future<AiMessageModel> saveMessage(AiMessageModel message) async {
    final row = _messageToJson(message);
    await _supabase.from('ai_messages').upsert(row);

    // Cache locally
    await _cacheMessage(message);
    return message;
  }

  Future<List<AiMessageModel>> fetchMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _supabase
        .from('ai_messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    final models = rows.map(_messageFromJson).toList();

    for (final m in models) {
      await _cacheMessage(m);
    }
    return models;
  }

  Future<int> countUserMessagesInLastHour({
    required String companyId,
    required String userId,
  }) async {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    // ai_messages has no user_id column — resolve via ai_conversations
    final convRows = await _supabase
        .from('ai_conversations')
        .select('id')
        .eq('company_id', companyId)
        .eq('user_id', userId)
        .isFilter('deleted_at', null);

    final convIds = convRows.map((r) => r['id'] as String).toList();
    if (convIds.isEmpty) return 0;

    final rows = await _supabase
        .from('ai_messages')
        .select('id')
        .inFilter('conversation_id', convIds)
        .eq('role', 'user')
        .gte('created_at', oneHourAgo.toUtc().toIso8601String())
        .isFilter('deleted_at', null);

    return rows.length;
  }

  // ---------------------------------------------------------------------------
  // Undo logs
  // ---------------------------------------------------------------------------

  Future<void> saveUndoLog(AiUndoLogModel log) async {
    final row = _undoLogToJson(log);
    await _supabase.from('ai_undo_logs').upsert(row);

    // Cache locally
    await _cacheUndoLog(log);
  }

  Future<List<AiUndoLogModel>> fetchUndoLogsForMessage(String messageId) async {
    final rows = await _supabase
        .from('ai_undo_logs')
        .select()
        .eq('message_id', messageId)
        .eq('is_undone', false)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);

    return rows.map(_undoLogFromJson).toList();
  }

  Future<void> markUndone(List<String> logIds) async {
    if (logIds.isEmpty) return;
    final now = DateTime.now();
    await _supabase.from('ai_undo_logs').update({
      'is_undone': true,
      'undone_at': now.toUtc().toIso8601String(),
      'updated_at': now.toUtc().toIso8601String(),
    }).inFilter('id', logIds);

    // Update local cache
    for (final id in logIds) {
      await (_db.update(_db.aiUndoLogs)..where((t) => t.id.equals(id)))
          .write(AiUndoLogsCompanion(
        isUndone: const Value(true),
        undoneAt: Value(now),
        updatedAt: Value(now),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Local cache watch streams
  // ---------------------------------------------------------------------------

  Stream<List<AiMessageModel>> watchLocalMessages(String conversationId) {
    final query = _db.select(_db.aiMessages)
      ..where((t) => t.conversationId.equals(conversationId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

    return query.watch().map(
          (rows) => rows.map(_messageFromEntity).toList(),
        );
  }

  Stream<List<AiConversationModel>> watchLocalConversations(
    String companyId,
    String userId,
  ) {
    final query = _db.select(_db.aiConversations)
      ..where((t) =>
          t.companyId.equals(companyId) &
          t.userId.equals(userId) &
          t.isArchived.equals(false) &
          t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query.watch().map(
          (rows) => rows.map(_conversationFromEntity).toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  Future<void> cleanupLocalCache() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    await (_db.delete(_db.aiConversations)
          ..where((t) => t.createdAt.isSmallerThanValue(cutoff)))
        .go();
    await (_db.delete(_db.aiMessages)
          ..where((t) => t.createdAt.isSmallerThanValue(cutoff)))
        .go();

    final undoCutoff = DateTime.now().subtract(const Duration(days: 30));
    await (_db.delete(_db.aiUndoLogs)
          ..where((t) => t.createdAt.isSmallerThanValue(undoCutoff)))
        .go();

    AppLogger.info('AI local cache cleanup complete', tag: 'AI');
  }

  Future<void> cleanupStaleStreaming() async {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 2));
    await (_db.update(_db.aiMessages)
          ..where((t) =>
              t.status.equalsValue(AiMessageStatus.streaming) &
              t.updatedAt.isSmallerThanValue(cutoff)))
        .write(AiMessagesCompanion(
      status: const Value(AiMessageStatus.error),
      errorMessage: const Value('Streaming timed out'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ---------------------------------------------------------------------------
  // Private JSON mappers
  // ---------------------------------------------------------------------------

  AiConversationModel _conversationFromJson(Map<String, dynamic> json) {
    return AiConversationModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      screenContext: json['screen_context'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  AiMessageModel _messageFromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      conversationId: json['conversation_id'] as String,
      role: AiMessageRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      toolCalls: json['tool_calls'] as String?,
      toolResults: json['tool_results'] as String?,
      status: AiMessageStatus.values.byName(json['status'] as String),
      errorMessage: json['error_message'] as String?,
      tokenCount: json['token_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  AiUndoLogModel _undoLogFromJson(Map<String, dynamic> json) {
    return AiUndoLogModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      conversationId: json['conversation_id'] as String,
      messageId: json['message_id'] as String,
      toolCallId: json['tool_call_id'] as String,
      operationType: json['operation_type'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      snapshotBefore: json['snapshot_before'] as String?,
      snapshotAfter: json['snapshot_after'] as String?,
      isUndone: json['is_undone'] as bool? ?? false,
      undoneAt: json['undone_at'] != null ? DateTime.parse(json['undone_at'] as String) : null,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> _messageToJson(AiMessageModel m) => {
        'id': m.id,
        'company_id': m.companyId,
        'conversation_id': m.conversationId,
        'role': m.role.name,
        'content': m.content,
        'tool_calls': m.toolCalls,
        'tool_results': m.toolResults,
        'status': m.status.name,
        'error_message': m.errorMessage,
        'token_count': m.tokenCount,
        'created_at': m.createdAt.toUtc().toIso8601String(),
        'updated_at': m.updatedAt.toUtc().toIso8601String(),
        'deleted_at': m.deletedAt?.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _undoLogToJson(AiUndoLogModel m) => {
        'id': m.id,
        'company_id': m.companyId,
        'conversation_id': m.conversationId,
        'message_id': m.messageId,
        'tool_call_id': m.toolCallId,
        'operation_type': m.operationType,
        'entity_type': m.entityType,
        'entity_id': m.entityId,
        'snapshot_before': m.snapshotBefore,
        'snapshot_after': m.snapshotAfter,
        'is_undone': m.isUndone,
        'undone_at': m.undoneAt?.toUtc().toIso8601String(),
        'expires_at': m.expiresAt.toUtc().toIso8601String(),
        'created_at': m.createdAt.toUtc().toIso8601String(),
        'updated_at': m.updatedAt.toUtc().toIso8601String(),
        'deleted_at': m.deletedAt?.toUtc().toIso8601String(),
      };

  // ---------------------------------------------------------------------------
  // Private entity mappers (Drift row -> model)
  // ---------------------------------------------------------------------------

  AiConversationModel _conversationFromEntity(AiConversation e) {
    return AiConversationModel(
      id: e.id,
      companyId: e.companyId,
      userId: e.userId,
      title: e.title,
      screenContext: e.screenContext,
      isArchived: e.isArchived,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );
  }

  AiMessageModel _messageFromEntity(AiMessage e) {
    return AiMessageModel(
      id: e.id,
      companyId: e.companyId,
      conversationId: e.conversationId,
      role: e.role,
      content: e.content,
      toolCalls: e.toolCalls,
      toolResults: e.toolResults,
      status: e.status,
      errorMessage: e.errorMessage,
      tokenCount: e.tokenCount,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Private cache helpers
  // ---------------------------------------------------------------------------

  Future<void> _cacheConversation(AiConversationModel m) async {
    await _db.into(_db.aiConversations).insertOnConflictUpdate(
          AiConversationsCompanion.insert(
            id: m.id,
            companyId: m.companyId,
            userId: m.userId,
            title: Value(m.title),
            screenContext: Value(m.screenContext),
            isArchived: Value(m.isArchived),
            createdAt: m.createdAt,
            updatedAt: m.updatedAt,
            deletedAt: Value(m.deletedAt),
          ),
        );
  }

  Future<void> _cacheMessage(AiMessageModel m) async {
    await _db.into(_db.aiMessages).insertOnConflictUpdate(
          AiMessagesCompanion.insert(
            id: m.id,
            companyId: m.companyId,
            conversationId: m.conversationId,
            role: m.role,
            content: m.content,
            toolCalls: Value(m.toolCalls),
            toolResults: Value(m.toolResults),
            status: m.status,
            errorMessage: Value(m.errorMessage),
            tokenCount: Value(m.tokenCount),
            createdAt: m.createdAt,
            updatedAt: m.updatedAt,
            deletedAt: Value(m.deletedAt),
          ),
        );
  }

  Future<void> _cacheUndoLog(AiUndoLogModel m) async {
    await _db.into(_db.aiUndoLogs).insertOnConflictUpdate(
          AiUndoLogsCompanion.insert(
            id: m.id,
            companyId: m.companyId,
            conversationId: m.conversationId,
            messageId: m.messageId,
            toolCallId: m.toolCallId,
            operationType: m.operationType,
            entityType: m.entityType,
            entityId: m.entityId,
            snapshotBefore: Value(m.snapshotBefore),
            snapshotAfter: Value(m.snapshotAfter),
            isUndone: Value(m.isUndone),
            undoneAt: Value(m.undoneAt),
            expiresAt: m.expiresAt,
            createdAt: m.createdAt,
            updatedAt: m.updatedAt,
            deletedAt: Value(m.deletedAt),
          ),
        );
  }
}
