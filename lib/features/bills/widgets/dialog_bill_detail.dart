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
              width: 600,
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Dialog(
          child: SizedBox(
            width: 700,
            height: 500,
            child: Column(
              children: [
                _buildHeader(context, ref, bill, l),
                const Divider(height: 1),
                Expanded(child: _buildOrderList(context, ref, bill, l)),
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
    final timeFormat = DateFormat('HH:mm', 'cs');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.billDetailBillNumber(bill.billNumber),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                _buildBillLocation(context, ref, bill, l),
                Text(
                  l.billDetailCreated(timeFormat.format(bill.openedAt)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${bill.totalGross ~/ 100} Kč',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBillLocation(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    if (bill.isTakeaway) {
      return Text(l.billDetailTakeaway, style: Theme.of(context).textTheme.bodyMedium);
    }
    if (bill.tableId == null) {
      return Text(l.billDetailNoTable, style: Theme.of(context).textTheme.bodyMedium);
    }
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<TableModel>>(
      stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final tables = snap.data ?? [];
        final table = tables.where((t) => t.id == bill.tableId).firstOrNull;
        return Text(
          table != null ? l.billDetailTable(table.name) : '',
          style: Theme.of(context).textTheme.bodyMedium,
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    return StreamBuilder<List<OrderModel>>(
      stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id),
      builder: (context, snap) {
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return Center(
            child: Text(l.billDetailNoOrders,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) => _OrderCard(order: orders[index]),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final isClosed = bill.status != BillStatus.opened;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel
          if (!isClosed) ...[
            SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                onPressed: () => _cancelBill(context, ref, bill, l),
                child: Text(l.billDetailCancel),
              ),
            ),
            const Spacer(),
          ],
          if (isClosed) const Spacer(),
          // Pay
          if (!isClosed && bill.totalGross > 0) ...[
            SizedBox(
              height: 44,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () => _payBill(context, ref, bill),
                child: Text(l.billDetailPay),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Order
          if (!isClosed) ...[
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/sell/${bill.id}');
                },
                child: Text(l.billDetailOrder),
              ),
            ),
          ],
          if (isClosed)
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.actionClose),
              ),
            ),
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
    }
  }

  Future<void> _payBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    await showDialog(
      context: context,
      builder: (_) => DialogPayment(bill: bill),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final timeFormat = DateFormat('HH:mm', 'cs');
    final statusColor = _statusColor(order.status, context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${order.orderNumber}  ${timeFormat.format(order.createdAt)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusLabel(order.status, l),
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
                if (order.status == PrepStatus.created ||
                    order.status == PrepStatus.inPrep ||
                    order.status == PrepStatus.ready) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<PrepStatus>(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    onSelected: (status) => _changeStatus(ref, status),
                    itemBuilder: (_) => _availableTransitions(order.status, l),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<OrderItemModel>>(
              stream: ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
              builder: (context, snap) {
                final items = snap.data ?? [];
                return Column(
                  children: items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}×',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(child: Text(item.itemName)),
                        Text('${(item.salePriceAtt * item.quantity).round() ~/ 100} Kč'),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
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

  Color _statusColor(PrepStatus status, BuildContext context) {
    return switch (status) {
      PrepStatus.created => Colors.blue,
      PrepStatus.inPrep => Colors.orange,
      PrepStatus.ready => Colors.green,
      PrepStatus.delivered => Colors.grey,
      PrepStatus.cancelled => Colors.red,
      PrepStatus.voided => Colors.red,
    };
  }

  String _statusLabel(PrepStatus status, dynamic l) {
    return switch (status) {
      PrepStatus.created => l.prepStatusCreated,
      PrepStatus.inPrep => l.prepStatusInPrep,
      PrepStatus.ready => l.prepStatusReady,
      PrepStatus.delivered => l.prepStatusDelivered,
      PrepStatus.cancelled => l.prepStatusCancelled,
      PrepStatus.voided => l.prepStatusVoided,
    };
  }
}
