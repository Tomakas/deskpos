import 'dart:async';
import 'dart:convert';

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
import '../../../core/widgets/pos_color_palette.dart';
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
  String? _customerId;
  String? _customerName;
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  bool _isSearchOpen = false;
  Timer? _displaySyncTimer;

  bool _didSetActiveBill = false;
  String? _quickBillId;
  String? _cachedRegisterId;

  // Cached references for use in dispose() where ref is no longer available.
  late final _registerRepo = ref.read(registerRepositoryProvider);
  late final _billRepo = ref.read(billRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    if (widget.billId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _setActiveBill(widget.billId!));
    } else if (widget.isQuickSale) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _createQuickBill());
    }
  }

  @override
  void dispose() {
    _displaySyncTimer?.cancel();
    _clearActiveBill();
    _clearDisplayCart();
    if (_quickBillId != null) {
      _billRepo.cancelBill(_quickBillId!);
    }
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setActiveBill(String billId) {
    final register = ref.read(activeRegisterProvider).value;
    if (register != null) {
      _cachedRegisterId = register.id;
      ref.read(registerRepositoryProvider).setActiveBill(register.id, billId);
      _didSetActiveBill = true;
    }
  }

  void _clearActiveBill() {
    if (!_didSetActiveBill) return;
    if (_cachedRegisterId != null) {
      _registerRepo.setActiveBill(_cachedRegisterId!, null);
    }
  }

  void _scheduleDisplaySync() {
    _displaySyncTimer?.cancel();
    _displaySyncTimer = Timer(const Duration(milliseconds: 300), _syncCartToDisplay);
  }

  Future<void> _syncCartToDisplay() async {
    final registerId = ref.read(activeRegisterProvider).value?.id;
    if (registerId == null) return;

    final items = <Map<String, dynamic>>[];
    for (final entry in _cart) {
      if (entry is _CartItem) {
        items.add({
          'name': entry.name,
          'qty': entry.quantity,
          'price': entry.unitPrice,
          if (entry.notes != null) 'notes': entry.notes,
        });
      }
    }
    final json = items.isEmpty ? null : jsonEncode(items);
    await ref.read(registerRepositoryProvider).setDisplayCart(registerId, json);
  }

  void _clearDisplayCart() {
    if (_cachedRegisterId == null) return;
    _registerRepo.setDisplayCart(_cachedRegisterId!, null);
  }

  Future<void> _createQuickBill() async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final billRepo = ref.read(billRepositoryProvider);
    final sections = await ref.read(sectionRepositoryProvider).watchAll(company.id).first;
    final defaultSection = sections.where((s) => s.isDefault).firstOrNull ?? sections.firstOrNull;
    final register = await ref.read(activeRegisterProvider.future);
    final session = ref.read(activeRegisterSessionProvider).value;

    final billResult = await billRepo.createBill(
      companyId: company.id,
      userId: user.id,
      currencyId: company.defaultCurrencyId,
      sectionId: defaultSection?.id,
      registerId: register?.id,
      registerSessionId: session?.id,
      isTakeaway: true,
      numberOfGuests: 1,
    );

    if (billResult is Success<BillModel> && mounted) {
      setState(() => _quickBillId = billResult.value.id);
      _setActiveBill(billResult.value.id);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.trim());
    });
  }

  Future<void> _loadCustomerName() async {
    if (widget.billId == null) return;
    final billResult = await ref.read(billRepositoryProvider).getById(widget.billId!);
    if (billResult is Success<BillModel>) {
      final bill = billResult.value;
      if (bill.customerId != null) {
        final customer = await ref.read(customerRepositoryProvider).getById(bill.customerId!);
        if (customer != null && mounted) {
          setState(() {
            _customerId = customer.id;
            _customerName = '${customer.firstName} ${customer.lastName}';
          });
        }
      } else if (bill.customerName != null && mounted) {
        setState(() {
          _customerName = bill.customerName;
        });
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
          if (reg == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.registerNotBoundMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
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
                    Expanded(
                      child: _searchQuery.isNotEmpty
                          ? _buildSearchResults(context, ref, l)
                          : _buildGrid(context, ref, reg, l),
                    ),
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
        children: _isSearchOpen
            ? [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _searchController.clear();
                            _debounce?.cancel();
                            setState(() {
                              _searchQuery = '';
                              _isSearchOpen = false;
                              _currentPage = 0;
                              _pageStack.clear();
                            });
                          },
                        ),
                        hintText: l.sellSearch,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
              ]
            : [
                SizedBox(
                  height: 40,
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _isSearchOpen = true),
                  ),
                ),
                const SizedBox(width: 8),
                _toolbarChip(l.sellScan, onSelected: null),
                const SizedBox(width: 8),
                _toolbarChip(
                  _customerName ?? l.sellCustomer,
                  selected: _customerName != null,
                  onSelected: () => _selectCustomer(context),
                ),
                const SizedBox(width: 8),
                _toolbarChip(l.sellNote, selected: _orderNotes != null && _orderNotes!.isNotEmpty, onSelected: () => _showOrderNoteDialog(context)),
                const SizedBox(width: 8),
                _toolbarChip(l.sellSeparator, onSelected: _cart.isEmpty ? null : () {
                  if (_cart.isNotEmpty && _cart.last is! _CartSeparator) {
                    setState(() => _cart.add(const _CartSeparator()));
                    _scheduleDisplaySync();
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
                          onTap: () {
                            setState(() => _cart.removeAt(index));
                            _scheduleDisplaySync();
                          },
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
                        onLongPress: () {
                          setState(() {
                            item.quantity--;
                            if (item.quantity <= 0) _cart.removeAt(index);
                          });
                          _scheduleDisplaySync();
                        },
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

  Widget _buildSearchResults(BuildContext context, WidgetRef ref, dynamic l) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<ItemModel>>(
      stream: ref.watch(itemRepositoryProvider).search(company.id, _searchQuery),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return ListTile(
              title: Text(item.name),
              trailing: Text('${item.unitPrice ~/ 100} Kč'),
              onTap: () => _addToCart(ref, item, company.id),
            );
          },
        );
      },
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
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          child: const SizedBox.expand(),
        ),
      );
    }

    if (layoutItem.type == LayoutItemType.category) {
      final cat = allCategories.where((c) => c.id == layoutItem.categoryId).firstOrNull;
      return _ItemButton(
        label: layoutItem.label ?? cat?.name ?? '?',
        color: layoutItem.color != null
            ? parseHexColor(layoutItem.color)
            : Theme.of(context).colorScheme.secondaryContainer,
        isCategory: true,
        onTap: () => _onCategoryTap(register.id, layoutItem),
      );
    }

    final item = allItems.where((i) => i.id == layoutItem.itemId).firstOrNull;
    if (item == null) return const SizedBox.shrink();

    return _ItemButton(
      label: layoutItem.label ?? item.name,
      subtitle: '${item.unitPrice ~/ 100} Kč',
      color: layoutItem.color != null
          ? parseHexColor(layoutItem.color)
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
              _scheduleDisplaySync();
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
      _scheduleDisplaySync();
    }
  }

  Future<void> _selectCustomer(BuildContext context) async {
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: _customerName != null,
    );
    if (result == null) return;
    final billId = widget.billId ?? _quickBillId;
    if (result is CustomerModel) {
      if (billId != null) {
        await ref.read(billRepositoryProvider).updateCustomer(billId, result.id);
      }
      if (mounted) {
        setState(() {
          _customerId = result.id;
          _customerName = '${result.firstName} ${result.lastName}';
        });
      }
    } else if (result is String) {
      // Free-text customer name
      if (billId != null) {
        await ref.read(billRepositoryProvider).updateCustomerName(billId, result);
      }
      if (mounted) {
        setState(() {
          _customerId = null;
          _customerName = result;
        });
      }
    } else {
      // _RemoveCustomer sentinel
      if (billId != null) {
        await ref.read(billRepositoryProvider).updateCustomer(billId, null);
      }
      if (mounted) {
        setState(() {
          _customerId = null;
          _customerName = null;
        });
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
    _scheduleDisplaySync();
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

    // Register-based numbering: O{n}-{counter}
    final register = await ref.read(activeRegisterProvider.future);
    final regNum = register?.registerNumber ?? 0;
    return 'O$regNum-${counterResult.value.toString().padLeft(4, '0')}';
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _displaySyncTimer?.cancel();
    _clearDisplayCart();
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
        final register = await ref.read(activeRegisterProvider.future);
        final result = await orderRepo.createOrderWithItems(
          companyId: company.id,
          billId: widget.billId!,
          userId: user.id,
          orderNumber: orderNumber,
          items: orderItems,
          orderNotes: i == 0 ? _orderNotes : null,
          registerId: register?.id,
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
    final billId = _quickBillId;
    if (billId == null) return;
    setState(() => _isSubmitting = true);
    _displaySyncTimer?.cancel();
    _clearDisplayCart();
    try {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final billRepo = ref.read(billRepositoryProvider);

    // Update customer on the quick bill if set
    if (_customerId != null) {
      await billRepo.updateCustomer(billId, _customerId);
    } else if (_customerName != null) {
      await billRepo.updateCustomerName(billId, _customerName!);
    }

    // Create order(s)
    final groups = _splitCartIntoGroups();
    final orderRepo = ref.read(orderRepositoryProvider);
    final register = await ref.read(activeRegisterProvider.future);
    for (var i = 0; i < groups.length; i++) {
      final orderNumber = await _nextOrderNumber(ref);
      final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
      await orderRepo.createOrderWithItems(
        companyId: company.id,
        billId: billId,
        userId: user.id,
        orderNumber: orderNumber,
        items: orderItems,
        orderNotes: i == 0 ? _orderNotes : null,
        registerId: register?.id,
      );
    }
    await billRepo.updateTotals(billId);

    if (!context.mounted) return;

    // Fetch updated bill with totals
    final updatedBillResult = await billRepo.getById(billId);
    if (updatedBillResult is! Success<BillModel>) return;

    if (!context.mounted) return;

    // Show payment dialog
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(bill: updatedBillResult.value),
    );

    if (paid == true && context.mounted) {
      _quickBillId = null;
      _didSetActiveBill = false; // Keep activeBillId so customer display shows "Thank you"
      context.pop();
    } else {
      // User cancelled payment — cancel the bill and create fresh one for retry
      await billRepo.cancelBill(billId);
      await billRepo.updateTotals(billId);
      if (mounted) await _createQuickBill();
    }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _convertToBill(BuildContext context, WidgetRef ref) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _displaySyncTimer?.cancel();
    _clearDisplayCart();
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);

      // Cancel the quick bill before creating a regular one
      if (_quickBillId != null) {
        await billRepo.cancelBill(_quickBillId!);
        _quickBillId = null;
      }

      // Resolve default section
      final sections = await ref.read(sectionRepositoryProvider).watchAll(company.id).first;
      final defaultSection = sections.where((s) => s.isDefault).firstOrNull ?? sections.firstOrNull;

      // Create regular bill on default section, no table
      final register = await ref.read(activeRegisterProvider.future);
      final session = ref.read(activeRegisterSessionProvider).value;
      final billResult = await billRepo.createBill(
        companyId: company.id,
        userId: user.id,
        currencyId: company.defaultCurrencyId,
        sectionId: defaultSection?.id,
        customerId: _customerId,
        customerName: _customerId == null ? _customerName : null,
        registerId: register?.id,
        registerSessionId: session?.id,
        isTakeaway: false,
      );
      if (billResult is! Success<BillModel>) return;
      final bill = billResult.value;

      // Set active bill for customer display
      _setActiveBill(bill.id);

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
          registerId: register?.id,
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
  const _ItemButton({
    required this.label,
    required this.color,
    this.onTap,
    this.subtitle,
    this.isCategory = false,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool isCategory;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCategory)
                  const Icon(Icons.folder_outlined, size: 16),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
