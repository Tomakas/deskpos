import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

/// Simple dialog shown only on the very first register session opening
/// (when no cash movement history exists). Returns the initial cash amount
/// in haléře, or `null` if cancelled.
class DialogOpeningCash extends ConsumerStatefulWidget {
  const DialogOpeningCash({super.key, this.initialAmount});

  /// Pre-fill amount from previous session's closing cash (in haléře).
  final int? initialAmount;

  @override
  ConsumerState<DialogOpeningCash> createState() => _DialogOpeningCashState();
}

class _DialogOpeningCashState extends ConsumerState<DialogOpeningCash> {
  String _amountText = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      final currency = ref.read(currentCurrencyProvider).value;
      _amountText = wholeUnitsFromMinor(widget.initialAmount!, currency).toString();
    }
  }

  void _numpadTap(String digit) {
    if (_amountText.length >= 7) return;
    setState(() => _amountText += digit);
  }

  void _numpadBackspace() {
    if (_amountText.isEmpty) return;
    setState(() {
      _amountText = _amountText.substring(0, _amountText.length - 1);
    });
  }

  void _numpadClear() {
    setState(() => _amountText = '');
  }

  void _confirm() {
    final currency = ref.read(currentCurrencyProvider).value;
    Navigator.pop(context, parseMoney(_amountText, currency));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.openingCashTitle,
      maxWidth: 340,
      maxHeight: 520,
      expandHeight: true,
      children: [
        Center(
          child: Text(
            l.openingCashSubtitle,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        // Amount display
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            ref.money(parseMoney(_amountText, ref.watch(currentCurrencyProvider).value)),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Numpad
        Expanded(
          child: PosNumpad(
            width: 250,
            expand: true,
            onDigit: _numpadTap,
            onBackspace: _numpadBackspace,
            onClear: _numpadClear,
          ),
        ),
        const SizedBox(height: 16),
        // Actions
        SizedBox(
          width: 250,
          child: PosDialogActions(
            height: 48,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                style: PosButtonStyles.confirm(context),
                onPressed: _confirm,
                child: Text(l.openingCashConfirm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
