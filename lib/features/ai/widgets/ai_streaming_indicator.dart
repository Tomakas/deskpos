import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';

class AiStreamingIndicator extends StatefulWidget {
  const AiStreamingIndicator({super.key, required this.text});

  final String text;

  @override
  State<AiStreamingIndicator> createState() => _AiStreamingIndicatorState();
}

class _AiStreamingIndicatorState extends State<AiStreamingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.text.isEmpty
              ? _buildTypingIndicator(theme)
              : _buildStreamingText(theme),
        ),
      ),
    );
  }

  Widget _buildStreamingText(ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Text.rich(
          TextSpan(
            text: widget.text,
            children: [
              TextSpan(
                text: '\u258c',
                style: TextStyle(
                  color: theme.colorScheme.primary
                      .withValues(alpha: _controller.value),
                ),
              ),
            ],
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
        );
      },
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.aiThinking,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 4),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final dots = '.' * (1 + (_controller.value * 2).floor());
            return SizedBox(
              width: 20,
              child: Text(
                dots,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
