import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

/// Kitchen Display System — a touch-optimized, kitchen-facing order board.
///
/// Shows active orders (created → inPrep → ready) as large cards with elapsed
/// time since creation. Kitchen staff taps the card to advance all items to the
/// next status (bump).  Individual items can also be tapped to advance them
/// independently. Storno orders are excluded from the KDS view.
class ScreenKds extends ConsumerStatefulWidget {
  const ScreenKds({super.key});

  @override
  ConsumerState<ScreenKds> createState() => _ScreenKdsState();
}

class _ScreenKdsState extends ConsumerState<ScreenKds> {
  Set<PrepStatus>? _statusFilter; // null = active (created+inPrep+ready)
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
      appBar: AppBar(title: Text(l.kdsTitle)),
      body: Column(
        children: [
          // Order cards grid
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

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth > 1200
                            ? 4
                            : constraints.maxWidth > 800
                                ? 3
                                : 2;
                    final cardWidth = (constraints.maxWidth -
                            32 -
                            (crossAxisCount - 1) * 8) /
                        crossAxisCount;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final order in orders)
                            SizedBox(
                              width: cardWidth,
                              child: _KdsOrderCard(
                                order: order,
                                onBump: () => _bumpOrder(order),
                                onItemBump: (item) =>
                                    _bumpItem(order, item),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Status filter bar
          _KdsStatusFilterBar(
            selected: _statusFilter,
            onChanged: (filter) => setState(() => _statusFilter = filter),
          ),
        ],
      ),
    );
  }

  List<OrderModel> _applyStatusFilter(List<OrderModel> orders) {
    if (_statusFilter == null) {
      // Active = created + inPrep + ready
      return orders
          .where((o) =>
              o.status == PrepStatus.created ||
              o.status == PrepStatus.inPrep ||
              o.status == PrepStatus.ready)
          .toList();
    }
    return orders.where((o) => _statusFilter!.contains(o.status)).toList();
  }

  /// Bump all active items in the order to their next status.
  Future<void> _bumpOrder(OrderModel order) async {
    if (_isBumping) return;
    _isBumping = true;
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final items = await orderRepo.watchOrderItems(order.id).first;
      for (final item in items) {
        final next = _nextStatus(item.status);
        if (next != null) {
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

  PrepStatus? _nextStatus(PrepStatus current) => switch (current) {
        PrepStatus.created => PrepStatus.inPrep,
        PrepStatus.inPrep => PrepStatus.ready,
        PrepStatus.ready => PrepStatus.delivered,
        _ => null,
      };
}

// ---------------------------------------------------------------------------
// KDS Order Card — larger, touch-optimized
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
    final timeFormat = DateFormat('HH:mm');
    final elapsed = DateTime.now().difference(order.createdAt);
    final elapsedMin = elapsed.inMinutes;

    // Color intensity increases with elapsed time
    final urgencyColor = _urgencyColor(elapsedMin);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _statusColor(order.status), width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onBump,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: order number + elapsed time badge
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor(order.status),
                    ),
                  ),
                  Text(
                    order.orderNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TableName(billId: order.billId),
                  const Spacer(),
                  // Elapsed time badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l.kdsMinAgo(elapsedMin.toString()),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Time + status
              Row(
                children: [
                  Text(
                    timeFormat.format(order.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _statusLabel(order.status, l),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _statusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Items
              StreamBuilder<List<OrderItemModel>>(
                stream: ref
                    .watch(orderRepositoryProvider)
                    .watchOrderItems(order.id),
                builder: (context, snap) {
                  final items = snap.data ?? [];
                  return Column(
                    children: [
                      for (final item in items)
                        _KdsItemRow(
                          item: item,
                          onTap: () => onItemBump(item),
                        ),
                    ],
                  );
                },
              ),
              // Notes
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
              // Bump button
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _statusColor(order.status),
                  ),
                  onPressed: onBump,
                  child: Text(
                    l.kdsBump,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _urgencyColor(int minutes) {
    if (minutes < 5) return Colors.green;
    if (minutes < 10) return Colors.orange;
    return Colors.red;
  }

  Color _statusColor(PrepStatus status) => switch (status) {
        PrepStatus.created => Colors.blue,
        PrepStatus.inPrep => Colors.orange,
        PrepStatus.ready => Colors.green,
        PrepStatus.delivered => Colors.grey,
        PrepStatus.cancelled => Colors.pink,
        PrepStatus.voided => Colors.red,
      };

  String _statusLabel(PrepStatus status, dynamic l) => switch (status) {
        PrepStatus.created => l.ordersFilterCreated,
        PrepStatus.inPrep => l.ordersFilterInPrep,
        PrepStatus.ready => l.ordersFilterReady,
        PrepStatus.delivered => l.ordersFilterDelivered,
        PrepStatus.cancelled => l.ordersFilterStorno,
        PrepStatus.voided => l.ordersFilterStorno,
      };
}

// ---------------------------------------------------------------------------
// KDS Item Row — larger text, tap to bump individual item
// ---------------------------------------------------------------------------
class _KdsItemRow extends StatelessWidget {
  const _KdsItemRow({
    required this.item,
    required this.onTap,
  });
  final OrderItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVoided =
        item.status == PrepStatus.voided || item.status == PrepStatus.cancelled;
    final canBump = !isVoided && _nextStatus(item.status) != null;

    return InkWell(
      onTap: canBump ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _itemStatusColor(item.status),
              ),
            ),
            // Quantity
            SizedBox(
              width: 32,
              child: Text(
                '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}x',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                  color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            // Item name
            Expanded(
              child: Text(
                item.itemName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                  color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            // Notes icon
            if (item.notes != null && item.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.note,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  PrepStatus? _nextStatus(PrepStatus current) => switch (current) {
        PrepStatus.created => PrepStatus.inPrep,
        PrepStatus.inPrep => PrepStatus.ready,
        PrepStatus.ready => PrepStatus.delivered,
        _ => null,
      };

  Color _itemStatusColor(PrepStatus status) => switch (status) {
        PrepStatus.created => Colors.blue,
        PrepStatus.inPrep => Colors.orange,
        PrepStatus.ready => Colors.green,
        PrepStatus.delivered => Colors.grey,
        PrepStatus.cancelled => Colors.pink,
        PrepStatus.voided => Colors.red,
      };
}

// ---------------------------------------------------------------------------
// Table name resolver (same as ScreenOrders)
// ---------------------------------------------------------------------------
class _TableName extends ConsumerWidget {
  const _TableName({required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<BillModel>>(
      stream: ref.watch(billRepositoryProvider).watchByCompany(company.id),
      builder: (context, billSnap) {
        final bills = billSnap.data ?? [];
        final bill = bills.where((b) => b.id == billId).firstOrNull;
        if (bill == null) return const SizedBox.shrink();

        if (bill.isTakeaway) {
          return Text(
            l.billsQuickBill,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          );
        }

        if (bill.tableId == null) return const SizedBox.shrink();

        return StreamBuilder<List<TableModel>>(
          stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
          builder: (context, tableSnap) {
            final tables = tableSnap.data ?? [];
            final table =
                tables.where((t) => t.id == bill.tableId).firstOrNull;
            if (table == null) return const SizedBox.shrink();
            return Text(
              table.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// KDS Status Filter Bar
// ---------------------------------------------------------------------------
class _KdsStatusFilterBar extends StatelessWidget {
  const _KdsStatusFilterBar({
    required this.selected,
    required this.onChanged,
  });
  final Set<PrepStatus>? selected; // null = active
  final ValueChanged<Set<PrepStatus>?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final filters = <(Set<PrepStatus>?, String, Color)>[
      (null, l.ordersFilterActive, Colors.blue),
      ({PrepStatus.created}, l.ordersFilterCreated, Colors.blue),
      ({PrepStatus.inPrep}, l.ordersFilterInPrep, Colors.orange),
      ({PrepStatus.ready}, l.ordersFilterReady, Colors.green),
      ({PrepStatus.delivered}, l.ordersFilterDelivered, Colors.grey),
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
                  showCheckmark: false,
                  backgroundColor: filters[i].$3.withValues(alpha: 0.08),
                  selectedColor: filters[i].$3.withValues(alpha: 0.2),
                  label: SizedBox(
                    width: double.infinity,
                    child:
                        Text(filters[i].$2, textAlign: TextAlign.center),
                  ),
                  selected: _isSelected(filters[i].$1),
                  onSelected: (_) => onChanged(filters[i].$1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSelected(Set<PrepStatus>? filterKey) {
    if (filterKey == null && selected == null) return true;
    if (filterKey == null || selected == null) return false;
    return filterKey.length == selected!.length &&
        filterKey.every((s) => selected!.contains(s));
  }
}
