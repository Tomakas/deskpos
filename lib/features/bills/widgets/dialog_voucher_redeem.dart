import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

class DialogVoucherRedeem extends StatefulWidget {
  const DialogVoucherRedeem({super.key});

  @override
  State<DialogVoucherRedeem> createState() => _DialogVoucherRedeemState();
}

class _DialogVoucherRedeemState extends State<DialogVoucherRedeem> {
  String _digits = '';

  /// Formatted display: auto-insert dash after 4th digit.
  String get _displayCode {
    if (_digits.length <= 4) return _digits;
    return '${_digits.substring(0, 4)}-${_digits.substring(4)}';
  }

  /// Code is complete when exactly 8 digits entered (XXXX-XXXX).
  bool get _isComplete => _digits.length == 8;

  void _onDigit(String d) {
    if (_digits.length < 8) {
      setState(() => _digits += d);
    }
  }

  void _onBackspace() {
    if (_digits.isNotEmpty) {
      setState(() => _digits = _digits.substring(0, _digits.length - 1));
    }
  }

  Widget _digitBox(ThemeData theme, int index) {
    final filled = index < _digits.length;
    final active = index == _digits.length;
    return Container(
      width: 30,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: active
              ? theme.colorScheme.primary
              : theme.dividerColor,
          width: active ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              _digits[index],
              style: theme.textTheme.titleLarge,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.billDetailVoucher,
      maxWidth: 340,
      maxHeight: 460,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      bottomActions: PosDialogActions(
        expanded: true,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: _isComplete
                ? () => Navigator.pop(context, _displayCode)
                : null,
            child: Text(l.voucherRedeem),
          ),
        ],
      ),
      children: [
        // Code boxes: ☐☐☐☐ - ☐☐☐☐
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 8; i++) ...[
              if (i == 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('-', style: theme.textTheme.headlineMedium),
                ),
              _digitBox(theme, i),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Numpad
        Expanded(
          child: PosNumpad(
            size: PosNumpadSize.compact,
            expand: true,
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onClear: () => setState(() => _digits = ''),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
