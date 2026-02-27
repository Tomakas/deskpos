import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/currency_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// Foreign currency cash data for closing reconciliation.
class ForeignCurrencyCashData {
  const ForeignCurrencyCashData({
    required this.currencyId,
    required this.code,
    required this.symbol,
    required this.decimalPlaces,
    required this.openingCash,
    required this.expectedCash,
    required this.cashRevenue,
    this.cashDeposits = 0,
    this.cashWithdrawals = 0,
  });

  final String currencyId;
  final String code;
  final String symbol;
  final int decimalPlaces;
  final int openingCash;
  final int expectedCash; // opening + cashRevenue + deposits - withdrawals
  final int cashRevenue;
  final int cashDeposits;
  final int cashWithdrawals;

  CurrencyModel toCurrencyModel() => CurrencyModel(
    id: currencyId, code: code, symbol: symbol,
    name: '', decimalPlaces: decimalPlaces,
    createdAt: DateTime.now(), updatedAt: DateTime.now(),
  );
}

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
    this.foreignCurrencyCash = const [],
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

  /// Foreign currency cash reconciliation data.
  final List<ForeignCurrencyCashData> foreignCurrencyCash;

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
    this.foreignClosingCash = const {},
    this.printReport = false,
  });

  /// Actual cash counted by the cashier, in haléře.
  final int closingCash;
  final String? note;

  /// Foreign currency closing cash: currencyId → amount in minor units.
  final Map<String, int> foreignClosingCash;

  /// Whether to print the Z-report after closing.
  final bool printReport;
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
  final Map<String, TextEditingController> _foreignClosingCtrls = {};
  String? _note;
  bool _printReport = false;

  ClosingSessionData get _data => widget.data;

  @override
  void initState() {
    super.initState();
    final baseCurrency = ref.read(currentCurrencyProvider).value;
    _closingCashCtrl = TextEditingController(
      text: '${wholeUnitsFromMinor(_data.expectedCash, baseCurrency)}',
    );
    _closingCashCtrl.addListener(() => setState(() {}));
    for (final fc in _data.foreignCurrencyCash) {
      final ctrl = TextEditingController(
        text: '${wholeUnitsFromMinor(fc.expectedCash, fc.toCurrencyModel())}',
      );
      ctrl.addListener(() => setState(() {}));
      _foreignClosingCtrls[fc.currencyId] = ctrl;
    }
  }

  @override
  void dispose() {
    _closingCashCtrl.dispose();
    for (final ctrl in _foreignClosingCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int? get _closingCashMinor {
    final text = _closingCashCtrl.text.trim();
    if (text.isEmpty || parseInputDouble(text) == null) return null;
    return parseMoney(text, ref.read(currentCurrencyProvider).value);
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

    final foreignClosing = <String, int>{};
    for (final fc in _data.foreignCurrencyCash) {
      final ctrl = _foreignClosingCtrls[fc.currencyId]!;
      final text = ctrl.text.trim();
      if (text.isNotEmpty && parseInputDouble(text) != null) {
        foreignClosing[fc.currencyId] = parseMoney(text, fc.toCurrencyModel());
      }
    }

    Navigator.pop(
      context,
      ClosingSessionResult(
        closingCash: closing,
        note: _note,
        foreignClosingCash: foreignClosing,
        printReport: _printReport,
      ),
    );
  }

  Future<void> _showNoteDialog() async {
    final l = context.l10n;
    final ctrl = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => PosDialogShell(
        title: l.closingNoteTitle,
        maxWidth: 400,
        children: [
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l.closingNoteHint,
            ),
            maxLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PosDialogActions(
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
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && mounted) {
      setState(() => _note = result.isEmpty ? null : result);
    }
  }

  Future<String?> _showCashInputDialog({
    required String title,
    required int expectedCash,
    required String initialText,
    required CurrencyModel currency,
    required String locale,
  }) async {
    final l = context.l10n;
    String fmt(int amount) => formatMoney(amount, currency, appLocale: locale);
    String fmtSign(int amount) =>
        formatMoneyWithSign(amount, currency, appLocale: locale);

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var input = initialText;
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            final closingMinor =
                input.isNotEmpty && parseInputDouble(input) != null
                    ? parseMoney(input, currency)
                    : null;
            final diff =
                closingMinor != null ? closingMinor - expectedCash : null;

            return PosDialogShell(
              title: title,
              maxWidth: 340,
              maxHeight: 480,
              expandHeight: true,
              bottomActions: SizedBox(
                width: 250,
                child: PosDialogActions(
                  expanded: true,
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l.actionCancel),
                    ),
                    FilledButton(
                      style: PosButtonStyles.confirm(ctx),
                      onPressed: input.isNotEmpty
                          ? () => Navigator.pop(dialogContext, input)
                          : null,
                      child: Text(l.actionConfirm),
                    ),
                  ],
                ),
              ),
              children: [
                // Expected cash info row
                _row(l.closingExpectedCash, fmt(expectedCash), bold: true),
                // Live difference row
                if (diff != null)
                  _row(
                    l.closingDifference,
                    fmtSign(diff),
                    bold: true,
                    valueColor: cashDifferenceColor(diff, ctx),
                  ),
                const SizedBox(height: 12),
                // Amount display
                Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(ctx).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    input.isNotEmpty
                        ? fmt(parseMoney(input, currency))
                        : '—',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                // Numpad
                Expanded(
                  child: PosNumpad(
                    width: 250,
                    expand: true,
                    onDigit: (digit) {
                      if (input.length >= 7) return;
                      setInnerState(() => input += digit);
                    },
                    onBackspace: () {
                      if (input.isEmpty) return;
                      setInnerState(() {
                        input = input.substring(0, input.length - 1);
                      });
                    },
                    onClear: () => setInnerState(() => input = ''),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _cashInputRow(String label, String value,
      {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label),
            ),
            Text(value),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
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
      bottomActions: _buildActions(l, theme),
      children: [
        // --- Session info ---
                _buildSessionInfo(l, theme),
                const Divider(height: 24),

                // --- Revenue by payment type ---
                _buildRevenue(l, theme),
                const Divider(height: 24),

                // --- Foreign currency cash ---
                if (_data.foreignCurrencyCash.isNotEmpty) ...[
                  _buildForeignCashReconciliation(l, theme),
                  const Divider(height: 24),
                ],

                // --- Cash reconciliation + closing input ---
                _buildCashReconciliation(l, theme),
                const SizedBox(height: 20),

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
        _row(l.closingDuration, formatDuration(duration,
            hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly)),
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
    final diff = _difference;

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
        const SizedBox(height: 8),
        _cashInputRow(
          l.closingActualCash,
          _closingCashMinor != null ? ref.money(_closingCashMinor!) : '—',
          onTap: () async {
            final currency = ref.read(currentCurrencyProvider).value!;
            final locale = ref.read(appLocaleProvider).value ?? 'cs';
            final result = await _showCashInputDialog(
              title: l.closingActualCash,
              expectedCash: _data.expectedCash,
              initialText: _closingCashCtrl.text,
              currency: currency,
              locale: locale,
            );
            if (result != null) {
              _closingCashCtrl.text = result;
            }
          },
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
  // Section: Foreign currency cash reconciliation
  // ---------------------------------------------------------------------------

  Widget _buildForeignCashReconciliation(AppLocalizations l, ThemeData theme) {
    final locale = ref.read(appLocaleProvider).value ?? 'cs';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.closingForeignCashTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final fc in _data.foreignCurrencyCash) ...[
          _buildForeignCurrencySection(fc, l, theme, locale),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildForeignCurrencySection(
    ForeignCurrencyCashData fc, AppLocalizations l, ThemeData theme, String locale,
  ) {
    final cur = fc.toCurrencyModel();
    String fmt(int amount) => formatMoney(amount, cur, appLocale: locale);
    String fmtSign(int amount) => formatMoneyWithSign(amount, cur, appLocale: locale);

    final ctrl = _foreignClosingCtrls[fc.currencyId]!;
    final closingText = ctrl.text.trim();
    final closingMinor = closingText.isNotEmpty && parseInputDouble(closingText) != null
        ? parseMoney(closingText, cur)
        : null;
    final diff = closingMinor != null ? closingMinor - fc.expectedCash : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${fc.code} (${fc.symbol})',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _row(l.closingOpeningCash, fmt(fc.openingCash)),
        _row(l.closingCashRevenue, fmtSign(fc.cashRevenue)),
        if (fc.cashDeposits > 0)
          _row(l.closingDeposits, fmtSign(fc.cashDeposits)),
        if (fc.cashWithdrawals > 0)
          _row(l.closingWithdrawals, fmtSign(-fc.cashWithdrawals)),
        const Divider(height: 8),
        _row(l.closingExpectedCash, fmt(fc.expectedCash), bold: true),
        const SizedBox(height: 8),
        _cashInputRow(
          l.closingActualCash,
          closingMinor != null ? fmt(closingMinor) : '—',
          onTap: () async {
            final result = await _showCashInputDialog(
              title: '${l.closingActualCash} (${fc.code})',
              expectedCash: fc.expectedCash,
              initialText: ctrl.text,
              currency: cur,
              locale: locale,
            );
            if (result != null) {
              ctrl.text = result;
            }
          },
        ),
        if (diff != null) ...[
          const SizedBox(height: 4),
          _row(
            l.closingDifference,
            fmtSign(diff),
            bold: true,
            valueColor: cashDifferenceColor(diff, context),
          ),
        ],
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
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActions(AppLocalizations l, ThemeData theme) {
    return PosDialogActions(
      expanded: true,
      actions: [
        FilledButton.tonal(
          onPressed: _showNoteDialog,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.cashMovementNote),
              if (_note != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
              ],
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => setState(() => _printReport = !_printReport),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.closingPrint),
              if (_printReport) ...[
                const SizedBox(width: 4),
                Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
              ],
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          style: PosButtonStyles.confirm(context),
          onPressed: _closingCashMinor != null ? _confirm : null,
          child: Text(l.closingConfirm),
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
