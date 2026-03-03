import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';

class AiConfirmationCard extends StatelessWidget {
  const AiConfirmationCard({
    super.key,
    required this.description,
    required this.isDestructive,
    required this.onConfirm,
    required this.onCancel,
  });

  final String description;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.aiConfirmAction,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onCancel,
                  child: Text(l.actionCancel),
                ),
                const SizedBox(width: 8),
                if (isDestructive)
                  OutlinedButton(
                    style: PosButtonStyles.destructiveOutlined(context),
                    onPressed: onConfirm,
                    child: Text(l.actionDelete),
                  )
                else
                  FilledButton(
                    onPressed: onConfirm,
                    child: Text(l.aiConfirmExecute),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
