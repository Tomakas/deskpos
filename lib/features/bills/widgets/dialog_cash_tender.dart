import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/currency_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

class CashTenderResult {
  const CashTenderResult({
    required this.receivedAmount,
    required this.changeAmount,
    this.skipped = false,
  });

  /// "Bez zadání" — skip tender, proceed with payment without evidence.
  static const skip = CashTenderResult(receivedAmount: 0, changeAmount: 0, skipped: true);

  /// Přijatá částka v měně platby (minor units).
  final int receivedAmount;

  /// Částka k vrácení — vždy ve výchozí měně (minor units).
  final int changeAmount;

  /// True when user chose "Bez zadání" (skip).
  final bool skipped;
}

class DialogCashTender extends ConsumerStatefulWidget {
  const DialogCashTender({
    super.key,
    required this.amountDue,
    required this.currency,
    required this.baseCurrency,
    this.exchangeRate,
  });

  /// Zbývající částka na účtu ve výchozí měně (minor units).
  final int amountDue;

  /// Měna ve které se platí (může být cizí i výchozí).
  final CurrencyModel currency;

  /// Výchozí měna firmy (pro zobrazení change a konverze).
  final CurrencyModel baseCurrency;

  /// Kurz cizí měny → výchozí měna. null pokud platba ve výchozí měně.
  final double? exchangeRate;

  @override
  ConsumerState<DialogCashTender> createState() => _DialogCashTenderState();
}

class _DialogCashTenderState extends ConsumerState<DialogCashTender> {
  String _input = '';
  bool _replaceOnNextDigit = true;
  late final List<int> _displayQuick;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get _isForeign => widget.exchangeRate != null;

  int get _receivedMinor => parseMoney(_input, widget.currency);

  /// Přijatá částka přepočtená do výchozí měny (minor units).
  /// Identická logika jako DialogPayment._foreignToBase (řádky 562–572).
  int get _receivedInBase {
    if (!_isForeign) return _receivedMinor;
    final rate = widget.exchangeRate!;
    if (rate <= 0) return 0;
    final baseDecimals = widget.baseCurrency.decimalPlaces;
    final baseDivisor = pow(10, baseDecimals);
    final foreignDecimals = widget.currency.decimalPlaces;
    final foreignDivisor = foreignDecimals > 0 ? pow(10, foreignDecimals) : 1;
    return ((_receivedMinor / foreignDivisor.toDouble()) * rate * baseDivisor)
        .round();
  }

  /// Dlužná částka přepočtená do platební měny (minor units).
  /// Identická logika jako DialogPayment._remainingInForeign (řádky 547–558).
  int get _amountDueInPayCurrency {
    if (!_isForeign) return widget.amountDue;
    final rate = widget.exchangeRate!;
    if (rate <= 0) return 0;
    final baseDecimals = widget.baseCurrency.decimalPlaces;
    final baseDivisor = pow(10, baseDecimals);
    final foreignDecimals = widget.currency.decimalPlaces;
    final foreignDivisor = foreignDecimals > 0 ? pow(10, foreignDecimals) : 1;
    return (widget.amountDue / baseDivisor / rate * foreignDivisor.toDouble())
        .ceil();
  }

  int get _changeAmount => max(0, _receivedInBase - widget.amountDue);
  bool get _coversAmount => _receivedInBase >= widget.amountDue;

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _fmtBase(int minorUnits) => formatMoney(
        minorUnits,
        widget.baseCurrency,
        appLocale: ref.read(appLocaleProvider).value ?? 'cs',
      );

  String _fmtPay(int minorUnits) => formatMoney(
        minorUnits,
        widget.currency,
        appLocale: ref.read(appLocaleProvider).value ?? 'cs',
      );

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Compute quick amounts — round up to nearest 10, 50, 100, 500
    // in payment currency whole units (vzor: DialogChangeTotalToPay)
    final dueWhole =
        wholeUnitsFromMinor(_amountDueInPayCurrency, widget.currency) + 1;
    final quickAmounts = <int>[];
    for (final step in [10, 50, 100, 500]) {
      final rounded = ((dueWhole / step).ceil() * step);
      if (rounded > 0 && !quickAmounts.contains(rounded)) {
        quickAmounts.add(rounded);
      }
    }
    _displayQuick = quickAmounts.take(4).toList();
    // Pre-fill with first quick amount
    if (_displayQuick.isNotEmpty) {
      _input = _displayQuick.first.toString();
    }
  }

  // ---------------------------------------------------------------------------
  // Numpad
  // ---------------------------------------------------------------------------

  void _onDigit(String d) {
    setState(() {
      if (_replaceOnNextDigit) {
        _input = d;
        _replaceOnNextDigit = false;
      } else {
        _input += d;
      }
    });
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _replaceOnNextDigit = false;
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _input = '';
      _replaceOnNextDigit = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final infoStyle = theme.textTheme.bodyMedium;

    // Change / remaining
    final String changeLabel;
    final String changeValue;
    final Color changeColor;
    if (_receivedMinor == 0) {
      changeLabel = l.cashTenderChangeLabel;
      changeValue = '—';
      changeColor = theme.colorScheme.onSurfaceVariant;
    } else if (_coversAmount) {
      changeLabel = l.cashTenderChangeLabel;
      changeValue = _fmtBase(_changeAmount);
      changeColor = Colors.green;
    } else {
      changeLabel = l.cashTenderRemainingLabel;
      changeValue = _fmtBase(widget.amountDue - _receivedInBase);
      changeColor = theme.colorScheme.error;
    }

    // Title: "K úhradě: 320 Kč"
    final titleText = '${l.cashTenderAmountDue}: ${_fmtPay(_amountDueInPayCurrency)}';

    return PosDialogShell(
      title: titleText,
      showCloseButton: true,
      maxWidth: 440,
      maxHeight: 440,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      bottomActions: PosDialogActions(
        expanded: true,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, CashTenderResult.skip),
            child: Text(l.cashTenderSkip),
          ),
          FilledButton(
            style: PosButtonStyles.confirm(context),
            onPressed: _coversAmount && _receivedMinor > 0
                ? () => Navigator.pop(
                      context,
                      CashTenderResult(
                        receivedAmount: _receivedMinor,
                        changeAmount: _changeAmount,
                      ),
                    )
                : null,
            child: Text(l.actionConfirm),
          ),
        ],
      ),
      children: [
        // Vrátit / Zbývá
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$changeLabel: ', style: theme.textTheme.titleLarge),
            Text(
              changeValue,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Přijato — input box
        Row(
          children: [
            Text('${l.cashTenderReceived}: ', style: infoStyle),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _receivedMinor > 0 ? _fmtPay(_receivedMinor) : '',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            if (_isForeign && _receivedMinor > 0) ...[
              const SizedBox(width: 8),
              Text(
                '= ${_fmtBase(_receivedInBase)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick buttons
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _displayQuick.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => setState(() {
                              _input = _displayQuick[i].toString();
                              _replaceOnNextDigit = true;
                            }),
                            child: Text('${_displayQuick[i]}'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Numpad
              Expanded(
                flex: 3,
                child: PosNumpad(
                  expand: true,
                  onDigit: _onDigit,
                  onBackspace: _onBackspace,
                  onClear: _onClear,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
