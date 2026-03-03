import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_provider_models.freezed.dart';

// --- Chat message sealed union (not stored, used for API calls) ---

sealed class AiChatMessage {
  const AiChatMessage();
}

class UserMessage extends AiChatMessage {
  const UserMessage({required this.content});
  final String content;
}

class AssistantMessage extends AiChatMessage {
  const AssistantMessage({this.content, this.toolCalls});
  final String? content;
  final List<AiToolCall>? toolCalls;
}

class ToolResultMessage extends AiChatMessage {
  const ToolResultMessage({
    required this.toolCallId,
    required this.content,
    this.isError = false,
  });
  final String toolCallId;
  final String content;
  final bool isError;
}

// --- Freezed models ---

@freezed
abstract class AiToolCall with _$AiToolCall {
  const factory AiToolCall({
    required String id,
    required String name,
    required Map<String, dynamic> arguments,
  }) = _AiToolCall;
}

@freezed
abstract class AiToolDefinition with _$AiToolDefinition {
  const factory AiToolDefinition({
    required String name,
    required String description,
    required Map<String, dynamic> parameters,
  }) = _AiToolDefinition;
}

@freezed
abstract class AiProviderResponse with _$AiProviderResponse {
  const factory AiProviderResponse({
    String? content,
    List<AiToolCall>? toolCalls,
    required int promptTokens,
    required int completionTokens,
    required String finishReason,
  }) = _AiProviderResponse;
}
