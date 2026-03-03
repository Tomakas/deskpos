import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ai_message_role.dart';
import '../enums/ai_message_status.dart';
import 'company_scoped_model.dart';

part 'ai_message_model.freezed.dart';

@freezed
abstract class AiMessageModel with _$AiMessageModel implements CompanyScopedModel {
  const factory AiMessageModel({
    required String id,
    required String companyId,
    required String conversationId,
    required AiMessageRole role,
    required String content,
    String? toolCalls,
    String? toolResults,
    required AiMessageStatus status,
    String? errorMessage,
    int? tokenCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _AiMessageModel;
}
