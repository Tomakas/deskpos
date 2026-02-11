import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

/// Simple dialog shown only on the very first register session opening
/// (when no cash movement history exists). Returns the initial cash amount
/// in haléře, or `null` if cancelled.
class DialogOpeningCash extends StatefulWidget {
  const DialogOpeningCash({super.key, this.initialAmount});

  /// Pre-fill amount from previous session's closing cash (in haléře).
  final int? initialAmount;

  @override
  State<DialogOpeningCash> createState() => _DialogOpeningCashState();
}

class _DialogOpeningCashState extends State<DialogOpeningCash> {
  String _amountText = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountText = (widget.initialAmount! ~/ 100).toString();
    }
  }

  int get _amountKc => int.tryParse(_amountText) ?? 0;

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
    Navigator.pop(context, _amountKc * 100);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.openingCashTitle,
      maxWidth: 340,
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
            '$_amountKc Kč',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Numpad
        PosNumpad(
          width: 250,
          onDigit: _numpadTap,
          onBackspace: _numpadBackspace,
          onClear: _numpadClear,
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
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
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
