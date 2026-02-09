import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import 'dialog_payment.dart';

class DialogBillDetail extends ConsumerWidget {
  const DialogBillDetail({super.key, required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<BillModel?>(
      stream: ref.watch(billRepositoryProvider).watchById(billId),
      builder: (context, billSnap) {
        final bill = billSnap.data;
        if (bill == null) {
          return const Dialog(
            child: SizedBox(
              width: 700,
              height: 500,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Dialog(
          child: SizedBox(
            width: 750,
            height: 520,
            child: Column(
              children: [
                _buildHeader(context, ref, bill, l),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      // Left icon strip
                      _buildLeftIcons(context, ref, bill, l),
                      const VerticalDivider(width: 1),
                      // Center: order history
                      Expanded(child: _buildOrderList(context, ref, bill, l)),
                      const VerticalDivider(width: 1),
                      // Right action buttons
                      _buildRightButtons(context, l),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(context, ref, bill, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final dateFormat = DateFormat('d.M.yyyy  HH:mm', 'cs');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill title (table name or takeaway)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillTitle(context, ref, bill, l),
                const SizedBox(height: 2),
                Text(
                  l.billDetailTotalSpent('${bill.totalGross ~/ 100},- Kč'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Dates
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l.billDetailCreatedAt(dateFormat.format(bill.openedAt)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                StreamBuilder<List<OrderModel>>(
                  stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id),
                  builder: (context, snap) {
                    final orders = snap.data ?? [];
                    if (orders.isEmpty) return const SizedBox.shrink();
                    final lastOrder = orders.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
                    return Text(
                      l.billDetailLastOrderAt(dateFormat.format(lastOrder.createdAt)),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTitle(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    if (bill.isTakeaway) {
      return Text(l.billsQuickBill, style: Theme.of(context).textTheme.titleLarge);
    }
    if (bill.tableId == null) {
      return Text(
        '${l.billDetailBillNumber(bill.billNumber)} - ${l.billDetailNoTable}',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<TableModel>>(
      stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final tables = snap.data ?? [];
        final table = tables.where((t) => t.id == bill.tableId).firstOrNull;
        return Text(
          table?.name ?? bill.billNumber,
          style: Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }

  Widget _buildLeftIcons(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final isClosed = bill.status != BillStatus.opened;

    return SizedBox(
      width: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Up arrow (disabled)
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            color: Colors.blue,
            onPressed: null,
            tooltip: null,
          ),
          // Down arrow (disabled)
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            color: Colors.blue,
            onPressed: null,
            tooltip: null,
          ),
          const SizedBox(height: 8),
          // Cancel (X)
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            color: Colors.red,
            onPressed: isClosed ? null : () => _cancelBill(context, ref, bill, l),
          ),
          const SizedBox(height: 8),
          // Add order (+)
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            color: Colors.teal,
            onPressed: isClosed
                ? null
                : () {
                    Navigator.pop(context);
                    context.push('/sell/${bill.id}');
                  },
          ),
          const SizedBox(height: 8),
          // Menu (disabled)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            l.billDetailOrderHistory,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // Order items
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id),
            builder: (context, snap) {
              final orders = snap.data ?? [];
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    l.billDetailNoOrders,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: orders.length,
                itemBuilder: (context, index) => _OrderSection(order: orders[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRightButtons(BuildContext context, dynamic l) {
    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            _SideButton(label: l.billDetailCustomer, onPressed: null),
            const SizedBox(height: 4),
            _SideButton(label: l.billDetailMove, onPressed: null),
            const SizedBox(height: 4),
            _SideButton(label: l.billDetailMerge, onPressed: null),
            const SizedBox(height: 4),
            _SideButton(label: l.billDetailSplit, onPressed: null),
            const SizedBox(height: 4),
            _SideButton(label: l.billDetailSummary, onPressed: null),
            const Spacer(),
            _SideButton(label: l.billDetailPrint, onPressed: null, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final isClosed = bill.status != BillStatus.opened;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Close
          SizedBox(
            height: 44,
            width: 130,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isClosed ? null : Colors.red.shade400,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionClose),
            ),
          ),
          if (!isClosed && bill.totalGross > 0) ...[
            const SizedBox(width: 12),
            // Pay
            SizedBox(
              height: 44,
              width: 130,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _payBill(context, ref, bill),
                child: Text(l.billDetailPay),
              ),
            ),
          ],
          if (!isClosed) ...[
            const SizedBox(width: 12),
            // Order
            SizedBox(
              height: 44,
              width: 130,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/sell/${bill.id}');
                },
                child: Text(l.billDetailOrder),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelBill(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.billDetailConfirmCancel),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.cancelBill(bill.id);
    if (result is Success) {
      await repo.updateTotals(bill.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _payBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(bill: bill),
    );
    if (paid == true && context.mounted) {
      Navigator.pop(context);
    }
  }
}

// ---------------------------------------------------------------------------
// Side button for right panel
// ---------------------------------------------------------------------------
class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.onPressed, this.color});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: color != null
            ? FilledButton.styleFrom(backgroundColor: color!.withValues(alpha: 0.2))
            : null,
        child: Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order section (shows items inline, with status)
// ---------------------------------------------------------------------------
class _OrderSection extends ConsumerWidget {
  const _OrderSection({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final timeFormat = DateFormat('HH:mm', 'cs');
    final statusColor = _statusColor(order.status);

    return StreamBuilder<List<OrderItemModel>>(
      stream: ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return Column(
          children: [
            for (final item in items)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        timeFormat.format(order.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ks',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Text(item.itemName, style: Theme.of(context).textTheme.bodyMedium)),
                    SizedBox(
                      width: 70,
                      child: Text(
                        '${(item.salePriceAtt * item.quantity).round() ~/ 100} Kč',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Status change popup
                    if (order.status == PrepStatus.created ||
                        order.status == PrepStatus.inPrep ||
                        order.status == PrepStatus.ready)
                      PopupMenuButton<PrepStatus>(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        onSelected: (status) => _changeStatus(ref, status),
                        itemBuilder: (_) => _availableTransitions(order.status, l),
                      )
                    else
                      const SizedBox(width: 32),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _changeStatus(WidgetRef ref, PrepStatus status) {
    final repo = ref.read(orderRepositoryProvider);
    switch (status) {
      case PrepStatus.inPrep:
        repo.startPreparation(order.id);
      case PrepStatus.ready:
        repo.markReady(order.id);
      case PrepStatus.delivered:
        repo.markDelivered(order.id);
      case PrepStatus.cancelled:
        repo.cancelOrder(order.id);
      case PrepStatus.voided:
        repo.voidOrder(order.id);
      default:
        break;
    }
  }

  List<PopupMenuEntry<PrepStatus>> _availableTransitions(PrepStatus current, dynamic l) {
    switch (current) {
      case PrepStatus.created:
        return [
          PopupMenuItem(value: PrepStatus.inPrep, child: Text(l.prepStatusInPrep)),
          PopupMenuItem(value: PrepStatus.cancelled, child: Text(l.prepStatusCancelled)),
        ];
      case PrepStatus.inPrep:
        return [
          PopupMenuItem(value: PrepStatus.ready, child: Text(l.prepStatusReady)),
          PopupMenuItem(value: PrepStatus.voided, child: Text(l.prepStatusVoided)),
        ];
      case PrepStatus.ready:
        return [
          PopupMenuItem(value: PrepStatus.delivered, child: Text(l.prepStatusDelivered)),
          PopupMenuItem(value: PrepStatus.voided, child: Text(l.prepStatusVoided)),
        ];
      default:
        return [];
    }
  }

  Color _statusColor(PrepStatus status) {
    return switch (status) {
      PrepStatus.created => Colors.blue,
      PrepStatus.inPrep => Colors.orange,
      PrepStatus.ready => Colors.green,
      PrepStatus.delivered => Colors.grey,
      PrepStatus.cancelled => Colors.red,
      PrepStatus.voided => Colors.red,
    };
  }
}
