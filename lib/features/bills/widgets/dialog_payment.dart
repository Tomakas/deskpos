import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/models/payment_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import 'dialog_change_total.dart';

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
  late BillModel _bill;
  int? _customAmount;

  @override
  void initState() {
    super.initState();
    _bill = widget.bill;
  }

  int get _remaining => _bill.totalGross - _bill.paidAmount;

  int get _payAmount => _customAmount ?? _remaining;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

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
                      _SideButton(
                        label: l.paymentEditAmount,
                        onPressed: _remaining > 0 ? () => _editAmount(context) : null,
                      ),
                      const Spacer(),
                      _SideButton(
                        label: l.actionCancel,
                        onPressed: () => Navigator.pop(context, _bill.paidAmount > widget.bill.paidAmount),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              // Center — bill info + payments list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        l.paymentTitle.toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.paymentBillSubtitle(
                          _bill.billNumber,
                          widget.tableName ?? l.billDetailNoTable,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Already-made payments
                      StreamBuilder<List<PaymentModel>>(
                        stream: ref.watch(paymentRepositoryProvider).watchByBill(_bill.id),
                        builder: (context, snap) {
                          final payments = snap.data ?? [];
                          if (payments.isEmpty) return const SizedBox.shrink();
                          return _buildPaymentsList(context, payments);
                        },
                      ),
                      const Spacer(),
                      // Remaining amount
                      if (_customAmount != null) ...[
                        Text(
                          _formatKc(_remaining),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatKc(_customAmount!),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          _formatKc(_remaining),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_customAmount != null && _customAmount! > _remaining)
                        Text(
                          '(${l.paymentTip(_formatKc(_customAmount! - _remaining))})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Text(
                          '${l.paymentPrintReceipt}: ${l.paymentPrintYes}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const Spacer(),
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
                              onPressed: _processing || _remaining <= 0
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

  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> payments) {
    final theme = Theme.of(context);
    final methodRepo = ref.read(paymentMethodRepositoryProvider);
    final company = ref.read(currentCompanyProvider);

    return FutureBuilder<List<PaymentMethodModel>>(
      future: company != null ? methodRepo.getAll(company.id) : Future.value([]),
      builder: (context, snap) {
        final methods = snap.data ?? [];
        final methodMap = {for (final m in methods) m.id: m.name};

        return Column(
          children: [
            for (final p in payments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      methodMap[p.paymentMethodId] ?? '?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatKc(p.amount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (p.tipIncludedAmount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(+${_formatKc(p.tipIncludedAmount)})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const Divider(),
          ],
        );
      },
    );
  }

  Future<void> _editAmount(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => DialogChangeTotalToPay(originalAmount: _remaining),
    );
    if (result != null && mounted) {
      setState(() => _customAmount = result);
    }
  }

  Future<void> _pay(BuildContext context, String methodId) async {
    setState(() => _processing = true);

    if (_remaining <= 0) return;

    final amount = _payAmount;
    final tipAmount = amount > _remaining ? amount - _remaining : 0;
    final effectiveAmount = amount > _remaining ? _remaining : amount;

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.recordPayment(
      companyId: _bill.companyId,
      billId: _bill.id,
      paymentMethodId: methodId,
      currencyId: _bill.currencyId,
      amount: effectiveAmount,
      tipAmount: tipAmount,
      userId: ref.read(activeUserProvider)?.id,
    );

    if (!mounted) return;

    if (result is Success<BillModel>) {
      final updatedBill = result.value;
      final fullyPaid = updatedBill.paidAmount >= updatedBill.totalGross;

      if (fullyPaid) {
        Navigator.pop(context, true);
      } else {
        // Stay open — update state for next payment
        setState(() {
          _bill = updatedBill;
          _customAmount = null;
          _processing = false;
        });
      }
    } else {
      setState(() => _processing = false);
    }
  }

  String _formatKc(int halere) {
    return '${(halere / 100).toStringAsFixed(2).replaceAll('.', ',')} Kč';
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
