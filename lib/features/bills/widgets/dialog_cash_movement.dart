import 'package:flutter/material.dart';

import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class CashMovementResult {
  const CashMovementResult({
    required this.type,
    required this.amount,
    this.reason,
  });

  /// [deposit] or [withdrawal].
  final CashMovementType type;

  /// Amount in haléře (cents). Always positive.
  final int amount;

  /// Optional note / reason for the movement.
  final String? reason;
}

class DialogCashMovement extends StatefulWidget {
  const DialogCashMovement({super.key});

  @override
  State<DialogCashMovement> createState() => _DialogCashMovementState();
}

class _DialogCashMovementState extends State<DialogCashMovement> {
  String _amountText = '';
  String? _note;

  int get _amountKc => int.tryParse(_amountText) ?? 0;
  bool get _hasAmount => _amountKc > 0;

  // ---------------------------------------------------------------------------
  // Numpad input
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _confirm(CashMovementType type) {
    if (!_hasAmount) return;
    Navigator.pop(
      context,
      CashMovementResult(
        type: type,
        amount: _amountKc * 100,
        reason: _note,
      ),
    );
  }

  Future<void> _showNoteDialog() async {
    final l = context.l10n;
    final ctrl = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.cashMovementNoteTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: l.cashMovementNoteHint,
          ),
          maxLines: 2,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && mounted) {
      setState(() => _note = result.isEmpty ? null : result);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(l.cashMovementTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              // Amount display
              _buildAmountDisplay(theme, l),
              const SizedBox(height: 16),
              // Numpad + action buttons
              _buildNumpadAndActions(theme, l),
              const SizedBox(height: 16),
              // Bottom: Cancel + Note
              _buildBottomButtons(l, theme),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Amount display
  // ---------------------------------------------------------------------------

  Widget _buildAmountDisplay(ThemeData theme, dynamic l) {
    return Row(
      children: [
        Text(l.cashMovementAmount, style: theme.textTheme.titleMedium),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
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
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Numpad + VKLAD / VÝBĚR
  // ---------------------------------------------------------------------------

  Widget _buildNumpadAndActions(ThemeData theme, dynamic l) {
    const rowHeight = 56.0;
    const gap = 8.0;
    const totalHeight = rowHeight * 4 + gap * 3; // 248
    const actionHeight = (totalHeight - gap) / 2; // 120

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numpad 3×4
          SizedBox(
            width: 250,
            child: Column(
              children: [
                _numpadRow(['1', '2', '3'], rowHeight),
                const SizedBox(height: gap),
                _numpadRow(['4', '5', '6'], rowHeight),
                const SizedBox(height: gap),
                _numpadRow(['7', '8', '9'], rowHeight),
                const SizedBox(height: gap),
                _numpadRow(['⌫', '0', 'C'], rowHeight),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // VKLAD / VÝBĚR
          SizedBox(
            width: 110,
            child: Column(
              children: [
                SizedBox(
                  height: actionHeight,
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        _hasAmount ? () => _confirm(CashMovementType.deposit) : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l.cashMovementDeposit,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.add_circle_outline, size: 32),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: gap),
                SizedBox(
                  height: actionHeight,
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        _hasAmount ? () => _confirm(CashMovementType.withdrawal) : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l.cashMovementWithdrawal,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.remove_circle_outline, size: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Numpad helpers
  // ---------------------------------------------------------------------------

  Widget _numpadRow(List<String> keys, double height) {
    return SizedBox(
      height: height,
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

  // ---------------------------------------------------------------------------
  // Bottom buttons
  // ---------------------------------------------------------------------------

  Widget _buildBottomButtons(dynamic l, ThemeData theme) {
    return Row(
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
            child: FilledButton.tonal(
              onPressed: _showNoteDialog,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.cashMovementNote),
                  if (_note != null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
