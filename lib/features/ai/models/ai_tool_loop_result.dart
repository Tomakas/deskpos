import '../../../core/ai/models/ai_provider_models.dart';

/// Sealed class for orchestration loop outcomes.
sealed class AiToolLoopResult {
  const AiToolLoopResult();
}

/// Loop completed — AI returned a final text response.
class AiToolLoopCompleted extends AiToolLoopResult {
  const AiToolLoopCompleted({
    required this.content,
    required this.promptTokens,
    required this.completionTokens,
  });

  final String content;
  final int promptTokens;
  final int completionTokens;
}

/// Loop paused — a write/delete tool needs user confirmation.
class AiToolLoopNeedsConfirmation extends AiToolLoopResult {
  const AiToolLoopNeedsConfirmation({
    required this.toolCall,
    required this.isDestructive,
    required this.description,
    required this.currentHistory,
  });

  final AiToolCall toolCall;
  final bool isDestructive;
  final String description;
  final List<AiChatMessage> currentHistory;
}

/// Loop ended with an error.
class AiToolLoopError extends AiToolLoopResult {
  const AiToolLoopError(this.message);

  final String message;
}
