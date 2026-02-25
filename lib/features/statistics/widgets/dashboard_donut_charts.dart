import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../models/dashboard_data.dart';

class DashboardDonutCharts extends StatelessWidget {
  const DashboardDonutCharts({
    super.key,
    required this.paymentMethods,
    required this.categories,
    required this.moneyFormatter,
  });

  final List<DonutEntry> paymentMethods;
  final List<DonutEntry> categories;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (paymentMethods.isNotEmpty)
          Expanded(
            child: _DonutSection(
              title: l.dashboardPaymentMethods,
              entries: paymentMethods,
              moneyFormatter: moneyFormatter,
            ),
          ),
        if (paymentMethods.isNotEmpty && categories.isNotEmpty)
          const SizedBox(width: 16),
        if (categories.isNotEmpty)
          Expanded(
            child: _DonutSection(
              title: l.dashboardCategories,
              entries: categories,
              moneyFormatter: moneyFormatter,
            ),
          ),
      ],
    );
  }
}

class _DonutSection extends StatelessWidget {
  const _DonutSection({
    required this.title,
    required this.entries,
    required this.moneyFormatter,
  });

  final String title;
  final List<DonutEntry> entries;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 2,
              sections: [
                for (final entry in entries)
                  PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: entry.color,
                    radius: 40,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: entry.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  total > 0
                      ? '${(entry.value / total * 100).toStringAsFixed(1)} %'
                      : '0.0 %',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
