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
  bool _replaceOnNextDigit = true;
  late final List<int> _displayQuick;

  int get _amountInMinor {
    final currency = ref.read(currentCurrencyProvider).value;
    return parseMoney(_input, currency);
  }

  @override
  void initState() {
    super.initState();
    final currency = ref.read(currentCurrencyProvider).value;
    // Compute quick amounts — round up to nearest 10, 50, 100, 500
    final originalWhole = wholeUnitsFromMinor(widget.originalAmount, currency) + 1;
    final quickAmounts = <int>[];
    for (final step in [10, 50, 100, 500]) {
      final rounded = ((originalWhole / step).ceil() * step);
      if (rounded > 0 && !quickAmounts.contains(rounded)) {
        quickAmounts.add(rounded);
      }
    }
    _displayQuick = quickAmounts.take(4).toList();
    // Pre-fill with first quick amount
    _input = _displayQuick.isNotEmpty
        ? _displayQuick.first.toString()
        : minorUnitsToInputString(widget.originalAmount, currency);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final difference = _amountInMinor - widget.originalAmount;
    final diffColor = difference > 0
        ? Colors.green
        : difference < 0
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface;

    final smallStyle = theme.textTheme.bodyMedium;
    final bigStyle = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    final diffStyle = smallStyle?.copyWith(color: diffColor, fontWeight: FontWeight.bold);

    return PosDialogShell(
      title: l.changeTotalTitle,
      titleWidget: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(ref.money(widget.originalAmount), style: smallStyle),
          Text('→', style: smallStyle),
          Text(ref.money(_amountInMinor), style: bigStyle),
          Text('(${ref.moneyWithSign(difference)})', style: diffStyle),
        ],
      ),
      maxWidth: 440,
      maxHeight: 400,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: quick buttons
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _displayQuick.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => setState(() {
                              _input = _displayQuick[i].toString();
                              _replaceOnNextDigit = true;
                            }),
                            child: Text('${_displayQuick[i]}'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: numpad
              Expanded(
                flex: 3,
                child: PosNumpad(
                  expand: true,
                  onDigit: (d) => setState(() {
                    if (_replaceOnNextDigit) {
                      _input = d;
                      _replaceOnNextDigit = false;
                    } else {
                      _input += d;
                    }
                  }),
                  onBackspace: () {
                    if (_input.isNotEmpty) {
                      setState(() {
                        _replaceOnNextDigit = false;
                        _input = _input.substring(0, _input.length - 1);
                      });
                    }
                  },
                  onClear: () => setState(() => _input = ''),
                ),
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
