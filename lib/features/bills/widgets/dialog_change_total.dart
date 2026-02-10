import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';

class DialogChangeTotalToPay extends StatefulWidget {
  const DialogChangeTotalToPay({
    super.key,
    required this.originalAmount,
  });

  final int originalAmount;

  @override
  State<DialogChangeTotalToPay> createState() => _DialogChangeTotalToPayState();
}

class _DialogChangeTotalToPayState extends State<DialogChangeTotalToPay> {
  String _input = '';

  int get _amountInHalere {
    final parsed = double.tryParse(_input) ?? 0;
    return (parsed * 100).round();
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill with original amount
    final kc = widget.originalAmount / 100;
    _input = kc == kc.roundToDouble()
        ? kc.round().toString()
        : kc.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final originalKc = (widget.originalAmount / 100).toStringAsFixed(2).replaceAll('.', ',');

    // Quick buttons — round amounts around the original
    final originalKcInt = (widget.originalAmount / 100).ceil();
    final quickAmounts = <int>[];
    // Round up to nearest 10, 50, 100, 500
    for (final step in [10, 50, 100, 500]) {
      final rounded = ((originalKcInt / step).ceil() * step);
      if (rounded > 0 && !quickAmounts.contains(rounded)) {
        quickAmounts.add(rounded);
      }
    }
    // Keep max 4 unique values
    final displayQuick = quickAmounts.take(4).toList();

    return Dialog(
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.changeTotalTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: quick buttons
                  SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        for (final amount in displayQuick) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _input = amount.toString()),
                              child: Text('$amount'),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Center: display
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${l.changeTotalOriginal}: $originalKc Kč',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l.changeTotalEdited}:',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _input.isEmpty ? '0' : _input,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right: numpad
                  SizedBox(
                    width: 140,
                    child: _buildNumpad(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom actions
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
                        onPressed: () => setState(() => _input = ''),
                        child: Text(l.actionDelete),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _amountInHalere > 0
                            ? () => Navigator.pop(context, _amountInHalere)
                            : null,
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
              child: const Icon(Icons.backspace_outlined, size: 18),
              onTap: () {
                if (_input.isNotEmpty) {
                  setState(() => _input = _input.substring(0, _input.length - 1));
                }
              },
            ),
            const SizedBox(width: 4),
            _numpadButton(
              child: const Text('0', style: TextStyle(fontSize: 18)),
              onTap: () => setState(() => _input += '0'),
            ),
            const SizedBox(width: 4),
            _numpadButton(
              child: const Text('C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onTap: () => setState(() => _input = ''),
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
            child: Text(digits[i], style: const TextStyle(fontSize: 18)),
            onTap: () => setState(() => _input += digits[i]),
          ),
        ],
      ],
    );
  }

  Widget _numpadButton({required Widget child, required VoidCallback onTap}) {
    return Expanded(
      child: SizedBox(
        height: 44,
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
