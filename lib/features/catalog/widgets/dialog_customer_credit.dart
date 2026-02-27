import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_dialog_theme.dart';
import '../../../core/widgets/pos_numpad.dart';
import '../../bills/widgets/dialog_payment.dart';
import '../../bills/widgets/dialog_receipt_preview.dart';
import 'dialog_customer_transactions.dart';

class DialogCustomerCredit extends ConsumerStatefulWidget {
  const DialogCustomerCredit({super.key, required this.customer});
  final CustomerModel customer;

  @override
  ConsumerState<DialogCustomerCredit> createState() => _DialogCustomerCreditState();
}

class _DialogCustomerCreditState extends ConsumerState<DialogCustomerCredit> {
  String _amountText = '';
  late CustomerModel _customer;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
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
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final currency = ref.read(currentCurrencyProvider).value;
    final amount = parseMoney(_amountText, currency);
    final note = _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null;
    final l = context.l10n;

    final billRepo = ref.read(billRepositoryProvider);
    final orderRepo = ref.read(orderRepositoryProvider);

    // 1. Create bill for credit top-up
    final register = ref.read(activeRegisterProvider).value;
    final session = ref.read(activeRegisterSessionProvider).value;
    final billResult = await billRepo.createBill(
      companyId: company.id,
      userId: user.id,
      currencyId: company.defaultCurrencyId,
      customerId: _customer.id,
      registerId: register?.id,
      registerSessionId: session?.id,
      isTakeaway: true,
    );
    if (billResult is! Success<BillModel>) return;
    if (!mounted) return;
    final bill = billResult.value;

    // 2. Create order with credit top-up item (no tax)
    final orderNumber = await _nextOrderNumber();
    final itemName = '${l.loyaltyCreditTopUp} – ${_customer.firstName} ${_customer.lastName}';
    await orderRepo.createOrderWithItems(
      companyId: company.id,
      billId: bill.id,
      userId: user.id,
      orderNumber: orderNumber,
      registerId: register?.id,
      items: [
        OrderItemInput(
          itemId: 'credit:${_customer.id}',
          itemName: itemName,
          quantity: 1,
          salePriceAtt: amount,
          saleTaxRateAtt: 0,
          saleTaxAmount: 0,
        ),
      ],
    );

    // 3. Update bill totals
    await billRepo.updateTotals(bill.id);
    final updatedBillResult = await billRepo.getById(bill.id);
    if (updatedBillResult is! Success<BillModel>) return;
    if (!mounted) return;

    // 4. Show payment dialog (skip loyalty — credit purchase is not a sale)
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(
        bill: updatedBillResult.value,
        skipLoyaltyEarn: true,
      ),
    );

    if (paid == true) {
      // 5. Payment succeeded — credit the customer
      final customerRepo = ref.read(customerRepositoryProvider);
      await customerRepo.adjustCredit(
        customerId: _customer.id,
        delta: amount,
        processedByUserId: user.id,
        orderId: bill.id,
        reference: updatedBillResult.value.billNumber,
        note: note,
      );
      // 6. Print receipt
      if (mounted) {
        await showReceiptPrintDialog(context, ref, bill.id);
      }
      if (mounted) {
        _refreshCustomer();
        setState(() => _amountText = '');
        _noteCtrl.clear();
      }
    } else {
      // Payment cancelled — cancel the bill
      await billRepo.cancelBill(bill.id, userId: user.id);
      await billRepo.updateTotals(bill.id);
    }
  }

  Future<String> _nextOrderNumber() async {
    final session = ref.read(activeRegisterSessionProvider).value;
    if (session == null) return 'O-0000';
    final sessionRepo = ref.read(registerSessionRepositoryProvider);
    final registerModel = ref.read(activeRegisterProvider).value;
    final counterResult = await sessionRepo.incrementOrderCounter(session.id);
    if (counterResult is! Success<int>) return 'O-0000';
    final regNum = registerModel?.registerNumber ?? 0;
    return 'O$regNum-${counterResult.value.toString().padLeft(4, '0')}';
  }

  Future<void> _deduct() async {
    if (!_hasAmount) return;
    final currency = ref.read(currentCurrencyProvider).value;
    final deductAmount = parseMoney(_amountText, currency);
    if (deductAmount > _customer.credit) return;
    final user = ref.read(activeUserProvider);
    final repo = ref.read(customerRepositoryProvider);
    final note = _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null;
    final l = context.l10n;
    final result = await repo.adjustCredit(
      customerId: _customer.id,
      delta: -deductAmount,
      processedByUserId: user?.id ?? '',
      reference: l.manualDeduction,
      note: note,
    );
    if (result is Success && mounted) {
      _refreshCustomer();
      setState(() => _amountText = '');
      _noteCtrl.clear();
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
      maxWidth: 420,
      maxHeight: 540,
      expandHeight: true,
      children: [
        // Customer name + balance on one row
        Row(
          children: [
            Expanded(
              child: Text(
                '${_customer.firstName} ${_customer.lastName}',
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              ref.money(_customer.credit),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _customer.credit > 0
                    ? context.appColors.success
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Amount display with label
        _buildAmountDisplay(theme, l),
        const SizedBox(height: 8),
        // Note field
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            hintText: l.loyaltyTransactionNote,
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        // Numpad + action buttons
        _buildNumpadAndActions(theme, l),
      ],
      bottomActions: PosDialogActions(
        expanded: true,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionClose),
          ),
          FilledButton.tonal(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => DialogCustomerTransactions(customerId: _customer.id),
            ),
            child: Text(l.loyaltyTransactionHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(ThemeData theme, AppLocalizations l) {
    final currency = ref.watch(currentCurrencyProvider).value;

    return Row(
      children: [
        Text(l.cashMovementAmount, style: theme.textTheme.titleMedium),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              ref.money(parseMoney(_amountText, currency)),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpadAndActions(ThemeData theme, AppLocalizations l) {
    final currency = ref.watch(currentCurrencyProvider).value;

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Numpad 3×4
          Expanded(
            flex: 5,
            child: PosNumpad(
              expand: true,
              onDigit: _numpadTap,
              onBackspace: _numpadBackspace,
              onClear: _numpadClear,
            ),
          ),
          const SizedBox(width: 12),
          // Top Up / Deduct
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
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
                ),
                const SizedBox(height: PosDialogTheme.numpadLargeGap),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: PosButtonStyles.destructiveFilledWith(context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PosDialogTheme.numpadLargeRadius),
                        ),
                      ),
                      onPressed: _hasAmount && parseMoney(_amountText, currency) <= _customer.credit
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
