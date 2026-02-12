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
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class ScreenOrders extends ConsumerStatefulWidget {
  const ScreenOrders({super.key});

  @override
  ConsumerState<ScreenOrders> createState() => _ScreenOrdersState();
}

class _ScreenOrdersState extends ConsumerState<ScreenOrders> {
  bool _sessionScope = true;
  Set<PrepStatus>? _statusFilter; // null = active (created+inPrep+ready)

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final session = ref.watch(activeRegisterSessionProvider).valueOrNull;
    final since = (_sessionScope && session != null) ? session.openedAt : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.ordersTitle)),
      body: Column(
        children: [
          // Scope toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (final entry in [
                  (true, l.ordersScopeSession),
                  (false, l.ordersScopeAll),
                ]) ...[
                  if (entry.$1 != true) const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(entry.$2, textAlign: TextAlign.center),
                        ),
                        selected: _sessionScope == entry.$1,
                        onSelected: (_) => setState(() => _sessionScope = entry.$1),
                      ),
                    ),
                  ),
                ],
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
                final orders = _applyStatusFilter(allOrders);

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

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
                    final cardWidth = (constraints.maxWidth - 32 - (crossAxisCount - 1) * 8) / crossAxisCount;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final order in orders)
                            SizedBox(
                              width: cardWidth,
                              child: _OrderCard(
                                order: order,
                                onItemStatusChange: (item, status) =>
                                    _changeItemStatus(order, item, status),
                                onVoidItem: (item) => _voidItem(order, item),
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
          _OrderStatusFilterBar(
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

  Future<void> _changeItemStatus(
      OrderModel order, OrderItemModel item, PrepStatus status) async {
    final orderRepo = ref.read(orderRepositoryProvider);
    await orderRepo.updateItemStatus(item.id, order.id, status);
  }

  Future<void> _voidItem(OrderModel order, OrderItemModel item) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.orderItemStornoConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final user = ref.read(activeUserProvider);
    if (user == null) return;

    // Generate storno order number
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    final registerModel = ref.read(activeRegisterProvider).value;
    final regNum = registerModel?.registerNumber ?? 0;
    String stornoNumber = 'X$regNum-0000';
    if (session != null) {
      final sessionRepo = ref.read(registerSessionRepositoryProvider);
      final counter = await sessionRepo.incrementOrderCounter(session.id);
      if (counter is Success<int>) {
        stornoNumber = 'X$regNum-${counter.value.toString().padLeft(4, '0')}';
      }
    }

    final orderRepo = ref.read(orderRepositoryProvider);
    await orderRepo.voidItem(
      orderId: order.id,
      orderItemId: item.id,
      companyId: order.companyId,
      userId: user.id,
      stornoOrderNumber: stornoNumber,
      registerId: registerModel?.id,
    );
    await ref.read(billRepositoryProvider).updateTotals(order.billId);
  }
}

// ---------------------------------------------------------------------------
// Order Card
// ---------------------------------------------------------------------------
class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.onItemStatusChange,
    required this.onVoidItem,
  });
  final OrderModel order;
  final void Function(OrderItemModel, PrepStatus) onItemStatusChange;
  final void Function(OrderItemModel) onVoidItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final isStorno = order.isStorno;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isStorno
            ? const BorderSide(color: Colors.red, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row 1: status dot + order number + storno ref ... time
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(order.status),
                  ),
                ),
                if (isStorno)
                  Text(
                    '${l.ordersStornoPrefix} ',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  order.orderNumber,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isStorno ? Colors.red : null,
                  ),
                ),
                if (isStorno && order.stornoSourceOrderId != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: _StornoRef(
                      billId: order.billId,
                      sourceOrderId: order.stornoSourceOrderId!,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  timeFormat.format(order.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Header row 2: table name ... status label
            Row(
              children: [
                _TableName(billId: order.billId),
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
              stream: ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
              builder: (context, snap) {
                final items = snap.data ?? [];
                return Column(
                  children: [
                    for (final item in items)
                      _OrderItemRow(
                        item: item,
                        canVoid: !isStorno && _isItemActive(item.status),
                        canChangeStatus: !isStorno,
                        onVoid: () => onVoidItem(item),
                        onStatusChange: (status) =>
                            onItemStatusChange(item, status),
                      ),
                  ],
                );
              },
            ),
            // Notes
            if (order.notes != null && order.notes!.isNotEmpty && !isStorno) ...[
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
        ),
      ),
    );
  }

  bool _isItemActive(PrepStatus status) =>
      status == PrepStatus.created ||
      status == PrepStatus.inPrep ||
      status == PrepStatus.ready;

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
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Table name resolver
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
            style: Theme.of(context).textTheme.bodySmall,
          );
        }

        if (bill.tableId == null) return const SizedBox.shrink();

        return StreamBuilder<List<TableModel>>(
          stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
          builder: (context, tableSnap) {
            final tables = tableSnap.data ?? [];
            final table = tables.where((t) => t.id == bill.tableId).firstOrNull;
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
// Order item row
// ---------------------------------------------------------------------------
class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.item,
    required this.canVoid,
    required this.canChangeStatus,
    required this.onVoid,
    required this.onStatusChange,
  });
  final OrderItemModel item;
  final bool canVoid;
  final bool canChangeStatus;
  final VoidCallback onVoid;
  final void Function(PrepStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isVoided =
        item.status == PrepStatus.voided || item.status == PrepStatus.cancelled;
    final price = (item.salePriceAtt * item.quantity).round();
    final next = canChangeStatus ? _nextStatus(item.status) : null;

    return InkWell(
      onTap: canVoid && !isVoided ? onVoid : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _itemStatusColor(item.status),
              ),
            ),
            // Quantity
            SizedBox(
              width: 28,
              child: Text(
                '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}x',
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                  color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            // Item name
            Expanded(
              child: Text(
                item.itemName,
                style: theme.textTheme.bodyMedium?.copyWith(
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
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            // Price
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${price ~/ 100},-',
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                  color: isVoided ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            // Next-status button
            if (next != null)
              SizedBox(
                height: 28,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor:
                        _itemStatusColor(next).withValues(alpha: 0.15),
                    foregroundColor: _itemStatusColor(next),
                    textStyle: theme.textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => onStatusChange(next),
                  child: Text(_nextStatusLabel(next, l)),
                ),
              )
            else if (isVoided)
              Text(
                l.ordersFilterStorno,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
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

  String _nextStatusLabel(PrepStatus status, dynamic l) => switch (status) {
        PrepStatus.inPrep => l.ordersFilterInPrep,
        PrepStatus.ready => l.ordersFilterReady,
        PrepStatus.delivered => l.ordersFilterDelivered,
        _ => '',
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
// Status Filter Bar
// ---------------------------------------------------------------------------
class _OrderStatusFilterBar extends StatelessWidget {
  const _OrderStatusFilterBar({
    required this.selected,
    required this.onChanged,
  });
  final Set<PrepStatus>? selected; // null = active
  final ValueChanged<Set<PrepStatus>?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // (filterKey, label, color)
    final filters = <(Set<PrepStatus>?, String, Color)>[
      (null, l.ordersFilterActive, Colors.blue),
      ({PrepStatus.created}, l.ordersFilterCreated, Colors.blue),
      ({PrepStatus.inPrep}, l.ordersFilterInPrep, Colors.orange),
      ({PrepStatus.ready}, l.ordersFilterReady, Colors.green),
      ({PrepStatus.delivered}, l.ordersFilterDelivered, Colors.grey),
      ({PrepStatus.cancelled, PrepStatus.voided}, l.ordersFilterStorno, Colors.red),
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
                  showCheckmark: false,
                  backgroundColor: filters[i].$3.withValues(alpha: 0.08),
                  selectedColor: filters[i].$3.withValues(alpha: 0.2),
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(filters[i].$2, textAlign: TextAlign.center),
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
