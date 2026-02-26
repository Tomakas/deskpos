import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';

class DialogDiscount extends ConsumerStatefulWidget {
  const DialogDiscount({
    super.key,
    this.title,
    this.currentDiscount = 0,
    this.currentDiscountType = DiscountType.absolute,
    required this.referenceAmount,
  });

  final String? title;
  final int currentDiscount;
  final DiscountType currentDiscountType;
  final int referenceAmount;

  @override
  ConsumerState<DialogDiscount> createState() => _DialogDiscountState();
}

class _DialogDiscountState extends ConsumerState<DialogDiscount> {
  String _input = '';

  @override
  void initState() {
    super.initState();
    if (widget.currentDiscount > 0) {
      _input = (widget.currentDiscount / 100).toStringAsFixed(
        widget.currentDiscount % 100 == 0 ? 0 : 2,
      );
    }
  }

  /// Raw value: input * 100 (minor units for absolute, basis points for percent).
  int get _discountValue {
    final parsed = double.tryParse(_input) ?? 0;
    return (parsed * 100).round();
  }

  /// Absolute: capped at referenceAmount (minor units).
  int get _cappedAbsolute =>
      _discountValue.clamp(0, widget.referenceAmount);

  /// Percent: capped at 10000 (= 100%).
  int get _cappedPercent =>
      _discountValue.clamp(0, 10000);

  int get _percentEffective =>
      (widget.referenceAmount * _cappedPercent / 10000).round();

  String _formatPercent(int basisPoints) {
    return formatQuantity(basisPoints / 100, ref.watch(appLocaleProvider).value ?? 'cs', maxDecimals: 2);
  }

  void _onDot() {
    if (!_input.contains('.')) {
      setState(() => _input = _input.isEmpty ? '0.' : '$_input.');
    }
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() => _input = _input.substring(0, _input.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hasValue = _discountValue > 0;

    return PosDialogShell(
      title: widget.title ?? l.billDetailDiscount,
      maxWidth: 340,
      maxHeight: 460,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      children: [
        // Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _input.isEmpty ? '0' : _input,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 12),
        // Numpad
        Expanded(
          child: PosNumpad(
            size: PosNumpadSize.compact,
            expand: true,
            onDigit: (d) => setState(() => _input += d),
            onBackspace: _onBackspace,
            onDot: _onDot,
          ),
        ),
        const SizedBox(height: 16),
        // Actions: [currency] [back] [%]
        PosDialogActions(
          height: 52,
          expanded: true,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                (DiscountType.absolute, _cappedAbsolute),
              ),
              child: hasValue
                  ? Text('-${ref.moneyValue(_cappedAbsolute)} ${ref.currencySymbol}')
                  : Text(ref.currencySymbol),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.wizardBack),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                (DiscountType.percent, _cappedPercent),
              ),
              child: hasValue
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${_formatPercent(_cappedPercent)} %'),
                        Text(
                          '-${ref.money(_percentEffective)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    )
                  : const Text('%'),
            ),
          ],
        ),
      ],
    );
  }
}
