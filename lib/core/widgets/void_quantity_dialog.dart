import 'package:flutter/material.dart';

import '../data/enums/unit_type.dart';
import '../l10n/app_localizations_ext.dart';
import '../theme/app_colors.dart';
import '../utils/unit_type_l10n.dart';
import 'pos_dialog_actions.dart';
import 'pos_dialog_shell.dart';
import 'pos_numpad.dart';

/// Dialog with numpad for selecting the quantity to void.
///
/// Returns a [double] quantity, or null if cancelled.
class VoidQuantityDialog extends StatefulWidget {
  const VoidQuantityDialog({
    super.key,
    required this.itemName,
    required this.maxQuantity,
    required this.unit,
  });

  final String itemName;
  final double maxQuantity;
  final UnitType unit;

  @override
  State<VoidQuantityDialog> createState() => _VoidQuantityDialogState();
}

class _VoidQuantityDialogState extends State<VoidQuantityDialog> {
  String _amountText = '';

  void _numpadTap(String digit) {
    if (_amountText.length >= 7) return;
    setState(() => _amountText += digit);
  }

  void _numpadDot() {
    if (_amountText.contains('.')) return;
    setState(() => _amountText += _amountText.isEmpty ? '0.' : '.');
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

  double? _parsedValue() {
    final value = double.tryParse(_amountText);
    if (value == null || value <= 0 || value > widget.maxQuantity) return null;
    return value;
  }

  void _confirm() {
    final value = _parsedValue();
    if (value == null) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final unitLabel = localizedUnitType(l, widget.unit);

    return PosDialogShell(
      title: l.orderItemStorno,
      maxWidth: 340,
      maxHeight: 520,
      expandHeight: true,
      children: [
        Center(
          child: Text(
            '${widget.itemName} (max ${_fmtQty(widget.maxQuantity)} $unitLabel)',
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
            _amountText.isEmpty ? '0' : '$_amountText $unitLabel',
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
            onDot: _numpadDot,
          ),
        ),
        const SizedBox(height: 16),
      ],
      bottomActions: SizedBox(
        width: 250,
        child: PosDialogActions(
          expanded: true,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              style: PosButtonStyles.destructiveFilled(context),
              onPressed: _parsedValue() != null ? _confirm : null,
              child: Text(l.actionConfirm),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toString();
  }
}
