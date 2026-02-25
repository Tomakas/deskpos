import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../models/dashboard_data.dart';

class DashboardTopProducts extends StatelessWidget {
  const DashboardTopProducts({
    super.key,
    required this.products,
    required this.byRevenue,
    required this.onToggleChanged,
    required this.moneyFormatter,
  });

  final List<TopProductEntry> products;
  final bool byRevenue;
  final ValueChanged<bool> onToggleChanged;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final sorted = [...products]..sort((a, b) => byRevenue
        ? b.revenue.compareTo(a.revenue)
        : b.quantity.compareTo(a.quantity));
    final maxRevenue =
        sorted.fold<int>(0, (m, p) => math.max(m, p.revenue));
    final maxQty =
        sorted.fold<double>(0, (m, p) => math.max(m, p.quantity));
    final maxValue = byRevenue ? maxRevenue.toDouble() : maxQty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.dashboardTopProducts,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            FilterChip(
              label: Text(l.dashboardByQuantity),
              selected: !byRevenue,
              onSelected: (_) => onToggleChanged(false),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text(l.dashboardByRevenue),
              selected: byRevenue,
              onSelected: (_) => onToggleChanged(true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final product in sorted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fraction = maxValue > 0
                          ? (byRevenue
                                  ? product.revenue.toDouble()
                                  : product.quantity) /
                              maxValue
                          : 0.0;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 18,
                          width: constraints.maxWidth * fraction,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    product.quantity == product.quantity.roundToDouble()
                        ? '${product.quantity.round()}'
                        : product.quantity.toStringAsFixed(1),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    moneyFormatter(product.revenue),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
