import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'ai_undo_log_model.freezed.dart';

@freezed
abstract class AiUndoLogModel with _$AiUndoLogModel implements CompanyScopedModel {
  const factory AiUndoLogModel({
    required String id,
    required String companyId,
    required String conversationId,
    required String messageId,
    required String toolCallId,
    required String operationType,
    required String entityType,
    required String entityId,
    String? snapshotBefore,
    String? snapshotAfter,
    @Default(false) bool isUndone,
    DateTime? undoneAt,
    required DateTime expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _AiUndoLogModel;
}
