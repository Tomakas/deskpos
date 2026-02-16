import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class ClosingSessionData {
  const ClosingSessionData({
    required this.sessionOpenedAt,
    required this.openedByUserName,
    required this.openingCash,
    required this.expectedCash,
    required this.paymentSummaries,
    required this.totalRevenue,
    required this.totalTips,
    required this.billsPaid,
    required this.billsCancelled,
    required this.cashDeposits,
    required this.cashWithdrawals,
    required this.openBillsCount,
    required this.openBillsAmount,
  });

  final DateTime sessionOpenedAt;
  final String openedByUserName;

  /// In haléře.
  final int openingCash;

  /// opening + cashRevenue + deposits - withdrawals, in haléře.
  final int expectedCash;

  final List<PaymentTypeSummary> paymentSummaries;

  /// Sum of all payment types, in haléře.
  final int totalRevenue;

  /// Total tips across all payments, in haléře.
  final int totalTips;

  final int billsPaid;
  final int billsCancelled;

  /// Total cash deposited during session, in haléře.
  final int cashDeposits;

  /// Total cash withdrawn during session, in haléře.
  final int cashWithdrawals;

  /// Open bills count and total amount at close time.
  final int openBillsCount;
  final int openBillsAmount;

  /// Cash revenue only (sum of payments where method type == cash), in haléře.
  int get cashRevenue {
    return paymentSummaries
        .where((s) => s.isCash)
        .fold(0, (sum, s) => sum + s.amount);
  }
}

class PaymentTypeSummary {
  const PaymentTypeSummary({
    required this.name,
    required this.amount,
    required this.count,
    this.isCash = false,
  });

  final String name;

  /// In haléře.
  final int amount;
  final int count;

  /// Whether this is a cash payment type (used for cash reconciliation).
  final bool isCash;
}

class ClosingSessionResult {
  const ClosingSessionResult({
    required this.closingCash,
    this.note,
  });

  /// Actual cash counted by the cashier, in haléře.
  final int closingCash;
  final String? note;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class DialogClosingSession extends ConsumerStatefulWidget {
  const DialogClosingSession({super.key, required this.data});
  final ClosingSessionData data;

  @override
  ConsumerState<DialogClosingSession> createState() => _DialogClosingSessionState();
}

class _DialogClosingSessionState extends ConsumerState<DialogClosingSession> {
  late final TextEditingController _closingCashCtrl;
  String? _note;

  ClosingSessionData get _data => widget.data;

  @override
  void initState() {
    super.initState();
    _closingCashCtrl = TextEditingController();
    _closingCashCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _closingCashCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  int? get _closingCashMinor {
    final parsed = int.tryParse(_closingCashCtrl.text);
    return parsed == null ? null : parsed * 100;
  }

  int? get _difference {
    final closing = _closingCashMinor;
    return closing == null ? null : closing - _data.expectedCash;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _confirm() {
    final closing = _closingCashMinor;
    if (closing == null) return;
    Navigator.pop(
      context,
      ClosingSessionResult(closingCash: closing, note: _note),
    );
  }

  Future<void> _showNoteDialog() async {
    final l = context.l10n;
    final ctrl = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.closingNoteTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: l.closingNoteHint,
          ),
          maxLines: 3,
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

    return PosDialogShell(
      title: l.closingTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 500,
      scrollable: true,
      children: [
        // --- Session info ---
                _buildSessionInfo(l, theme),
                const Divider(height: 24),

                // --- Revenue by payment type ---
                _buildRevenue(l, theme),
                const Divider(height: 24),

                // --- Cash reconciliation ---
                _buildCashReconciliation(l, theme),
                const SizedBox(height: 16),

                // --- Closing cash input ---
                _buildClosingCashInput(l, theme),
                const SizedBox(height: 20),

                // --- Actions ---
                _buildActions(l, theme),
              ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Session info
  // ---------------------------------------------------------------------------

  Widget _buildSessionInfo(AppLocalizations l, ThemeData theme) {
    final duration = DateTime.now().difference(_data.sessionOpenedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.closingSessionTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _row(
          l.closingOpenedAt,
          '${ref.fmtDate(_data.sessionOpenedAt)} ${ref.fmtTime(_data.sessionOpenedAt)}',
        ),
        _row(l.closingOpenedBy, _data.openedByUserName),
        _row(l.closingDuration, _fmtDuration(duration)),
        _row(l.closingBillsPaid, '${_data.billsPaid}'),
        if (_data.billsCancelled > 0)
          _row(l.closingBillsCancelled, '${_data.billsCancelled}'),
        if (_data.openBillsCount > 0)
          _row(l.closingOpenBills, '${_data.openBillsCount} (${ref.money(_data.openBillsAmount)})'),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Revenue breakdown
  // ---------------------------------------------------------------------------

  Widget _buildRevenue(AppLocalizations l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.closingRevenueTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final ps in _data.paymentSummaries)
          _revenueRow(ps.name, ps.amount, ps.count, theme),
        const Divider(height: 12),
        _row(
          l.closingRevenueTotal,
          ref.money(_data.totalRevenue),
          bold: true,
        ),
        if (_data.totalTips > 0)
          _row(l.closingTips, ref.money(_data.totalTips)),
      ],
    );
  }

  Widget _revenueRow(String label, int amount, int count, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          SizedBox(
            width: 100,
            child: Text(
              ref.money(amount),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '$count×',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Cash reconciliation
  // ---------------------------------------------------------------------------

  Widget _buildCashReconciliation(AppLocalizations l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.closingCashTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _row(l.closingOpeningCash, ref.money(_data.openingCash)),
        _signedRow(l.closingCashRevenue, _data.cashRevenue, theme),
        if (_data.cashDeposits > 0)
          _signedRow(l.closingDeposits, _data.cashDeposits, theme),
        if (_data.cashWithdrawals > 0)
          _signedRow(l.closingWithdrawals, -_data.cashWithdrawals, theme),
        const Divider(height: 12),
        _row(
          l.closingExpectedCash,
          ref.money(_data.expectedCash),
          bold: true,
        ),
      ],
    );
  }

  Widget _signedRow(String label, int amount, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            ref.moneyWithSign(amount),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Closing cash input + difference
  // ---------------------------------------------------------------------------

  Widget _buildClosingCashInput(AppLocalizations l, ThemeData theme) {
    final diff = _difference;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _closingCashCtrl,
          decoration: InputDecoration(
            labelText: l.closingActualCash,
            suffixText: ref.currencySymbol,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          style: theme.textTheme.titleLarge,
        ),
        if (diff != null) ...[
          const SizedBox(height: 8),
          _row(
            l.closingDifference,
            ref.moneyWithSign(diff),
            bold: true,
            valueColor: cashDifferenceColor(diff, context),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActions(AppLocalizations l, ThemeData theme) {
    return PosDialogActions(
      height: 40,
      spacing: 6,
      actions: [
        FilledButton.tonal(
          onPressed: _showNoteDialog,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.cashMovementNote, style: const TextStyle(fontSize: 12)),
              if (_note != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
              ],
            ],
          ),
        ),
        OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: Text(l.closingPrint, style: const TextStyle(fontSize: 12)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: Text(l.actionCancel, style: const TextStyle(fontSize: 12)),
        ),
        FilledButton(
          style: PosButtonStyles.confirmWith(context, padding: const EdgeInsets.symmetric(horizontal: 8)),
          onPressed: _closingCashMinor != null ? _confirm : null,
          child: Text(l.closingConfirm, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Generic row helper
  // ---------------------------------------------------------------------------

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold
                  ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                  : theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: (bold
                    ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                    : theme.textTheme.bodyMedium)
                ?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
