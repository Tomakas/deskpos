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
    required this.topProductByRevenue,
    required this.onTopProductToggleChanged,
    required this.moneyFormatter,
    required this.qtyFormatter,
    required this.locale,
  });

  final DashboardData data;
  final bool topProductByRevenue;
  final ValueChanged<bool> onTopProductToggleChanged;
  final String Function(int) moneyFormatter;
  final String Function(double) qtyFormatter;
  final String locale;

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
            moneyFormatter: moneyFormatter,
          ),
          if (data.revenueByPeriod.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DashboardRevenueChart(
                  entries: data.revenueByPeriod,
                  moneyFormatter: moneyFormatter,
                ),
              ),
            ),
          ],
          if (data.paymentMethodBreakdown.isNotEmpty ||
              data.categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DashboardDonutCharts(
                  paymentMethods: data.paymentMethodBreakdown,
                  categories: data.categoryBreakdown,
                  moneyFormatter: moneyFormatter,
                  locale: locale,
                ),
              ),
            ),
          ],
          if (data.topProducts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DashboardTopProducts(
                  products: data.topProducts,
                  byRevenue: topProductByRevenue,
                  onToggleChanged: onTopProductToggleChanged,
                  moneyFormatter: moneyFormatter,
                  qtyFormatter: qtyFormatter,
                ),
              ),
            ),
          ],
          if (data.heatmapData.any((row) => row.any((v) => v > 0))) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DashboardHeatmap(
                  data: data.heatmapData,
                  moneyFormatter: moneyFormatter,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
