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
  });

  /// Přijatá částka v měně platby (minor units).
  final int receivedAmount;

  /// Částka k vrácení — vždy ve výchozí měně (minor units).
  final int changeAmount;
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

    return PosDialogShell(
      title: l.cashTenderTitle,
      maxWidth: 440,
      maxHeight: 400,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      children: [
        // 1. K úhradě header
        _buildAmountDueHeader(theme),
        const SizedBox(height: 12),
        // 2. Quick buttons + Numpad
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick buttons (flex: 1)
              Expanded(child: _buildQuickButtons()),
              const SizedBox(width: 16),
              // Numpad (flex: 3)
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
        const SizedBox(height: 12),
        // 3. Konverzní řádek (jen cizí měna + nenulový vstup)
        if (_isForeign && _receivedMinor > 0) ...[
          _buildConversionLine(theme),
          const SizedBox(height: 4),
        ],
        // 4. Vrátit / Zbývá / Prázdný stav
        _buildChangeLine(theme, l),
        const SizedBox(height: 16),
        // 5. Akce
        PosDialogActions(
          expanded: true,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
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
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI building blocks
  // ---------------------------------------------------------------------------

  Widget _buildAmountDueHeader(ThemeData theme) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _fmtBase(widget.amountDue),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            if (_isForeign)
              Text(
                '(${_fmtPay(_amountDueInPayCurrency)} × ${widget.exchangeRate!.toStringAsFixed(2)})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Column(
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
    );
  }

  Widget _buildConversionLine(ThemeData theme) {
    final l = context.l10n;
    return Text(
      l.cashTenderConversion(
        _fmtPay(_receivedMinor),
        widget.exchangeRate!.toStringAsFixed(2),
        _fmtBase(_receivedInBase),
      ),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildChangeLine(ThemeData theme, dynamic l) {
    if (_receivedMinor == 0) {
      // Prázdný stav — zobrazit dlužnou částku šedě
      return Text(
        '${l.cashTenderAmountDue}: ${_fmtBase(widget.amountDue)}',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (_coversAmount) {
      // Vrátit — zelený text
      return Text(
        l.cashTenderChange(_fmtBase(_changeAmount)),
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Zbývá — červený text
    return Text(
      l.cashTenderRemaining(
        _fmtBase(widget.amountDue - _receivedInBase),
      ),
      textAlign: TextAlign.center,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.error,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
