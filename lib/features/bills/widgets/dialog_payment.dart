import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogPayment extends ConsumerStatefulWidget {
  const DialogPayment({super.key, required this.bill});
  final BillModel bill;

  @override
  ConsumerState<DialogPayment> createState() => _DialogPaymentState();
}

class _DialogPaymentState extends ConsumerState<DialogPayment> {
  String? _selectedMethodId;
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final remaining = widget.bill.totalGross - widget.bill.paidAmount;
    _amountCtrl = TextEditingController(text: (remaining / 100).toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final remaining = widget.bill.totalGross - widget.bill.paidAmount;

    return AlertDialog(
      title: Text(l.paymentTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.paymentTotalDue('${remaining ~/ 100} Kč'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(l.paymentMethod, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            StreamBuilder<List<PaymentMethodModel>>(
              stream: ref.watch(paymentMethodRepositoryProvider).watchAll(company.id),
              builder: (context, snap) {
                final methods = (snap.data ?? []).where((m) => m.isActive).toList();
                if (_selectedMethodId == null && methods.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedMethodId = methods.first.id);
                    }
                  });
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: methods.map((method) => ChoiceChip(
                    label: Text(method.name),
                    selected: _selectedMethodId == method.id,
                    onSelected: (_) => setState(() => _selectedMethodId = method.id),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              decoration: InputDecoration(labelText: l.paymentAmount),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          onPressed: _selectedMethodId == null ? null : () => _pay(context),
          child: Text(l.paymentConfirm),
        ),
      ],
    );
  }

  Future<void> _pay(BuildContext context) async {
    final amount = ((double.tryParse(_amountCtrl.text) ?? 0) * 100).round();
    if (amount <= 0 || _selectedMethodId == null) return;

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.recordPayment(
      companyId: widget.bill.companyId,
      billId: widget.bill.id,
      paymentMethodId: _selectedMethodId!,
      currencyId: widget.bill.currencyId,
      amount: amount,
    );

    if (result is Success && mounted) {
      Navigator.pop(context, true);
    }
  }
}
