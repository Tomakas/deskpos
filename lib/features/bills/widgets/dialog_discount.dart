import 'package:flutter/material.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogDiscount extends StatefulWidget {
  const DialogDiscount({
    super.key,
    this.currentDiscount = 0,
    this.currentDiscountType = DiscountType.absolute,
    required this.referenceAmount,
  });

  final int currentDiscount;
  final DiscountType currentDiscountType;
  final int referenceAmount;

  @override
  State<DialogDiscount> createState() => _DialogDiscountState();
}

class _DialogDiscountState extends State<DialogDiscount> {
  late DiscountType _type;
  String _input = '';

  @override
  void initState() {
    super.initState();
    _type = widget.currentDiscountType;
    if (widget.currentDiscount > 0) {
      if (_type == DiscountType.percent) {
        // Convert from basis points to percent display
        _input = (widget.currentDiscount / 100).toStringAsFixed(
          widget.currentDiscount % 100 == 0 ? 0 : 2,
        );
      } else {
        // Convert from halere to Kc display
        _input = (widget.currentDiscount / 100).toStringAsFixed(
          widget.currentDiscount % 100 == 0 ? 0 : 2,
        );
      }
    }
  }

  int get _discountValue {
    final parsed = double.tryParse(_input) ?? 0;
    if (_type == DiscountType.percent) {
      // Input is percent (e.g. 10 = 10%), store as basis points (1000)
      return (parsed * 100).round();
    } else {
      // Input is Kc (e.g. 50 = 50 Kc), store as halere (5000)
      return (parsed * 100).round();
    }
  }

  int get _effectiveDiscount {
    final val = _discountValue;
    if (_type == DiscountType.percent) {
      return (widget.referenceAmount * val / 10000).round();
    } else {
      return val;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Dialog(
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.billDetailDiscount,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Type toggle
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        showCheckmark: false,
                        label: SizedBox(
                          width: double.infinity,
                          child: Text('Kč', textAlign: TextAlign.center),
                        ),
                        selected: _type == DiscountType.absolute,
                        onSelected: (_) => setState(() {
                          _type = DiscountType.absolute;
                          _input = '';
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        showCheckmark: false,
                        label: SizedBox(
                          width: double.infinity,
                          child: Text('%', textAlign: TextAlign.center),
                        ),
                        selected: _type == DiscountType.percent,
                        onSelected: (_) => setState(() {
                          _type = DiscountType.percent;
                          _input = '';
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              // Preview
              Text(
                '${l.billDetailDiscount}: -${_effectiveDiscount ~/ 100} Kč',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Numpad
              _buildNumpad(),
              const SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.actionCancel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () => Navigator.pop(context, (DiscountType.absolute, 0)),
                        child: Text(l.actionDelete),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, (_type, _discountValue)),
                        child: const Text('OK'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        _numpadRow(['1', '2', '3']),
        const SizedBox(height: 4),
        _numpadRow(['4', '5', '6']),
        const SizedBox(height: 4),
        _numpadRow(['7', '8', '9']),
        const SizedBox(height: 4),
        Row(
          children: [
            _numpadButton(
              child: const Text('.', style: TextStyle(fontSize: 20)),
              onTap: () {
                if (!_input.contains('.')) {
                  setState(() => _input = _input.isEmpty ? '0.' : '$_input.');
                }
              },
            ),
            const SizedBox(width: 4),
            _numpadButton(
              child: const Text('0', style: TextStyle(fontSize: 20)),
              onTap: () => setState(() => _input += '0'),
            ),
            const SizedBox(width: 4),
            _numpadButton(
              child: const Icon(Icons.backspace_outlined, size: 20),
              onTap: () {
                if (_input.isNotEmpty) {
                  setState(() => _input = _input.substring(0, _input.length - 1));
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _numpadRow(List<String> digits) {
    return Row(
      children: [
        for (var i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _numpadButton(
            child: Text(digits[i], style: const TextStyle(fontSize: 20)),
            onTap: () => setState(() => _input += digits[i]),
          ),
        ],
      ],
    );
  }

  Widget _numpadButton({required Widget child, required VoidCallback onTap}) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.zero,
          ),
          child: child,
        ),
      ),
    );
  }
}
