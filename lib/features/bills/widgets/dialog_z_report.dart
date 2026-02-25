import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/data/models/currency_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/printing_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_opener.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/printing/receipt_data.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../models/z_report_data.dart';

class DialogZReport extends ConsumerWidget {
  const DialogZReport({super.key, required this.data});
  final ZReportData data;

  String _fmtTaxRate(int basisPoints, String locale) {
    return formatPercent(basisPoints / 100, locale);
  }

  ZReportLabels _buildLabels(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = ref.read(appLocaleProvider).value ?? 'cs';
    return ZReportLabels(
      reportTitle: l.zReportTitle,
      session: l.zReportSessionInfo,
      openedAt: l.zReportOpenedAt,
      closedAt: l.zReportClosedAt,
      duration: l.zReportDuration,
      openedBy: l.zReportOpenedBy,
      revenueTitle: l.zReportRevenueByPayment,
      revenueTotal: l.zReportRevenueTotal,
      taxTitle: l.zReportTaxTitle,
      taxRate: l.zReportTaxRate,
      taxNet: l.zReportTaxNet,
      taxAmount: l.zReportTaxAmount,
      taxGross: l.zReportTaxGross,
      tipsTitle: l.zReportTipsTotal,
      tipsTotal: l.zReportTipsTotal,
      tipsByUser: l.zReportTipsByUser,
      discountsTitle: l.zReportDiscounts,
      discountsTotal: l.zReportDiscounts,
      billCountsTitle: l.zReportBillsPaid,
      billsPaid: l.zReportBillsPaid,
      billsCancelled: l.zReportBillsCancelled,
      billsRefunded: l.zReportBillsRefunded,
      openBillsAtOpen: l.zReportOpenBillsAtOpen,
      openBillsAtClose: l.zReportOpenBillsAtClose,
      cashTitle: l.zReportCashTitle,
      cashOpening: l.zReportCashOpening,
      cashRevenue: l.zReportCashRevenue,
      cashDeposits: l.zReportCashDeposits,
      cashWithdrawals: l.zReportCashWithdrawals,
      cashExpected: l.zReportCashExpected,
      cashClosing: l.zReportCashClosing,
      cashDifference: l.zReportCashDifference,
      shiftsTitle: l.zReportShiftsTitle,
      currencySymbol: ref.currencySymbol,
      locale: locale,
      formatDuration: (d) => formatDuration(d,
          hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly),
      currency: ref.watch(currentCurrencyProvider).value,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    String fmtDur(Duration d) => formatDuration(d,
        hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly);

    final isVenueReport = data.registerBreakdowns.isNotEmpty;
    final title = isVenueReport ? l.zReportVenueReportTitle : l.zReportTitle;

    return PosDialogShell(
      title: title,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 520,
      scrollable: true,
      children: [
        // --- Session info ---
                Text(l.zReportSessionInfo, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (data.registerName != null)
                  _row(context, l.zReportRegisterColumn, data.registerName!),
                _row(context, l.zReportOpenedAt,
                    '${ref.fmtDate(data.openedAt)} ${ref.fmtTime(data.openedAt)}'),
                if (data.closedAt != null)
                  _row(context, l.zReportClosedAt,
                      '${ref.fmtDate(data.closedAt!)} ${ref.fmtTime(data.closedAt!)}'),
                _row(context, l.zReportDuration, fmtDur(data.duration)),
                _row(context, l.zReportOpenedBy, data.openedByName),
                const Divider(height: 24),

                // --- Revenue by payment type ---
                Text(l.zReportRevenueByPayment, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final ps in data.paymentSummaries)
                  _revenueRow(context, ref, ps.name, ps.amount, ps.count),
                const Divider(height: 12),
                _row(context, l.zReportRevenueTotal, ref.money(data.totalRevenue), bold: true),
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
                          SizedBox(width: 60, child: Text(_fmtTaxRate(row.taxRatePercent, ref.watch(appLocaleProvider).value ?? 'cs'), style: theme.textTheme.bodyMedium)),
                          Expanded(child: Text(ref.money(row.netAmount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium)),
                          Expanded(child: Text(ref.money(row.taxAmount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium)),
                          Expanded(child: Text(ref.money(row.grossAmount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                ],

                // --- Tips ---
                if (data.totalTips > 0) ...[
                  _row(context, l.zReportTipsTotal, ref.money(data.totalTips), bold: true),
                  if (data.tipsByUser.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(l.zReportTipsByUser, style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    for (final entry in data.tipsByUser.values)
                      _row(context, '  ${entry.$1}', ref.money(entry.$2)),
                  ],
                  const Divider(height: 24),
                ],

                // --- Discounts ---
                if (data.totalDiscounts > 0) ...[
                  _row(context, l.zReportDiscounts, ref.money(data.totalDiscounts)),
                  const Divider(height: 24),
                ],

                // --- Bill counts ---
                _row(context, l.zReportBillsPaid, '${data.billsPaid}'),
                if (data.billsCancelled > 0)
                  _row(context, l.zReportBillsCancelled, '${data.billsCancelled}'),
                if (data.billsRefunded > 0)
                  _row(context, l.zReportBillsRefunded, '${data.billsRefunded}'),
                if (data.openBillsAtOpenCount > 0)
                  _row(context, l.zReportOpenBillsAtOpen,
                       '${data.openBillsAtOpenCount} (${ref.money(data.openBillsAtOpenAmount)})'),
                if (data.openBillsAtCloseCount > 0)
                  _row(context, l.zReportOpenBillsAtClose,
                       '${data.openBillsAtCloseCount} (${ref.money(data.openBillsAtCloseAmount)})'),
                const Divider(height: 24),

                // --- Cash reconciliation ---
                Text(l.zReportCashTitle, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _row(context, l.zReportCashOpening, ref.money(data.openingCash)),
                _signedRow(context, ref, l.zReportCashRevenue, data.cashRevenue),
                if (data.cashDeposits > 0)
                  _signedRow(context, ref, l.zReportCashDeposits, data.cashDeposits),
                if (data.cashWithdrawals > 0)
                  _signedRow(context, ref, l.zReportCashWithdrawals, -data.cashWithdrawals),
                const Divider(height: 12),
                _row(context, l.zReportCashExpected, ref.money(data.expectedCash), bold: true),
                _row(context, l.zReportCashClosing, ref.money(data.closingCash)),
                _row(
                  context,
                  l.zReportCashDifference,
                  ref.moneyWithSign(data.difference),
                  bold: true,
                  valueColor: cashDifferenceColor(data.difference, context),
                ),


                // --- Foreign currency cash ---
                if (data.foreignCurrencyCash.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(l.zReportForeignCashTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final fc in data.foreignCurrencyCash) ...[
                    _buildForeignCashSection(context, ref, fc, l),
                    const SizedBox(height: 8),
                  ],
                ],
                const Divider(height: 24),

                // --- Per-register breakdown (venue reports) ---
                if (data.registerBreakdowns.length > 1) ...[
                  Text(l.zReportRegisterBreakdown, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final rb in data.registerBreakdowns) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.zReportRegisterName(rb.registerName),
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          for (final ps in rb.paymentSummaries)
                            _revenueRow(context, ref, ps.name, ps.amount, ps.count),
                          const Divider(height: 8),
                          _row(context, l.zReportRevenueTotal, ref.money(rb.totalRevenue), bold: true),
                          _row(context, l.zReportBillsPaid, '${rb.billsPaid}'),
                          _row(context, l.zReportCashOpening, ref.money(rb.openingCash)),
                          _row(context, l.zReportCashClosing, ref.money(rb.closingCash)),
                          _row(
                            context,
                            l.zReportCashDifference,
                            ref.moneyWithSign(rb.difference),
                            valueColor: cashDifferenceColor(rb.difference, context),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                ],

                // --- Shift durations ---
                if (data.shiftDurations.isNotEmpty) ...[
                  Text(l.zReportShiftsTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final entry in data.shiftDurations.values)
                    _row(context, entry.$1, fmtDur(entry.$2)),
                  const SizedBox(height: 16),
                ],

                // --- Actions ---
                PosDialogActions(
                  actions: [
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          final labels = _buildLabels(context, ref);
                          final bytes = await ref.read(printingServiceProvider)
                              .generateZReportPdf(data, labels);
                          final dir = await getTemporaryDirectory();
                          if (!dir.existsSync()) dir.createSync(recursive: true);
                          final file = File('${dir.path}/z_report_${data.sessionId}.pdf');
                          await file.writeAsBytes(bytes);
                          await FileOpener.share(file.path);
                        } catch (e, s) {
                          AppLogger.error('Failed to print Z-report', error: e, stackTrace: s);
                        }
                      },
                      child: Text(l.zReportPrint),
                    ),
                    FilledButton.tonal(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.zReportClose),
                    ),
                  ],
                ),
              ],
    );
  }

  Widget _buildForeignCashSection(
    BuildContext context, WidgetRef ref,
    ForeignCurrencyCashSummary fc, dynamic l,
  ) {
    final theme = Theme.of(context);
    final locale = ref.read(appLocaleProvider).value ?? 'cs';
    final cur = CurrencyModel(
      id: '', code: fc.currencyCode, symbol: fc.currencySymbol,
      name: '', decimalPlaces: fc.decimalPlaces,
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    String fmt(int amount) => formatMoney(amount, cur, appLocale: locale);
    String fmtSign(int amount) => formatMoneyWithSign(amount, cur, appLocale: locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${fc.currencyCode} (${fc.currencySymbol})',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _row(context, l.zReportForeignOpening, fmt(fc.openingCash)),
        _row(context, l.zReportForeignRevenue, fmtSign(fc.cashRevenue)),
        const Divider(height: 8),
        _row(context, l.zReportForeignExpected, fmt(fc.expectedCash), bold: true),
        _row(context, l.zReportForeignClosing, fmt(fc.closingCash)),
        _row(
          context,
          l.zReportForeignDifference,
          fmtSign(fc.difference),
          bold: true,
          valueColor: cashDifferenceColor(fc.difference, context),
        ),
      ],
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

  Widget _revenueRow(BuildContext context, WidgetRef ref, String label, int amount, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          SizedBox(
            width: 100,
            child: Text(ref.money(amount), textAlign: TextAlign.right, style: theme.textTheme.bodyMedium),
          ),
          SizedBox(
            width: 50,
            child: Text('$count×', textAlign: TextAlign.right, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _signedRow(BuildContext context, WidgetRef ref, String label, int amount) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(ref.moneyWithSign(amount), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
