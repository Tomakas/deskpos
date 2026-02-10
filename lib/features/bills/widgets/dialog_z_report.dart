import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../models/z_report_data.dart';

class DialogZReport extends StatelessWidget {
  const DialogZReport({super.key, required this.data});
  final ZReportData data;

  String _fmtKc(int halere) => '${halere ~/ 100} Kč';

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  String _fmtTaxRate(int basisPoints) {
    final pct = basisPoints / 100;
    return pct == pct.roundToDouble() ? '${pct.round()}%' : '${pct.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d.M.yyyy', 'cs');
    final timeFormat = DateFormat('HH:mm', 'cs');

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text(l.zReportTitle, style: theme.textTheme.headlineSmall)),
                const SizedBox(height: 16),

                // --- Session info ---
                Text(l.zReportSessionInfo, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _row(context, l.zReportOpenedAt,
                    '${dateFormat.format(data.openedAt)} ${timeFormat.format(data.openedAt)}'),
                if (data.closedAt != null)
                  _row(context, l.zReportClosedAt,
                      '${dateFormat.format(data.closedAt!)} ${timeFormat.format(data.closedAt!)}'),
                _row(context, l.zReportDuration, _fmtDuration(data.duration)),
                _row(context, l.zReportOpenedBy, data.openedByName),
                const Divider(height: 24),

                // --- Revenue by payment type ---
                Text(l.zReportRevenueByPayment, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final ps in data.paymentSummaries)
                  _revenueRow(context, ps.name, ps.amount, ps.count),
                const Divider(height: 12),
                _row(context, l.zReportRevenueTotal, _fmtKc(data.totalRevenue), bold: true),
                const Divider(height: 24),

                // --- DPH breakdown ---
                if (data.taxBreakdown.isNotEmpty) ...[
                  Text(l.zReportTaxTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(width: 60, child: Text(l.zReportTaxRate, style: theme.textTheme.labelSmall)),
                        Expanded(child: Text(l.zReportTaxNet, textAlign: TextAlign.right, style: theme.textTheme.labelSmall)),
                        Expanded(child: Text(l.zReportTaxAmount, textAlign: TextAlign.right, style: theme.textTheme.labelSmall)),
                        Expanded(child: Text(l.zReportTaxGross, textAlign: TextAlign.right, style: theme.textTheme.labelSmall)),
                      ],
                    ),
                  ),
                  for (final row in data.taxBreakdown)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(width: 60, child: Text(_fmtTaxRate(row.taxRatePercent), style: theme.textTheme.bodyMedium)),
                          Expanded(child: Text(_fmtKc(row.netAmount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium)),
                          Expanded(child: Text(_fmtKc(row.taxAmount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium)),
                          Expanded(child: Text(_fmtKc(row.grossAmount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                ],

                // --- Tips ---
                if (data.totalTips > 0) ...[
                  _row(context, l.zReportTipsTotal, _fmtKc(data.totalTips), bold: true),
                  if (data.tipsByUser.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(l.zReportTipsByUser, style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    for (final entry in data.tipsByUser.values)
                      _row(context, '  ${entry.$1}', _fmtKc(entry.$2)),
                  ],
                  const Divider(height: 24),
                ],

                // --- Discounts ---
                if (data.totalDiscounts > 0) ...[
                  _row(context, l.zReportDiscounts, _fmtKc(data.totalDiscounts)),
                  const Divider(height: 24),
                ],

                // --- Bill counts ---
                _row(context, l.zReportBillsPaid, '${data.billsPaid}'),
                if (data.billsCancelled > 0)
                  _row(context, l.zReportBillsCancelled, '${data.billsCancelled}'),
                if (data.billsRefunded > 0)
                  _row(context, l.zReportBillsRefunded, '${data.billsRefunded}'),
                const Divider(height: 24),

                // --- Cash reconciliation ---
                Text(l.zReportCashTitle, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _row(context, l.zReportCashOpening, _fmtKc(data.openingCash)),
                _signedRow(context, l.zReportCashRevenue, data.cashRevenue),
                if (data.cashDeposits > 0)
                  _signedRow(context, l.zReportCashDeposits, data.cashDeposits),
                if (data.cashWithdrawals > 0)
                  _signedRow(context, l.zReportCashWithdrawals, -data.cashWithdrawals),
                const Divider(height: 12),
                _row(context, l.zReportCashExpected, _fmtKc(data.expectedCash), bold: true),
                _row(context, l.zReportCashClosing, _fmtKc(data.closingCash)),
                _row(
                  context,
                  l.zReportCashDifference,
                  '${data.difference >= 0 ? '+' : ''}${data.difference ~/ 100} Kč',
                  bold: true,
                  valueColor: data.difference == 0
                      ? Colors.green
                      : data.difference > 0
                          ? Colors.blue
                          : Theme.of(context).colorScheme.error,
                ),
                const Divider(height: 24),

                // --- Shift durations ---
                if (data.shiftDurations.isNotEmpty) ...[
                  Text(l.zReportShiftsTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final entry in data.shiftDurations.values)
                    _row(context, entry.$1, _fmtDuration(entry.$2)),
                  const SizedBox(height: 16),
                ],

                // --- Actions ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: null,
                      child: Text(l.zReportPrint),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.zReportClose),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool bold = false, Color? valueColor}) {
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

  Widget _revenueRow(BuildContext context, String label, int halere, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          SizedBox(
            width: 100,
            child: Text(_fmtKc(halere), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium),
          ),
          SizedBox(
            width: 50,
            child: Text('$count×', textAlign: TextAlign.right, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _signedRow(BuildContext context, String label, int halere) {
    final theme = Theme.of(context);
    final prefix = halere >= 0 ? '+' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text('$prefix${halere ~/ 100} Kč', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
