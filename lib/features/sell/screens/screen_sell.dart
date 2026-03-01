import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/display_device_type.dart';
import '../../../core/data/enums/negative_stock_policy.dart';
import '../../../core/data/enums/sell_mode.dart';
import '../../../core/data/enums/item_type.dart';
import '../../../core/data/enums/unit_type.dart';
import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/currency_model.dart';
import '../../../core/data/models/customer_display_content.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/item_modifier_group_model.dart';
import '../../../core/data/models/modifier_group_item_model.dart';
import '../../../core/data/models/modifier_group_model.dart';
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
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/pos_color_palette.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_numpad.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_dialog_theme.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../bills/widgets/dialog_customer_search.dart';
import '../../bills/widgets/dialog_payment.dart';
import '../../shared/session_helpers.dart' as helpers;

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
  String? _displayCode;
  bool _didSendThankYou = false;
  bool _isRetailMode = false;
  String? _warehouseId;

  // Cached reference for use in dispose() where ref is no longer available.
  late final _displayChannel = ref.read(customerDisplayChannelProvider);

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    _initDisplayBroadcast();
    _initWarehouse();
  }

  Future<void> _initWarehouse() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;
    final locale = ref.read(appLocaleProvider).value ?? 'cs';
    final warehouse = await ref.read(warehouseRepositoryProvider).getDefault(company.id, locale: locale);
    if (mounted) {
      setState(() {
        _warehouseId = warehouse.id;
      });
    }
  }

  @override
  void dispose() {
    if (!_didSendThankYou) _pushDisplayIdle();
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
      await _displayChannel.join('display:${_displayCode!}');
      AppLogger.info(
        'ScreenSell: joined display:${_displayCode!}',
        tag: 'BROADCAST',
      );
    }
  }

  void _pushToDisplay() {
    if (_displayCode == null) return;

    final l = context.l10n;
    final items = <DisplayItem>[];
    int subtotal = 0;
    for (final entry in _cart) {
      if (entry is _CartItem) {
        final totalPrice = (entry.effectiveUnitPrice * entry.quantity).round();
        subtotal += totalPrice;
        items.add(DisplayItem(
          name: entry.name,
          quantity: entry.quantity,
          unitPrice: entry.effectiveUnitPrice,
          totalPrice: totalPrice,
          unitLabel: localizedUnitType(l, entry.unit),
          notes: entry.notes,
          modifiers: entry.modifiers
              .map((m) => DisplayModifier(name: m.name, unitPrice: m.unitPrice))
              .toList(),
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

    _displayChannel.send(content.toJson());
  }

  void _pushDisplayIdle() {
    if (_displayCode == null) return;
    _displayChannel.send(const DisplayIdle().toJson());
  }

  /// Retail mode: clears cart state for the next sale.
  void _resetForNextSale() {
    setState(() {
      _cart.clear();
      _orderNotes = null;
      _customerId = null;
      _customerName = null;
      _currentPage = 0;
      _pageStack.clear();
      _didSendThankYou = false;
    });
    _pushDisplayIdle();
  }

  void _onCancelTap(BuildContext context) {
    if (_cart.isNotEmpty) {
      // Remove last entry (item or separator)
      setState(() => _cart.removeLast());
      _pushToDisplay();
    } else {
      // Empty cart — go home
      if (_isRetailMode) {
        _resetForNextSale();
      } else {
        context.pop();
      }
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
    final registerAsync = ref.watch(activeRegisterProvider);
    final reg = registerAsync.valueOrNull;

    // Latch retail mode once register loads — stable across provider reloads
    if (reg != null) {
      _isRetailMode = reg.sellMode == SellMode.retail;
    }

    Widget body;
    if (registerAsync.isLoading && reg == null) {
      // First load — no previous data yet
      body = const Center(child: CircularProgressIndicator());
    } else if (reg == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l.registerNotBoundMessage,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = Row(
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
    }

    Widget scaffold = Scaffold(body: body);

    if (_isRetailMode) {
      return PopScope(canPop: false, child: scaffold);
    }
    return scaffold;
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
                if (!_isRetailMode) ...[
                  const SizedBox(width: 8),
                  _toolbarChip(l.sellSeparator, onSelected: _cart.isEmpty ? null : () {
                    if (_cart.isNotEmpty && _cart.last is! _CartSeparator) {
                      setState(() => _cart.add(const _CartSeparator()));
                      _pushToDisplay();
                    }
                  }),
                ],
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
        total += (entry.effectiveUnitPrice * entry.quantity).round();
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
            padding: EdgeInsets.only(left: _isRetailMode ? 4 : 16, right: 16),
            child: Row(
              children: [
                if (_isRetailMode)
                  const _RetailMenuButton(),
                Expanded(
                  child: Text(l.sellCartSummary, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
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
                      final qty = ref.fmtQty(item.quantity, maxDecimals: 1);
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showItemNoteDialog(context, item),
                        onLongPress: () {
                          setState(() {
                            item.quantity--;
                            if (item.quantity <= 0) _cart.removeAt(index);
                          });
                          _pushToDisplay();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$qty ${localizedUnitType(l, item.unit)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: theme.textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ref.money((item.effectiveUnitPrice * item.quantity).round()),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              for (final mod in item.modifiers)
                                Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: Text(
                                    '+ ${mod.name}${mod.unitPrice > 0 ? '  +${ref.money(mod.unitPrice)}' : ''}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: Text(
                                    item.notes!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
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
            // Cancel + Save to bill | Pay
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onLongPress: _cart.isEmpty ? null : () {
                        setState(() => _cart.clear());
                        _pushToDisplay();
                      },
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: PosButtonStyles.destructiveOutlined(context),
                          onPressed: () => _onCancelTap(context),
                          child: Text(l.sellCancelOrder),
                        ),
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
              trailing: Text(item.unitPrice != null ? ref.money(item.unitPrice!) : '???'),
              onTap: () => _addToCart(ref, item, company.id),
              onLongPress: () => _addToCart(ref, item, company.id, forceQuantityDialog: true),
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
    final showBadge = register.showStockBadge && _warehouseId != null;

    return StreamBuilder<List<ItemModel>>(
      stream: ref.watch(itemRepositoryProvider).watchAll(companyId),
      builder: (context, itemSnap) {
        final allItems = itemSnap.data ?? [];
        return StreamBuilder<List<CategoryModel>>(
          stream: ref.watch(categoryRepositoryProvider).watchAll(companyId),
          builder: (context, catSnap) {
            final allCategories = catSnap.data ?? [];

            Widget buildGrid(Map<String, double> stockMap) {
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
                              cellWidth: cellW,
                              cellHeight: cellH,
                              stockMap: stockMap,
                            ),
                          ),
                    ],
                  );
                },
              );
            }

            if (!showBadge) return buildGrid(const {});

            return StreamBuilder<Map<String, double>>(
              stream: ref.watch(stockLevelRepositoryProvider).watchStockMap(companyId, _warehouseId!),
              builder: (context, stockSnap) {
                return buildGrid(stockSnap.data ?? const {});
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
    AppLocalizations l, {
    required double cellWidth,
    required double cellHeight,
    required Map<String, double> stockMap,
  }) {
    final layoutItem = layoutItems.where((li) => li.gridRow == row && li.gridCol == col).firstOrNull;
    final showBadge = register.showStockBadge && stockMap.isNotEmpty;

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
      // Marker cell at [0,0] on sub-pages = back button
      if (_currentPage > 0 && row == 0 && col == 0) {
        return _ItemButton(
          label: l.sellBackToCategories,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          isCategory: true,
          cellHeight: cellHeight,
          onTap: () => _onCategoryTap(register.id, layoutItem),
        );
      }
      final cat = allCategories.where((c) => c.id == layoutItem.categoryId).firstOrNull;
      return _ItemButton(
        label: layoutItem.label ?? cat?.name ?? '?',
        color: layoutItem.color != null
            ? parseHexColor(layoutItem.color)
            : Theme.of(context).colorScheme.secondaryContainer,
        isCategory: true,
        cellHeight: cellHeight,
        onTap: () => _onCategoryTap(register.id, layoutItem),
      );
    }

    final item = allItems.where((i) => i.id == layoutItem.itemId).firstOrNull;
    if (item == null) return const SizedBox.shrink();

    // Hide price for parent products that have variants (they are just containers)
    final hasVariants = item.itemType == ItemType.product &&
        allItems.any((v) => v.parentId == item.id && v.itemType == ItemType.variant);

    // Stock badge logic
    String? stockBadge;
    _BadgeLevel? badgeLevel;
    if (showBadge) {
      if (hasVariants) {
        // Variants that have stock data (either own isStockTracked or stock_levels row)
        final variants = allItems.where(
          (v) => v.parentId == item.id && v.itemType == ItemType.variant,
        ).toList();
        final trackedVariants = variants.where(
          (v) => v.isStockTracked || stockMap.containsKey(v.id),
        );
        if (trackedVariants.isEmpty && !item.isStockTracked) {
          // No stock-tracked variants — no badge
        } else {
          stockBadge = 'V';
          final checkVariants = trackedVariants.isEmpty ? variants : trackedVariants;
          final available = checkVariants.where((v) => (stockMap[v.id] ?? 0.0) > 0).length;
          if (available == checkVariants.length) {
            badgeLevel = _BadgeLevel.positive;
          } else if (available > 0) {
            badgeLevel = _BadgeLevel.partial;
          } else {
            badgeLevel = _BadgeLevel.zero;
          }
        }
      } else {
        // Check stock tracking on item itself, or inherited from parent for variants
        var isTracked = item.isStockTracked;
        if (!isTracked && item.itemType == ItemType.variant && item.parentId != null) {
          final parent = allItems.where((p) => p.id == item.parentId).firstOrNull;
          isTracked = parent?.isStockTracked ?? false;
        }
        if (isTracked) {
          final qty = stockMap[item.id] ?? 0.0;
          stockBadge = ref.fmtQty(qty);
          badgeLevel = qty > 0 ? _BadgeLevel.positive : _BadgeLevel.zero;
        }
      }
    }

    return _ItemButton(
      label: layoutItem.label ?? item.name,
      subtitle: hasVariants ? null : (item.unitPrice != null ? ref.moneyValue(item.unitPrice!) : '???'),
      color: layoutItem.color != null
          ? parseHexColor(layoutItem.color)
          : Theme.of(context).colorScheme.primaryContainer,
      cellHeight: cellHeight,
      stockBadge: stockBadge,
      badgeLevel: badgeLevel,
      onTap: item.isSellable ? () => _addToCart(ref, item, companyId,
          cellWidth: cellWidth,
          cellHeight: cellHeight,
          cellColor: layoutItem.color != null
              ? parseHexColor(layoutItem.color)
              : Theme.of(context).colorScheme.primaryContainer,
      ) : null,
      onLongPress: item.isSellable ? () => _addToCart(ref, item, companyId,
          forceQuantityDialog: true,
          cellWidth: cellWidth,
          cellHeight: cellHeight,
          cellColor: layoutItem.color != null
              ? parseHexColor(layoutItem.color)
              : Theme.of(context).colorScheme.primaryContainer,
      ) : null,
    );
  }

  Future<void> _showItemNoteDialog(BuildContext context, _CartItem item) async {
    final result = await showDialog<_ItemNoteResult>(
      context: context,
      builder: (_) => _ItemNoteDialog(item: item),
    );
    if (result != null && mounted) {
      setState(() {
        if (result.deleted) {
          _cart.remove(item);
        } else {
          item.notes = result.notes.isEmpty ? null : result.notes;
          item.quantity = result.quantity;
        }
      });
      _pushToDisplay();
    }
  }

  Future<void> _selectCustomer(BuildContext context) async {
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: _customerName != null,
      currentCustomerName: _customerName,
      currentCustomerId: _customerId,
    );
    if (!mounted) return;
    if (result == null) return;
    // For existing bills, persist immediately; for quick sale, defer to submission
    final billId = widget.billId;
    if (result is CustomerModel) {
      if (billId != null) {
        await ref.read(billRepositoryProvider).updateCustomer(billId, result.id, customerName: '${result.firstName} ${result.lastName}');
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
      builder: (_) => PosDialogShell(
        title: context.l10n.sellNote,
        maxWidth: 380,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(context.l10n.actionSave),
            ),
          ],
        ),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.sellNote,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() => _orderNotes = result.isEmpty ? null : result);
    }
  }

  Future<void> _onCategoryTap(String registerId, LayoutItemModel layoutItem) async {
    // Marker cell at [0,0] on sub-pages navigates back
    if (_currentPage > 0 && layoutItem.gridRow == 0 && layoutItem.gridCol == 0) {
      setState(() {
        if (_pageStack.isNotEmpty) {
          _currentPage = _pageStack.removeLast();
        } else {
          _currentPage = 0;
        }
      });
      return;
    }

    // Navigate to category's sub-page
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

  Future<void> _addToCart(WidgetRef ref, ItemModel item, String companyId, {
    bool forceQuantityDialog = false,
    double? cellWidth,
    double? cellHeight,
    Color? cellColor,
  }) async {
    // Variant items: add directly (user picked from search or sub-grid)
    // Product items: check for variants first
    ItemModel selectedItem = item;
    if (item.itemType == ItemType.product) {
      final variants = await ref.read(itemRepositoryProvider).watchVariants(item.id).first;
      if (!mounted) return;
      if (variants.isNotEmpty) {
        final selected = await _showVariantPickerDialog(item, variants,
            cellWidth: cellWidth, cellHeight: cellHeight, cellColor: cellColor);
        if (selected == null || !mounted) return;
        selectedItem = selected;
      }
    }

    // Open-price items: ask cashier for price (+ quantity in same dialog)
    int? resolvedPrice;
    double quantity = 1;
    if (selectedItem.unitPrice == null) {
      final currency = ref.read(currentCurrencyProvider).value;
      final result = await showDialog<({int price, double quantity})>(
        context: context,
        builder: (_) => _PriceInputDialog(
          item: selectedItem,
          currencySymbol: currency?.symbol ?? '',
          currency: currency,
        ),
      );
      if (result == null || !mounted) return;
      resolvedPrice = result.price;
      quantity = result.quantity;
    } else {
      // Quantity dialog for non-ks items, or when forced (long press)
      if (selectedItem.unit != UnitType.ks || forceQuantityDialog) {
        final q = await showDialog<double>(
          context: context,
          builder: (_) => _QuantityInputDialog(item: selectedItem),
        );
        if (q == null || !mounted) return;
        quantity = q;
      }
    }

    // Check for modifier groups (on item itself + inherited from parent)
    final groups = await _loadModifierGroups(ref, selectedItem);
    if (!mounted) return;

    if (groups.isNotEmpty) {
      final modifiers = await _showModifierDialog(selectedItem, groups,
          resolvedPrice: resolvedPrice,
          cellWidth: cellWidth, cellHeight: cellHeight, cellColor: cellColor);
      if (modifiers == null || !mounted) return;
      _addItemToCart(selectedItem, quantity: quantity, modifiers: modifiers, priceOverride: resolvedPrice);
    } else {
      _addItemToCart(selectedItem, quantity: quantity, priceOverride: resolvedPrice);
    }
  }

  Future<List<_ModifierGroupWithItems>> _loadModifierGroups(WidgetRef ref, ItemModel item) async {
    final imgRepo = ref.read(itemModifierGroupRepositoryProvider);
    final mgRepo = ref.read(modifierGroupRepositoryProvider);
    final mgiRepo = ref.read(modifierGroupItemRepositoryProvider);
    final itemRepo = ref.read(itemRepositoryProvider);

    // Get assignments for this item + parent (inheritance)
    final assignments = await imgRepo.getByItem(item.id);
    List<ItemModifierGroupModel> parentAssignments = [];
    if (item.parentId != null) {
      parentAssignments = await imgRepo.getByItem(item.parentId!);
    }

    // Merge, deduplicate by groupId
    final allAssignments = [...assignments, ...parentAssignments];
    final seenGroupIds = <String>{};
    final uniqueAssignments = <ItemModifierGroupModel>[];
    for (final a in allAssignments) {
      if (seenGroupIds.add(a.modifierGroupId)) {
        uniqueAssignments.add(a);
      }
    }

    // Sort by sortOrder
    uniqueAssignments.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final result = <_ModifierGroupWithItems>[];
    for (final assignment in uniqueAssignments) {
      final group = await mgRepo.getById(assignment.modifierGroupId);
      if (group == null || group.deletedAt != null) continue;

      final groupItems = await mgiRepo.getByGroup(assignment.modifierGroupId);
      final itemsWithDetail = <_ModifierGroupItemWithDetail>[];
      for (final gi in groupItems) {
        if (gi.deletedAt != null) continue;
        final modItem = await itemRepo.getById(gi.itemId);
        if (modItem == null || modItem.deletedAt != null) continue;
        itemsWithDetail.add(_ModifierGroupItemWithDetail(groupItem: gi, item: modItem));
      }
      if (itemsWithDetail.isEmpty) continue;
      result.add(_ModifierGroupWithItems(group: group, items: itemsWithDetail));
    }
    return result;
  }

  Future<ItemModel?> _showVariantPickerDialog(ItemModel parent, List<ItemModel> variants, {
    double? cellWidth,
    double? cellHeight,
    Color? cellColor,
  }) async {
    // Load stock data for variant picker if badge is enabled
    final register = await ref.read(activeRegisterProvider.future);
    final showBadge = register != null && register.showStockBadge;
    Map<String, double> variantStockMap = const {};
    if (showBadge && _warehouseId != null) {
      variantStockMap = await ref.read(stockLevelRepositoryProvider)
          .watchStockMap(parent.companyId, _warehouseId!).first;
    }
    if (!mounted) return null;

    final color = cellColor ?? Theme.of(context).colorScheme.primaryContainer;
    final width = cellWidth ?? 100.0;
    final height = cellHeight ?? 80.0;

    return showDialog<ItemModel>(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: parent.name,
        maxWidth: width * 5 + PosDialogTheme.padding * 2,
        scrollable: true,
        showCloseButton: true,
        children: [
          Wrap(
            children: [
              for (final v in variants)
                () {
                  String? stockBadge;
                  _BadgeLevel? badgeLevel;
                  if (showBadge) {
                    final isTracked = v.isStockTracked ||
                        parent.isStockTracked;
                    if (isTracked) {
                      final qty = variantStockMap[v.id] ?? 0.0;
                      stockBadge = ref.fmtQty(qty);
                      badgeLevel = qty > 0
                          ? _BadgeLevel.positive
                          : _BadgeLevel.zero;
                    }
                  }
                  return SizedBox(
                    width: width,
                    height: height,
                    child: _ItemButton(
                      label: v.name,
                      subtitle: v.unitPrice != null ? ref.moneyValue(v.unitPrice!) : '???',
                      color: color,
                      cellHeight: height,
                      stockBadge: stockBadge,
                      badgeLevel: badgeLevel,
                      onTap: () => Navigator.pop(ctx, v),
                    ),
                  );
                }(),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<_CartModifier>?> _showModifierDialog(
    ItemModel item,
    List<_ModifierGroupWithItems> groups, {
    int? resolvedPrice,
    double? cellWidth,
    double? cellHeight,
    Color? cellColor,
  }) async {
    return showDialog<List<_CartModifier>>(
      context: context,
      builder: (ctx) => _ModifierSelectionDialog(
        item: item,
        groups: groups,
        moneyFormatter: ref.money,
        resolvedPrice: resolvedPrice,
        cellWidth: cellWidth ?? 100.0,
        cellHeight: cellHeight ?? 80.0,
        cellColor: cellColor,
      ),
    );
  }

  void _addItemToCart(ItemModel item, {double quantity = 1, List<_CartModifier> modifiers = const [], int? priceOverride}) {
    final resolvedUnitPrice = priceOverride ?? item.unitPrice ?? 0;
    setState(() {
      // Find last separator index
      int lastSepIdx = -1;
      for (int i = _cart.length - 1; i >= 0; i--) {
        if (_cart[i] is _CartSeparator) { lastSepIdx = i; break; }
      }
      // Build merge key: itemId + sorted modifier item IDs
      final modKey = (modifiers.map((m) => m.itemId).toList()..sort()).join(',');
      // Search only in current group — items with notes never merge
      final existing = _cart.sublist(lastSepIdx + 1)
          .whereType<_CartItem>()
          .where((c) {
            if (c.notes != null) return false;
            final cModKey = (c.modifiers.map((m) => m.itemId).toList()..sort()).join(',');
            return c.itemId == item.id && cModKey == modKey && c.unitPrice == resolvedUnitPrice;
          })
          .firstOrNull;
      if (existing != null) {
        existing.quantity += quantity;
      } else {
        _cart.add(_CartItem(
          itemId: item.id,
          name: item.name,
          unitPrice: resolvedUnitPrice,
          unit: item.unit,
          saleTaxRateId: item.saleTaxRateId,
          modifiers: modifiers,
        )..quantity = quantity);
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

      // Build modifier inputs with resolved tax rates
      final modInputs = <OrderItemModifierInput>[];
      for (final mod in cartItem.modifiers) {
        int modTaxBps = 0;
        int modTaxAmount = 0;
        if (mod.saleTaxRateId != null) {
          final modTaxRate = await taxRateRepo.getById(mod.saleTaxRateId!);
          if (!mounted) return orderItems;
          if (modTaxRate != null) {
            modTaxBps = modTaxRate.rate;
            modTaxAmount = (mod.unitPrice * modTaxBps / (10000 + modTaxBps)).round();
          }
        }
        modInputs.add(OrderItemModifierInput(
          modifierItemId: mod.itemId,
          modifierItemName: mod.name,
          modifierGroupId: mod.modifierGroupId,
          unitPrice: mod.unitPrice,
          taxRate: modTaxBps,
          taxAmount: modTaxAmount,
        ));
      }

      orderItems.add(OrderItemInput(
        itemId: cartItem.itemId,
        itemName: cartItem.name,
        quantity: cartItem.quantity,
        salePriceAtt: cartItem.unitPrice,
        saleTaxRateAtt: taxRateBps,
        saleTaxAmount: taxAmount,
        unit: cartItem.unit,
        notes: cartItem.notes,
        modifiers: modInputs,
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

      final settingsRepo = ref.read(companySettingsRepositoryProvider);
      final settings = await settingsRepo.getByCompany(company.id);
      if (!mounted) return;
      final negativeStockPolicy =
          settings?.negativeStockPolicy ?? NegativeStockPolicy.allow;

      bool anySuccess = false;

      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        if (!mounted) return;
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        if (!mounted) return;
        final register = await ref.read(activeRegisterProvider.future);
        if (!mounted) return;
        try {
          final result = await orderRepo.createOrderWithItems(
            companyId: company.id,
            billId: widget.billId!,
            userId: user.id,
            orderNumber: orderNumber,
            items: orderItems,
            orderNotes: i == 0 ? _orderNotes : null,
            registerId: register?.id,
            negativeStockPolicy: negativeStockPolicy,
          );
          if (result is Success<OrderModel>) {
            anySuccess = true;
          }
        } on InsufficientStockException catch (e) {
          if (!context.mounted) return;
          final stockResult = await _handleStockException(context, e);
          if (stockResult == _StockAction.retry) {
            final retryResult = await orderRepo.createOrderWithItems(
              companyId: company.id,
              billId: widget.billId!,
              userId: user.id,
              orderNumber: orderNumber,
              items: orderItems,
              orderNotes: i == 0 ? _orderNotes : null,
              registerId: register?.id,
              negativeStockPolicy: negativeStockPolicy,
              skipStockCheck: true,
            );
            if (retryResult is Success<OrderModel>) {
              anySuccess = true;
            }
          } else {
            break;
          }
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
    if (helpers.requireActiveSession(context, ref) == null) return;
    setState(() => _isSubmitting = true);
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);
      final sectionRepo = ref.read(sectionRepositoryProvider);

      final settingsRepo = ref.read(companySettingsRepositoryProvider);
      final settings = await settingsRepo.getByCompany(company.id);
      if (!mounted) return;
      final negativeStockPolicy =
          settings?.negativeStockPolicy ?? NegativeStockPolicy.allow;

      // Create bill on-demand
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
        customerId: _customerId,
        customerName: _customerId == null ? _customerName : null,
        registerId: register?.id,
        registerSessionId: session?.id,
        isTakeaway: true,
        numberOfGuests: 1,
      );
      if (billResult is! Success<BillModel>) return;
      final billId = billResult.value.id;

      // Create order(s)
      final groups = _splitCartIntoGroups();
      bool stockFailed = false;
      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        if (!mounted) return;
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        if (!mounted) return;
        try {
          await orderRepo.createOrderWithItems(
            companyId: company.id,
            billId: billId,
            userId: user.id,
            orderNumber: orderNumber,
            items: orderItems,
            orderNotes: i == 0 ? _orderNotes : null,
            registerId: register?.id,
            negativeStockPolicy: negativeStockPolicy,
          );
        } on InsufficientStockException catch (e) {
          if (!context.mounted) return;
          final stockResult = await _handleStockException(context, e);
          if (stockResult == _StockAction.retry) {
            await orderRepo.createOrderWithItems(
              companyId: company.id,
              billId: billId,
              userId: user.id,
              orderNumber: orderNumber,
              items: orderItems,
              orderNotes: i == 0 ? _orderNotes : null,
              registerId: register?.id,
              negativeStockPolicy: negativeStockPolicy,
              skipStockCheck: true,
            );
          } else {
            stockFailed = true;
            break;
          }
        }
      }

      if (stockFailed) {
        await billRepo.cancelBill(billId, userId: user.id);
        return;
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
        // Send thank-you message to customer display
        if (_displayCode != null && mounted) {
          _didSendThankYou = true;
          final l = context.l10n;
          _displayChannel.send(
            DisplayMessage(
              text: l.customerDisplayThankYou,
              messageType: 'success',
              autoClearAfterMs: 10000,
            ).toJson(),
          );
        }
        if (_isRetailMode) {
          _resetForNextSale();
        } else {
          context.pop();
        }
      } else {
        // User cancelled payment — cancel the bill
        await billRepo.cancelBill(billId, userId: ref.read(activeUserProvider)?.id);
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

      final settingsRepo = ref.read(companySettingsRepositoryProvider);
      final settings = await settingsRepo.getByCompany(company.id);
      if (!mounted) return;
      final negativeStockPolicy =
          settings?.negativeStockPolicy ?? NegativeStockPolicy.allow;

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
      bool stockFailed = false;
      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        if (!mounted) return;
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        if (!mounted) return;
        try {
          await orderRepo.createOrderWithItems(
            companyId: company.id,
            billId: bill.id,
            userId: user.id,
            orderNumber: orderNumber,
            items: orderItems,
            orderNotes: i == 0 ? _orderNotes : null,
            registerId: register?.id,
            negativeStockPolicy: negativeStockPolicy,
          );
        } on InsufficientStockException catch (e) {
          if (!context.mounted) return;
          final stockResult = await _handleStockException(context, e);
          if (stockResult == _StockAction.retry) {
            await orderRepo.createOrderWithItems(
              companyId: company.id,
              billId: bill.id,
              userId: user.id,
              orderNumber: orderNumber,
              items: orderItems,
              orderNotes: i == 0 ? _orderNotes : null,
              registerId: register?.id,
              negativeStockPolicy: negativeStockPolicy,
              skipStockCheck: true,
            );
          } else {
            stockFailed = true;
            break;
          }
        }
      }

      if (stockFailed) {
        await billRepo.cancelBill(bill.id, userId: user.id);
        return;
      }

      await billRepo.updateTotals(bill.id);

      if (!context.mounted) return;
      if (_isRetailMode) {
        _resetForNextSale();
      } else {
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Shows a structured stock shortage dialog.
  /// Returns [_StockAction.retry] when the user confirms a warning,
  /// [_StockAction.stop] otherwise.
  Future<_StockAction> _handleStockException(
      BuildContext context, InsufficientStockException e) async {
    if (e.isWarningOnly) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final l = ctx.l10n;
          return PosDialogShell(
            title: l.stockWarningTitle,
            scrollable: true,
            bottomActions: PosDialogActions(
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(l.stockWarningContinue),
                ),
              ],
            ),
            children: [
              _StockShortageTable(shortages: e.shortages, isWarning: true),
            ],
          );
        },
      );
      return confirmed == true ? _StockAction.retry : _StockAction.stop;
    } else {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final l = ctx.l10n;
          return PosDialogShell(
            title: l.stockInsufficientTitle,
            scrollable: true,
            bottomActions: PosDialogActions(
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l.actionClose),
                ),
              ],
            ),
            children: [
              _StockShortageTable(shortages: e.shortages, isWarning: false),
            ],
          );
        },
      );
      return _StockAction.stop;
    }
  }
}

enum _StockAction { retry, stop }

class _StockShortageTable extends StatelessWidget {
  const _StockShortageTable({
    required this.shortages,
    required this.isWarning,
  });
  final List<StockShortage> shortages;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    String qty(double v) => formatQuantity(v, locale);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Table(
        columnWidths: {
          0: const FlexColumnWidth(2),
          1: const FlexColumnWidth(1),
          2: const FlexColumnWidth(1),
          if (isWarning) 3: const FlexColumnWidth(1),
        },
        children: [
          TableRow(
            children: [
              _headerCell(l.stockColumnItem, theme),
              _headerCell(l.stockColumnRequired, theme, align: TextAlign.right),
              _headerCell(l.stockColumnAvailable, theme, align: TextAlign.right),
              if (isWarning)
                _headerCell(l.stockColumnAfter, theme, align: TextAlign.right),
            ],
          ),
          for (final s in shortages)
            TableRow(
              children: [
                _dataCell(s.itemName, theme),
                _dataCell(qty(s.needed), theme,
                    align: TextAlign.right),
                _dataCell(qty(s.available), theme,
                    align: TextAlign.right,
                    color: theme.colorScheme.error),
                if (isWarning)
                  _dataCell(qty(s.available - s.needed), theme,
                      align: TextAlign.right,
                      color: theme.colorScheme.error),
              ],
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, ThemeData theme, {TextAlign? align}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          textAlign: align,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }

  Widget _dataCell(String text, ThemeData theme,
      {TextAlign? align, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text,
          textAlign: align,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: color)),
    );
  }
}

class _CartItem {
  _CartItem({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    this.unit = UnitType.ks,
    this.saleTaxRateId,
    this.modifiers = const [],
  });

  final String itemId;
  final String name;
  final int unitPrice;
  final UnitType unit;
  final String? saleTaxRateId;
  final List<_CartModifier> modifiers;
  double quantity = 1;
  String? notes;

  /// Unit price including modifiers
  int get effectiveUnitPrice =>
      unitPrice + modifiers.fold(0, (sum, m) => sum + m.unitPrice);
}

class _CartModifier {
  const _CartModifier({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    this.saleTaxRateId,
    required this.modifierGroupId,
  });

  final String itemId;
  final String name;
  final int unitPrice;
  final String? saleTaxRateId;
  final String modifierGroupId;
}

class _ItemNoteResult {
  const _ItemNoteResult({required this.notes, required this.quantity, this.deleted = false});
  final String notes;
  final double quantity;
  final bool deleted;
}

class _ItemNoteDialog extends ConsumerStatefulWidget {
  const _ItemNoteDialog({required this.item});
  final _CartItem item;

  @override
  ConsumerState<_ItemNoteDialog> createState() => _ItemNoteDialogState();
}

class _ItemNoteDialogState extends ConsumerState<_ItemNoteDialog> {
  late final TextEditingController _noteController;
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.notes);
    _quantity = widget.item.quantity;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final item = widget.item;
    final qtyStr = ref.fmtQty(_quantity, maxDecimals: 1);
    final totalPrice = (item.effectiveUnitPrice * _quantity).round();

    return PosDialogShell(
      title: item.name,
      titleWidget: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$qtyStr ${localizedUnitType(l, item.unit)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ref.money(totalPrice),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            for (final mod in item.modifiers)
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  '+ ${mod.name}${mod.unitPrice > 0 ? '  +${ref.money(mod.unitPrice)}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
      maxWidth: 380,
      scrollable: true,
      bottomActions: PosDialogActions(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              child: const Text('-1'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => setState(() => _quantity++),
              child: const Text('+1'),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            style: PosButtonStyles.destructiveOutlined(context),
            onPressed: () => _confirmDelete(context),
            child: const Icon(Icons.delete_outline),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _ItemNoteResult(
                notes: _noteController.text,
                quantity: _quantity,
              ),
            ),
            child: Text(l.actionSave),
          ),
        ],
      ),
      children: [
        TextField(
          controller: _noteController,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l.sellNote,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => PosDialogShell(
        title: l.actionDelete,
        maxWidth: 340,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              style: PosButtonStyles.destructiveFilled(context),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.actionDelete),
            ),
          ],
        ),
        children: [
          Text(l.sellRemoveFromCart),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(
        context,
        const _ItemNoteResult(notes: '', quantity: 0, deleted: true),
      );
    }
  }
}

class _QuantityInputDialog extends StatefulWidget {
  const _QuantityInputDialog({required this.item});
  final ItemModel item;

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  String _amountText = '';

  void _numpadTap(String digit) {
    if (_amountText.length >= 7) return;
    setState(() => _amountText += digit);
  }

  void _numpadDot() {
    if (_amountText.contains('.')) return;
    setState(() => _amountText += _amountText.isEmpty ? '0.' : '.');
  }

  void _numpadBackspace() {
    if (_amountText.isEmpty) return;
    setState(() {
      _amountText = _amountText.substring(0, _amountText.length - 1);
    });
  }

  void _numpadClear() {
    setState(() => _amountText = '');
  }

  void _confirm() {
    final value = double.tryParse(_amountText);
    if (value == null || value <= 0) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final unitLabel = localizedUnitType(l, widget.item.unit);

    return PosDialogShell(
      title: l.sellEnterQuantity,
      maxWidth: 340,
      maxHeight: 520,
      expandHeight: true,
      bottomActions: SizedBox(
        width: 250,
        child: PosDialogActions(
          expanded: true,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: _confirm,
              child: Text(l.actionConfirm),
            ),
          ],
        ),
      ),
      children: [
        Center(
          child: Text(
            '${widget.item.name} ($unitLabel)',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        // Amount display
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _amountText.isEmpty ? '0' : '$_amountText $unitLabel',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Numpad
        Expanded(
          child: PosNumpad(
            width: 250,
            expand: true,
            onDigit: _numpadTap,
            onBackspace: _numpadBackspace,
            onClear: _numpadClear,
            onDot: _numpadDot,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PriceInputDialog extends StatefulWidget {
  const _PriceInputDialog({
    required this.item,
    required this.currencySymbol,
    required this.currency,
  });
  final ItemModel item;
  final String currencySymbol;
  final CurrencyModel? currency;

  @override
  State<_PriceInputDialog> createState() => _PriceInputDialogState();
}

class _PriceInputDialogState extends State<_PriceInputDialog> {
  String _amountText = '';
  int _quantity = 1;

  void _numpadTap(String digit) {
    if (_amountText.length >= 10) return;
    setState(() => _amountText += digit);
  }

  void _numpadDot() {
    if (_amountText.contains('.')) return;
    setState(() => _amountText += _amountText.isEmpty ? '0.' : '.');
  }

  void _numpadBackspace() {
    if (_amountText.isEmpty) return;
    setState(() {
      _amountText = _amountText.substring(0, _amountText.length - 1);
    });
  }

  void _numpadClear() {
    setState(() => _amountText = '');
  }

  void _confirm() {
    final price = parseMoney(_amountText, widget.currency);
    if (price <= 0) return;
    Navigator.pop(context, (price: price, quantity: _quantity.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final suffix = widget.currencySymbol;

    return PosDialogShell(
      title: widget.item.name,
      maxWidth: 340,
      maxHeight: 520,
      expandHeight: true,
      bottomActions: SizedBox(
        width: 250,
        child: PosDialogActions(
          expanded: true,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: _confirm,
              child: Text(l.actionConfirm),
            ),
          ],
        ),
      ),
      children: [
        // Quantity stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: const Icon(Icons.remove, size: 20),
              visualDensity: VisualDensity.compact,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$_quantity ${localizedUnitType(l, widget.item.unit)}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton.outlined(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${_amountText.isEmpty ? '0' : _amountText} $suffix',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PosNumpad(
            width: 250,
            expand: true,
            onDigit: _numpadTap,
            onBackspace: _numpadBackspace,
            onClear: _numpadClear,
            onDot: _numpadDot,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ModifierGroupWithItems {
  const _ModifierGroupWithItems({required this.group, required this.items});
  final ModifierGroupModel group;
  final List<_ModifierGroupItemWithDetail> items;
}

class _ModifierGroupItemWithDetail {
  const _ModifierGroupItemWithDetail({required this.groupItem, required this.item});
  final ModifierGroupItemModel groupItem;
  final ItemModel item;
}

class _RetailMenuButton extends ConsumerWidget {
  const _RetailMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final canStats = ref.watch(hasAnyPermissionInGroupProvider('stats'));
    final canViewOrders = ref.watch(hasPermissionProvider('orders.view'));
    final canCatalog = ref.watch(hasAnyPermissionInGroupProvider('products'));
    final canInventory = ref.watch(hasAnyPermissionInGroupProvider('stock'));
    final canVouchers = ref.watch(hasAnyPermissionInGroupProvider('vouchers'));
    final canData = ref.watch(hasAnyPermissionInGroupProvider('data'));
    final canSettings = ref.watch(hasAnyPermissionInGroupProvider('settings_company')) ||
        ref.watch(hasAnyPermissionInGroupProvider('settings_venue')) ||
        ref.watch(hasAnyPermissionInGroupProvider('settings_register'));
    final sessionAsync = ref.watch(activeRegisterSessionProvider);
    final hasSession = sessionAsync.valueOrNull != null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      tooltip: l.billsMore,
      itemBuilder: (_) => [
        if (hasSession
            ? ref.watch(hasPermissionProvider('register.close_session'))
            : ref.watch(hasPermissionProvider('register.open_session')))
          PopupMenuItem(
            value: 'toggle-session',
            height: 48,
            child: Text(hasSession ? l.registerSessionClose : l.registerSessionStart),
          ),
        if (hasSession && ref.watch(hasPermissionProvider('stats.cash_journal')))
          PopupMenuItem(value: 'cash-journal', height: 48, child: Text(l.billsCashJournal)),
        // TODO: Show when cash drawer hardware is connected
        // if (hasSession)
        //   PopupMenuItem(value: 'open-drawer', height: 48, child: Text(l.registerOpenDrawer)),
        if (canStats)
          PopupMenuItem(
            value: 'statistics',
            height: 48,
            child: Text(l.moreStatistics),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'bills',
          height: 48,
          child: Text(l.billsTitle),
        ),
        if (canViewOrders)
          PopupMenuItem(
            value: 'orders',
            height: 48,
            child: Text(l.ordersTitle),
          ),
        if (canCatalog)
          PopupMenuItem(
            value: 'catalog',
            height: 48,
            child: Text(l.moreCatalog),
          ),
        if (canInventory)
          PopupMenuItem(
            value: 'inventory',
            height: 48,
            child: Text(l.billsInventory),
          ),
        if (canVouchers)
          PopupMenuItem(
            value: 'vouchers',
            height: 48,
            child: Text(l.vouchersTitle),
          ),
        if (canData)
          PopupMenuItem(
            value: 'data',
            height: 48,
            child: Text(l.dataTitle),
          ),
        const PopupMenuDivider(),
        if (canSettings)
          PopupMenuItem(
            value: 'settings',
            height: 48,
            child: Text(l.settingsTitle),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          height: 48,
          child: Text(l.actionLogout),
        ),
      ],
      onSelected: (value) => _onMenuSelected(context, ref, value),
    );
  }

  Future<void> _onMenuSelected(BuildContext context, WidgetRef ref, String value) async {
    switch (value) {
      case 'toggle-session':
        final hasSession = ref.read(activeRegisterSessionProvider).valueOrNull != null;
        if (hasSession) {
          await helpers.closeSession(context, ref);
        } else {
          await helpers.openSession(context, ref);
        }
      case 'cash-journal':
        await helpers.showCashJournalDialog(context, ref);
      case 'open-drawer':
        AppLogger.info('Open cash drawer requested (no hardware connected)');
      case 'statistics':
        if (context.mounted) context.push('/statistics');
      case 'bills':
        final register = await ref.read(activeRegisterProvider.future);
        if (!context.mounted) return;
        register?.sellMode == SellMode.retail
            ? context.push('/bills')
            : context.go('/bills');
      case 'orders':
        if (context.mounted) context.push('/orders');
      case 'catalog':
        if (context.mounted) context.push('/catalog');
      case 'inventory':
        if (context.mounted) context.push('/inventory');
      case 'vouchers':
        if (context.mounted) context.push('/vouchers');
      case 'data':
        if (context.mounted) context.push('/data');
      case 'settings':
        if (context.mounted) context.push('/settings');
      case 'logout':
        await helpers.performLogout(context, ref);
    }
  }
}

class _ModifierSelectionDialog extends StatefulWidget {
  const _ModifierSelectionDialog({
    required this.item,
    required this.groups,
    required this.moneyFormatter,
    this.resolvedPrice,
    required this.cellWidth,
    required this.cellHeight,
    this.cellColor,
  });
  final ItemModel item;
  final List<_ModifierGroupWithItems> groups;
  final String Function(int) moneyFormatter;
  final int? resolvedPrice;
  final double cellWidth;
  final double cellHeight;
  final Color? cellColor;

  @override
  State<_ModifierSelectionDialog> createState() => _ModifierSelectionDialogState();
}

class _ModifierSelectionDialogState extends State<_ModifierSelectionDialog> {
  // groupId → set of selected modifier item IDs
  late final Map<String, Set<String>> _selections = {};

  @override
  void initState() {
    super.initState();
    // Pre-select defaults
    for (final g in widget.groups) {
      final defaults = <String>{};
      for (final gi in g.items) {
        if (gi.groupItem.isDefault) defaults.add(gi.item.id);
      }
      _selections[g.group.id] = defaults;
    }
  }

  bool get _isValid {
    for (final g in widget.groups) {
      final selected = _selections[g.group.id]?.length ?? 0;
      if (selected < g.group.minSelections) return false;
    }
    return true;
  }

  int get _modifierTotal {
    int total = 0;
    for (final g in widget.groups) {
      final sel = _selections[g.group.id] ?? {};
      for (final gi in g.items) {
        if (sel.contains(gi.item.id)) total += gi.item.unitPrice ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final basePrice = widget.resolvedPrice ?? widget.item.unitPrice ?? 0;
    final total = basePrice + _modifierTotal;

    return PosDialogShell(
      title: widget.item.name,
      titleWidget: Row(
        children: [
          Expanded(child: Text(widget.item.name, style: theme.textTheme.titleLarge)),
          Text(widget.moneyFormatter(basePrice),
              style: theme.textTheme.titleMedium),
        ],
      ),
      maxWidth: widget.cellWidth * 5 + PosDialogTheme.padding * 2,
      scrollable: true,
      bottomActions: PosDialogActions(
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: _isValid
                ? () {
                    final result = <_CartModifier>[];
                    for (final g in widget.groups) {
                      final sel = _selections[g.group.id] ?? {};
                      for (final gi in g.items) {
                        if (sel.contains(gi.item.id)) {
                          result.add(_CartModifier(
                            itemId: gi.item.id,
                            name: gi.item.name,
                            unitPrice: gi.item.unitPrice ?? 0,
                            saleTaxRateId: gi.item.saleTaxRateId,
                            modifierGroupId: g.group.id,
                          ));
                        }
                      }
                    }
                    Navigator.pop(context, result);
                  }
                : null,
            child: Text(l.actionAdd),
          ),
        ],
      ),
      children: [
        for (final g in widget.groups) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(g.group.name,
                    style: theme.textTheme.titleSmall),
              ),
              Text(
                _groupRuleLabel(l, g.group),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildGroupItems(g),
        ],
        const SizedBox(height: 16),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.sellTotal, style: theme.textTheme.titleMedium),
            Text(widget.moneyFormatter(total), style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _groupRuleLabel(AppLocalizations l, ModifierGroupModel g) {
    if (g.minSelections > 0 && g.maxSelections == null) return l.required;
    if (g.minSelections > 0) return '${l.required} (min ${g.minSelections}, max ${g.maxSelections})';
    if (g.maxSelections != null) return '${l.optional} (max ${g.maxSelections})';
    return l.optional;
  }

  Widget _buildGroupItems(_ModifierGroupWithItems g) {
    final isSingleSelect = g.group.maxSelections == 1;
    final sel = _selections[g.group.id] ?? {};
    final color = widget.cellColor ?? Theme.of(context).colorScheme.primaryContainer;

    return Wrap(
      children: [
        for (final gi in g.items)
          () {
            final isSelected = sel.contains(gi.item.id);
            final canToggle = _canToggle(g, gi.item.id, sel);
            final disabled = !isSelected && !canToggle;

            return Opacity(
              opacity: disabled ? 0.5 : 1.0,
              child: SizedBox(
                width: widget.cellWidth,
                height: widget.cellHeight,
                child: _ItemButton(
                  label: gi.item.name,
                  subtitle: (gi.item.unitPrice ?? 0) > 0
                      ? '+${widget.moneyFormatter(gi.item.unitPrice!)}'
                      : null,
                  color: color,
                  cellHeight: widget.cellHeight,
                  selected: isSelected,
                  onTap: disabled
                      ? null
                      : () {
                          if (isSingleSelect) {
                            setState(() {
                              if (isSelected && g.group.minSelections == 0) {
                                _selections[g.group.id] = {};
                              } else {
                                _selections[g.group.id] = {gi.item.id};
                              }
                            });
                          } else {
                            setState(() {
                              final s = _selections[g.group.id] ??= {};
                              if (s.contains(gi.item.id)) {
                                s.remove(gi.item.id);
                              } else {
                                s.add(gi.item.id);
                              }
                            });
                          }
                        },
                ),
              ),
            );
          }(),
      ],
    );
  }

  bool _canToggle(_ModifierGroupWithItems g, String itemId, Set<String> sel) {
    if (sel.contains(itemId)) return true; // always allow deselect
    if (g.group.maxSelections == null) return true; // unlimited
    return sel.length < g.group.maxSelections!;
  }
}

class _ItemButton extends StatelessWidget {
  const _ItemButton({
    required this.label,
    required this.color,
    this.onTap,
    this.onLongPress,
    this.subtitle,
    this.isCategory = false,
    this.selected = false,
    this.cellHeight = 80,
    this.stockBadge,
    this.badgeLevel,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? subtitle;
  final bool isCategory;
  final bool selected;
  final double cellHeight;
  final String? stockBadge;
  final _BadgeLevel? badgeLevel;

  @override
  Widget build(BuildContext context) {
    final labelSize = (cellHeight * 0.13).clamp(7.0, 14.0);
    final subtitleSize = (cellHeight * 0.09).clamp(6.0, 11.0);
    final badgeFontSize = (cellHeight * 0.10).clamp(8.0, 12.0);
    final iconSize = (cellHeight * 0.18).clamp(12.0, 20.0);
    final checkSize = (cellHeight * 0.28).clamp(16.0, 28.0);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor, width: 2.5),
                  )
                : null,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCategory)
                          Icon(Icons.folder_outlined, size: iconSize),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w500),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Icon(Icons.check_circle, size: checkSize, color: Colors.green),
                  ),
                if (stockBadge != null)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: _StockBadge(
                      text: stockBadge!,
                      level: badgeLevel ?? _BadgeLevel.positive,
                      fontSize: badgeFontSize,
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

enum _BadgeLevel { positive, partial, zero }

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.text,
    required this.level,
    required this.fontSize,
  });
  final String text;
  final _BadgeLevel level;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    switch (level) {
      case _BadgeLevel.positive:
        badgeColor = context.appColors.success.withValues(alpha: 0.55);
      case _BadgeLevel.partial:
        badgeColor = Colors.orange.withValues(alpha: 0.55);
      case _BadgeLevel.zero:
        badgeColor = context.appColors.danger.withValues(alpha: 0.55);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
