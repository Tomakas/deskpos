import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_dialog_theme.dart';
import '../../../core/widgets/pos_numpad.dart';

class CashMovementResult {
  const CashMovementResult({
    required this.type,
    required this.amount,
    this.reason,
  });

  /// [deposit] or [withdrawal].
  final CashMovementType type;

  /// Amount in minor units (cents). Always positive.
  final int amount;

  /// Optional note / reason for the movement.
  final String? reason;
}

class DialogCashMovement extends ConsumerStatefulWidget {
  const DialogCashMovement({super.key});

  @override
  ConsumerState<DialogCashMovement> createState() => _DialogCashMovementState();
}

class _DialogCashMovementState extends ConsumerState<DialogCashMovement> {
  String _amountText = '';
  String? _note;

  int get _amountWhole => int.tryParse(_amountText) ?? 0;
  bool get _hasAmount => _amountWhole > 0;

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
    final currency = ref.read(currentCurrencyProvider).value;
    Navigator.pop(
      context,
      CashMovementResult(
        type: type,
        amount: parseMoney(_amountText, currency),
        reason: _note,
      ),
    );
  }

  Future<void> _showNoteDialog() async {
    final l = context.l10n;
    final ctrl = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => PosDialogShell(
        title: l.cashMovementNoteTitle,
        maxWidth: 400,
        scrollable: true,
        children: [
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l.cashMovementNoteHint,
            ),
            maxLines: 2,
            autofocus: true,
          ),
          const SizedBox(height: 16),
        ],
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, ctrl.text),
              child: Text(l.actionSave),
            ),
          ],
        ),
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

    return PosDialogShell(
      title: l.cashMovementTitle,
      maxWidth: 420,
      maxHeight: 520,
      expandHeight: true,
      children: [
        // Amount display
        _buildAmountDisplay(theme, l),
        const SizedBox(height: 16),
        // Numpad + action buttons
        _buildNumpadAndActions(theme, l),
        const SizedBox(height: 16),
      ],
      bottomActions: PosDialogActions(
        expanded: true,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          FilledButton.tonal(
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Amount display
  // ---------------------------------------------------------------------------

  Widget _buildAmountDisplay(ThemeData theme, AppLocalizations l) {
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
              ref.money(parseMoney(_amountText, ref.watch(currentCurrencyProvider).value)),
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

  Widget _buildNumpadAndActions(ThemeData theme, AppLocalizations l) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Numpad 3×4
          Expanded(
            flex: 5,
            child: PosNumpad(
              expand: true,
              onDigit: _numpadTap,
              onBackspace: _numpadBackspace,
              onClear: _numpadClear,
            ),
          ),
          const SizedBox(width: 12),
          // VKLAD / VÝBĚR
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: PosButtonStyles.confirmWith(
                        context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PosDialogTheme.numpadLargeRadius),
                        ),
                      ),
                      onPressed:
                          _hasAmount ? () => _confirm(CashMovementType.deposit) : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l.cashMovementDeposit,
                            style: const TextStyle(fontSize: PosDialogTheme.actionFontSize),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.add_circle_outline, size: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: PosDialogTheme.numpadLargeGap),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PosDialogTheme.numpadLargeRadius),
                        ),
                      ),
                      onPressed:
                          _hasAmount ? () => _confirm(CashMovementType.withdrawal) : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l.cashMovementWithdrawal,
                            style: const TextStyle(fontSize: PosDialogTheme.actionFontSize),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.remove_circle_outline, size: 32),
                        ],
                      ),
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
}
