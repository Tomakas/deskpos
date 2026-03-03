import 'ai_provider_models.dart';

sealed class AiStreamEvent {
  const AiStreamEvent();
}

class TextDelta extends AiStreamEvent {
  const TextDelta(this.text);
  final String text;
}

class ToolCallStart extends AiStreamEvent {
  const ToolCallStart({
    required this.index,
    required this.id,
    required this.name,
  });
  final int index;
  final String id;
  final String name;
}

class ToolCallDelta extends AiStreamEvent {
  const ToolCallDelta({
    required this.index,
    required this.argumentsDelta,
  });
  final int index;
  final String argumentsDelta;
}

class ToolCallComplete extends AiStreamEvent {
  const ToolCallComplete({required this.toolCall});
  final AiToolCall toolCall;
}

class StreamDone extends AiStreamEvent {
  const StreamDone({
    required this.promptTokens,
    required this.completionTokens,
    required this.finishReason,
  });
  final int promptTokens;
  final int completionTokens;
  final String finishReason;
}

class StreamError extends AiStreamEvent {
  const StreamError(this.message);
  final String message;
}
