import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'ai_conversation_model.freezed.dart';

@freezed
abstract class AiConversationModel with _$AiConversationModel implements CompanyScopedModel {
  const factory AiConversationModel({
    required String id,
    required String companyId,
    required String userId,
    String? title,
    String? screenContext,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _AiConversationModel;
}
