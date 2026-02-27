import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/currency_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

/// Data for a foreign currency in the opening cash dialog.
class ForeignCurrencyOpening {
  const ForeignCurrencyOpening({
    required this.currencyId,
    required this.code,
    required this.symbol,
    required this.decimalPlaces,
    this.lastClosingCash,
  });

  final String currencyId;
  final String code;
  final String symbol;
  final int decimalPlaces;
  final int? lastClosingCash;
}

/// Result from the opening cash dialog containing base and foreign amounts.
class OpeningCashResult {
  const OpeningCashResult({
    required this.baseCash,
    required this.foreignCash,
  });

  final int baseCash;
  final Map<String, int> foreignCash; // currencyId → amount in minor units
}

/// Simple dialog shown only on the very first register session opening
/// (when no cash movement history exists). Returns the initial cash amount
/// in haléře, or `null` if cancelled.
class DialogOpeningCash extends ConsumerStatefulWidget {
  const DialogOpeningCash({
    super.key,
    this.initialAmount,
    this.foreignCurrencies = const [],
  });

  /// Pre-fill amount from previous session's closing cash (in haléře).
  final int? initialAmount;

  /// Active foreign currencies with optional last closing cash.
  final List<ForeignCurrencyOpening> foreignCurrencies;

  @override
  ConsumerState<DialogOpeningCash> createState() => _DialogOpeningCashState();
}

class _DialogOpeningCashState extends ConsumerState<DialogOpeningCash> {
  /// Currently displayed numpad text (for the active currency).
  String _amountText = '';

  /// Stored amounts per currency: null key = base, currencyId = foreign.
  final Map<String?, String> _amounts = {};

  /// null = base currency selected.
  String? _selectedCurrencyId;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      final currency = ref.read(currentCurrencyProvider).value;
      _amountText = wholeUnitsFromMinor(widget.initialAmount!, currency).toString();
      _amounts[null] = _amountText;
    }
    for (final fc in widget.foreignCurrencies) {
      if (fc.lastClosingCash != null && fc.lastClosingCash! > 0) {
        final mockCurrency = CurrencyModel(
          id: fc.currencyId, code: fc.code, symbol: fc.symbol,
          name: '', decimalPlaces: fc.decimalPlaces,
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        );
        _amounts[fc.currencyId] = wholeUnitsFromMinor(fc.lastClosingCash!, mockCurrency).toString();
      }
    }
  }

  CurrencyModel? get _activeCurrency {
    if (_selectedCurrencyId == null) return null;
    final fc = widget.foreignCurrencies.firstWhere(
      (c) => c.currencyId == _selectedCurrencyId,
    );
    return CurrencyModel(
      id: fc.currencyId, code: fc.code, symbol: fc.symbol,
      name: '', decimalPlaces: fc.decimalPlaces,
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
  }

  void _selectCurrency(String? currencyId) {
    if (currencyId == _selectedCurrencyId) return;
    setState(() {
      _amounts[_selectedCurrencyId] = _amountText;
      _selectedCurrencyId = currencyId;
      _amountText = _amounts[currencyId] ?? '';
    });
  }

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

  void _confirm() {
    // Save current display into amounts map.
    _amounts[_selectedCurrencyId] = _amountText;

    final baseCurrency = ref.read(currentCurrencyProvider).value;
    final baseCash = parseMoney(_amounts[null] ?? '', baseCurrency);

    final foreignCash = <String, int>{};
    for (final fc in widget.foreignCurrencies) {
      final text = (_amounts[fc.currencyId] ?? '').trim();
      if (text.isNotEmpty) {
        final mockCurrency = CurrencyModel(
          id: fc.currencyId, code: fc.code, symbol: fc.symbol,
          name: '', decimalPlaces: fc.decimalPlaces,
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        );
        foreignCash[fc.currencyId] = parseMoney(text, mockCurrency);
      }
    }

    Navigator.pop(context, OpeningCashResult(baseCash: baseCash, foreignCash: foreignCash));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hasForeign = widget.foreignCurrencies.isNotEmpty;
    final currency = _activeCurrency ?? ref.watch(currentCurrencyProvider).value;
    final locale = ref.read(appLocaleProvider).value ?? 'cs';

    return PosDialogShell(
      title: l.openingCashTitle,
      maxWidth: 340,
      maxHeight: 520,
      expandHeight: true,
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
              style: PosButtonStyles.confirm(context),
              onPressed: _confirm,
              child: Text(l.openingCashConfirm),
            ),
          ],
        ),
      ),
      children: [
        Center(
          child: Text(
            l.openingCashSubtitle,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        // Currency chip bar
        if (hasForeign) ...[
          _buildCurrencyChips(theme),
          const SizedBox(height: 12),
        ],
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
            _selectedCurrencyId != null
                ? formatMoney(parseMoney(_amountText, currency), currency, appLocale: locale)
                : ref.money(parseMoney(_amountText, currency)),
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
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCurrencyChips(ThemeData theme) {
    final baseCurrency = ref.watch(currentCurrencyProvider).value;
    final baseCode = baseCurrency?.code ?? '---';

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilterChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(baseCode, textAlign: TextAlign.center),
              ),
              selected: _selectedCurrencyId == null,
              onSelected: (_) => _selectCurrency(null),
            ),
          ),
        ),
        for (final fc in widget.foreignCurrencies) ...[
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: FilterChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(fc.code, textAlign: TextAlign.center),
                ),
                selected: _selectedCurrencyId == fc.currencyId,
                onSelected: (_) => _selectCurrency(fc.currencyId),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
