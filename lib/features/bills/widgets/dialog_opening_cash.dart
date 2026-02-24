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
  String _amountText = '';
  final Map<String, TextEditingController> _foreignControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      final currency = ref.read(currentCurrencyProvider).value;
      _amountText = wholeUnitsFromMinor(widget.initialAmount!, currency).toString();
    }
    for (final fc in widget.foreignCurrencies) {
      final ctrl = TextEditingController();
      if (fc.lastClosingCash != null && fc.lastClosingCash! > 0) {
        final mockCurrency = CurrencyModel(
          id: fc.currencyId, code: fc.code, symbol: fc.symbol,
          name: '', decimalPlaces: fc.decimalPlaces,
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        );
        ctrl.text = wholeUnitsFromMinor(fc.lastClosingCash!, mockCurrency).toString();
      }
      _foreignControllers[fc.currencyId] = ctrl;
    }
  }

  @override
  void dispose() {
    for (final ctrl in _foreignControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
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
    final currency = ref.read(currentCurrencyProvider).value;
    final baseCash = parseMoney(_amountText, currency);

    final foreignCash = <String, int>{};
    for (final fc in widget.foreignCurrencies) {
      final ctrl = _foreignControllers[fc.currencyId]!;
      final text = ctrl.text.trim();
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

    return PosDialogShell(
      title: l.openingCashTitle,
      maxWidth: hasForeign ? 420 : 340,
      maxHeight: 520,
      expandHeight: true,
      children: [
        Center(
          child: Text(
            l.openingCashSubtitle,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
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
            ref.money(parseMoney(_amountText, ref.watch(currentCurrencyProvider).value)),
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
        // Foreign currency fields
        if (hasForeign) ...[
          const Divider(height: 24),
          Text(l.openingForeignCashTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final fc in widget.foreignCurrencies)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _foreignControllers[fc.currencyId],
                decoration: InputDecoration(
                  labelText: fc.code,
                  suffixText: fc.symbol,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
        ],
        const SizedBox(height: 16),
        // Actions
        SizedBox(
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
      ],
    );
  }
}
