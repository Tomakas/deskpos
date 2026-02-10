import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class SplitBillResult {
  const SplitBillResult({
    required this.orderItemIds,
    required this.payImmediately,
  });

  final List<String> orderItemIds;
  final bool payImmediately;
}

class DialogSplitBill extends ConsumerStatefulWidget {
  const DialogSplitBill({super.key, required this.billId});
  final String billId;

  @override
  ConsumerState<DialogSplitBill> createState() => _DialogSplitBillState();
}

class _DialogSplitBillState extends ConsumerState<DialogSplitBill> {
  final Set<String> _selectedItemIds = {};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 550),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.splitBillTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.splitBillSelectItems,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: StreamBuilder<List<OrderModel>>(
                  stream: ref.watch(orderRepositoryProvider).watchByBill(widget.billId),
                  builder: (context, orderSnap) {
                    final orders = (orderSnap.data ?? []).where((o) =>
                        o.status != PrepStatus.cancelled &&
                        o.status != PrepStatus.voided).toList();

                    if (orders.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, index) =>
                          _buildOrderItems(context, orders[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _selectedItemIds.isNotEmpty
                            ? () => Navigator.pop(
                                  context,
                                  SplitBillResult(
                                    orderItemIds: _selectedItemIds.toList(),
                                    payImmediately: true,
                                  ),
                                )
                            : null,
                        child: Text(
                          l.splitBillPayButton,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _selectedItemIds.isNotEmpty
                            ? () => Navigator.pop(
                                  context,
                                  SplitBillResult(
                                    orderItemIds: _selectedItemIds.toList(),
                                    payImmediately: false,
                                  ),
                                )
                            : null,
                        child: Text(
                          l.splitBillNewBillButton,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.actionCancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, OrderModel order) {
    return StreamBuilder<List<OrderItemModel>>(
      stream: ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
      builder: (context, snap) {
        final items = (snap.data ?? []).where((item) =>
            item.status != PrepStatus.cancelled &&
            item.status != PrepStatus.voided).toList();

        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            for (final item in items)
              CheckboxListTile(
                dense: true,
                value: _selectedItemIds.contains(item.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedItemIds.add(item.id);
                    } else {
                      _selectedItemIds.remove(item.id);
                    }
                  });
                },
                title: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}×',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.itemName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '${_itemTotal(item) ~/ 100} Kč',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  int _itemTotal(OrderItemModel item) {
    final subtotal = (item.salePriceAtt * item.quantity).round();
    if (item.discount > 0) {
      final discount = item.discountType == DiscountType.percent
          ? (subtotal * item.discount / 10000).round()
          : item.discount;
      return subtotal - discount;
    }
    return subtotal;
  }
}
