import 'package:uuid/uuid.dart';

import '../../../core/data/models/ai_conversation_model.dart';
import 'ai_direct_supabase_service.dart';

const _uuid = Uuid();

/// High-level conversation operations.
class AiConversationManager {
  AiConversationManager({required AiDirectSupabaseService aiDirectService})
      : _aiDirectService = aiDirectService;

  final AiDirectSupabaseService _aiDirectService;

  /// Gets the most recent active conversation or creates a new one.
  Future<AiConversationModel> getOrCreateConversation({
    required String companyId,
    required String userId,
    String? screenContext,
  }) async {
    // Try to find an existing active conversation
    final existing = await _aiDirectService.fetchConversations(
      companyId: companyId,
      userId: userId,
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first;
    }

    // Create a new conversation
    return _aiDirectService.createConversation(
      id: _uuid.v7(),
      companyId: companyId,
      userId: userId,
      screenContext: screenContext,
    );
  }

  /// Generates a title from the first user message.
  Future<void> generateTitle({
    required String conversationId,
    required String firstUserMessage,
  }) async {
    // Take first 50 chars as title
    final title = firstUserMessage.length > 50
        ? '${firstUserMessage.substring(0, 50)}...'
        : firstUserMessage;
    await _aiDirectService.updateConversationTitle(conversationId, title);
  }
}
