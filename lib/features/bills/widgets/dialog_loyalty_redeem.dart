import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogLoyaltyRedeem extends ConsumerStatefulWidget {
  const DialogLoyaltyRedeem({
    super.key,
    required this.bill,
    required this.customer,
    required this.pointValueHalere,
  });
  final BillModel bill;
  final CustomerModel customer;
  final int pointValueHalere;

  @override
  ConsumerState<DialogLoyaltyRedeem> createState() => _DialogLoyaltyRedeemState();
}

class _DialogLoyaltyRedeemState extends ConsumerState<DialogLoyaltyRedeem> {
  String _input = '';

  int get _pointsToUse => int.tryParse(_input) ?? 0;
  int get _discountHalere => _pointsToUse * widget.pointValueHalere;
  int get _maxPoints {
    // Can't exceed bill totalGross with the discount
    final maxByBill = widget.bill.totalGross ~/ widget.pointValueHalere;
    return maxByBill < widget.customer.points ? maxByBill : widget.customer.points;
  }
  bool get _isValid => _pointsToUse > 0 && _pointsToUse <= _maxPoints;

  void _numpadTap(String digit) {
    if (_input.length >= 6) return;
    setState(() => _input += digit);
  }

  void _numpadBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _numpadClear() {
    setState(() => _input = '');
  }

  void _useMax() {
    setState(() => _input = _maxPoints.toString());
  }

  Future<void> _confirm() async {
    if (!_isValid) return;
    final user = ref.read(activeUserProvider);
    final repo = ref.read(billRepositoryProvider);
    final result = await repo.applyLoyaltyDiscount(
      widget.bill.id,
      _pointsToUse,
      widget.pointValueHalere,
      user?.id ?? '',
    );
    if (mounted && result is Success) {
      Navigator.pop(context, true);
    }
  }

  String _formatKc(int halere) {
    return '${(halere / 100).toStringAsFixed(2).replaceAll('.', ',')} Kč';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.loyaltyRedeem, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              // Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${l.loyaltyAvailablePoints}: ${widget.customer.points}'),
                  Text('${l.loyaltyPointsValue}: ${_formatKc(widget.pointValueHalere)}/bod'),
                ],
              ),
              const SizedBox(height: 8),
              // Amount display
              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_pointsToUse',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Preview
              Text(
                l.loyaltyDiscountPreview(_pointsToUse, _formatKc(_discountHalere)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isValid ? Colors.green : null,
                ),
              ),
              const SizedBox(height: 16),
              // Numpad
              _buildNumpad(),
              const SizedBox(height: 16),
              // Bottom
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.actionCancel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.tonal(
                        onPressed: _useMax,
                        child: Text('Max: $_maxPoints'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: _isValid ? _confirm : null,
                        child: Text(l.paymentConfirm),
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
    const rowHeight = 48.0;
    const gap = 8.0;
    return Column(
      children: [
        _numpadRow(['1', '2', '3'], rowHeight),
        const SizedBox(height: gap),
        _numpadRow(['4', '5', '6'], rowHeight),
        const SizedBox(height: gap),
        _numpadRow(['7', '8', '9'], rowHeight),
        const SizedBox(height: gap),
        _numpadRow(['⌫', '0', 'C'], rowHeight),
      ],
    );
  }

  Widget _numpadRow(List<String> keys, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (int i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _numpadButton(keys[i])),
          ],
        ],
      ),
    );
  }

  Widget _numpadButton(String key) {
    final Widget child;
    final VoidCallback onTap;
    switch (key) {
      case '⌫':
        child = const Icon(Icons.backspace_outlined);
        onTap = _numpadBackspace;
      case 'C':
        child = const Text('C', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
        onTap = _numpadClear;
      default:
        child = Text(key, style: const TextStyle(fontSize: 24));
        onTap = () => _numpadTap(key);
    }
    return SizedBox(
      height: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }
}
