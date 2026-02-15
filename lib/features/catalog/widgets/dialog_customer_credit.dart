import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/customer_transaction_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_dialog_theme.dart';
import '../../../core/widgets/pos_numpad.dart';

class DialogCustomerCredit extends ConsumerStatefulWidget {
  const DialogCustomerCredit({super.key, required this.customer});
  final CustomerModel customer;

  @override
  ConsumerState<DialogCustomerCredit> createState() => _DialogCustomerCreditState();
}

class _DialogCustomerCreditState extends ConsumerState<DialogCustomerCredit> {
  String _amountText = '';
  late CustomerModel _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  int get _amountWhole => int.tryParse(_amountText) ?? 0;
  bool get _hasAmount => _amountWhole > 0;

  void _numpadTap(String digit) {
    if (_amountText.length >= 7) return;
    setState(() => _amountText += digit);
  }

  void _numpadBackspace() {
    if (_amountText.isEmpty) return;
    setState(() => _amountText = _amountText.substring(0, _amountText.length - 1));
  }

  void _numpadClear() {
    setState(() => _amountText = '');
  }

  Future<void> _topUp() async {
    if (!_hasAmount) return;
    final user = ref.read(activeUserProvider);
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.adjustCredit(
      customerId: _customer.id,
      delta: _amountWhole * 100,
      processedByUserId: user?.id ?? '',
    );
    if (result is Success && mounted) {
      _refreshCustomer();
      setState(() => _amountText = '');
    }
  }

  Future<void> _deduct() async {
    if (!_hasAmount) return;
    final deductAmount = _amountWhole * 100;
    if (deductAmount > _customer.credit) return;
    final user = ref.read(activeUserProvider);
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.adjustCredit(
      customerId: _customer.id,
      delta: -deductAmount,
      processedByUserId: user?.id ?? '',
    );
    if (result is Success && mounted) {
      _refreshCustomer();
      setState(() => _amountText = '');
    }
  }

  Future<void> _refreshCustomer() async {
    final repo = ref.read(customerRepositoryProvider);
    final updated = await repo.getById(_customer.id);
    if (updated != null && mounted) {
      setState(() => _customer = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.loyaltyCredit,
      maxWidth: 500,
      children: [
        Center(
          child: Text(
            '${_customer.firstName} ${_customer.lastName}',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            '${l.loyaltyCreditBalance}: ${ref.money(_customer.credit)}',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
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
            ref.money(_amountWhole * 100),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Numpad + action buttons
        _buildNumpadAndActions(theme, l),
        const SizedBox(height: 16),
        // Transaction history
        Text(l.loyaltyTransactionHistory, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: _buildTransactionHistory(context),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: PosDialogTheme.actionHeight,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionClose),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpadAndActions(ThemeData theme, dynamic l) {
    const rowHeight = PosDialogTheme.numpadLargeHeight;
    const gap = PosDialogTheme.numpadLargeGap;
    const totalHeight = rowHeight * 4 + gap * 3;
    const actionHeight = (totalHeight - gap) / 2;

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 230,
            child: PosNumpad(
              onDigit: _numpadTap,
              onBackspace: _numpadBackspace,
              onClear: _numpadClear,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Column(
              children: [
                SizedBox(
                  height: actionHeight,
                  width: double.infinity,
                  child: FilledButton(
                    style: PosButtonStyles.confirmWith(
                      context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PosDialogTheme.numpadLargeRadius),
                      ),
                    ),
                    onPressed: _hasAmount ? _topUp : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.loyaltyCreditTopUp, style: const TextStyle(fontSize: PosDialogTheme.actionFontSize)),
                        const SizedBox(height: 4),
                        const Icon(Icons.add_circle_outline, size: 32),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: gap),
                SizedBox(
                  height: actionHeight,
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PosDialogTheme.numpadLargeRadius),
                      ),
                    ),
                    onPressed: _hasAmount && _amountWhole * 100 <= _customer.credit
                        ? _deduct
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.loyaltyCreditDeduct, style: const TextStyle(fontSize: PosDialogTheme.actionFontSize)),
                        const SizedBox(height: 4),
                        const Icon(Icons.remove_circle_outline, size: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<CustomerTransactionModel>>(
      stream: ref.watch(customerTransactionRepositoryProvider).watchByCustomer(_customer.id),
      builder: (context, snap) {
        final txs = snap.data ?? [];
        if (txs.isEmpty) {
          return Center(
            child: Text('-', style: theme.textTheme.bodyMedium),
          );
        }
        return ListView.builder(
          itemCount: txs.length > 10 ? 10 : txs.length,
          itemBuilder: (context, i) {
            final tx = txs[i];
            final hasPoints = tx.pointsChange != 0;
            final hasCredit = tx.creditChange != 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      ref.fmtDateTimeShort(tx.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (hasPoints)
                    Expanded(
                      child: Text(
                        '${tx.pointsChange > 0 ? '+' : ''}${tx.pointsChange} bodů',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: valueChangeColor(tx.pointsChange, context),
                        ),
                      ),
                    ),
                  if (hasCredit)
                    Expanded(
                      child: Text(
                        '${tx.creditChange > 0 ? '+' : ''}${ref.money(tx.creditChange)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: valueChangeColor(tx.creditChange, context),
                        ),
                      ),
                    ),
                  if (!hasPoints && !hasCredit) const Expanded(child: SizedBox.shrink()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
