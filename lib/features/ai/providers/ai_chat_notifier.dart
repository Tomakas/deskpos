import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/models/ai_provider_models.dart';
import '../../../core/ai/models/ai_stream_event.dart';
import '../../../core/data/enums/ai_message_role.dart';
import '../../../core/data/enums/ai_message_status.dart';
import '../../../core/data/models/ai_conversation_model.dart';
import '../../../core/data/models/ai_message_model.dart';
import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';
import '../models/ai_tool_loop_result.dart';
import '../services/ai_command_service.dart';
import '../services/ai_context_builder.dart';
import '../services/ai_conversation_manager.dart';
import '../services/ai_direct_supabase_service.dart';
import '../services/ai_rate_limiter.dart';
import '../services/ai_system_prompt_builder.dart';
import '../services/ai_tool_execution_loop.dart';
import '../services/ai_tool_registry.dart';
import '../services/ai_undo_service.dart';
import 'ai_providers.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AiChatState {
  const AiChatState({
    this.conversation,
    this.messages = const [],
    this.isProcessing = false,
    this.streamingText = '',
    this.pendingConfirmation,
    this.errorMessage,
  });

  final AiConversationModel? conversation;
  final List<AiMessageModel> messages;
  final bool isProcessing;
  final String streamingText;
  final AiPendingConfirmation? pendingConfirmation;
  final String? errorMessage;

  AiChatState copyWith({
    AiConversationModel? conversation,
    List<AiMessageModel>? messages,
    bool? isProcessing,
    String? streamingText,
    AiPendingConfirmation? pendingConfirmation,
    bool clearPendingConfirmation = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AiChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      streamingText: streamingText ?? this.streamingText,
      pendingConfirmation: clearPendingConfirmation
          ? null
          : (pendingConfirmation ?? this.pendingConfirmation),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier({
    required AiProvider? provider,
    required AiDirectSupabaseService aiDirectService,
    required AiConversationManager conversationManager,
    required AiToolExecutionLoop toolExecutionLoop,
    required AiCommandService commandService,
    required AiContextBuilder contextBuilder,
    required AiSystemPromptBuilder systemPromptBuilder,
    required AiToolRegistry toolRegistry,
    required AiRateLimiter rateLimiter,
    required AiUndoService undoService,
    required CompanySettingsModel? companySettings,
    required this.companyId,
    required this.userId,
    required this.userName,
    required this.userPermissions,
  })  : _provider = provider,
        _aiDirectService = aiDirectService,
        _conversationManager = conversationManager,
        _toolExecutionLoop = toolExecutionLoop,
        _commandService = commandService,
        _contextBuilder = contextBuilder,
        _systemPromptBuilder = systemPromptBuilder,
        _toolRegistry = toolRegistry,
        _rateLimiter = rateLimiter,
        _undoService = undoService,
        _companySettings = companySettings,
        super(const AiChatState()) {
    if (companyId.isNotEmpty) {
      loadConversation();
    }
  }

  final AiProvider? _provider;
  final AiDirectSupabaseService _aiDirectService;
  final AiConversationManager _conversationManager;
  final AiToolExecutionLoop _toolExecutionLoop;
  final AiCommandService _commandService;
  final AiContextBuilder _contextBuilder;
  final AiSystemPromptBuilder _systemPromptBuilder;
  final AiToolRegistry _toolRegistry;
  final AiRateLimiter _rateLimiter;
  final AiUndoService _undoService;
  final CompanySettingsModel? _companySettings;

  final String companyId;
  final String userId;
  final String userName;
  final Set<String> userPermissions;

  /// Paused history when waiting for user confirmation.
  List<AiChatMessage>? _pausedHistory;

  StreamSubscription<AiStreamEvent>? _streamSubscription;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Public: loadConversation
  // ---------------------------------------------------------------------------

  Future<void> loadConversation() async {
    try {
      final conversation = await _conversationManager.getOrCreateConversation(
        companyId: companyId,
        userId: userId,
      );
      if (!mounted) return;

      final messages = await _aiDirectService.fetchMessages(
        conversationId: conversation.id,
      );
      if (!mounted) return;

      state = state.copyWith(
        conversation: conversation,
        messages: messages,
        clearErrorMessage: true,
      );
    } catch (e, s) {
      if (!mounted) return;
      AppLogger.error('Failed to load conversation', tag: 'AI', error: e, stackTrace: s);
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Public: sendMessage
  // ---------------------------------------------------------------------------

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (_provider == null) {
      AppLogger.warn('sendMessage: _provider is null, aborting', tag: 'AI');
      return;
    }
    if (state.isProcessing) return;

    // Rate limit check
    final settings = _companySettings;
    if (settings != null) {
      try {
        final canSend = await _rateLimiter.canSendMessage(
          companyId: companyId,
          userId: userId,
          limitPerHour: settings.aiRateLimitPerHour,
        );
        if (!canSend) {
          state = state.copyWith(errorMessage: 'rate_limit');
          return;
        }
      } catch (e, s) {
        AppLogger.error('Rate limit check failed, continuing', tag: 'AI', error: e, stackTrace: s);
      }
    }

    final conversation = state.conversation;
    if (conversation == null) {
      AppLogger.warn('sendMessage: conversation is null, aborting', tag: 'AI');
      return;
    }

    // Create & save user message
    final now = DateTime.now();
    final userMessage = AiMessageModel(
      id: _uuid.v7(),
      companyId: companyId,
      conversationId: conversation.id,
      role: AiMessageRole.user,
      content: trimmed,
      status: AiMessageStatus.completed,
      createdAt: now,
      updatedAt: now,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isProcessing: true,
      streamingText: '',
      clearErrorMessage: true,
      clearPendingConfirmation: true,
    );

    try {
      await _aiDirectService.saveMessage(userMessage);
    } catch (e, s) {
      AppLogger.error('Failed to save user message', tag: 'AI', error: e, stackTrace: s);
    }

    try {
      // Generate title from first user message
      final isFirstUserMessage = state.messages
          .where((m) => m.role == AiMessageRole.user)
          .length == 1;
      if (isFirstUserMessage) {
        _conversationManager.generateTitle(
          conversationId: conversation.id,
          firstUserMessage: trimmed,
        );
      }

      // Build system prompt
      final catalogSummary = await _contextBuilder.buildCatalogSummary(companyId);
      final systemPrompt = _systemPromptBuilder.build(
        locale: settings?.locale ?? 'cs',
        companyName: companyId,
        userName: userName,
        currentScreen: 'ai_chat',
        userPermissions: userPermissions,
        catalogSummary: catalogSummary,
        hasActiveSession: false,
      );

      // Build tool definitions filtered by permissions
      final tools = _toolRegistry.getTools(userPermissions);

      // Build history
      final history = _buildHistory(state.messages);

      // Start streaming
      await _startStreaming(
        systemPrompt: systemPrompt,
        history: history,
        tools: tools,
        conversation: conversation,
      );
    } catch (e, s) {
      AppLogger.error('sendMessage failed', tag: 'AI', error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(
          isProcessing: false,
          streamingText: '',
          errorMessage: e.toString(),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Public: confirmPendingAction
  // ---------------------------------------------------------------------------

  Future<void> confirmPendingAction() async {
    final pending = state.pendingConfirmation;
    if (pending == null) return;

    final conversation = state.conversation;
    if (conversation == null) return;

    state = state.copyWith(
      isProcessing: true,
      clearPendingConfirmation: true,
    );

    try {
      // Execute the pending tool call
      final result = await _commandService.executeToolCall(
        toolCall: pending.toolCall,
        companyId: companyId,
        userId: userId,
        conversationId: conversation.id,
        messageId: pending.messageId,
        userPermissions: userPermissions,
      );

      final resultContent = switch (result) {
        AiCommandSuccess(:final message) => message,
        AiCommandError(:final message) => 'Error: $message',
        AiCommandPermissionDenied(:final message) => 'Permission denied: $message',
        AiCommandNeedsConfirmation() => 'Confirmation required',
      };

      // Add tool result to paused history
      final history = _pausedHistory ?? _buildHistory(state.messages);
      history.add(ToolResultMessage(
        toolCallId: pending.toolCall.id,
        content: resultContent,
        isError: result is AiCommandError,
      ));

      // Persist tool result so history stays consistent across sessions
      final toolResultMsg = AiMessageModel(
        id: _uuid.v7(),
        companyId: companyId,
        conversationId: conversation.id,
        role: AiMessageRole.tool,
        content: resultContent,
        toolResults: jsonEncode({
          'tool_call_id': pending.toolCall.id,
          'is_error': result is AiCommandError,
        }),
        status: AiMessageStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, toolResultMsg]);
      try {
        await _aiDirectService.saveMessage(toolResultMsg);
      } catch (e) {
        AppLogger.warn('Failed to save tool result message', tag: 'AI', error: e);
      }

      // Invalidate context cache after write
      _contextBuilder.invalidateCache();

      // Continue the conversation
      final settings = _companySettings;
      final catalogSummary = await _contextBuilder.buildCatalogSummary(companyId);
      final systemPrompt = _systemPromptBuilder.build(
        locale: settings?.locale ?? 'cs',
        companyName: companyId,
        userName: userName,
        currentScreen: 'ai_chat',
        userPermissions: userPermissions,
        catalogSummary: catalogSummary,
        hasActiveSession: false,
      );

      final tools = _toolRegistry.getTools(userPermissions);

      // Send the updated history for the next AI response
      final response = await _provider!.sendMessage(
        systemPrompt: systemPrompt,
        messages: history,
        tools: tools,
      );

      final loopResult = await _toolExecutionLoop.processResponse(
        provider: _provider,
        response: response,
        companyId: companyId,
        userId: userId,
        conversationId: conversation.id,
        messageId: pending.messageId,
        userPermissions: userPermissions,
        currentHistory: history,
        systemPrompt: systemPrompt,
        tools: tools,
      );

      await _handleLoopResult(loopResult, conversation);
    } catch (e, s) {
      AppLogger.error('Confirm action failed', tag: 'AI', error: e, stackTrace: s);
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Public: rejectPendingAction
  // ---------------------------------------------------------------------------

  Future<void> rejectPendingAction() async {
    final pending = state.pendingConfirmation;
    if (pending == null) return;

    final conversation = state.conversation;
    if (conversation == null) return;

    state = state.copyWith(
      isProcessing: true,
      clearPendingConfirmation: true,
    );

    try {
      // Send rejection as tool result
      final history = _pausedHistory ?? _buildHistory(state.messages);
      history.add(ToolResultMessage(
        toolCallId: pending.toolCall.id,
        content: 'User cancelled the operation.',
        isError: true,
      ));

      // Persist tool result so history stays consistent across sessions
      final toolResultMsg = AiMessageModel(
        id: _uuid.v7(),
        companyId: companyId,
        conversationId: conversation.id,
        role: AiMessageRole.tool,
        content: 'User cancelled the operation.',
        toolResults: jsonEncode({
          'tool_call_id': pending.toolCall.id,
          'is_error': true,
        }),
        status: AiMessageStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, toolResultMsg]);
      try {
        await _aiDirectService.saveMessage(toolResultMsg);
      } catch (e) {
        AppLogger.warn('Failed to save tool result message', tag: 'AI', error: e);
      }

      final settings = _companySettings;
      final catalogSummary = await _contextBuilder.buildCatalogSummary(companyId);
      final systemPrompt = _systemPromptBuilder.build(
        locale: settings?.locale ?? 'cs',
        companyName: companyId,
        userName: userName,
        currentScreen: 'ai_chat',
        userPermissions: userPermissions,
        catalogSummary: catalogSummary,
        hasActiveSession: false,
      );

      final tools = _toolRegistry.getTools(userPermissions);

      final response = await _provider!.sendMessage(
        systemPrompt: systemPrompt,
        messages: history,
        tools: tools,
      );

      final loopResult = await _toolExecutionLoop.processResponse(
        provider: _provider,
        response: response,
        companyId: companyId,
        userId: userId,
        conversationId: conversation.id,
        messageId: pending.messageId,
        userPermissions: userPermissions,
        currentHistory: history,
        systemPrompt: systemPrompt,
        tools: tools,
      );

      await _handleLoopResult(loopResult, conversation);
    } catch (e, s) {
      AppLogger.error('Reject action failed', tag: 'AI', error: e, stackTrace: s);
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Public: transcribeAudio
  // ---------------------------------------------------------------------------

  Future<String> transcribeAudio(List<int> audioBytes, String mimeType) async {
    return await _provider!.transcribe(audioBytes: audioBytes, mimeType: mimeType);
  }

  // ---------------------------------------------------------------------------
  // Public: retryLastMessage
  // ---------------------------------------------------------------------------

  Future<void> retryLastMessage() async {
    final lastUserMessage = state.messages.lastWhere(
      (m) => m.role == AiMessageRole.user,
      orElse: () => throw StateError('No user message to retry'),
    );

    // Remove all messages after (and including) the last assistant message
    final lastUserIdx = state.messages.lastIndexOf(lastUserMessage);
    state = state.copyWith(
      messages: state.messages.sublist(0, lastUserIdx),
      clearErrorMessage: true,
    );

    await sendMessage(lastUserMessage.content);
  }

  // ---------------------------------------------------------------------------
  // Public: undoMessage
  // ---------------------------------------------------------------------------

  Future<void> undoMessage(String messageId) async {
    final result = await _undoService.undoMessage(messageId);

    if (result is Success) {
      _contextBuilder.invalidateCache();
    }

    // Reload messages to reflect changes
    final conversation = state.conversation;
    if (conversation != null) {
      try {
        final messages = await _aiDirectService.fetchMessages(
          conversationId: conversation.id,
        );
        state = state.copyWith(messages: messages);
      } catch (e) {
        AppLogger.warn('Failed to reload messages after undo', tag: 'AI', error: e);
      }
    }

    if (result is Failure) {
      state = state.copyWith(errorMessage: result.message);
    }
  }

  // ---------------------------------------------------------------------------
  // Public: switchConversation
  // ---------------------------------------------------------------------------

  Future<void> switchConversation(AiConversationModel conv) async {
    _streamSubscription?.cancel();
    _pausedHistory = null;

    state = const AiChatState();

    try {
      final messages = await _aiDirectService.fetchMessages(
        conversationId: conv.id,
      );

      state = state.copyWith(
        conversation: conv,
        messages: messages,
      );
    } catch (e, s) {
      AppLogger.error('Failed to switch conversation', tag: 'AI', error: e, stackTrace: s);
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Public: newConversation
  // ---------------------------------------------------------------------------

  Future<void> newConversation() async {
    _streamSubscription?.cancel();
    _pausedHistory = null;

    state = const AiChatState();

    try {
      final conversation = await _aiDirectService.createConversation(
        id: _uuid.v7(),
        companyId: companyId,
        userId: userId,
      );

      state = state.copyWith(conversation: conversation);
    } catch (e, s) {
      AppLogger.error('Failed to create conversation', tag: 'AI', error: e, stackTrace: s);
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Private: streaming
  // ---------------------------------------------------------------------------

  Future<void> _startStreaming({
    required String systemPrompt,
    required List<AiChatMessage> history,
    required List<AiToolDefinition> tools,
    required AiConversationModel conversation,
  }) async {
    final provider = _provider;
    if (provider == null) return;

    final accumulatedToolCalls = <AiToolCall>[];
    var accumulatedText = '';
    var promptTokens = 0;
    var completionTokens = 0;

    try {
      final stream = provider.sendMessageStream(
        systemPrompt: systemPrompt,
        messages: history,
        tools: tools,
      );

      await for (final event in stream) {
        if (!mounted) return;

        switch (event) {
          case TextDelta(:final text):
            accumulatedText += text;
            state = state.copyWith(streamingText: accumulatedText);

          case ToolCallComplete(:final toolCall):
            accumulatedToolCalls.add(toolCall);

          case StreamDone(
              promptTokens: final pt,
              completionTokens: final ct,
            ):
            promptTokens = pt;
            completionTokens = ct;

          case StreamError(:final message):
            await _saveAssistantMessage(
              conversation: conversation,
              content: '',
              status: AiMessageStatus.error,
              errorMessage: message,
            );
            state = state.copyWith(
              isProcessing: false,
              streamingText: '',
              errorMessage: message,
            );
            return;

          case ToolCallStart() || ToolCallDelta():
            break;
        }
      }
    } catch (e, s) {
      AppLogger.error('Streaming failed', tag: 'AI', error: e, stackTrace: s);
      state = state.copyWith(
        isProcessing: false,
        streamingText: '',
        errorMessage: e.toString(),
      );
      return;
    }

    // Stream finished — process tool calls if any
    if (accumulatedToolCalls.isEmpty) {
      // Simple text response — save and finish
      await _saveAssistantMessage(
        conversation: conversation,
        content: accumulatedText,
        status: AiMessageStatus.completed,
        tokenCount: promptTokens + completionTokens,
      );
      state = state.copyWith(
        isProcessing: false,
        streamingText: '',
      );
      return;
    }

    // Tool calls present — create response and process through loop
    final response = AiProviderResponse(
      content: accumulatedText.isEmpty ? null : accumulatedText,
      toolCalls: accumulatedToolCalls,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      finishReason: 'tool_calls',
    );

    // Note: do NOT add AssistantMessage here — processResponse handles it.
    state = state.copyWith(streamingText: '');

    final loopResult = await _toolExecutionLoop.processResponse(
      provider: provider,
      response: response,
      companyId: companyId,
      userId: userId,
      conversationId: conversation.id,
      messageId: _uuid.v7(),
      userPermissions: userPermissions,
      currentHistory: history,
      systemPrompt: systemPrompt,
      tools: tools,
    );

    await _handleLoopResult(loopResult, conversation);
  }

  // ---------------------------------------------------------------------------
  // Private: handle loop result
  // ---------------------------------------------------------------------------

  Future<void> _handleLoopResult(
    AiToolLoopResult result,
    AiConversationModel conversation,
  ) async {
    switch (result) {
      case AiToolLoopCompleted(:final content, :final promptTokens, :final completionTokens):
        await _saveAssistantMessage(
          conversation: conversation,
          content: content,
          status: AiMessageStatus.completed,
          tokenCount: promptTokens + completionTokens,
        );
        state = state.copyWith(
          isProcessing: false,
          streamingText: '',
        );

      case AiToolLoopNeedsConfirmation(
          :final toolCall,
          :final isDestructive,
          :final description,
          :final currentHistory,
        ):
        _pausedHistory = currentHistory;
        final messageId = _uuid.v7();

        // Save the tool-calling assistant message so undo logs can
        // reference it via FK (ai_undo_logs.message_id → ai_messages.id).
        final now = DateTime.now();
        final toolCallMsg = AiMessageModel(
          id: messageId,
          companyId: companyId,
          conversationId: conversation.id,
          role: AiMessageRole.assistant,
          content: description,
          toolCalls: jsonEncode([
            {
              'id': toolCall.id,
              'name': toolCall.name,
              'arguments': toolCall.arguments,
            },
          ]),
          status: AiMessageStatus.completed,
          tokenCount: null,
          createdAt: now,
          updatedAt: now,
        );
        try {
          await _aiDirectService.saveMessage(toolCallMsg);
        } catch (e) {
          AppLogger.warn('Failed to save tool-call message', tag: 'AI', error: e);
        }

        state = state.copyWith(
          messages: [...state.messages, toolCallMsg],
          isProcessing: false,
          streamingText: '',
          pendingConfirmation: AiPendingConfirmation(
            conversationId: conversation.id,
            messageId: messageId,
            toolCall: toolCall,
            description: description,
            isDestructive: isDestructive,
            createdAt: DateTime.now(),
          ),
        );

      case AiToolLoopError(:final message):
        await _saveAssistantMessage(
          conversation: conversation,
          content: '',
          status: AiMessageStatus.error,
          errorMessage: message,
        );
        state = state.copyWith(
          isProcessing: false,
          streamingText: '',
          errorMessage: message,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Private: save assistant message
  // ---------------------------------------------------------------------------

  Future<void> _saveAssistantMessage({
    required AiConversationModel conversation,
    required String content,
    required AiMessageStatus status,
    String? errorMessage,
    int? tokenCount,
    String? toolCalls,
  }) async {
    final now = DateTime.now();
    final message = AiMessageModel(
      id: _uuid.v7(),
      companyId: companyId,
      conversationId: conversation.id,
      role: AiMessageRole.assistant,
      content: content,
      toolCalls: toolCalls,
      status: status,
      errorMessage: errorMessage,
      tokenCount: tokenCount,
      createdAt: now,
      updatedAt: now,
    );

    state = state.copyWith(
      messages: [...state.messages, message],
    );

    try {
      await _aiDirectService.saveMessage(message);
    } catch (e, s) {
      AppLogger.error('Failed to save assistant message', tag: 'AI', error: e, stackTrace: s);
    }
  }

  // ---------------------------------------------------------------------------
  // Private: history building
  // ---------------------------------------------------------------------------

  List<AiChatMessage> _buildHistory(List<AiMessageModel> messages) {
    final history = <AiChatMessage>[];

    for (final m in messages) {
      switch (m.role) {
        case AiMessageRole.user:
          history.add(UserMessage(content: m.content));

        case AiMessageRole.assistant:
          List<AiToolCall>? toolCalls;
          if (m.toolCalls != null) {
            try {
              final decoded = jsonDecode(m.toolCalls!) as List;
              toolCalls = decoded
                  .map((tc) => AiToolCall(
                        id: tc['id'] as String,
                        name: tc['name'] as String,
                        arguments:
                            Map<String, dynamic>.from(tc['arguments'] as Map),
                      ))
                  .toList();
            } catch (_) {
              // Malformed tool calls JSON — skip
            }
          }
          history.add(AssistantMessage(
            content: m.content.isEmpty ? null : m.content,
            toolCalls: toolCalls,
          ));

        case AiMessageRole.tool:
          if (m.toolResults != null) {
            try {
              final decoded = jsonDecode(m.toolResults!) as Map<String, dynamic>;
              history.add(ToolResultMessage(
                toolCallId: decoded['tool_call_id'] as String? ?? '',
                content: m.content,
                isError: decoded['is_error'] as bool? ?? false,
              ));
            } catch (_) {
              history.add(ToolResultMessage(
                toolCallId: '',
                content: m.content,
              ));
            }
          }
      }
    }

    return history;
  }
}
