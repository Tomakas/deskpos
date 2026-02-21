import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/prep_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatting_ext.dart';
import 'package:go_router/go_router.dart';

/// Kitchen Display System — a touch-optimized, kitchen-facing order board.
///
/// Shows active orders (created → ready) as full-width cards with
/// elapsed time since creation. Kitchen staff taps the order-level button to
/// advance items with the lowest status. Individual items can also be advanced
/// independently. Storno orders are excluded from the KDS view.
class ScreenKds extends ConsumerStatefulWidget {
  const ScreenKds({super.key});

  @override
  ConsumerState<ScreenKds> createState() => _ScreenKdsState();
}

class _ScreenKdsState extends ConsumerState<ScreenKds> {
  Set<PrepStatus> _statusFilter = {
    PrepStatus.created,
    PrepStatus.ready,
  };
  Timer? _ticker;
  bool _isBumping = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(l.kdsTitle),
        actions: [
          _KdsClockWidget(),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l.actionLogout),
                onTap: () {
                  final session = ref.read(sessionManagerProvider);
                  session.logoutAll();
                  ref.read(activeUserProvider.notifier).state = null;
                  ref.read(loggedInUsersProvider.notifier).state = [];
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Order cards list
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: ref
                  .watch(orderRepositoryProvider)
                  .watchByCompany(company.id),
              builder: (context, snap) {
                final allOrders = snap.data ?? [];
                // Exclude storno orders from KDS view
                final nonStorno =
                    allOrders.where((o) => !o.isStorno).toList();
                final orders = _applyStatusFilter(nonStorno);

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      l.kdsNoOrders,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _KdsOrderCard(
                    order: orders[i],
                    onBump: () => _bumpOrder(orders[i]),
                    onItemBump: (item) => _bumpItem(orders[i], item),
                  ),
                );
              },
            ),
          ),
          // Status filter bar
          _KdsStatusFilterBar(
            selected: _statusFilter,
            onChanged: (filter) =>
                setState(() => _statusFilter = filter),
          ),
        ],
      ),
    );
  }

  List<OrderModel> _applyStatusFilter(List<OrderModel> orders) {
    if (_statusFilter.isEmpty) return orders;
    return orders.where((o) => _statusFilter.contains(o.status)).toList();
  }

  /// Bump items with the lowest active status to the next status.
  Future<void> _bumpOrder(OrderModel order) async {
    if (_isBumping) return;
    _isBumping = true;
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final items = await orderRepo.watchOrderItems(order.id).first;
      final activeItems = items.where((i) =>
          i.status != PrepStatus.voided && i.status != PrepStatus.cancelled);
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

  /// Bump a single item to the next status.
  Future<void> _bumpItem(OrderModel order, OrderItemModel item) async {
    if (_isBumping) return;
    _isBumping = true;
    try {
      final next = _nextStatus(item.status);
      if (next == null) return;
      await ref.read(orderRepositoryProvider).updateItemStatus(
            item.id,
            order.id,
            next,
          );
    } finally {
      _isBumping = false;
    }
  }
}

// ---------------------------------------------------------------------------
// KDS Order Card
// ---------------------------------------------------------------------------
class _KdsOrderCard extends ConsumerWidget {
  const _KdsOrderCard({
    required this.order,
    required this.onBump,
    required this.onItemBump,
  });
  final OrderModel order;
  final VoidCallback onBump;
  final void Function(OrderItemModel) onItemBump;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final statusColor = order.status.color(context);
    final elapsed = DateTime.now().difference(order.createdAt);
    final elapsedMin = elapsed.inMinutes;
    final urgencyColor = _urgencyColor(elapsedMin, context.appColors);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<List<OrderItemModel>>(
          stream:
              ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
          builder: (context, snap) {
            final items = snap.data ?? [];

            // Find lowest active item status for the order-level button
            final activeItems = items.where((i) =>
                i.status != PrepStatus.voided &&
                i.status != PrepStatus.cancelled);
            final lowestStatus = activeItems.isNotEmpty
                ? activeItems
                    .map((i) => i.status)
                    .reduce((a, b) => a.index < b.index ? a : b)
                : null;
            final lowestNext =
                lowestStatus != null ? _nextStatus(lowestStatus) : null;
            final lowestColor =
                lowestStatus != null ? lowestStatus.color(context) : statusColor;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: 3 columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1: order number + status button (single row)
                    Expanded(
                      child: Row(
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
                          Flexible(
                            child: Text(
                              order.orderNumber,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (lowestNext != null)
                            Flexible(
                              child: SizedBox(
                              height: 36,
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  backgroundColor:
                                      lowestColor.withValues(alpha: 0.15),
                                  foregroundColor: lowestColor,
                                  textStyle: theme.textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                clipBehavior: Clip.hardEdge,
                                onPressed: onBump,
                                child: Text(
                                  _statusLabel(lowestStatus!, l),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            )
                          else
                            Flexible(
                              child: Container(
                              height: 36,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                _statusLabel(order.status, l),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
                      child: _TimeTable(
                        createdAt: order.createdAt,
                        updatedAt: order.updatedAt,
                        urgencyColor: urgencyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Items
                Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 4),
                      _KdsItemCard(
                        item: items[i],
                        onBump: () => onItemBump(items[i]),
                      ),
                    ],
                  ],
                ),
                // Notes
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    order.notes!,
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
// KDS Item sub-card
// ---------------------------------------------------------------------------
class _KdsItemCard extends ConsumerWidget {
  const _KdsItemCard({
    required this.item,
    required this.onBump,
  });
  final OrderItemModel item;
  final VoidCallback onBump;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isVoided =
        item.status == PrepStatus.voided || item.status == PrepStatus.cancelled;
    final next = !isVoided ? _nextStatus(item.status) : null;

    final stripColor = isVoided ? context.appColors.inactiveIndicator : item.status.color(context);
    final bgColor =
        isVoided ? Colors.transparent : stripColor.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: next != null ? onBump : null,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
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
                                '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}x',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      isVoided ? TextDecoration.lineThrough : null,
                                  color: isVoided
                                      ? theme.colorScheme.onSurfaceVariant
                                      : null,
                                ),
                              ),
                            ),
                            // Item name
                            Expanded(
                              child: Text(
                                item.itemName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration:
                                      isVoided ? TextDecoration.lineThrough : null,
                                  color: isVoided
                                      ? theme.colorScheme.onSurfaceVariant
                                      : null,
                                ),
                              ),
                            ),
                            // Notes icon
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.note,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            // Next-status button (flex to fit narrow screens)
                            Flexible(
                              child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 40,
                                child: next != null
                                    ? FilledButton.tonal(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          backgroundColor: next.color(context)
                                              .withValues(alpha: 0.15),
                                          foregroundColor: next.color(context),
                                          textStyle: theme.textTheme.labelSmall
                                              ?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        onPressed: onBump,
                                        child: Text(
                                          _nextStatusLabel(next, l),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : isVoided
                                        ? Center(
                                            child: Text(
                                              l.ordersFilterStorno,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
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
                        StreamBuilder(
                          stream: ref.watch(orderItemModifierRepositoryProvider).watchByOrderItem(item.id),
                          builder: (context, modSnap) {
                            final mods = modSnap.data ?? [];
                            if (mods.isEmpty) return const SizedBox.shrink();
                            return Padding(
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
                            );
                          },
                        ),
                      ],
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
// Bill info table (table + customer, left-aligned)
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
              stream:
                  ref.watch(customerRepositoryProvider).watchAll(company.id),
              builder: (context, customerSnap) {
                final table = bill.tableId != null
                    ? tables.where((t) => t.id == bill.tableId).firstOrNull
                    : null;

                final tableName =
                    bill.isTakeaway ? l.billsQuickBill : table?.name;

                // Resolve customer: linked record takes priority, then bill.customerName
                String? resolvedCustomer;
                if (bill.customerId != null) {
                  final customers = customerSnap.data ?? [];
                  final customer = customers
                      .where((c) => c.id == bill.customerId)
                      .firstOrNull;
                  if (customer != null) {
                    resolvedCustomer =
                        '${customer.firstName} ${customer.lastName}'.trim();
                  }
                }
                resolvedCustomer ??= bill.customerName;
                final customerDisplay =
                    (resolvedCustomer != null && resolvedCustomer.isNotEmpty)
                        ? resolvedCustomer
                        : '–';

                final tableDisplay =
                    (tableName != null && tableName.isNotEmpty)
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
// Live clock for KDS AppBar
// ---------------------------------------------------------------------------
class _KdsClockWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<_KdsClockWidget> createState() => _KdsClockWidgetState();
}

class _KdsClockWidgetState extends ConsumerState<_KdsClockWidget> {
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
  Widget build(BuildContext context, ) {
    return Text(
      '${ref.fmtDate(_now)}  ${ref.fmtTimeSeconds(_now)}',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------
String _statusLabel(PrepStatus status, AppLocalizations l) => switch (status) {
      PrepStatus.created => l.ordersFilterCreated,
      PrepStatus.ready => l.ordersFilterReady,
      PrepStatus.delivered => l.ordersFilterDelivered,
      PrepStatus.cancelled => l.ordersFilterStorno,
      PrepStatus.voided => l.ordersFilterStorno,
    };

PrepStatus? _nextStatus(PrepStatus current) => switch (current) {
      PrepStatus.created => PrepStatus.ready,
      PrepStatus.ready => PrepStatus.delivered,
      _ => null,
    };

String _nextStatusLabel(PrepStatus status, AppLocalizations l) => switch (status) {
      PrepStatus.ready => l.ordersFilterReady,
      PrepStatus.delivered => l.ordersFilterDelivered,
      _ => '',
    };

Color _urgencyColor(int minutes, AppColorsExtension colors) {
  if (minutes < 5) return colors.success;
  if (minutes < 10) return colors.warning;
  return colors.danger;
}

// ---------------------------------------------------------------------------
// KDS Status Filter Bar (toggle-based, matching ScreenOrders)
// ---------------------------------------------------------------------------
class _KdsStatusFilterBar extends StatelessWidget {
  const _KdsStatusFilterBar({
    required this.selected,
    required this.onChanged,
  });
  final Set<PrepStatus> selected;
  final ValueChanged<Set<PrepStatus>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final filters = <(Set<PrepStatus>, String, Color)>[
      ({PrepStatus.created}, l.ordersFilterCreated, PrepStatus.created.color(context)),
      ({PrepStatus.ready}, l.ordersFilterReady, PrepStatus.ready.color(context)),
      ({PrepStatus.delivered}, l.ordersFilterDelivered, PrepStatus.delivered.color(context)),
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
                  backgroundColor:
                      filters[i].$3.withValues(alpha: 0.08),
                  selectedColor:
                      filters[i].$3.withValues(alpha: 0.2),
                  checkmarkColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(filters[i].$2,
                        textAlign: TextAlign.center),
                  ),
                  selected:
                      filters[i].$1.every((s) => selected.contains(s)),
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
