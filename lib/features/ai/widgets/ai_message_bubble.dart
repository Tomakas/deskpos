import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/data/enums/ai_message_role.dart';
import '../../../core/data/enums/ai_message_status.dart';
import '../../../core/data/models/ai_message_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({
    super.key,
    required this.message,
    this.onUndo,
    this.onRetry,
  });

  final AiMessageModel message;
  final VoidCallback? onUndo;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Tool messages are not rendered
    if (message.role == AiMessageRole.tool) {
      return const SizedBox.shrink();
    }

    final isUser = message.role == AiMessageRole.user;
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.content.isNotEmpty)
                isUser
                    ? SelectableText(
                        message.content,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : MarkdownBody(
                        data: message.content,
                        selectable: true,
                        shrinkWrap: true,
                        styleSheet: _markdownStyle(theme),
                      ),
              if (message.status == AiMessageStatus.error &&
                  message.errorMessage != null) ...[
                const SizedBox(height: 4),
                Text(
                  message.errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              if (!isUser && (onUndo != null || onRetry != null))
                _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(ThemeData theme) {
    final color = theme.colorScheme.onSurface;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(color: color);
    return MarkdownStyleSheet(
      p: textStyle,
      strong: textStyle?.copyWith(fontWeight: FontWeight.bold),
      em: textStyle?.copyWith(fontStyle: FontStyle.italic),
      h1: theme.textTheme.titleLarge?.copyWith(color: color),
      h2: theme.textTheme.titleMedium?.copyWith(color: color),
      h3: theme.textTheme.titleSmall?.copyWith(color: color),
      tableHead: textStyle?.copyWith(fontWeight: FontWeight.bold),
      tableBody: textStyle,
      tableBorder: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        width: 0.5,
      ),
      tableCellsPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      code: theme.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        color: color,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      listBullet: textStyle,
    );
  }

  Widget _buildActions(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null && message.status == AiMessageStatus.error)
            _ActionChip(
              icon: Icons.refresh,
              label: l.aiRetry,
              onPressed: onRetry!,
            ),
          if (onUndo != null) ...[
            if (onRetry != null && message.status == AiMessageStatus.error)
              const SizedBox(width: 8),
            _ActionChip(
              icon: Icons.undo,
              label: l.aiUndoAction,
              onPressed: onUndo!,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
