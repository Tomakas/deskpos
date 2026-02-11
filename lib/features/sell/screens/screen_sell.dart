import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/layout_item_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../bills/widgets/dialog_customer_search.dart';
import '../../bills/widgets/dialog_payment.dart';

class ScreenSell extends ConsumerStatefulWidget {
  const ScreenSell({super.key, this.billId});
  final String? billId;

  bool get isQuickSale => billId == null;

  @override
  ConsumerState<ScreenSell> createState() => _ScreenSellState();
}

class _CartSeparator {
  const _CartSeparator();
}

class _ScreenSellState extends ConsumerState<ScreenSell> {
  final List<Object> _cart = []; // _CartItem | _CartSeparator
  bool _isSubmitting = false;
  int _currentPage = 0;
  final List<int> _pageStack = [];
  String? _orderNotes;
  String? _customerName;

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
  }

  Future<void> _loadCustomerName() async {
    if (widget.billId == null) return;
    final billResult = await ref.read(billRepositoryProvider).getById(widget.billId!);
    if (billResult is Success<BillModel> && billResult.value.customerId != null) {
      final customer = await ref.read(customerRepositoryProvider).getById(billResult.value.customerId!);
      if (customer != null && mounted) {
        setState(() => _customerName = '${customer.firstName} ${customer.lastName}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final register = ref.watch(activeRegisterProvider);

    return Scaffold(
      body: register.when(
        data: (reg) {
          if (reg == null) return const Center(child: CircularProgressIndicator());
          return Row(
            children: [
              // Left panel - Cart (20%)
              SizedBox(
                width: 280,
                child: _buildCart(context, l),
              ),
              // Right panel - Toolbar + Grid (80%)
              Expanded(
                child: Column(
                  children: [
                    _buildToolbar(context, l),
                    const Divider(height: 1),
                    Expanded(child: _buildGrid(context, ref, reg, l)),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, dynamic l) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _toolbarChip(l.sellSearch, selected: true, onSelected: () => setState(() { _currentPage = 0; _pageStack.clear(); })),
          const SizedBox(width: 8),
          _toolbarChip(l.sellScan, onSelected: null),
          const SizedBox(width: 8),
          _toolbarChip(
            _customerName ?? l.sellCustomer,
            selected: _customerName != null,
            onSelected: widget.billId != null ? () => _selectCustomer(context) : null,
          ),
          const SizedBox(width: 8),
          _toolbarChip(l.sellNote, selected: _orderNotes != null && _orderNotes!.isNotEmpty, onSelected: () => _showOrderNoteDialog(context)),
          const SizedBox(width: 8),
          _toolbarChip(l.sellSeparator, onSelected: _cart.isEmpty ? null : () {
            if (_cart.isNotEmpty && _cart.last is! _CartSeparator) {
              setState(() => _cart.add(const _CartSeparator()));
            }
          }),
          const SizedBox(width: 8),
          _toolbarChip(l.sellActions, onSelected: null),
          if (_currentPage > 0) ...[
            const SizedBox(width: 8),
            _toolbarChip(l.sellBackToCategories, selected: true, onSelected: () {
              setState(() {
                if (_pageStack.isNotEmpty) {
                  _currentPage = _pageStack.removeLast();
                } else {
                  _currentPage = 0;
                }
              });
            }),
          ],
        ],
      ),
    );
  }

  Widget _toolbarChip(String label, {bool selected = false, VoidCallback? onSelected}) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: FilterChip(
          showCheckmark: false,
          label: SizedBox(
            width: double.infinity,
            child: Text(label, textAlign: TextAlign.center),
          ),
          selected: selected,
          onSelected: onSelected != null ? (_) => onSelected() : null,
        ),
      ),
    );
  }

  Widget _buildCart(BuildContext context, dynamic l) {
    final theme = Theme.of(context);
    int total = 0;
    for (final entry in _cart) {
      if (entry is _CartItem) {
        total += (entry.unitPrice * entry.quantity).round();
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(l.sellCartSummary, style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 1),
          // Items
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Text(
                      l.sellCartEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final entry = _cart[index];
                      if (entry is _CartSeparator) {
                        return InkWell(
                          onTap: () => setState(() => _cart.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(l.sellSeparatorLabel, style: theme.textTheme.bodySmall),
                              ),
                              const Expanded(child: Divider()),
                            ]),
                          ),
                        );
                      }
                      final item = entry as _CartItem;
                      return ListTile(
                        dense: true,
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.sellQuantity(item.quantity.toStringAsFixed(
                                item.quantity == item.quantity.roundToDouble() ? 0 : 1,
                              )),
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Text(
                                item.notes!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text('${(item.unitPrice * item.quantity).round() ~/ 100} Kč'),
                        onTap: () => _showItemNoteDialog(context, item),
                        onLongPress: () => setState(() {
                          item.quantity--;
                          if (item.quantity <= 0) _cart.removeAt(index);
                        }),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          // Total
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.sellTotal, style: theme.textTheme.titleMedium),
                Text(
                  '${total ~/ 100} Kč',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          // Actions
          if (widget.isQuickSale) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                        onPressed: () => context.pop(),
                        child: Text(l.sellCancelOrder),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _cart.isEmpty
                            ? null
                            : () => _convertToBill(context, ref),
                        child: Text(l.sellSaveToBill),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _cart.isEmpty
                      ? null
                      : () => _submitQuickSale(context, ref),
                  child: Text(l.paymentConfirm),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                        onPressed: () => context.pop(),
                        child: Text(l.sellCancelOrder),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: _cart.isEmpty
                            ? null
                            : () => _submitOrder(context, ref),
                        child: Text(l.sellSubmitOrder),
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

  Widget _buildGrid(BuildContext context, WidgetRef ref, RegisterModel register, dynamic l) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<LayoutItemModel>>(
      stream: ref.watch(layoutItemRepositoryProvider).watchByRegister(register.id, page: _currentPage),
      builder: (context, snap) {
        final layoutItems = snap.data ?? [];
        return _buildGridContent(
          context, ref, register, layoutItems, company.id, l,
        );
      },
    );
  }

  Widget _buildGridContent(
    BuildContext context,
    WidgetRef ref,
    RegisterModel register,
    List<LayoutItemModel> layoutItems,
    String companyId,
    dynamic l,
  ) {
    final rows = register.gridRows;
    final cols = register.gridCols;

    return StreamBuilder<List<ItemModel>>(
      stream: ref.watch(itemRepositoryProvider).watchAll(companyId),
      builder: (context, itemSnap) {
        final allItems = itemSnap.data ?? [];
        return StreamBuilder<List<CategoryModel>>(
          stream: ref.watch(categoryRepositoryProvider).watchAll(companyId),
          builder: (context, catSnap) {
            final allCategories = catSnap.data ?? [];
            return LayoutBuilder(
              builder: (context, constraints) {
                final cellW = constraints.maxWidth / cols;
                final cellH = constraints.maxHeight / rows;

                return Stack(
                  children: [
                    for (int r = 0; r < rows; r++)
                      for (int c = 0; c < cols; c++)
                        Positioned(
                          left: c * cellW,
                          top: r * cellH,
                          width: cellW,
                          height: cellH,
                          child: _buildCell(
                            context, ref, layoutItems, allItems, allCategories,
                            r, c, register, companyId, l,
                          ),
                        ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    WidgetRef ref,
    List<LayoutItemModel> layoutItems,
    List<ItemModel> allItems,
    List<CategoryModel> allCategories,
    int row,
    int col,
    RegisterModel register,
    String companyId,
    dynamic l,
  ) {
    final layoutItem = layoutItems.where((li) => li.gridRow == row && li.gridCol == col).firstOrNull;

    if (layoutItem == null) {
      return const SizedBox.shrink();
    }

    if (layoutItem.type == LayoutItemType.category) {
      final cat = allCategories.where((c) => c.id == layoutItem.categoryId).firstOrNull;
      return _ItemButton(
        label: layoutItem.label ?? cat?.name ?? '?',
        color: layoutItem.color != null
            ? Color(int.parse(layoutItem.color!.replaceFirst('#', 'FF'), radix: 16))
            : Theme.of(context).colorScheme.secondaryContainer,
        onTap: () => _onCategoryTap(register.id, layoutItem),
      );
    }

    final item = allItems.where((i) => i.id == layoutItem.itemId).firstOrNull;
    if (item == null) return const SizedBox.shrink();

    return _ItemButton(
      label: layoutItem.label ?? item.name,
      color: layoutItem.color != null
          ? Color(int.parse(layoutItem.color!.replaceFirst('#', 'FF'), radix: 16))
          : Theme.of(context).colorScheme.primaryContainer,
      onTap: item.isSellable ? () => _addToCart(ref, item, companyId) : null,
    );
  }

  Future<void> _showItemNoteDialog(BuildContext context, _CartItem item) async {
    final controller = TextEditingController(text: item.notes);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.name),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.sellNote,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              setState(() => item.quantity++);
              Navigator.pop(context);
            },
            child: const Text('+1'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => item.notes = result.isEmpty ? null : result);
    }
  }

  Future<void> _selectCustomer(BuildContext context) async {
    if (widget.billId == null) return;
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: _customerName != null,
    );
    if (result == null) return;
    if (result is CustomerModel) {
      await ref.read(billRepositoryProvider).updateCustomer(widget.billId!, result.id);
      if (mounted) {
        setState(() => _customerName = '${result.firstName} ${result.lastName}');
      }
    } else {
      // _RemoveCustomer sentinel
      await ref.read(billRepositoryProvider).updateCustomer(widget.billId!, null);
      if (mounted) {
        setState(() => _customerName = null);
      }
    }
  }

  Future<void> _showOrderNoteDialog(BuildContext context) async {
    final controller = TextEditingController(text: _orderNotes);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.sellNote),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.sellNote,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _orderNotes = result.isEmpty ? null : result);
    }
  }

  Future<void> _onCategoryTap(String registerId, LayoutItemModel layoutItem) async {
    if (_currentPage > 0) {
      // On sub-page, category marker navigates back
      setState(() {
        if (_pageStack.isNotEmpty) {
          _currentPage = _pageStack.removeLast();
        } else {
          _currentPage = 0;
        }
      });
      return;
    }

    // On root page, navigate to sub-page
    final page = await ref
        .read(layoutItemRepositoryProvider)
        .getPageForCategory(registerId, layoutItem.categoryId!);
    if (page != null && mounted) {
      setState(() {
        _pageStack.add(_currentPage);
        _currentPage = page;
      });
    }
  }

  void _addToCart(WidgetRef ref, ItemModel item, String companyId) {
    setState(() {
      // Find last separator index
      int lastSepIdx = -1;
      for (int i = _cart.length - 1; i >= 0; i--) {
        if (_cart[i] is _CartSeparator) { lastSepIdx = i; break; }
      }
      // Search only in current group
      final existing = _cart.sublist(lastSepIdx + 1)
          .whereType<_CartItem>()
          .where((c) => c.itemId == item.id)
          .firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _cart.add(_CartItem(
          itemId: item.id,
          name: item.name,
          unitPrice: item.unitPrice,
          saleTaxRateId: item.saleTaxRateId,
        ));
      }
    });
  }

  Future<List<OrderItemInput>> _buildOrderItemsFromGroup(WidgetRef ref, List<_CartItem> group) async {
    final taxRateRepo = ref.read(taxRateRepositoryProvider);
    final orderItems = <OrderItemInput>[];
    for (final cartItem in group) {
      int taxRateBps = 0;
      int taxAmount = 0;

      if (cartItem.saleTaxRateId != null) {
        final taxRate = await taxRateRepo.getById(cartItem.saleTaxRateId!);
        if (taxRate != null) {
          taxRateBps = taxRate.rate;
          taxAmount = (cartItem.unitPrice * taxRateBps / (10000 + taxRateBps)).round();
        }
      }

      orderItems.add(OrderItemInput(
        itemId: cartItem.itemId,
        itemName: cartItem.name,
        quantity: cartItem.quantity,
        salePriceAtt: cartItem.unitPrice,
        saleTaxRateAtt: taxRateBps,
        saleTaxAmount: taxAmount,
        notes: cartItem.notes,
      ));
    }
    return orderItems;
  }

  /// Splits the cart by separators into groups of cart items.
  List<List<_CartItem>> _splitCartIntoGroups() {
    final groups = <List<_CartItem>>[];
    var current = <_CartItem>[];
    for (final entry in _cart) {
      if (entry is _CartSeparator) {
        if (current.isNotEmpty) groups.add(current);
        current = <_CartItem>[];
      } else {
        current.add(entry as _CartItem);
      }
    }
    if (current.isNotEmpty) groups.add(current);
    return groups;
  }

  Future<String> _nextOrderNumber(WidgetRef ref) async {
    final session = ref.read(activeRegisterSessionProvider).value;
    if (session == null) return 'O-0000';
    final sessionRepo = ref.read(registerSessionRepositoryProvider);
    final counterResult = await sessionRepo.incrementOrderCounter(session.id);
    if (counterResult is! Success<int>) return 'O-0000';
    return 'O-${counterResult.value.toString().padLeft(4, '0')}';
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final groups = _splitCartIntoGroups();
      if (groups.isEmpty) return;

      final orderRepo = ref.read(orderRepositoryProvider);
      bool anySuccess = false;

      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        final result = await orderRepo.createOrderWithItems(
          companyId: company.id,
          billId: widget.billId!,
          userId: user.id,
          orderNumber: orderNumber,
          items: orderItems,
          orderNotes: i == 0 ? _orderNotes : null,
        );
        if (result is Success) anySuccess = true;
      }

      if (anySuccess) {
        await ref.read(billRepositoryProvider).updateTotals(widget.billId!);
        if (!context.mounted) return;
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitQuickSale(BuildContext context, WidgetRef ref) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final billRepo = ref.read(billRepositoryProvider);

    // Create bill
    final billResult = await billRepo.createBill(
      companyId: company.id,
      userId: user.id,
      currencyId: company.defaultCurrencyId,
      isTakeaway: true,
    );
    if (billResult is! Success<BillModel>) return;
    final bill = billResult.value;

    // Create order(s)
    final groups = _splitCartIntoGroups();
    final orderRepo = ref.read(orderRepositoryProvider);
    for (var i = 0; i < groups.length; i++) {
      final orderNumber = await _nextOrderNumber(ref);
      final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
      await orderRepo.createOrderWithItems(
        companyId: company.id,
        billId: bill.id,
        userId: user.id,
        orderNumber: orderNumber,
        items: orderItems,
        orderNotes: i == 0 ? _orderNotes : null,
      );
    }
    await billRepo.updateTotals(bill.id);

    if (!context.mounted) return;

    // Fetch updated bill with totals
    final updatedBillResult = await billRepo.getById(bill.id);
    if (updatedBillResult is! Success<BillModel>) return;

    if (!context.mounted) return;

    // Show payment dialog
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(bill: updatedBillResult.value),
    );

    if (paid == true && context.mounted) {
      context.pop();
    } else {
      // User cancelled payment — cancel the bill
      await billRepo.cancelBill(bill.id);
      await billRepo.updateTotals(bill.id);
    }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _convertToBill(BuildContext context, WidgetRef ref) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);

      // Create regular bill on default section, no table
      final billResult = await billRepo.createBill(
        companyId: company.id,
        userId: user.id,
        currencyId: company.defaultCurrencyId,
        isTakeaway: false,
      );
      if (billResult is! Success<BillModel>) return;
      final bill = billResult.value;

      // Create order(s) with cart items
      final groups = _splitCartIntoGroups();
      final orderRepo = ref.read(orderRepositoryProvider);
      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        await orderRepo.createOrderWithItems(
          companyId: company.id,
          billId: bill.id,
          userId: user.id,
          orderNumber: orderNumber,
          items: orderItems,
          orderNotes: i == 0 ? _orderNotes : null,
        );
      }
      await billRepo.updateTotals(bill.id);

      if (!context.mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _CartItem {
  _CartItem({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    this.saleTaxRateId,
  });

  final String itemId;
  final String name;
  final int unitPrice;
  final String? saleTaxRateId;
  double quantity = 1;
  String? notes;
}

class _ItemButton extends StatelessWidget {
  const _ItemButton({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.1, 0.9, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
