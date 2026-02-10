import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';

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

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.openingCashTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l.openingCashSubtitle,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
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
            SizedBox(
              width: 250,
              child: Column(
                children: [
                  _numpadRow(['1', '2', '3']),
                  const SizedBox(height: 8),
                  _numpadRow(['4', '5', '6']),
                  const SizedBox(height: 8),
                  _numpadRow(['7', '8', '9']),
                  const SizedBox(height: 8),
                  _numpadRow(['⌫', '0', 'C']),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            SizedBox(
              width: 250,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.actionCancel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _confirm,
                        child: Text(l.openingCashConfirm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _numpadRow(List<String> keys) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          for (int i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _numpadButton(keys[i])),
          ],
        ],
      ),
    );
  }

  Widget _numpadButton(String key) {
    final Widget child;
    final VoidCallback onTap;

    switch (key) {
      case '⌫':
        child = const Icon(Icons.backspace_outlined);
        onTap = _numpadBackspace;
      case 'C':
        child = const Text('C', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
        onTap = _numpadClear;
      default:
        child = Text(key, style: const TextStyle(fontSize: 24));
        onTap = () => _numpadTap(key);
    }

    return SizedBox(
      height: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }
}
