import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/enums/voucher_discount_scope.dart';
import '../../../core/data/enums/voucher_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../bills/widgets/dialog_payment.dart';

class DialogVoucherCreate extends ConsumerStatefulWidget {
  const DialogVoucherCreate({super.key});

  @override
  ConsumerState<DialogVoucherCreate> createState() => _DialogVoucherCreateState();
}

class _DialogVoucherCreateState extends ConsumerState<DialogVoucherCreate> {
  VoucherType _type = VoucherType.gift;
  VoucherDiscountScope _scope = VoucherDiscountScope.bill;
  DiscountType _discountType = DiscountType.absolute;
  String _valueInput = '';
  int _maxUses = 1;
  String? _note;
  DateTime? _expiresAt;

  int get _rawValue {
    final parsed = double.tryParse(_valueInput) ?? 0;
    return (parsed * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Dialog(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.voucherCreate, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              // Type selection
              Row(
                children: [
                  for (final entry in {
                    VoucherType.gift: l.voucherTypeGift,
                    VoucherType.deposit: l.voucherTypeDeposit,
                    VoucherType.discount: l.voucherTypeDiscount,
                  }.entries) ...[
                    if (entry.key != VoucherType.gift) const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(entry.value, textAlign: TextAlign.center),
                          ),
                          selected: _type == entry.key,
                          onSelected: (_) => setState(() => _type = entry.key),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Discount-specific: scope + discount type
              if (_type == VoucherType.discount) ...[
                Row(
                  children: [
                    for (final entry in {
                      VoucherDiscountScope.bill: l.voucherScopeBill,
                      VoucherDiscountScope.product: l.voucherScopeProduct,
                      VoucherDiscountScope.category: l.voucherScopeCategory,
                    }.entries) ...[
                      if (entry.key != VoucherDiscountScope.bill) const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: FilterChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(entry.value, textAlign: TextAlign.center),
                            ),
                            selected: _scope == entry.key,
                            onSelected: (_) => setState(() => _scope = entry.key),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // Value input
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _valueInput.isEmpty ? '0' : _valueInput,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),
              // Numpad
              _buildNumpad(),
              const SizedBox(height: 12),
              // Max uses (discount only)
              if (_type == VoucherType.discount) ...[
                Row(
                  children: [
                    Text(l.voucherMaxUses),
                    const Spacer(),
                    IconButton(
                      onPressed: _maxUses > 1 ? () => setState(() => _maxUses--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$_maxUses', style: theme.textTheme.titleMedium),
                    IconButton(
                      onPressed: () => setState(() => _maxUses++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // Expiration
              Row(
                children: [
                  Text(l.voucherExpires),
                  const Spacer(),
                  if (_expiresAt != null)
                    TextButton(
                      onPressed: () => setState(() => _expiresAt = null),
                      child: const Text('X'),
                    ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) setState(() => _expiresAt = date);
                    },
                    child: Text(_expiresAt != null
                        ? '${_expiresAt!.day}.${_expiresAt!.month}.${_expiresAt!.year}'
                        : '-'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Actions
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
                  const SizedBox(width: 12),
                  if (_type == VoucherType.discount)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _rawValue > 0 ? _createDiscountVoucher : null,
                          child: Text(l.voucherCreate),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _rawValue > 0 ? () => _confirmAbsolute() : null,
                          child: Text(
                            _rawValue > 0
                                ? '${l.voucherSell} ${_rawValue ~/ 100} Kč'
                                : l.voucherSell,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAbsolute() async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final voucherRepo = ref.read(voucherRepositoryProvider);
    final billRepo = ref.read(billRepositoryProvider);
    final orderRepo = ref.read(orderRepositoryProvider);
    final l = context.l10n;

    // 1. Generate code (no DB write yet)
    final code = voucherRepo.generateCode(_type);

    // 2. Create bill for voucher sale
    final billResult = await billRepo.createBill(
      companyId: company.id,
      userId: user.id,
      currencyId: company.defaultCurrencyId,
      isTakeaway: true,
    );
    if (billResult is! Success<BillModel>) return;
    final bill = billResult.value;

    // 3. Create order with voucher item (noTax: rate=0, taxAmount=0)
    final orderNumber = await _nextOrderNumber();
    final itemName = _type == VoucherType.gift
        ? '${l.voucherTypeGift} voucher $code'
        : '${l.voucherTypeDeposit} voucher $code';
    await orderRepo.createOrderWithItems(
      companyId: company.id,
      billId: bill.id,
      userId: user.id,
      orderNumber: orderNumber,
      items: [
        OrderItemInput(
          itemId: 'voucher:$code',
          itemName: itemName,
          quantity: 1,
          salePriceAtt: _rawValue,
          saleTaxRateAtt: 0,
          saleTaxAmount: 0,
        ),
      ],
    );

    // 4. Update bill totals and fetch updated bill
    await billRepo.updateTotals(bill.id);
    final updatedBillResult = await billRepo.getById(bill.id);
    if (updatedBillResult is! Success<BillModel>) return;
    if (!mounted) return;

    // 5. Show payment dialog
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(bill: updatedBillResult.value),
    );

    if (paid == true) {
      // 6. Payment succeeded — create voucher with sourceBillId
      final now = DateTime.now();
      final model = VoucherModel(
        id: const Uuid().v7(),
        companyId: company.id,
        code: code,
        type: _type,
        status: VoucherStatus.active,
        value: _rawValue,
        maxUses: 1,
        usedCount: 0,
        expiresAt: _expiresAt,
        note: _note,
        sourceBillId: bill.id,
        createdAt: now,
        updatedAt: now,
      );
      await voucherRepo.create(model);
      if (mounted) Navigator.pop(context, model);
    } else {
      // Payment cancelled — cancel the bill
      await billRepo.cancelBill(bill.id);
      await billRepo.updateTotals(bill.id);
    }
  }

  Future<String> _nextOrderNumber() async {
    final session = ref.read(activeRegisterSessionProvider).value;
    if (session == null) return 'O-0000';
    final sessionRepo = ref.read(registerSessionRepositoryProvider);
    final counterResult = await sessionRepo.incrementOrderCounter(session.id);
    if (counterResult is! Success<int>) return 'O-0000';
    return 'O-${counterResult.value.toString().padLeft(4, '0')}';
  }

  Future<void> _createDiscountVoucher() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;
    final repo = ref.read(voucherRepositoryProvider);
    final now = DateTime.now();
    final code = repo.generateCode(VoucherType.discount);

    final model = VoucherModel(
      id: const Uuid().v7(),
      companyId: company.id,
      code: code,
      type: VoucherType.discount,
      status: VoucherStatus.active,
      value: _rawValue,
      discountType: _discountType,
      discountScope: _scope,
      maxUses: _maxUses,
      usedCount: 0,
      expiresAt: _expiresAt,
      note: _note,
      createdAt: now,
      updatedAt: now,
    );

    final result = await repo.create(model);
    if (result is Success && mounted) {
      Navigator.pop(context, model);
    }
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
            if (_type == VoucherType.discount) ...[
              _numpadButton(
                child: Text(_discountType == DiscountType.absolute ? '%' : 'Kč',
                    style: const TextStyle(fontSize: 20)),
                onTap: () => setState(() => _discountType =
                    _discountType == DiscountType.absolute
                        ? DiscountType.percent
                        : DiscountType.absolute),
              ),
            ] else ...[
              _numpadButton(
                child: const Text('.', style: TextStyle(fontSize: 20)),
                onTap: () {
                  if (!_valueInput.contains('.')) {
                    setState(
                        () => _valueInput = _valueInput.isEmpty ? '0.' : '$_valueInput.');
                  }
                },
              ),
            ],
            const SizedBox(width: 4),
            _numpadButton(
              child: const Text('0', style: TextStyle(fontSize: 20)),
              onTap: () => setState(() => _valueInput += '0'),
            ),
            const SizedBox(width: 4),
            _numpadButton(
              child: const Icon(Icons.backspace_outlined, size: 20),
              onTap: () {
                if (_valueInput.isNotEmpty) {
                  setState(() => _valueInput = _valueInput.substring(0, _valueInput.length - 1));
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
            onTap: () => setState(() => _valueInput += digits[i]),
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
