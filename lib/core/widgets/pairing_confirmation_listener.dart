import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/sync_providers.dart';
import '../l10n/app_localizations_ext.dart';

/// Shows a pairing confirmation overlay on the main POS register.
/// Rendered as a Stack layer above the entire Navigator — works regardless
/// of which screen or dialog is currently active.
class PairingConfirmationListener extends ConsumerWidget {
  const PairingConfirmationListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(pendingPairingRequestProvider);

    return Stack(
      children: [
        child,
        if (request != null) ...[
          const ModalBarrier(dismissible: false, color: Colors.black54),
          Center(
            child: _PairingConfirmationDialog(request: request),
          ),
        ],
      ],
    );
  }
}

class _PairingConfirmationDialog extends ConsumerWidget {
  const _PairingConfirmationDialog({required this.request});
  final PairingRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isCustomerDisplay = request.deviceType == 'customerDisplay';

    return Card(
      elevation: 24,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.pairingRequestTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(l.pairingRequestMessage),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(isCustomerDisplay ? Icons.tv : Icons.restaurant_menu),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.deviceName.isEmpty
                          ? request.code
                          : request.deviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${l.pairingRequestCode}: ${request.code}',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _respond(ref, false),
                    child: Text(l.pairingReject),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _respond(ref, true),
                    child: Text(l.pairingConfirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _respond(WidgetRef ref, bool confirmed) async {
    final channel = ref.read(pairingChannelProvider);
    if (confirmed) {
      await channel.send({
        'action': 'pairing_confirmed',
        'code': request.code,
        'request_id': request.requestId,
      });
    } else {
      await channel.send({
        'action': 'pairing_rejected',
        'code': request.code,
        'request_id': request.requestId,
      });
    }
    ref.read(pendingPairingRequestProvider.notifier).state = null;
  }
}
