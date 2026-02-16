import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

class DialogChangeTotalToPay extends ConsumerStatefulWidget {
  const DialogChangeTotalToPay({
    super.key,
    required this.originalAmount,
  });

  final int originalAmount;

  @override
  ConsumerState<DialogChangeTotalToPay> createState() => _DialogChangeTotalToPayState();
}

class _DialogChangeTotalToPayState extends ConsumerState<DialogChangeTotalToPay> {
  String _input = '';

  int get _amountInMinor {
    final currency = ref.read(currentCurrencyProvider).value;
    return parseMoney(_input, currency);
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill with original amount
    final currency = ref.read(currentCurrencyProvider).value;
    _input = minorUnitsToInputString(widget.originalAmount, currency);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    // Quick buttons — round amounts around the original
    final currency = ref.watch(currentCurrencyProvider).value;
    final originalWhole = wholeUnitsFromMinor(widget.originalAmount, currency) + 1;
    final quickAmounts = <int>[];
    // Round up to nearest 10, 50, 100, 500
    for (final step in [10, 50, 100, 500]) {
      final rounded = ((originalWhole / step).ceil() * step);
      if (rounded > 0 && !quickAmounts.contains(rounded)) {
        quickAmounts.add(rounded);
      }
    }
    // Keep max 4 unique values
    final displayQuick = quickAmounts.take(4).toList();

    return PosDialogShell(
      title: l.changeTotalTitle,
      maxWidth: 480,
      maxHeight: 460,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: quick buttons
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    for (final amount in displayQuick) ...[
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _input = amount.toString()),
                            child: Text('$amount'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Center: display
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l.changeTotalOriginal}: ${ref.money(widget.originalAmount)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l.changeTotalEdited}:',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _input.isEmpty ? '0' : _input,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: numpad
              PosNumpad(
                width: 180,
                expand: true,
                onDigit: (d) => setState(() => _input += d),
                onBackspace: () {
                  if (_input.isNotEmpty) {
                    setState(() => _input = _input.substring(0, _input.length - 1));
                  }
                },
                onClear: () => setState(() => _input = ''),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Bottom actions
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.actionCancel),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: _amountInMinor > 0
                      ? () => Navigator.pop(context, _amountInMinor)
                      : null,
                  child: Text(l.actionConfirm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
