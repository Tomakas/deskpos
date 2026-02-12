import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../settings/widgets/dialog_mode_selector.dart';

/// Customer-facing display that shows the current bill items and total.
///
/// This screen is designed for a secondary monitor or a tablet turned toward
/// the customer.  It is read-only — no touch interaction.  All data is
/// streamed reactively from the local database so it updates in real-time
/// as the cashier adds items on the sell screen.
class ScreenCustomerDisplay extends ConsumerWidget {
  const ScreenCustomerDisplay({super.key, this.registerId});
  final String? registerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final l = context.l10n;

    final child = registerId == null
        ? _IdleDisplay(companyName: company.name)
        : _ActiveDisplay(registerId: registerId!);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(l.customerDisplayTitle)),
          body: child,
        ),
        // Mode-switch button — absolute top-right, over AppBar
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: IconButton.filled(
              iconSize: 32,
              style: IconButton.styleFrom(
                minimumSize: const Size(64, 64),
              ),
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const DialogModeSelector(
                  currentMode: RegisterMode.customerDisplay,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

    return Center(
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
    );
  }
}

// ---------------------------------------------------------------------------
// Active display — watches register's activeBillId
// ---------------------------------------------------------------------------
class _ActiveDisplay extends ConsumerWidget {
  const _ActiveDisplay({required this.registerId});
  final String registerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(currentCompanyProvider);

    return StreamBuilder<RegisterModel?>(
      stream: ref.watch(registerRepositoryProvider).watchById(registerId),
      builder: (context, regSnap) {
        final register = regSnap.data;
        final activeBillId = register?.activeBillId;

        if (activeBillId == null) {
          return _IdleDisplay(companyName: company?.name ?? '');
        }

        return _BillDisplay(
          billId: activeBillId,
          registerId: registerId,
          displayCartJson: register?.displayCartJson,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bill display — shows a specific bill's items and totals
// ---------------------------------------------------------------------------
class _BillDisplay extends ConsumerWidget {
  const _BillDisplay({
    required this.billId,
    required this.registerId,
    this.displayCartJson,
  });
  final String billId;
  final String registerId;
  final String? displayCartJson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);

    return StreamBuilder<BillModel?>(
      stream: ref.watch(billRepositoryProvider).watchById(billId),
      builder: (context, billSnap) {
        final bill = billSnap.data;
        if (bill == null) {
          return _IdleDisplay(companyName: company?.name ?? '');
        }

        // Show "Thank you" for paid bills
        if (bill.status == BillStatus.paid) {
          return _ThankYouDisplay(
            bill: bill,
            registerId: registerId,
          );
        }

        // Show idle for cancelled or refunded bills
        if (bill.status != BillStatus.opened) {
          return _IdleDisplay(companyName: company?.name ?? '');
        }

        // Parse preview cart items from register's displayCartJson
        final previewItems = _parseCartJson(displayCartJson);

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
            // Items list — real orders or preview cart items
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: ref
                    .watch(orderRepositoryProvider)
                    .watchByBill(bill.id),
                builder: (context, orderSnap) {
                  final orders = orderSnap.data ?? [];
                  // Filter out storno orders
                  final activeOrders =
                      orders.where((o) => !o.isStorno).toList();

                  if (activeOrders.isNotEmpty) {
                    // Show real order items
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      children: [
                        for (final order in activeOrders)
                          _OrderItemsList(orderId: order.id),
                      ],
                    );
                  }

                  // No real orders yet — show preview cart items
                  return _DisplayCartPreview(items: previewItems);
                },
              ),
            ),
            // Totals footer
            _TotalsFooter(bill: bill, previewItems: previewItems),
          ],
        );
      },
    );
  }

  static List<_PreviewItem> _parseCartJson(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return _PreviewItem(
          name: map['name'] as String,
          quantity: (map['qty'] as num).toDouble(),
          unitPrice: map['price'] as int,
          notes: map['notes'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class _PreviewItem {
  const _PreviewItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });
  final String name;
  final double quantity;
  final int unitPrice;
  final String? notes;
}

// ---------------------------------------------------------------------------
// Preview cart items from register's displayCartJson
// ---------------------------------------------------------------------------
class _DisplayCartPreview extends StatelessWidget {
  const _DisplayCartPreview({required this.items});
  final List<_PreviewItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _PreviewItemRow(item: item);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single preview item row — mirrors _CustomerItemRow style
// ---------------------------------------------------------------------------
class _PreviewItemRow extends StatelessWidget {
  const _PreviewItemRow({required this.item});
  final _PreviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineTotal = (item.unitPrice * item.quantity).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}x',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.name,
              style: theme.textTheme.titleMedium,
            ),
          ),
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
// "Thank you" display — shown after payment for ~5 seconds
// ---------------------------------------------------------------------------
class _ThankYouDisplay extends ConsumerStatefulWidget {
  const _ThankYouDisplay({required this.bill, required this.registerId});
  final BillModel bill;
  final String registerId;

  @override
  ConsumerState<_ThankYouDisplay> createState() => _ThankYouDisplayState();
}

class _ThankYouDisplayState extends ConsumerState<_ThankYouDisplay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      ref
          .read(registerRepositoryProvider)
          .setActiveBill(widget.registerId, null);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 24),
          Text(
            l.customerDisplayPaid,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatPrice(widget.bill.totalGross),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.customerDisplayThankYou,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
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
  const _TotalsFooter({required this.bill, required this.previewItems});
  final BillModel bill;
  final List<_PreviewItem> previewItems;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    // If the bill has real totals, use them directly
    if (bill.totalGross > 0) {
      return _buildFooter(context, l, theme, bill.subtotalGross, bill.totalGross, bill.roundingAmount);
    }

    // Otherwise compute from preview cart items
    int previewTotal = 0;
    for (final item in previewItems) {
      previewTotal += (item.unitPrice * item.quantity).round();
    }
    return _buildFooter(context, l, theme, previewTotal, previewTotal, 0);
  }

  Widget _buildFooter(BuildContext context, dynamic l, ThemeData theme, int subtotal, int total, int rounding) {
    final totalDiscount = subtotal - total + rounding;
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
            amount: subtotal,
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
            amount: total,
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
