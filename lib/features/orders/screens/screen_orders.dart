import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/void_quantity_dialog.dart';

class ScreenOrders extends ConsumerStatefulWidget {
  const ScreenOrders({super.key});

  @override
  ConsumerState<ScreenOrders> createState() => _ScreenOrdersState();
}

enum _OrderSortField { time, number, status }

class _ScreenOrdersState extends ConsumerState<ScreenOrders> {
  bool _sessionScope = true;
  _OrderSortField _sortField = _OrderSortField.time;
  bool _sortAscending = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  Set<PrepStatus> _statusFilter = {PrepStatus.created, PrepStatus.ready};
  Timer? _ticker;
  bool _isBumping = false;
  final Map<String, List<OrderItemModel>> _itemsCache = {};

  @override
  void initState() {
    super.initState();
    // Tick every 15 seconds to update elapsed time badges
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final session = ref.watch(activeRegisterSessionProvider).valueOrNull;
    final since = (_sessionScope && session != null) ? session.openedAt : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.ordersTitle),
        actions: [
          _OrdersClockWidget(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<bool>(
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    color: !_sessionScope ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onSelected: (v) => setState(() => _sessionScope = v),
                  itemBuilder: (_) => [
                    CheckedPopupMenuItem(
                      value: true,
                      checked: _sessionScope,
                      child: Text(l.ordersScopeSession),
                    ),
                    CheckedPopupMenuItem(
                      value: false,
                      checked: !_sessionScope,
                      child: Text(l.ordersScopeAll),
                    ),
                  ],
                ),
                PopupMenuButton<_OrderSortField>(
                  icon: const Icon(Icons.swap_vert),
                  onSelected: (field) {
                    if (field == _sortField) {
                      setState(() => _sortAscending = !_sortAscending);
                    } else {
                      setState(() {
                        _sortField = field;
                        _sortAscending = field == _OrderSortField.time ? false : true;
                      });
                    }
                  },
                  itemBuilder: (_) => [
                    for (final entry in {
                      _OrderSortField.time: l.ordersSortByTime,
                      _OrderSortField.number: l.ordersSortByNumber,
                      _OrderSortField.status: l.ordersSortByStatus,
                    }.entries)
                      PopupMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            if (entry.key == _sortField)
                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16)
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Text(entry.value, style: entry.key == _sortField ? const TextStyle(fontWeight: FontWeight.bold) : null),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Order cards list
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: ref.watch(orderRepositoryProvider).watchByCompany(
                    company.id,
                    since: since,
                  ),
              builder: (context, snap) {
                final allOrders = snap.data ?? [];
                _ensureItemsLoaded(allOrders);
                final orders = _applyFilters(allOrders);

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      l.ordersNoOrders,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _OrderCard(
                    order: orders[i],
                    searchQuery: _searchQuery,
                    onBump: () => _bumpOrder(orders[i]),
                    onUnbump: () => _unbumpOrder(orders[i]),
                    onItemStatusChange: (item, status) =>
                        _changeItemStatus(orders[i], item, status),
                    onVoidItem: (item) => _voidItem(orders[i], item),
                  ),
                );
              },
            ),
          ),
          // Status filter bar
          _OrderStatusFilterBar(
            selected: _statusFilter,
            onChanged: (filter) => setState(() => _statusFilter = filter),
          ),
        ],
      ),
    );
  }

  void _ensureItemsLoaded(List<OrderModel> orders) {
    final orderRepo = ref.read(orderRepositoryProvider);
    for (final order in orders) {
      if (_itemsCache.containsKey(order.id)) continue;
      _itemsCache[order.id] = const []; // mark as loading
      orderRepo.getOrderItems(order.id).then((items) {
        if (mounted) setState(() => _itemsCache[order.id] = items);
      });
    }
  }

  List<OrderModel> _applyFilters(List<OrderModel> orders) {
    var result = _statusFilter.isEmpty
        ? orders
        : orders.where((o) => _statusFilter.contains(o.status)).toList();

    if (_searchQuery.isNotEmpty) {
      final q = normalizeSearch(_searchQuery);
      result = result
          .where((o) =>
              normalizeSearch(o.orderNumber).contains(q) ||
              (o.notes != null && normalizeSearch(o.notes!).contains(q)) ||
              (_itemsCache[o.id] ?? [])
                  .any((item) => normalizeSearch(item.itemName).contains(q)))
          .toList();
    }

    result.sort((a, b) {
      final cmp = switch (_sortField) {
        _OrderSortField.time => a.createdAt.compareTo(b.createdAt),
        _OrderSortField.number => a.orderNumber.compareTo(b.orderNumber),
        _OrderSortField.status => a.status.index.compareTo(b.status.index),
      };
      return _sortAscending ? cmp : -cmp;
    });

    return result;
  }

  /// Bump items with the lowest active status to the next status.
  Future<void> _bumpOrder(OrderModel order) async {
    if (_isBumping) return;
    _isBumping = true;
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final items = await orderRepo.watchOrderItems(order.id).first;
      final activeItems = items.where((i) =>
          i.status != PrepStatus.voided);
      if (activeItems.isEmpty) return;
      final lowestStatus = activeItems
          .map((i) => i.status)
          .reduce((a, b) => a.index < b.index ? a : b);
      final next = _nextStatus(lowestStatus);
      if (next == null) return;
      for (final item in items) {
        if (item.status == lowestStatus) {
          await orderRepo.updateItemStatus(item.id, order.id, next);
        }
      }
    } finally {
      _isBumping = false;
    }
  }

  /// Return items with the lowest active status to the previous status.
  Future<void> _unbumpOrder(OrderModel order) async {
    if (_isBumping) return;
    // Check if revert is possible before showing dialog.
    final orderRepo = ref.read(orderRepositoryProvider);
    final items = await orderRepo.watchOrderItems(order.id).first;
    final activeItems = items.where((i) =>
        i.status != PrepStatus.voided);
    if (activeItems.isEmpty) return;
    final lowestStatus = activeItems
        .map((i) => i.status)
        .reduce((a, b) => a.index < b.index ? a : b);
    final prev = _prevStatus(lowestStatus);
    if (prev == null) return;

    if (!mounted) return;
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: l.ordersRevertConfirm,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.no)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.yes)),
          ],
        ),
        children: const [],
      ),
    );
    if (confirmed != true || !mounted) return;
    _isBumping = true;
    try {
      for (final item in items) {
        if (item.status == lowestStatus) {
          await orderRepo.updateItemStatus(item.id, order.id, prev);
        }
      }
    } finally {
      _isBumping = false;
    }
  }

  Future<void> _changeItemStatus(
      OrderModel order, OrderItemModel item, PrepStatus status) async {
    if (_isBumping) return;
    _isBumping = true;
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      await orderRepo.updateItemStatus(item.id, order.id, status);
    } finally {
      _isBumping = false;
    }
  }

  Future<void> _voidItem(OrderModel order, OrderItemModel item) async {
    final l = context.l10n;
    double? voidQty;

    if (item.quantity > 1) {
      final result = await showDialog<double>(
        context: context,
        builder: (_) => VoidQuantityDialog(
          itemName: item.itemName,
          maxQuantity: item.quantity,
          unit: item.unit,
        ),
      );
      if (result == null || !context.mounted) return;
      voidQty = result;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PosDialogShell(
          title: l.orderItemStornoConfirm,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
              FilledButton(style: PosButtonStyles.destructiveFilled(context), onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
            ],
          ),
          children: const [],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    final user = ref.read(activeUserProvider);
    if (user == null) return;

    // Generate storno order number
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    final registerModel = ref.read(activeRegisterProvider).value;
    final orderRepo = ref.read(orderRepositoryProvider);
    final billRepo = ref.read(billRepositoryProvider);
    final regNum = registerModel?.registerNumber ?? 0;
    String stornoNumber = 'X$regNum-0000';
    if (session != null) {
      final sessionRepo = ref.read(registerSessionRepositoryProvider);
      final counter = await sessionRepo.incrementOrderCounter(session.id);
      if (!context.mounted) return;
      if (counter is Success<int>) {
        stornoNumber = 'X$regNum-${counter.value.toString().padLeft(4, '0')}';
      }
    }

    final isFullVoid = voidQty == null || voidQty >= item.quantity;
    await orderRepo.voidItem(
      orderId: order.id,
      orderItemId: item.id,
      companyId: order.companyId,
      userId: user.id,
      stornoOrderNumber: stornoNumber,
      registerId: registerModel?.id,
      voidQuantity: isFullVoid ? null : voidQty,
    );
    await billRepo.updateTotals(order.billId);
  }
}

// ---------------------------------------------------------------------------
// Order Card
// ---------------------------------------------------------------------------
class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.searchQuery,
    required this.onBump,
    required this.onUnbump,
    required this.onItemStatusChange,
    required this.onVoidItem,
  });
  final OrderModel order;
  final String searchQuery;
  final VoidCallback onBump;
  final VoidCallback onUnbump;
  final void Function(OrderItemModel, PrepStatus) onItemStatusChange;
  final void Function(OrderItemModel) onVoidItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isStorno = order.isStorno;
    final statusColor = order.status.color(context);
    final elapsed = DateTime.now().difference(order.createdAt);
    final urgencyColor = _urgencyColor(elapsed.inMinutes, context.appColors);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isStorno
            ? BorderSide(color: context.appColors.danger, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<List<OrderItemModel>>(
          stream: ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
          builder: (context, snap) {
            final items = snap.data ?? [];

            // Find lowest active item status for the order-level button
            final activeItems = items.where((i) =>
                i.status != PrepStatus.voided);
            final lowestStatus = !isStorno && activeItems.isNotEmpty
                ? activeItems
                    .map((i) => i.status)
                    .reduce((a, b) => a.index < b.index ? a : b)
                : null;
            final lowestNext = lowestStatus != null
                ? _nextStatus(lowestStatus)
                : null;
            final lowestPrev = lowestStatus != null
                ? _prevStatus(lowestStatus)
                : null;
            final lowestColor = lowestNext != null
                ? lowestNext.color(context)
                : lowestStatus != null
                    ? lowestStatus.color(context)
                    : statusColor;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: 3 columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1: order identity + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                            if (isStorno)
                              Text(
                                '${l.ordersStornoPrefix} ',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: context.appColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            HighlightedText(
                              order.orderNumber,
                              query: searchQuery,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isStorno ? context.appColors.danger : null,
                              ),
                            ),
                            if (isStorno && order.stornoSourceOrderId != null) ...[
                              const SizedBox(width: 8),
                              _StornoRef(
                                billId: order.billId,
                                sourceOrderId: order.stornoSourceOrderId!,
                              ),
                            ],
                            ],
                          ),
                          Text(
                            '${l.ordersStatusPrefix}: ${_statusLabel(order.status, l)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Col 2: table + customer
                    Expanded(
                      child: _BillInfoTable(billId: order.billId),
                    ),
                    const SizedBox(width: 16),
                    // Col 3: times
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _TimeTable(
                          createdAt: order.createdAt,
                          updatedAt: order.updatedAt,
                          urgencyColor: urgencyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Items + order-level bump button
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            for (var i = 0; i < items.length; i++) ...[
                              if (i > 0) const SizedBox(height: 4),
                              _OrderItemCard(
                                item: items[i],
                                searchQuery: searchQuery,
                                isStorno: isStorno,
                                canVoid: !isStorno && _isItemActive(items[i].status),
                                canChangeStatus: !isStorno,
                                onVoid: () => onVoidItem(items[i]),
                                onStatusChange: (status) =>
                                    onItemStatusChange(items[i], status),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (lowestNext != null || lowestPrev != null) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 56),
                          child: GestureDetector(
                            onLongPress: onUnbump,
                            child: FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                backgroundColor:
                                    lowestColor.withValues(alpha: 0.15),
                                foregroundColor: lowestColor,
                                textStyle: theme.textTheme.labelSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              onPressed: lowestNext != null ? onBump : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.keyboard_double_arrow_right,
                                      size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    lowestNext != null
                                        ? _nextStatusLabel(lowestNext, l)
                                        : _statusLabel(lowestStatus!, l),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Notes
                if (order.notes != null && order.notes!.isNotEmpty && !isStorno) ...[
                  const SizedBox(height: 4),
                  HighlightedText(
                    order.notes!,
                    query: searchQuery,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Storno reference — resolves source order number
// ---------------------------------------------------------------------------
class _StornoRef extends ConsumerWidget {
  const _StornoRef({required this.billId, required this.sourceOrderId});
  final String billId;
  final String sourceOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return StreamBuilder<List<OrderModel>>(
      stream: ref.watch(orderRepositoryProvider).watchByBill(billId),
      builder: (context, snap) {
        final orders = snap.data ?? [];
        final source = orders.where((o) => o.id == sourceOrderId).firstOrNull;
        final orderNumber = source?.orderNumber ?? '...';
        return Text(
          l.ordersStornoRef(orderNumber),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appColors.danger,
                fontStyle: FontStyle.italic,
              ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bill info table (table + customer, colons aligned)
// ---------------------------------------------------------------------------
class _BillInfoTable extends ConsumerWidget {
  const _BillInfoTable({required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodySmall;

    return StreamBuilder<List<BillModel>>(
      stream: ref.watch(billRepositoryProvider).watchByCompany(company.id),
      builder: (context, billSnap) {
        final bills = billSnap.data ?? [];
        final bill = bills.where((b) => b.id == billId).firstOrNull;
        if (bill == null) return const SizedBox.shrink();

        return StreamBuilder<List<TableModel>>(
          stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
          builder: (context, tableSnap) {
            final tables = tableSnap.data ?? [];

            return StreamBuilder<List<CustomerModel>>(
              stream: ref.watch(customerRepositoryProvider).watchAll(company.id),
              builder: (context, customerSnap) {
                final table = bill.tableId != null
                    ? tables.where((t) => t.id == bill.tableId).firstOrNull
                    : null;

                final tableName = bill.isTakeaway
                    ? l.billsQuickBill
                    : table?.name;

                // Resolve customer: linked record takes priority, then bill.customerName
                String? resolvedCustomer;
                if (bill.customerId != null) {
                  final customers = customerSnap.data ?? [];
                  final customer = customers
                      .where((c) => c.id == bill.customerId)
                      .firstOrNull;
                  if (customer != null) {
                    resolvedCustomer = '${customer.firstName} ${customer.lastName}'.trim();
                  }
                }
                resolvedCustomer ??= bill.customerName;
                final customerDisplay = (resolvedCustomer != null && resolvedCustomer.isNotEmpty)
                    ? resolvedCustomer
                    : '–';

                final tableDisplay = (tableName != null && tableName.isNotEmpty)
                    ? tableName
                    : '–';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text('${l.ordersTableLabel}: ', style: labelStyle, overflow: TextOverflow.ellipsis)),
                      Flexible(flex: 2, child: Text(tableDisplay, style: valueStyle, overflow: TextOverflow.ellipsis)),
                    ]),
                    Row(children: [
                      Flexible(child: Text('${l.ordersCustomerLabel}: ', style: labelStyle, overflow: TextOverflow.ellipsis)),
                      Flexible(flex: 2, child: Text(customerDisplay, style: valueStyle, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

}

// ---------------------------------------------------------------------------
// Time table (created + updated, colons aligned)
// ---------------------------------------------------------------------------
class _TimeTable extends ConsumerWidget {
  const _TimeTable({
    required this.createdAt,
    required this.updatedAt,
    required this.urgencyColor,
  });
  final DateTime createdAt;
  final DateTime updatedAt;
  final Color urgencyColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: Text('${l.ordersTimeCreated}: ',
                style: labelStyle, overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(ref.fmtTime(createdAt), style: valueStyle?.copyWith(
                color: urgencyColor,
                fontWeight: FontWeight.bold,
              )),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: Text('${l.ordersTimeUpdated}: ',
                style: labelStyle, overflow: TextOverflow.ellipsis)),
            Text(ref.fmtTime(updatedAt), style: valueStyle),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Order item sub-card
// ---------------------------------------------------------------------------
class _OrderItemCard extends ConsumerWidget {
  const _OrderItemCard({
    required this.item,
    required this.searchQuery,
    required this.isStorno,
    required this.canVoid,
    required this.canChangeStatus,
    required this.onVoid,
    required this.onStatusChange,
  });
  final OrderItemModel item;
  final String searchQuery;
  final bool isStorno;
  final bool canVoid;
  final bool canChangeStatus;
  final VoidCallback onVoid;
  final void Function(PrepStatus) onStatusChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isVoided = item.status == PrepStatus.voided;
    final prev = canChangeStatus ? _prevStatus(item.status) : null;
    final next = canChangeStatus ? _nextStatus(item.status) : null;

    Future<void> confirmRevert() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PosDialogShell(
          title: l.ordersRevertConfirm,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.no)),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.yes)),
            ],
          ),
          children: const [],
        ),
      );
      if (confirmed == true) onStatusChange(prev!);
    }

    // Left strip color: grey for storno orders and voided items, status color otherwise
    final stripColor = isStorno || isVoided
        ? context.appColors.inactiveIndicator
        : item.status.color(context);

    // Background tint: none for storno/voided, subtle status color otherwise
    final bgColor = isStorno || isVoided
        ? Colors.transparent
        : stripColor.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onLongPress: canVoid && !isVoided ? onVoid : null,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left colored strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: stripColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: StreamBuilder(
                      stream: ref.watch(orderItemModifierRepositoryProvider).watchByOrderItem(item.id),
                      builder: (context, modSnap) {
                        final mods = modSnap.data ?? [];
                        final modTotal = mods.fold<int>(0, (sum, m) => sum + (m.unitPrice * m.quantity * item.quantity).round());
                        final price = (item.salePriceAtt * item.quantity).round() + modTotal;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                // Status dot
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: item.status.color(context),
                                  ),
                                ),
                                // Quantity
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${ref.fmtQty(item.quantity, maxDecimals: 1)} ${localizedUnitType(l, item.unit)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: isVoided ? TextDecoration.lineThrough : null,
                                      color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                                    ),
                                  ),
                                ),
                                // Item name + status
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      HighlightedText(
                                        item.itemName,
                                        query: searchQuery,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          decoration: isVoided ? TextDecoration.lineThrough : null,
                                          color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                                        ),
                                      ),
                                      Text(
                                        '${l.ordersStatusPrefix}: ${_statusLabel(item.status, l)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: item.status.color(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    ref.money(price),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      decoration: isVoided ? TextDecoration.lineThrough : null,
                                      color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                                    ),
                                  ),
                                ),
                                // Next-status button / delivered badge / voided label
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      height: 40,
                                      child: next != null
                                          ? GestureDetector(
                                              onLongPress: prev != null
                                                  ? confirmRevert
                                                  : null,
                                              child: FilledButton.tonal(
                                                style: FilledButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  backgroundColor:
                                                      next.color(context).withValues(alpha: 0.15),
                                                  foregroundColor: next.color(context),
                                                  textStyle: theme.textTheme.labelSmall
                                                      ?.copyWith(fontWeight: FontWeight.w600),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                onPressed: () => onStatusChange(next),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.chevron_right, size: 18),
                                                    Flexible(
                                                      child: Text(
                                                        _nextStatusLabel(next, l),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : !isVoided && prev != null
                                              ? GestureDetector(
                                                  onLongPress: confirmRevert,
                                                  child: FilledButton.tonal(
                                                    style: FilledButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                      backgroundColor:
                                                          item.status.color(context).withValues(alpha: 0.15),
                                                      foregroundColor: item.status.color(context),
                                                      textStyle: theme.textTheme.labelSmall
                                                          ?.copyWith(fontWeight: FontWeight.w600),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                    onPressed: null,
                                                    child: Text(
                                                      _statusLabel(item.status, l),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                )
                                              : isVoided
                                                  ? Center(
                                                      child: Text(
                                                        l.ordersFilterStorno,
                                                        style: theme.textTheme.labelSmall?.copyWith(
                                                          color: context.appColors.danger,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    )
                                                  : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Modifiers
                            if (mods.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 48, top: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final mod in mods)
                                      Text(
                                        '+ ${mod.modifierItemName}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            // Notes
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 48, top: 2),
                                child: Text(
                                  item.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
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

// ---------------------------------------------------------------------------
// Live clock for AppBar
// ---------------------------------------------------------------------------
class _OrdersClockWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<_OrdersClockWidget> createState() => _OrdersClockWidgetState();
}

class _OrdersClockWidgetState extends ConsumerState<_OrdersClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      ref.fmtTimeSeconds(_now),
      style: Theme.of(context).textTheme.titleMedium,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------
bool _isItemActive(PrepStatus status) =>
    status == PrepStatus.created ||
    status == PrepStatus.ready;

PrepStatus? _nextStatus(PrepStatus current) => switch (current) {
      PrepStatus.created => PrepStatus.ready,
      PrepStatus.ready => PrepStatus.delivered,
      _ => null,
    };

PrepStatus? _prevStatus(PrepStatus current) => switch (current) {
      PrepStatus.ready => PrepStatus.created,
      PrepStatus.delivered => PrepStatus.ready,
      _ => null,
    };

Color _urgencyColor(int minutes, AppColorsExtension colors) {
  if (minutes < 5) return colors.success;
  if (minutes < 10) return colors.warning;
  return colors.danger;
}

String _statusLabel(PrepStatus status, AppLocalizations l) => switch (status) {
      PrepStatus.created => l.ordersFilterCreated,
      PrepStatus.ready => l.ordersFilterReady,
      PrepStatus.delivered => l.ordersFilterDelivered,
      PrepStatus.voided => l.ordersFilterStorno,
    };

String _nextStatusLabel(PrepStatus status, AppLocalizations l) => switch (status) {
      PrepStatus.ready => l.ordersFilterReady,
      PrepStatus.delivered => l.ordersFilterDelivered,
      _ => '',
    };


// ---------------------------------------------------------------------------
// Status Filter Bar
// ---------------------------------------------------------------------------
class _OrderStatusFilterBar extends StatelessWidget {
  const _OrderStatusFilterBar({
    required this.selected,
    required this.onChanged,
  });
  final Set<PrepStatus> selected;
  final ValueChanged<Set<PrepStatus>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // (statuses, label, color)
    final filters = <(Set<PrepStatus>, String, Color)>[
      ({PrepStatus.created}, l.ordersFilterCreated, PrepStatus.created.color(context)),
      ({PrepStatus.ready}, l.ordersFilterReady, PrepStatus.ready.color(context)),
      ({PrepStatus.delivered}, l.ordersFilterDelivered, PrepStatus.delivered.color(context)),
      ({PrepStatus.voided}, l.ordersFilterStorno, PrepStatus.voided.color(context)),
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  backgroundColor: filters[i].$3.withValues(alpha: 0.08),
                  selectedColor: filters[i].$3.withValues(alpha: 0.2),
                  checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(filters[i].$2, textAlign: TextAlign.center),
                  ),
                  selected: filters[i].$1.every((s) => selected.contains(s)),
                  onSelected: (on) {
                    final next = Set<PrepStatus>.from(selected);
                    if (on) {
                      next.addAll(filters[i].$1);
                    } else {
                      next.removeAll(filters[i].$1);
                    }
                    onChanged(next);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
