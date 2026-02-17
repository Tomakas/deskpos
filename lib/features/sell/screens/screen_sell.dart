import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/display_device_type.dart';
import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/mappers/supabase_mappers.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/customer_display_content.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/layout_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
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
  String? _quickBillId;
  String? _displayCode;

  // Cached references for use in dispose() where ref is no longer available.
  late final _billRepo = ref.read(billRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    _initDisplayBroadcast();
    if (widget.isQuickSale) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _createQuickBill());
    }
  }

  @override
  void dispose() {
    _pushDisplayIdle();
    if (_quickBillId != null) {
      _billRepo.cancelBill(_quickBillId!);
    }
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initDisplayBroadcast() async {
    final register = await ref.read(activeRegisterProvider.future);
    if (register == null || !mounted) return;

    final displayDeviceRepo = ref.read(displayDeviceRepositoryProvider);
    final devices = await displayDeviceRepo.getByParentRegister(register.id);
    final customerDisplay = devices
        .where((d) => d.type == DisplayDeviceType.customerDisplay)
        .firstOrNull;
    if (customerDisplay != null && mounted) {
      _displayCode = customerDisplay.code;
      await ref.read(customerDisplayChannelProvider).join('display:${_displayCode!}');
      AppLogger.info(
        'ScreenSell: joined display:${_displayCode!}',
        tag: 'BROADCAST',
      );
    }
  }

  void _pushToDisplay() {
    if (_displayCode == null) return;

    final items = <DisplayItem>[];
    int subtotal = 0;
    for (final entry in _cart) {
      if (entry is _CartItem) {
        final totalPrice = (entry.unitPrice * entry.quantity).round();
        subtotal += totalPrice;
        items.add(DisplayItem(
          name: entry.name,
          quantity: entry.quantity,
          unitPrice: entry.unitPrice,
          totalPrice: totalPrice,
          notes: entry.notes,
        ));
      }
    }

    final content = items.isEmpty
        ? const DisplayIdle()
        : DisplayItems(
            items: items,
            subtotal: subtotal,
            total: subtotal,
          );

    ref.read(customerDisplayChannelProvider).send(content.toJson());
  }

  void _pushDisplayIdle() {
    if (_displayCode == null) return;
    ref.read(customerDisplayChannelProvider).send(const DisplayIdle().toJson());
  }

  Future<void> _broadcastKdsOrder(OrderModel order) async {
    final orderRepo = ref.read(orderRepositoryProvider);
    final channel = ref.read(kdsBroadcastChannelProvider);
    final items = await orderRepo.getOrderItems(order.id);
    if (!mounted) return;
    channel.send({
      'action': 'new_order',
      'order': orderToSupabaseJson(order),
      'order_items': items.map(orderItemToSupabaseJson).toList(),
    });
  }

  Future<void> _createQuickBill() async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final billRepo = ref.read(billRepositoryProvider);
    final sectionRepo = ref.read(sectionRepositoryProvider);
    final sections = await sectionRepo.watchAll(company.id).first;
    if (!mounted) return;
    final defaultSection = sections.where((s) => s.isDefault).firstOrNull ?? sections.firstOrNull;
    final register = await ref.read(activeRegisterProvider.future);
    if (!mounted) return;
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
    final billRepo = ref.read(billRepositoryProvider);
    final billResult = await billRepo.getById(widget.billId!);
    if (!mounted) return;
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
        error: (e, _) => Center(child: Text(context.l10n.errorGeneric(e.toString()))),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AppLocalizations l) {
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
                    _pushToDisplay();
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

  Widget _buildCart(BuildContext context, AppLocalizations l) {
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
                            _pushToDisplay();
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
                        trailing: Text(ref.money((item.unitPrice * item.quantity).round())),
                        onTap: () => _showItemNoteDialog(context, item),
                        onLongPress: () {
                          setState(() {
                            item.quantity--;
                            if (item.quantity <= 0) _cart.removeAt(index);
                          });
                          _pushToDisplay();
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
                  ref.money(total),
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
                  style: PosButtonStyles.confirm(context),
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
                        style: PosButtonStyles.confirm(context),
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

  Widget _buildSearchResults(BuildContext context, WidgetRef ref, AppLocalizations l) {
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
              trailing: Text(ref.money(item.unitPrice)),
              onTap: () => _addToCart(ref, item, company.id),
            );
          },
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, RegisterModel register, AppLocalizations l) {
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
    AppLocalizations l,
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
    AppLocalizations l,
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
      subtitle: ref.money(item.unitPrice),
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
              _pushToDisplay();
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
    if (result != null && mounted) {
      setState(() => item.notes = result.isEmpty ? null : result);
      _pushToDisplay();
    }
  }

  Future<void> _selectCustomer(BuildContext context) async {
    final billRepo = ref.read(billRepositoryProvider);
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: _customerName != null,
    );
    if (!mounted) return;
    if (result == null) return;
    final billId = widget.billId ?? _quickBillId;
    if (result is CustomerModel) {
      if (billId != null) {
        await billRepo.updateCustomer(billId, result.id);
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
        await billRepo.updateCustomerName(billId, result);
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
        await billRepo.updateCustomer(billId, null);
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
    if (result != null && mounted) {
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
    _pushToDisplay();
  }

  Future<List<OrderItemInput>> _buildOrderItemsFromGroup(WidgetRef ref, List<_CartItem> group) async {
    final taxRateRepo = ref.read(taxRateRepositoryProvider);
    final orderItems = <OrderItemInput>[];
    for (final cartItem in group) {
      int taxRateBps = 0;
      int taxAmount = 0;

      if (cartItem.saleTaxRateId != null) {
        final taxRate = await taxRateRepo.getById(cartItem.saleTaxRateId!);
        if (!mounted) return orderItems;
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
    if (!mounted) return 'O-0000';

    // Register-based numbering: O{n}-{counter}
    final register = await ref.read(activeRegisterProvider.future);
    if (!mounted) return 'O-0000';
    final regNum = register?.registerNumber ?? 0;
    return 'O$regNum-${counterResult.value.toString().padLeft(4, '0')}';
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _pushDisplayIdle();
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final groups = _splitCartIntoGroups();
      if (groups.isEmpty) return;

      final orderRepo = ref.read(orderRepositoryProvider);
      final billRepo = ref.read(billRepositoryProvider);
      bool anySuccess = false;

      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        if (!mounted) return;
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        if (!mounted) return;
        final register = await ref.read(activeRegisterProvider.future);
        if (!mounted) return;
        final result = await orderRepo.createOrderWithItems(
          companyId: company.id,
          billId: widget.billId!,
          userId: user.id,
          orderNumber: orderNumber,
          items: orderItems,
          orderNotes: i == 0 ? _orderNotes : null,
          registerId: register?.id,
        );
        if (result is Success<OrderModel>) {
          anySuccess = true;
          _broadcastKdsOrder(result.value);
        }
      }

      if (anySuccess) {
        await billRepo.updateTotals(widget.billId!);
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
    try {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final billRepo = ref.read(billRepositoryProvider);
    final orderRepo = ref.read(orderRepositoryProvider);

    // Update customer on the quick bill if set
    if (_customerId != null) {
      await billRepo.updateCustomer(billId, _customerId);
      if (!mounted) return;
    } else if (_customerName != null) {
      await billRepo.updateCustomerName(billId, _customerName!);
      if (!mounted) return;
    }

    // Create order(s)
    final groups = _splitCartIntoGroups();
    final register = await ref.read(activeRegisterProvider.future);
    if (!mounted) return;
    for (var i = 0; i < groups.length; i++) {
      final orderNumber = await _nextOrderNumber(ref);
      if (!mounted) return;
      final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
      if (!mounted) return;
      final result = await orderRepo.createOrderWithItems(
        companyId: company.id,
        billId: billId,
        userId: user.id,
        orderNumber: orderNumber,
        items: orderItems,
        orderNotes: i == 0 ? _orderNotes : null,
        registerId: register?.id,
      );
      if (result is Success<OrderModel>) {
        _broadcastKdsOrder(result.value);
      }
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
      // Send thank-you message to customer display
      if (_displayCode != null && mounted) {
        final l = context.l10n;
        ref.read(customerDisplayChannelProvider).send(
          DisplayMessage(
            text: l.customerDisplayThankYou,
            messageType: 'success',
            autoClearAfterMs: 5000,
          ).toJson(),
        );
      }
      context.pop();
    } else {
      // User cancelled payment — cancel the bill and create fresh one for retry
      await billRepo.cancelBill(billId, userId: ref.read(activeUserProvider)?.id);
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
    _pushDisplayIdle();
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);
      final sectionRepo = ref.read(sectionRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);

      // Cancel the quick bill before creating a regular one
      if (_quickBillId != null) {
        await billRepo.cancelBill(_quickBillId!, userId: ref.read(activeUserProvider)?.id);
        if (!mounted) return;
        _quickBillId = null;
      }

      // Resolve default section
      final sections = await sectionRepo.watchAll(company.id).first;
      if (!mounted) return;
      final defaultSection = sections.where((s) => s.isDefault).firstOrNull ?? sections.firstOrNull;

      // Create regular bill on default section, no table
      final register = await ref.read(activeRegisterProvider.future);
      if (!mounted) return;
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

      // Create order(s) with cart items
      final groups = _splitCartIntoGroups();
      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        if (!mounted) return;
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        if (!mounted) return;
        final result = await orderRepo.createOrderWithItems(
          companyId: company.id,
          billId: bill.id,
          userId: user.id,
          orderNumber: orderNumber,
          items: orderItems,
          orderNotes: i == 0 ? _orderNotes : null,
          registerId: register?.id,
        );
        if (result is Success<OrderModel>) {
          _broadcastKdsOrder(result.value);
        }
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
