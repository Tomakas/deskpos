import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/display_device_type.dart';
import '../../../core/data/enums/sell_mode.dart';
import '../../../core/data/enums/item_type.dart';
import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/category_model.dart';
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
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_color_palette.dart';
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

  // Cached reference for use in dispose() where ref is no longer available.
  late final _displayChannel = ref.read(customerDisplayChannelProvider);

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    _initDisplayBroadcast();
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
                      final qty = item.quantity.toStringAsFixed(
                        item.quantity == item.quantity.roundToDouble() ? 0 : 1,
                      );
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
                                    '${qty}x',
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
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
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

    // Hide price for parent products that have variants (they are just containers)
    final hasVariants = item.itemType == ItemType.product &&
        allItems.any((v) => v.parentId == item.id && v.itemType == ItemType.variant);

    return _ItemButton(
      label: layoutItem.label ?? item.name,
      subtitle: hasVariants ? null : ref.money(item.unitPrice),
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
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: _customerName != null,
    );
    if (!mounted) return;
    if (result == null) return;
    // For existing bills, persist immediately; for quick sale, defer to submission
    final billId = widget.billId;
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

  Future<void> _addToCart(WidgetRef ref, ItemModel item, String companyId) async {
    // Variant items: add directly (user picked from search or sub-grid)
    // Product items: check for variants first
    ItemModel selectedItem = item;
    if (item.itemType == ItemType.product) {
      final variants = await ref.read(itemRepositoryProvider).watchVariants(item.id).first;
      if (variants.isNotEmpty) {
        if (!mounted) return;
        final selected = await _showVariantPickerDialog(item, variants);
        if (selected == null || !mounted) return;
        selectedItem = selected;
      }
    }

    // Check for modifier groups (on item itself + inherited from parent)
    final groups = await _loadModifierGroups(ref, selectedItem);
    if (!mounted) return;

    final hasRequired = groups.any((g) => g.group.minSelections > 0);
    if (groups.isNotEmpty && hasRequired) {
      // Mandatory modifier groups — must show dialog
      final modifiers = await _showModifierDialog(selectedItem, groups);
      if (modifiers == null || !mounted) return;
      _addItemToCart(selectedItem, modifiers: modifiers);
    } else {
      // No modifier groups or all optional — add directly
      _addItemToCart(selectedItem);
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

  Future<ItemModel?> _showVariantPickerDialog(ItemModel parent, List<ItemModel> variants) async {
    return showDialog<ItemModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(parent.name),
        children: [
          for (final v in variants)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, v),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(v.name)),
                    Text(ref.money(v.unitPrice)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<List<_CartModifier>?> _showModifierDialog(
    ItemModel item,
    List<_ModifierGroupWithItems> groups,
  ) async {
    return showDialog<List<_CartModifier>>(
      context: context,
      builder: (ctx) => _ModifierSelectionDialog(
        item: item,
        groups: groups,
        moneyFormatter: ref.money,
      ),
    );
  }

  void _addItemToCart(ItemModel item, {List<_CartModifier> modifiers = const []}) {
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
            return c.itemId == item.id && cModKey == modKey;
          })
          .firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _cart.add(_CartItem(
          itemId: item.id,
          name: item.name,
          unitPrice: item.unitPrice,
          saleTaxRateId: item.saleTaxRateId,
          modifiers: modifiers,
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
    setState(() => _isSubmitting = true);
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);
      final sectionRepo = ref.read(sectionRepositoryProvider);

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
      for (var i = 0; i < groups.length; i++) {
        final orderNumber = await _nextOrderNumber(ref);
        if (!mounted) return;
        final orderItems = await _buildOrderItemsFromGroup(ref, groups[i]);
        if (!mounted) return;
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
      if (_isRetailMode) {
        _resetForNextSale();
      } else {
        context.pop();
      }
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
    this.modifiers = const [],
  });

  final String itemId;
  final String name;
  final int unitPrice;
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
    final canManage = ref.watch(hasPermissionProvider('settings.manage'));
    final canViewOrders = ref.watch(hasPermissionProvider('orders.view'));
    final sessionAsync = ref.watch(activeRegisterSessionProvider);
    final hasSession = sessionAsync.valueOrNull != null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      tooltip: l.billsMore,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle-session',
          height: 48,
          child: Text(hasSession ? l.registerSessionClose : l.registerSessionStart),
        ),
        if (hasSession)
          PopupMenuItem(value: 'cash-journal', height: 48, child: Text(l.billsCashJournal)),
        PopupMenuItem(
          value: 'z-reports',
          enabled: canManage,
          height: 48,
          child: Text(l.moreReports),
        ),
        PopupMenuItem(
          value: 'shifts',
          enabled: canManage,
          height: 48,
          child: Text(l.moreShifts),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'bills',
          height: 48,
          child: Text(l.billsTitle),
        ),
        PopupMenuItem(
          value: 'orders',
          enabled: canViewOrders,
          height: 48,
          child: Text(l.ordersTitle),
        ),
        PopupMenuItem(
          value: 'catalog',
          enabled: canManage,
          height: 48,
          child: Text(l.moreCatalog),
        ),
        PopupMenuItem(
          value: 'inventory',
          enabled: canManage,
          height: 48,
          child: Text(l.billsInventory),
        ),
        PopupMenuItem(
          value: 'vouchers',
          enabled: canManage,
          height: 48,
          child: Text(l.vouchersTitle),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'company-settings',
          enabled: canManage,
          height: 48,
          child: Text(l.moreCompanySettings),
        ),
        PopupMenuItem(
          value: 'venue-settings',
          enabled: canManage,
          height: 48,
          child: Text(l.moreVenueSettings),
        ),
        PopupMenuItem(
          value: 'register-settings',
          enabled: canManage,
          height: 48,
          child: Text(l.moreRegisterSettings),
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
      case 'z-reports':
        await helpers.showZReportsDialog(context, ref);
      case 'shifts':
        await helpers.showShiftsDialog(context, ref);
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
      case 'company-settings':
        if (context.mounted) context.push('/settings/company');
      case 'venue-settings':
        if (context.mounted) context.push('/settings/venue');
      case 'register-settings':
        if (context.mounted) context.push('/settings/register');
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
  });
  final ItemModel item;
  final List<_ModifierGroupWithItems> groups;
  final String Function(int) moneyFormatter;

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
        if (sel.contains(gi.item.id)) total += gi.item.unitPrice;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final total = widget.item.unitPrice + _modifierTotal;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(widget.item.name)),
          Text(widget.moneyFormatter(widget.item.unitPrice),
              style: theme.textTheme.titleMedium),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
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
                          unitPrice: gi.item.unitPrice,
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
    );
  }

  String _groupRuleLabel(AppLocalizations l, ModifierGroupModel g) {
    if (g.minSelections > 0 && g.maxSelections == null) return l.required;
    if (g.minSelections > 0) return '${g.minSelections}-${g.maxSelections}';
    if (g.maxSelections != null) return '${l.optional} (max ${g.maxSelections})';
    return l.optional;
  }

  Widget _buildGroupItems(_ModifierGroupWithItems g) {
    final isSingleSelect = g.group.maxSelections == 1;
    final sel = _selections[g.group.id] ?? {};

    return Column(
      children: [
        for (final gi in g.items)
          if (isSingleSelect)
            RadioListTile<String>(
              dense: true,
              title: Text(gi.item.name),
              secondary: gi.item.unitPrice > 0
                  ? Text('+${widget.moneyFormatter(gi.item.unitPrice)}')
                  : null,
              value: gi.item.id,
              groupValue: sel.length == 1 ? sel.first : null,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selections[g.group.id] = {v});
                }
              },
            )
          else
            CheckboxListTile(
              dense: true,
              title: Text(gi.item.name),
              secondary: gi.item.unitPrice > 0
                  ? Text('+${widget.moneyFormatter(gi.item.unitPrice)}')
                  : null,
              value: sel.contains(gi.item.id),
              onChanged: _canToggle(g, gi.item.id, sel)
                  ? (v) {
                      setState(() {
                        final s = _selections[g.group.id] ??= {};
                        if (v == true) {
                          s.add(gi.item.id);
                        } else {
                          s.remove(gi.item.id);
                        }
                      });
                    }
                  : null,
            ),
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
