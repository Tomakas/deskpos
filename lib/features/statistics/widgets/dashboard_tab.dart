import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../models/dashboard_data.dart';
import 'dashboard_donut_charts.dart';
import 'dashboard_heatmap.dart';
import 'dashboard_revenue_chart.dart';
import 'dashboard_summary_cards.dart';
import 'dashboard_top_products.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({
    super.key,
    required this.data,
    required this.showComparison,
    required this.onComparisonChanged,
    required this.topProductByRevenue,
    required this.onTopProductToggleChanged,
    required this.moneyFormatter,
    required this.dateFormatter,
  });

  final DashboardData data;
  final bool showComparison;
  final ValueChanged<bool> onComparisonChanged;
  final bool topProductByRevenue;
  final ValueChanged<bool> onTopProductToggleChanged;
  final String Function(int) moneyFormatter;
  final String Function(DateTime) dateFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    // Check if all data is empty/zero
    final isEmpty = data.billCount == 0 &&
        data.totalRevenue == 0 &&
        data.revenueByPeriod.isEmpty &&
        data.paymentMethodBreakdown.isEmpty &&
        data.topProducts.isEmpty;

    if (isEmpty) {
      return Center(child: Text(l.statsEmpty));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSummaryCards(
            data: data,
            showComparison: showComparison,
            onComparisonChanged: onComparisonChanged,
            moneyFormatter: moneyFormatter,
          ),
          const SizedBox(height: 24),
          if (data.revenueByPeriod.isNotEmpty) ...[
            DashboardRevenueChart(
              entries: data.revenueByPeriod,
              moneyFormatter: moneyFormatter,
            ),
            const SizedBox(height: 24),
          ],
          if (data.paymentMethodBreakdown.isNotEmpty ||
              data.categoryBreakdown.isNotEmpty) ...[
            DashboardDonutCharts(
              paymentMethods: data.paymentMethodBreakdown,
              categories: data.categoryBreakdown,
              moneyFormatter: moneyFormatter,
            ),
            const SizedBox(height: 24),
          ],
          if (data.topProducts.isNotEmpty) ...[
            DashboardTopProducts(
              products: data.topProducts,
              byRevenue: topProductByRevenue,
              onToggleChanged: onTopProductToggleChanged,
              moneyFormatter: moneyFormatter,
            ),
            const SizedBox(height: 24),
          ],
          if (data.heatmapData.any((row) => row.any((v) => v > 0)))
            DashboardHeatmap(
              data: data.heatmapData,
              moneyFormatter: moneyFormatter,
            ),
        ],
      ),
    );
  }
}
