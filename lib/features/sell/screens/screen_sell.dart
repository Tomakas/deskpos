import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/layout_item_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../bills/widgets/dialog_payment.dart';

class ScreenSell extends ConsumerStatefulWidget {
  const ScreenSell({super.key, this.billId});
  final String? billId;

  bool get isQuickSale => billId == null;

  @override
  ConsumerState<ScreenSell> createState() => _ScreenSellState();
}

class _ScreenSellState extends ConsumerState<ScreenSell> {
  final List<_CartItem> _cart = [];
  bool _editMode = false;
  String? _categoryFilterId;
  String? _orderNotes;

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
        error: (_, _) => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, dynamic l) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _toolbarChip(l.sellSearch, selected: true, onSelected: () => setState(() => _categoryFilterId = null)),
          const SizedBox(width: 8),
          _toolbarChip(l.sellScan, onSelected: null),
          const SizedBox(width: 8),
          _toolbarChip(l.sellCustomer, onSelected: null),
          const SizedBox(width: 8),
          _toolbarChip(l.sellNote, selected: _orderNotes != null && _orderNotes!.isNotEmpty, onSelected: () => _showOrderNoteDialog(context)),
          const SizedBox(width: 8),
          _toolbarChip(l.sellActions, onSelected: null),
          const SizedBox(width: 8),
          if (_categoryFilterId != null && !_editMode) ...[
            _toolbarChip(l.sellBackToCategories, selected: true, onSelected: () => setState(() => _categoryFilterId = null)),
            const SizedBox(width: 8),
          ],
          _toolbarChip(_editMode ? l.sellExitEdit : l.sellEditGrid, selected: _editMode, onSelected: () => setState(() => _editMode = !_editMode)),
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
    for (final item in _cart) {
      total += (item.unitPrice * item.quantity).round();
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
                      final item = _cart[index];
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
                          : widget.isQuickSale
                              ? () => _submitQuickSale(context, ref)
                              : () => _submitOrder(context, ref),
                      child: Text(widget.isQuickSale ? l.paymentConfirm : l.sellSubmitOrder),
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
      stream: ref.watch(layoutItemRepositoryProvider).watchByRegister(register.id),
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
    // If filtering by category, show items of that category instead of grid
    if (_categoryFilterId != null && !_editMode) {
      return StreamBuilder<List<ItemModel>>(
        stream: ref.watch(itemRepositoryProvider).watchAll(companyId),
        builder: (context, snap) {
          final items = (snap.data ?? [])
              .where((i) => i.categoryId == _categoryFilterId && i.isActive && i.isSellable)
              .toList();
          return _buildItemList(context, ref, items, companyId);
        },
      );
    }

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

  Widget _buildItemList(BuildContext context, WidgetRef ref, List<ItemModel> items, String companyId) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemButton(
          label: item.name,
          color: Theme.of(context).colorScheme.primaryContainer,
          onTap: () => _addToCart(ref, item, companyId),
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
    final layoutItem = layoutItems.where((li) => li.gridRow == row && li.gridCol == col && li.page == 0).firstOrNull;

    if (_editMode) {
      return _EditableCell(
        layoutItem: layoutItem,
        allItems: allItems,
        allCategories: allCategories,
        row: row,
        col: col,
        registerId: register.id,
        companyId: companyId,
        l: l,
        onAssigned: () => setState(() {}),
      );
    }

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
        onTap: () => setState(() => _categoryFilterId = layoutItem.categoryId),
      );
    }

    final item = allItems.where((i) => i.id == layoutItem.itemId).firstOrNull;
    if (item == null) return const SizedBox.shrink();

    return _ItemButton(
      label: layoutItem.label ?? item.name,
      color: layoutItem.color != null
          ? Color(int.parse(layoutItem.color!.replaceFirst('#', 'FF'), radix: 16))
          : Theme.of(context).colorScheme.primaryContainer,
      onTap: () => _addToCart(ref, item, companyId),
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

  void _addToCart(WidgetRef ref, ItemModel item, String companyId) {
    setState(() {
      final existing = _cart.where((c) => c.itemId == item.id).firstOrNull;
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

  Future<List<OrderItemInput>> _buildOrderItems(WidgetRef ref) async {
    final taxRateRepo = ref.read(taxRateRepositoryProvider);
    final orderItems = <OrderItemInput>[];
    for (final cartItem in _cart) {
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

  Future<String> _nextOrderNumber(WidgetRef ref) async {
    final session = ref.read(activeRegisterSessionProvider).value;
    if (session == null) return 'O-0000';
    final sessionRepo = ref.read(registerSessionRepositoryProvider);
    final counterResult = await sessionRepo.incrementOrderCounter(session.id);
    if (counterResult is! Success<int>) return 'O-0000';
    return 'O-${counterResult.value.toString().padLeft(4, '0')}';
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final orderNumber = await _nextOrderNumber(ref);
    final orderItems = await _buildOrderItems(ref);

    final orderRepo = ref.read(orderRepositoryProvider);
    final result = await orderRepo.createOrderWithItems(
      companyId: company.id,
      billId: widget.billId!,
      userId: user.id,
      orderNumber: orderNumber,
      items: orderItems,
      orderNotes: _orderNotes,
    );

    if (result is Success) {
      await ref.read(billRepositoryProvider).updateTotals(widget.billId!);
      if (mounted) context.pop();
    }
  }

  Future<void> _submitQuickSale(BuildContext context, WidgetRef ref) async {
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

    // Create order
    final orderNumber = await _nextOrderNumber(ref);
    final orderItems = await _buildOrderItems(ref);
    final orderRepo = ref.read(orderRepositoryProvider);
    await orderRepo.createOrderWithItems(
      companyId: company.id,
      billId: bill.id,
      userId: user.id,
      orderNumber: orderNumber,
      items: orderItems,
      orderNotes: _orderNotes,
    );
    await billRepo.updateTotals(bill.id);

    if (!mounted) return;

    // Fetch updated bill with totals
    final updatedBillResult = await billRepo.getById(bill.id);
    if (updatedBillResult is! Success<BillModel>) return;

    // Show payment dialog
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(bill: updatedBillResult.value),
    );

    if (paid == true && mounted) {
      context.pop();
    } else {
      // User cancelled payment — cancel the bill
      await billRepo.cancelBill(bill.id);
      await billRepo.updateTotals(bill.id);
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
  const _ItemButton({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

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

class _EditableCell extends ConsumerWidget {
  const _EditableCell({
    required this.layoutItem,
    required this.allItems,
    required this.allCategories,
    required this.row,
    required this.col,
    required this.registerId,
    required this.companyId,
    required this.l,
    required this.onAssigned,
  });

  final LayoutItemModel? layoutItem;
  final List<ItemModel> allItems;
  final List<CategoryModel> allCategories;
  final int row;
  final int col;
  final String registerId;
  final String companyId;
  final dynamic l;
  final VoidCallback onAssigned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String label = l.sellEmptySlot;
    Color color = Theme.of(context).colorScheme.surfaceContainerHighest;

    if (layoutItem != null) {
      if (layoutItem!.type == LayoutItemType.item) {
        final item = allItems.where((i) => i.id == layoutItem!.itemId).firstOrNull;
        label = layoutItem!.label ?? item?.name ?? '?';
        color = Theme.of(context).colorScheme.primaryContainer;
      } else {
        final cat = allCategories.where((c) => c.id == layoutItem!.categoryId).firstOrNull;
        label = layoutItem!.label ?? cat?.name ?? '?';
        color = Theme.of(context).colorScheme.secondaryContainer;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _showEditDialog(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.edit, size: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_GridEditResult>(
      context: context,
      builder: (_) => _GridEditDialog(
        allItems: allItems,
        allCategories: allCategories,
        l: l,
      ),
    );

    if (result == null) return;
    final repo = ref.read(layoutItemRepositoryProvider);

    if (result.clear) {
      await repo.clearCell(registerId: registerId, page: 0, gridRow: row, gridCol: col);
    } else {
      await repo.setCell(
        companyId: companyId,
        registerId: registerId,
        page: 0,
        gridRow: row,
        gridCol: col,
        type: result.type!,
        itemId: result.itemId,
        categoryId: result.categoryId,
      );
    }
    onAssigned();
  }
}

class _GridEditResult {
  _GridEditResult({this.type, this.itemId, this.categoryId, this.clear = false});
  final LayoutItemType? type;
  final String? itemId;
  final String? categoryId;
  final bool clear;
}

class _GridEditDialog extends StatelessWidget {
  const _GridEditDialog({
    required this.allItems,
    required this.allCategories,
    required this.l,
  });

  final List<ItemModel> allItems;
  final List<CategoryModel> allCategories;
  final dynamic l;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l.gridEditorTitle),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => _selectItem(context),
                child: Text(l.gridEditorItem),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => _selectCategory(context),
                child: Text(l.gridEditorCategory),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(context, _GridEditResult(clear: true)),
                child: Text(l.gridEditorClear),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }

  Future<void> _selectItem(BuildContext context) async {
    final sellableItems = allItems.where((i) => i.isActive && i.isSellable).toList();
    final selected = await showDialog<ItemModel>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.gridEditorSelectItem),
        content: SizedBox(
          width: 350,
          height: 400,
          child: ListView.builder(
            itemCount: sellableItems.length,
            itemBuilder: (context, index) {
              final item = sellableItems[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.unitPrice ~/ 100} Kč'),
                onTap: () => Navigator.pop(context, item),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      Navigator.pop(
        context,
        _GridEditResult(
          type: LayoutItemType.item,
          itemId: selected.id,
        ),
      );
    }
  }

  Future<void> _selectCategory(BuildContext context) async {
    final activeCategories = allCategories.where((c) => c.isActive).toList();
    final selected = await showDialog<CategoryModel>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.gridEditorSelectCategory),
        content: SizedBox(
          width: 350,
          height: 400,
          child: ListView.builder(
            itemCount: activeCategories.length,
            itemBuilder: (context, index) {
              final cat = activeCategories[index];
              return ListTile(
                title: Text(cat.name),
                onTap: () => Navigator.pop(context, cat),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      Navigator.pop(
        context,
        _GridEditResult(
          type: LayoutItemType.category,
          categoryId: selected.id,
        ),
      );
    }
  }
}

