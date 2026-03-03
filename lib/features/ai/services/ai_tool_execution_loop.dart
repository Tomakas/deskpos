import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/models/ai_provider_models.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';
import '../models/ai_tool_loop_result.dart';
import 'ai_command_service.dart';
import 'ai_tool_registry.dart';

/// Multi-turn tool execution loop. Handles the iterative pattern where
/// the AI calls tools, gets results, and may call more tools.
class AiToolExecutionLoop {
  AiToolExecutionLoop({
    required AiCommandService commandService,
    required AiToolRegistry toolRegistry,
  })  : _commandService = commandService,
        _toolRegistry = toolRegistry;

  final AiCommandService _commandService;
  final AiToolRegistry _toolRegistry;

  static const int maxIterations = 5;
  static const int maxToolCallsPerResponse = 10;

  /// Processes an AI provider response, executing tool calls and
  /// iterating until a final text response or confirmation is needed.
  Future<AiToolLoopResult> processResponse({
    required AiProvider provider,
    required AiProviderResponse response,
    required String companyId,
    required String userId,
    required String conversationId,
    required String messageId,
    required Set<String> userPermissions,
    required List<AiChatMessage> currentHistory,
    required String systemPrompt,
    required List<AiToolDefinition> tools,
  }) async {
    var currentResponse = response;
    var history = List<AiChatMessage>.from(currentHistory);
    var totalPromptTokens = response.promptTokens;
    var totalCompletionTokens = response.completionTokens;

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      final toolCalls = currentResponse.toolCalls;

      // No tool calls — return final text response
      if (toolCalls == null || toolCalls.isEmpty) {
        return AiToolLoopCompleted(
          content: currentResponse.content ?? '',
          promptTokens: totalPromptTokens,
          completionTokens: totalCompletionTokens,
        );
      }

      // Process tool calls (up to max limit)
      final callsToProcess = toolCalls.length > maxToolCallsPerResponse
          ? toolCalls.sublist(0, maxToolCallsPerResponse)
          : toolCalls;

      final toolResults = <ToolResultMessage>[];

      for (final toolCall in callsToProcess) {
        final isReadOnly = _toolRegistry.isReadOnly(toolCall.name);

        // Write/delete tools need confirmation — pause the loop
        if (!isReadOnly) {
          // Add assistant message with tool calls to history before pausing
          history.add(AssistantMessage(
            content: currentResponse.content,
            toolCalls: callsToProcess,
          ));

          // Add any tool results collected so far
          history.addAll(toolResults);

          final aiContent = currentResponse.content;
          return AiToolLoopNeedsConfirmation(
            toolCall: toolCall,
            isDestructive: toolCall.name.startsWith('delete_'),
            description: (aiContent != null && aiContent.isNotEmpty)
                ? aiContent
                : _toolRegistry.getConfirmLabel(
                    toolCall.name, toolCall.arguments),
            currentHistory: history,
          );
        }

        // Read-only tool — execute immediately
        final result = await _commandService.executeToolCall(
          toolCall: toolCall,
          companyId: companyId,
          userId: userId,
          conversationId: conversationId,
          messageId: messageId,
          userPermissions: userPermissions,
        );

        final resultContent = switch (result) {
          AiCommandSuccess(:final message) => message,
          AiCommandError(:final message) => 'Error: $message',
          AiCommandPermissionDenied(:final message) =>
            'Permission denied: $message',
          AiCommandNeedsConfirmation() => 'Confirmation required',
        };

        toolResults.add(ToolResultMessage(
          toolCallId: toolCall.id,
          content: resultContent,
          isError: result is AiCommandError,
        ));
      }

      // Append assistant message + tool results to history
      history.add(AssistantMessage(
        content: currentResponse.content,
        toolCalls: callsToProcess,
      ));
      history.addAll(toolResults);

      // Send updated history back to provider for next iteration
      try {
        currentResponse = await provider.sendMessage(
          systemPrompt: systemPrompt,
          messages: history,
          tools: tools,
        );
        totalPromptTokens += currentResponse.promptTokens;
        totalCompletionTokens += currentResponse.completionTokens;
      } catch (e, s) {
        AppLogger.error(
          'AI provider error during tool loop',
          tag: 'AI',
          error: e,
          stackTrace: s,
        );
        return AiToolLoopError('AI provider error: $e');
      }
    }

    // Max iterations reached
    return const AiToolLoopError(
      'Maximum tool call iterations reached',
    );
  }
}
