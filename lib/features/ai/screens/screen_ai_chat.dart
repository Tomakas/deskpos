import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/ai_message_role.dart';
import '../../../core/data/enums/ai_message_status.dart';
import '../../../core/data/models/ai_conversation_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../providers/ai_chat_notifier.dart';
import '../providers/ai_providers.dart';
import '../widgets/ai_confirmation_card.dart';
import '../widgets/ai_conversation_list_dialog.dart';
import '../widgets/ai_input_bar.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_streaming_indicator.dart';

class ScreenAiChat extends ConsumerStatefulWidget {
  const ScreenAiChat({super.key});

  @override
  ConsumerState<ScreenAiChat> createState() => _ScreenAiChatState();
}

class _ScreenAiChatState extends ConsumerState<ScreenAiChat> {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final chatState = ref.watch(aiChatNotifierProvider);
    final providerAsync = ref.watch(aiProviderFromSettingsProvider);
    final isProviderConfigured = providerAsync.valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.aiAssistant),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l.aiCopyConversation,
            onPressed: chatState.messages.isEmpty
                ? null
                : () => _copyConversation(chatState),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l.aiConversationHistory,
            onPressed: () => _showConversationHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l.aiNewConversation,
            onPressed: () {
              ref.read(aiChatNotifierProvider.notifier).newConversation();
            },
          ),
        ],
      ),
      body: !isProviderConfigured
          ? _buildNotConfigured(context, l)
          : Column(
              children: [
                Expanded(child: _buildMessageList(context, chatState, l)),
                AiInputBar(
                  onSend: (text) {
                    ref.read(aiChatNotifierProvider.notifier).sendMessage(text);
                  },
                  isEnabled: !chatState.isProcessing &&
                      chatState.pendingConfirmation == null,
                  onTranscribe: (bytes, mimeType) {
                    return ref
                        .read(aiChatNotifierProvider.notifier)
                        .transcribeAudio(bytes, mimeType);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildNotConfigured(BuildContext context, dynamic l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l.aiErrorNotConfigured,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    AiChatState chatState,
    dynamic l,
  ) {
    final messages = chatState.messages
        .where((m) =>
            m.role != AiMessageRole.tool &&
            // Hide assistant messages that are only tool calls (no content)
            !(m.role == AiMessageRole.assistant &&
                m.content.isEmpty &&
                m.toolCalls != null))
        .toList();

    // Build items in reverse order for reverse ListView
    final hasStreamingContent =
        chatState.isProcessing || chatState.streamingText.isNotEmpty;
    final hasPending = chatState.pendingConfirmation != null;
    final hasError = chatState.errorMessage != null && !chatState.isProcessing;

    // Count extra items at the top (index 0 in reverse)
    var extraItems = 0;
    if (hasPending) extraItems++;
    if (hasStreamingContent) extraItems++;
    if (hasError) extraItems++;

    final totalCount = messages.length + extraItems;

    if (totalCount == 0) {
      return _buildWelcomeCard(context, l);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: totalCount,
          itemBuilder: (context, index) {
            // Index 0 = most recent (bottom of chat)
            var extraIdx = 0;

            // Error message (most recent after messages)
            if (hasError) {
              if (index == extraIdx) {
                return _buildErrorMessage(context, chatState, l);
              }
              extraIdx++;
            }

            // Pending confirmation
            if (hasPending) {
              if (index == extraIdx) {
                return AiConfirmationCard(
                  description: chatState.pendingConfirmation!.description,
                  isDestructive: chatState.pendingConfirmation!.isDestructive,
                  onConfirm: () {
                    ref
                        .read(aiChatNotifierProvider.notifier)
                        .confirmPendingAction();
                  },
                  onCancel: () {
                    ref
                        .read(aiChatNotifierProvider.notifier)
                        .rejectPendingAction();
                  },
                );
              }
              extraIdx++;
            }

            // Streaming indicator
            if (hasStreamingContent) {
              if (index == extraIdx) {
                return AiStreamingIndicator(text: chatState.streamingText);
              }
              extraIdx++;
            }

            // Regular messages (reversed)
            final msgIndex = messages.length - 1 - (index - extraItems);
            if (msgIndex < 0 || msgIndex >= messages.length) {
              return const SizedBox.shrink();
            }

            final message = messages[msgIndex];
            return AiMessageBubble(
              message: message,
              onUndo: message.role == AiMessageRole.assistant &&
                      message.status == AiMessageStatus.completed
                  ? () {
                      ref
                          .read(aiChatNotifierProvider.notifier)
                          .undoMessage(message.id);
                    }
                  : null,
              onRetry: message.role == AiMessageRole.assistant &&
                      message.status == AiMessageStatus.error
                  ? () {
                      ref
                          .read(aiChatNotifierProvider.notifier)
                          .retryLastMessage();
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, dynamic l) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final capabilities = [
      l.aiWelcomeBills,
      l.aiWelcomeCatalog,
      l.aiWelcomeCustomers,
      l.aiWelcomeVouchers,
      l.aiWelcomeVenue,
      l.aiWelcomeStats,
      l.aiWelcomeStock,
      l.aiWelcomeUsers,
      l.aiWelcomePayments,
      l.aiWelcomeSettings,
    ];

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l.aiWelcomeName,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l.aiWelcomeDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: color),
                ),
                const SizedBox(height: 16),
                for (final item in capabilities)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('  •  ', style: TextStyle(color: color)),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, AiChatState chatState, dynamic l) {
    final errorKey = chatState.errorMessage;
    String errorText;

    if (errorKey == 'rate_limit') {
      errorText = l.aiErrorRateLimit;
    } else {
      errorText = l.aiErrorGeneral;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          errorText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  void _copyConversation(AiChatState chatState) {
    final buffer = StringBuffer();
    for (final m in chatState.messages) {
      if (m.role == AiMessageRole.tool) continue;
      // Skip assistant messages that are only tool calls (no user-visible content)
      if (m.role == AiMessageRole.assistant &&
          m.content.isEmpty &&
          m.toolCalls != null) {
        continue;
      }
      final prefix =
          m.role == AiMessageRole.user ? 'User' : 'Assistant';
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln('$prefix: ${m.content}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  Future<void> _showConversationHistory(BuildContext context) async {
    final selected = await showDialog<AiConversationModel>(
      context: context,
      builder: (_) => const AiConversationListDialog(),
    );

    if (selected != null && mounted) {
      ref.read(aiChatNotifierProvider.notifier).switchConversation(selected);
    }
  }
}
