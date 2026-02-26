import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_item_modifier_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class SplitItem {
  const SplitItem({required this.orderItemId, required this.moveQuantity});
  final String orderItemId;
  final double moveQuantity;
}

class SplitBillResult {
  const SplitBillResult({required this.items, required this.payImmediately});
  final List<SplitItem> items;
  final bool payImmediately;
}

class DialogSplitBill extends ConsumerStatefulWidget {
  const DialogSplitBill({
    super.key,
    required this.billId,
    required this.billNumber,
  });
  final String billId;
  final String billNumber;

  @override
  ConsumerState<DialogSplitBill> createState() => _DialogSplitBillState();
}

class _DialogSplitBillState extends ConsumerState<DialogSplitBill> {
  // itemId -> units moved to right panel
  final Map<String, double> _moveQuantities = {};

  // Cached modifiers per order item (loaded once, don't change during split)
  final Map<String, List<OrderItemModifierModel>> _modsByItem = {};
  final Set<String> _modLoadingIds = {};

  void _ensureModifiersLoaded(List<OrderItemModel> items) {
    final modRepo = ref.read(orderItemModifierRepositoryProvider);
    for (final item in items) {
      if (!_modsByItem.containsKey(item.id) && !_modLoadingIds.contains(item.id)) {
        _modLoadingIds.add(item.id);
        modRepo.getByOrderItem(item.id).then((mods) {
          if (mounted) {
            setState(() => _modsByItem[item.id] = mods);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return PosDialogShell(
      title: l.splitBillTitle,
      titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      maxWidth: 700,
      maxHeight: 600,
      expandHeight: true,
      children: [
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: ref.watch(orderRepositoryProvider).watchByBill(widget.billId),
            builder: (context, orderSnap) {
              final orders = (orderSnap.data ?? []).where((o) =>
                  o.status != PrepStatus.cancelled &&
                  o.status != PrepStatus.voided &&
                  !o.isStorno).toList();

              return _buildOrderItemsStream(context, orders, l);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
      bottomActions: _buildActions(context, l),
    );
  }

  Widget _buildOrderItemsStream(
    BuildContext context,
    List<OrderModel> orders,
    dynamic l,
  ) {
    if (orders.isEmpty) {
      return _buildPanels(context, [], l);
    }

    // Collect items from all orders using nested StreamBuilders
    return _NestedOrderItemsBuilder(
      orders: orders,
      builder: (allItems) {
        final filtered = allItems.where((item) =>
            item.status != PrepStatus.cancelled &&
            item.status != PrepStatus.voided).toList();
        _ensureModifiersLoaded(filtered);
        return _buildPanels(context, filtered, l);
      },
    );
  }

  Widget _buildPanels(
    BuildContext context,
    List<OrderItemModel> allItems,
    dynamic l,
  ) {
    return Row(
      children: [
        Expanded(child: _buildPanel(context, allItems, isSource: true)),
        const VerticalDivider(width: 1),
        Expanded(child: _buildPanel(context, allItems, isSource: false)),
      ],
    );
  }

  Widget _buildActions(BuildContext context, dynamic l) {
    final hasSelection = _moveQuantities.isNotEmpty;

    return PosDialogActions(
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: hasSelection
              ? () => _returnResult(payImmediately: true)
              : null,
          child: Text(
            l.splitBillPayButton,
            textAlign: TextAlign.center,
          ),
        ),
        FilledButton(
          onPressed: hasSelection
              ? () => _returnResult(payImmediately: false)
              : null,
          child: Text(
            l.splitBillNewBillButton,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context,
    List<OrderItemModel> allItems, {
    required bool isSource,
  }) {
    final l = context.l10n;

    // Build display list: items with qty > 0 on this side
    final displayItems = <_PanelItem>[];
    for (final item in allItems) {
      final moved = _moveQuantities[item.id] ?? 0.0;
      final displayQty = isSource ? item.quantity - moved : moved;
      if (displayQty > 0) {
        displayItems.add(_PanelItem(item: item, displayQty: displayQty));
      }
    }

    // Calculate panel total (including modifiers)
    int panelTotal = 0;
    for (final pi in displayItems) {
      panelTotal += _displayTotal(pi.item, pi.displayQty);
    }

    final headerLabel = isSource
        ? l.splitBillSourceLabel(widget.billNumber)
        : l.splitBillTargetLabel;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  headerLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${l.splitBillTotal}: ${ref.money(panelTotal)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Items
        Expanded(
          child: displayItems.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    final pi = displayItems[index];
                    return _buildItemRow(context, pi, isSource: isSource);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    _PanelItem pi, {
    required bool isSource,
  }) {
    final item = pi.item;
    final displayQty = pi.displayQty;
    final qtyStr = '${ref.fmtQty(displayQty, maxDecimals: 1)}\u00d7';
    final lineTotal = _displayTotal(item, displayQty);
    final mods = _modsByItem[item.id] ?? [];

    return InkWell(
      onTap: () => _tapItem(item, fromSource: isSource),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    qtyStr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.itemName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  ref.money(lineTotal),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (mods.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 44, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final mod in mods)
                      Text(
                        '+ ${mod.modifierItemName}${mod.unitPrice > 0 ? '  ${ref.money(mod.unitPrice)}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _tapItem(OrderItemModel item, {required bool fromSource}) {
    setState(() {
      final current = _moveQuantities[item.id] ?? 0.0;
      final isInteger = item.quantity == item.quantity.roundToDouble();
      final step = isInteger ? 1.0 : item.quantity;

      if (fromSource) {
        // Move one unit from left to right
        final remaining = item.quantity - current;
        if (remaining > 0) {
          _moveQuantities[item.id] =
              (current + step).clamp(0.0, item.quantity);
        }
      } else {
        // Return one unit from right to left
        if (current > 0) {
          final newVal = current - step;
          if (newVal <= 0.0) {
            _moveQuantities.remove(item.id);
          } else {
            _moveQuantities[item.id] = newVal;
          }
        }
      }
    });
  }

  /// Total price for displayQty units of an item, including modifiers.
  int _displayTotal(OrderItemModel item, double displayQty) {
    // Base item subtotal for full quantity
    int fullSubtotal = (item.salePriceAtt * item.quantity).round();

    // Add modifier costs
    final mods = _modsByItem[item.id] ?? [];
    for (final mod in mods) {
      fullSubtotal += (mod.unitPrice * mod.quantity * item.quantity).round();
    }

    // Apply discount
    int fullDiscount = 0;
    if (item.discount > 0) {
      fullDiscount = item.discountType == DiscountType.percent
          ? (fullSubtotal * item.discount / 10000).round()
          : item.discount;
    }
    final fullTotal = fullSubtotal - fullDiscount;
    // Proportional to displayQty
    return (fullTotal * displayQty / item.quantity).round();
  }

  void _returnResult({required bool payImmediately}) {
    final items = _moveQuantities.entries
        .map((e) => SplitItem(orderItemId: e.key, moveQuantity: e.value))
        .toList();
    Navigator.pop(
      context,
      SplitBillResult(items: items, payImmediately: payImmediately),
    );
  }
}

/// Helper to flatten order items from multiple orders via nested StreamBuilders.
class _NestedOrderItemsBuilder extends ConsumerWidget {
  const _NestedOrderItemsBuilder({
    required this.orders,
    required this.builder,
  });
  final List<OrderModel> orders;
  final Widget Function(List<OrderItemModel>) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildNested(context, ref, 0, []);
  }

  Widget _buildNested(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<OrderItemModel> accumulated,
  ) {
    if (index >= orders.length) {
      return builder(accumulated);
    }

    return StreamBuilder<List<OrderItemModel>>(
      stream: ref.watch(orderRepositoryProvider).watchOrderItems(orders[index].id),
      builder: (context, snap) {
        final items = snap.data ?? [];
        final combined = [...accumulated, ...items];
        return _buildNested(context, ref, index + 1, combined);
      },
    );
  }
}

class _PanelItem {
  const _PanelItem({required this.item, required this.displayQty});
  final OrderItemModel item;
  final double displayQty;
}
