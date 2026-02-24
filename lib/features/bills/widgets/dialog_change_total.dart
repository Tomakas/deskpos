import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/currency_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

class DialogChangeTotalToPay extends ConsumerStatefulWidget {
  const DialogChangeTotalToPay({
    super.key,
    required this.originalAmount,
    this.currency,
  });

  final int originalAmount;

  /// Optional foreign currency. When provided, the numpad works in this
  /// currency instead of the company default.
  final CurrencyModel? currency;

  @override
  ConsumerState<DialogChangeTotalToPay> createState() => _DialogChangeTotalToPayState();
}

class _DialogChangeTotalToPayState extends ConsumerState<DialogChangeTotalToPay> {
  String _input = '';
  bool _replaceOnNextDigit = true;
  late final List<int> _displayQuick;

  CurrencyModel? get _currency =>
      widget.currency ?? ref.read(currentCurrencyProvider).value;

  int get _amountInMinor => parseMoney(_input, _currency);

  String _fmt(int minorUnits) =>
      formatMoney(minorUnits, _currency, appLocale: ref.read(appLocaleProvider).value ?? 'cs');

  String _fmtWithSign(int minorUnits) =>
      formatMoneyWithSign(minorUnits, _currency, appLocale: ref.read(appLocaleProvider).value ?? 'cs');

  @override
  void initState() {
    super.initState();
    final currency = widget.currency ?? ref.read(currentCurrencyProvider).value;
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
          Text(_fmt(widget.originalAmount), style: smallStyle),
          Text('→', style: smallStyle),
          Text(_fmt(_amountInMinor), style: bigStyle),
          Text('(${_fmtWithSign(difference)})', style: diffStyle),
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
        PosDialogActions(
          expanded: true,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: _amountInMinor > 0
                  ? () => Navigator.pop(context, _amountInMinor)
                  : null,
              child: Text(l.actionConfirm),
            ),
          ],
        ),
      ],
    );
  }
}
