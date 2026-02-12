import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

/// Customer-facing display that shows the current bill items and total.
///
/// This screen is designed for a secondary monitor or a tablet turned toward
/// the customer.  It is read-only — no touch interaction.  All data is
/// streamed reactively from the local database so it updates in real-time
/// as the cashier adds items on the sell screen.
class ScreenCustomerDisplay extends ConsumerWidget {
  const ScreenCustomerDisplay({super.key, this.billId});
  final String? billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    // No active bill → show welcome / idle screen
    if (billId == null) {
      return _IdleDisplay(companyName: company.name);
    }

    return _ActiveDisplay(billId: billId!);
  }
}

// ---------------------------------------------------------------------------
// Idle display — shown when no bill is active
// ---------------------------------------------------------------------------
class _IdleDisplay extends StatelessWidget {
  const _IdleDisplay({required this.companyName});
  final String companyName;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              companyName,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.customerDisplayWelcome,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active display — shows bill items and totals
// ---------------------------------------------------------------------------
class _ActiveDisplay extends ConsumerWidget {
  const _ActiveDisplay({required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: StreamBuilder<BillModel?>(
        stream: ref.watch(billRepositoryProvider).watchById(billId),
        builder: (context, billSnap) {
          final bill = billSnap.data;
          if (bill == null) {
            return Center(
              child: Text(
                l.customerDisplayWelcome,
                style: theme.textTheme.headlineSmall,
              ),
            );
          }

          return Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                ),
                child: Row(
                  children: [
                    Text(
                      l.customerDisplayHeader,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      bill.billNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              // Items list
              Expanded(
                child: StreamBuilder<List<OrderModel>>(
                  stream: ref
                      .watch(orderRepositoryProvider)
                      .watchByBill(billId),
                  builder: (context, orderSnap) {
                    final orders = orderSnap.data ?? [];
                    // Filter out storno orders
                    final activeOrders =
                        orders.where((o) => !o.isStorno).toList();

                    if (activeOrders.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      children: [
                        for (final order in activeOrders)
                          _OrderItemsList(orderId: order.id),
                      ],
                    );
                  },
                ),
              ),
              // Totals footer
              _TotalsFooter(bill: bill),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items list for a single order
// ---------------------------------------------------------------------------
class _OrderItemsList extends ConsumerWidget {
  const _OrderItemsList({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<OrderItemModel>>(
      stream: ref.watch(orderRepositoryProvider).watchOrderItems(orderId),
      builder: (context, snap) {
        final items = snap.data ?? [];
        // Filter out voided/cancelled items
        final activeItems = items
            .where((i) =>
                i.status != PrepStatus.voided &&
                i.status != PrepStatus.cancelled)
            .toList();

        return Column(
          children: [
            for (final item in activeItems) _CustomerItemRow(item: item),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single item row — large, readable
// ---------------------------------------------------------------------------
class _CustomerItemRow extends StatelessWidget {
  const _CustomerItemRow({required this.item});
  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineTotal = (item.salePriceAtt * item.quantity).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Quantity
          SizedBox(
            width: 48,
            child: Text(
              '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}x',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Item name
          Expanded(
            child: Text(
              item.itemName,
              style: theme.textTheme.titleMedium,
            ),
          ),
          // Line total
          Text(
            _formatPrice(lineTotal),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int amountCents) {
    final whole = amountCents ~/ 100;
    return '$whole,-';
  }
}

// ---------------------------------------------------------------------------
// Totals footer
// ---------------------------------------------------------------------------
class _TotalsFooter extends StatelessWidget {
  const _TotalsFooter({required this.bill});
  final BillModel bill;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    // Derive the actual discount in cents from computed totals.
    // bill.discountAmount may store basis points (for percentage discounts),
    // so we cannot sum it directly — instead compute from authoritative totals.
    final totalDiscount =
        bill.subtotalGross - bill.totalGross + bill.roundingAmount;
    final hasDiscount = totalDiscount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          _TotalRow(
            label: l.customerDisplaySubtotal,
            amount: bill.subtotalGross,
            style: theme.textTheme.titleMedium,
          ),
          // Discount (only if applicable)
          if (hasDiscount) ...[
            const SizedBox(height: 4),
            _TotalRow(
              label: l.customerDisplayDiscount,
              amount: -totalDiscount,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Total
          _TotalRow(
            label: l.customerDisplayTotal,
            amount: bill.totalGross,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.style,
  });
  final String label;
  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(_formatPrice(amount), style: style),
      ],
    );
  }

  String _formatPrice(int amountCents) {
    final whole = amountCents ~/ 100;
    return '$whole,-';
  }
}
