import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/enums/voucher_discount_scope.dart';
import '../../../core/data/enums/voucher_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_numpad.dart';
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
  String? _selectedItemId;
  String? _selectedItemName;
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  int get _rawValue {
    final parsed = double.tryParse(_valueInput) ?? 0;
    return (parsed * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.voucherCreate,
      maxWidth: 400,
      padding: const EdgeInsets.all(20),
      children: [
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
                      onSelected: (_) => setState(() {
                    _scope = entry.key;
                    _selectedItemId = null;
                    _selectedItemName = null;
                    _selectedCategoryId = null;
                    _selectedCategoryName = null;
                  }),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_scope == VoucherDiscountScope.product) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.search, size: 20),
                label: Text(_selectedItemName ?? l.gridEditorSelectItem),
                onPressed: () => _selectItem(context),
              ),
            ),
          ],
          if (_scope == VoucherDiscountScope.category) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.category, size: 20),
                label: Text(_selectedCategoryName ?? l.gridEditorSelectCategory),
                onPressed: () => _selectCategory(context),
              ),
            ),
          ],
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
        PosNumpad(
          size: PosNumpadSize.compact,
          onDigit: (d) => setState(() => _valueInput += d),
          onBackspace: () {
            if (_valueInput.isNotEmpty) {
              setState(() => _valueInput = _valueInput.substring(0, _valueInput.length - 1));
            }
          },
          bottomLeftChild: _type == VoucherType.discount
              ? Text(
                  _discountType == DiscountType.absolute ? '%' : (ref.currencySymbol),
                  style: const TextStyle(fontSize: 20),
                )
              : const Text('.', style: TextStyle(fontSize: 20)),
          onBottomLeft: _type == VoucherType.discount
              ? () => setState(() => _discountType =
                  _discountType == DiscountType.absolute
                      ? DiscountType.percent
                      : DiscountType.absolute)
              : () {
                  if (!_valueInput.contains('.')) {
                    setState(
                        () => _valueInput = _valueInput.isEmpty ? '0.' : '$_valueInput.');
                  }
                },
        ),
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
                  ? ref.fmtDate(_expiresAt!)
                  : '-'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Actions
        PosDialogActions(
          height: 48,
          spacing: 12,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            if (_type == VoucherType.discount)
              FilledButton(
                onPressed: _rawValue > 0 && _isScopeValid ? _createDiscountVoucher : null,
                child: Text(l.voucherCreate),
              )
            else
              FilledButton(
                onPressed: _rawValue > 0 ? () => _confirmAbsolute() : null,
                child: Text(
                  _rawValue > 0
                      ? '${l.voucherSell} ${ref.money(_rawValue)}'
                      : l.voucherSell,
                ),
              ),
          ],
        ),
      ],
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
    final register = ref.read(activeRegisterProvider).value;
    final session = ref.read(activeRegisterSessionProvider).value;
    final billResult = await billRepo.createBill(
      companyId: company.id,
      userId: user.id,
      currencyId: company.defaultCurrencyId,
      registerId: register?.id,
      registerSessionId: session?.id,
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
      registerId: register?.id,
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
    final registerModel = ref.read(activeRegisterProvider).value;
    final regNum = registerModel?.registerNumber ?? 0;
    return 'O$regNum-${counterResult.value.toString().padLeft(4, '0')}';
  }

  bool get _isScopeValid {
    if (_scope == VoucherDiscountScope.product) return _selectedItemId != null;
    if (_scope == VoucherDiscountScope.category) return _selectedCategoryId != null;
    return true;
  }

  Future<void> _selectItem(BuildContext context) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;
    final selected = await showDialog<ItemModel>(
      context: context,
      builder: (_) => _ItemSearchDialog(companyId: company.id),
    );
    if (selected != null) {
      setState(() {
        _selectedItemId = selected.id;
        _selectedItemName = selected.name;
      });
    }
  }

  Future<void> _selectCategory(BuildContext context) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;
    final selected = await showDialog<CategoryModel>(
      context: context,
      builder: (_) => _CategorySearchDialog(companyId: company.id),
    );
    if (selected != null) {
      setState(() {
        _selectedCategoryId = selected.id;
        _selectedCategoryName = selected.name;
      });
    }
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
      itemId: _selectedItemId,
      categoryId: _selectedCategoryId,
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
}

class _ItemSearchDialog extends ConsumerStatefulWidget {
  const _ItemSearchDialog({required this.companyId});
  final String companyId;

  @override
  ConsumerState<_ItemSearchDialog> createState() => _ItemSearchDialogState();
}

class _ItemSearchDialogState extends ConsumerState<_ItemSearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.gridEditorSelectItem),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => setState(() => _query = normalizeSearch(v)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: ref.watch(itemRepositoryProvider).watchAll(widget.companyId),
                builder: (context, snap) {
                  final items = (snap.data ?? []).where((item) {
                    if (!item.isSellable || !item.isActive) return false;
                    if (_query.isEmpty) return true;
                    return normalizeSearch(item.name).contains(_query) ||
                        normalizeSearch(item.sku ?? '').contains(_query);
                  }).toList();
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: item.sku != null ? Text(item.sku!) : null,
                        trailing: Text(ref.money(item.unitPrice)),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySearchDialog extends ConsumerStatefulWidget {
  const _CategorySearchDialog({required this.companyId});
  final String companyId;

  @override
  ConsumerState<_CategorySearchDialog> createState() => _CategorySearchDialogState();
}

class _CategorySearchDialogState extends ConsumerState<_CategorySearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.gridEditorSelectCategory),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => setState(() => _query = normalizeSearch(v)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<CategoryModel>>(
                stream: ref.watch(categoryRepositoryProvider).watchAll(widget.companyId),
                builder: (context, snap) {
                  final categories = (snap.data ?? []).where((c) {
                    if (!c.isActive) return false;
                    if (_query.isEmpty) return true;
                    return normalizeSearch(c.name).contains(_query);
                  }).toList();
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final cat = categories[i];
                      return ListTile(
                        title: Text(cat.name),
                        onTap: () => Navigator.pop(context, cat),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
