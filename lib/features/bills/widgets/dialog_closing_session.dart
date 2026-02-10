import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations_ext.dart';

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

class DialogClosingSession extends StatefulWidget {
  const DialogClosingSession({super.key, required this.data});
  final ClosingSessionData data;

  @override
  State<DialogClosingSession> createState() => _DialogClosingSessionState();
}

class _DialogClosingSessionState extends State<DialogClosingSession> {
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

  String _fmtKc(int halere) => '${halere ~/ 100} Kč';

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  int? get _closingCashHalere {
    final parsed = int.tryParse(_closingCashCtrl.text);
    return parsed == null ? null : parsed * 100;
  }

  int? get _difference {
    final closing = _closingCashHalere;
    return closing == null ? null : closing - _data.expectedCash;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _confirm() {
    final closing = _closingCashHalere;
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

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(l.closingTitle, style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(height: 16),

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
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Session info
  // ---------------------------------------------------------------------------

  Widget _buildSessionInfo(dynamic l, ThemeData theme) {
    final timeFormat = DateFormat('HH:mm', 'cs');
    final dateFormat = DateFormat('d.M.yyyy', 'cs');
    final duration = DateTime.now().difference(_data.sessionOpenedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.closingSessionTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _row(
          l.closingOpenedAt,
          '${dateFormat.format(_data.sessionOpenedAt)} ${timeFormat.format(_data.sessionOpenedAt)}',
        ),
        _row(l.closingOpenedBy, _data.openedByUserName),
        _row(l.closingDuration, _fmtDuration(duration)),
        _row(l.closingBillsPaid, '${_data.billsPaid}'),
        if (_data.billsCancelled > 0)
          _row(l.closingBillsCancelled, '${_data.billsCancelled}'),
        if (_data.openBillsCount > 0)
          _row(l.closingOpenBills, '${_data.openBillsCount} (${_fmtKc(_data.openBillsAmount)})'),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Revenue breakdown
  // ---------------------------------------------------------------------------

  Widget _buildRevenue(dynamic l, ThemeData theme) {
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
          _fmtKc(_data.totalRevenue),
          bold: true,
        ),
        if (_data.totalTips > 0)
          _row(l.closingTips, _fmtKc(_data.totalTips)),
      ],
    );
  }

  Widget _revenueRow(String label, int halere, int count, ThemeData theme) {
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
              _fmtKc(halere),
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

  Widget _buildCashReconciliation(dynamic l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.closingCashTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _row(l.closingOpeningCash, _fmtKc(_data.openingCash)),
        _signedRow(l.closingCashRevenue, _data.cashRevenue, theme),
        if (_data.cashDeposits > 0)
          _signedRow(l.closingDeposits, _data.cashDeposits, theme),
        if (_data.cashWithdrawals > 0)
          _signedRow(l.closingWithdrawals, -_data.cashWithdrawals, theme),
        const Divider(height: 12),
        _row(
          l.closingExpectedCash,
          _fmtKc(_data.expectedCash),
          bold: true,
        ),
      ],
    );
  }

  Widget _signedRow(String label, int halere, ThemeData theme) {
    final prefix = halere >= 0 ? '+' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            '$prefix${halere ~/ 100} Kč',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Closing cash input + difference
  // ---------------------------------------------------------------------------

  Widget _buildClosingCashInput(dynamic l, ThemeData theme) {
    final diff = _difference;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _closingCashCtrl,
          decoration: InputDecoration(
            labelText: l.closingActualCash,
            suffixText: 'Kč',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          style: theme.textTheme.titleLarge,
        ),
        if (diff != null) ...[
          const SizedBox(height: 8),
          _row(
            l.closingDifference,
            '${diff >= 0 ? '+' : ''}${diff ~/ 100} Kč',
            bold: true,
            valueColor: diff == 0
                ? Colors.green
                : diff > 0
                    ? Colors.blue
                    : theme.colorScheme.error,
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActions(dynamic l, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton.tonal(
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
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text(l.closingPrint, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text(l.actionCancel, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: _closingCashHalere != null ? _confirm : null,
              child: Text(l.closingConfirm, style: const TextStyle(fontSize: 12)),
            ),
          ),
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
