import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogPayment extends ConsumerStatefulWidget {
  const DialogPayment({
    super.key,
    required this.bill,
    this.tableName,
  });
  final BillModel bill;
  final String? tableName;

  @override
  ConsumerState<DialogPayment> createState() => _DialogPaymentState();
}

class _DialogPaymentState extends ConsumerState<DialogPayment> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final remaining = widget.bill.totalGross - widget.bill.paidAmount;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left sidebar — action buttons
              SizedBox(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _SideButton(label: l.paymentOtherCurrency, onPressed: null),
                      const SizedBox(height: 8),
                      _SideButton(label: l.paymentEet, onPressed: null),
                      const SizedBox(height: 8),
                      _SideButton(label: l.paymentEditAmount, onPressed: null),
                      const SizedBox(height: 8),
                      _SideButton(label: l.paymentMixPayments, onPressed: null),
                      const Spacer(),
                      _SideButton(
                        label: l.actionCancel,
                        onPressed: () => Navigator.pop(context),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              // Center — bill info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        l.paymentTitle.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.paymentBillSubtitle(
                          widget.bill.billNumber,
                          widget.tableName ?? l.billDetailNoTable,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${(remaining / 100).toStringAsFixed(2).replaceAll('.', ',')} Kč',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '(${l.paymentTip('0 Kč')})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${l.paymentPrintReceipt}: ${l.paymentPrintYes}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right sidebar — payment methods
              SizedBox(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<List<PaymentMethodModel>>(
                    stream: ref.watch(paymentMethodRepositoryProvider).watchAll(company.id),
                    builder: (context, snap) {
                      final methods = (snap.data ?? []).where((m) => m.isActive).toList();
                      return Column(
                        children: [
                          for (var i = 0; i < methods.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            _PaymentMethodButton(
                              label: methods[i].name.toUpperCase(),
                              onPressed: _processing
                                  ? null
                                  : () => _pay(context, methods[i].id),
                            ),
                          ],
                          const SizedBox(height: 8),
                          _SideButton(label: l.paymentOtherPayment, onPressed: null),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, String methodId) async {
    setState(() => _processing = true);

    final remaining = widget.bill.totalGross - widget.bill.paidAmount;
    if (remaining <= 0) return;

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.recordPayment(
      companyId: widget.bill.companyId,
      billId: widget.bill.id,
      paymentMethodId: methodId,
      currencyId: widget.bill.currencyId,
      amount: remaining,
    );

    if (result is Success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() => _processing = false);
    }
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.onPressed, this.color});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: color != null
          ? FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            )
          : FilledButton.tonal(
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Colors.green),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
