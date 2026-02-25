import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../models/dashboard_data.dart';

class DashboardRevenueChart extends StatelessWidget {
  const DashboardRevenueChart({
    super.key,
    required this.entries,
    required this.moneyFormatter,
  });

  final List<RevenueBarEntry> entries;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final maxValue = entries.fold<int>(0, (m, e) => math.max(m, e.value.abs()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dashboardRevenueOverTime,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const leftReserved = 60.0;
              final chartWidth = constraints.maxWidth - leftReserved;

              // Calculate label interval from available width
              final maxLabelLen = entries.fold<int>(
                  0, (m, e) => math.max(m, e.label.length));
              // ~6px per character at fontSize 10 + 8px padding
              final estLabelWidth = maxLabelLen * 6.0 + 8.0;
              final slotWidth =
                  entries.isNotEmpty ? chartWidth / entries.length : 100.0;
              final labelInterval =
                  (estLabelWidth / slotWidth).ceil().clamp(1, 10);
              // 60% of the slot for the bar, 40% gap
              final barWidth = entries.isNotEmpty
                  ? (chartWidth / entries.length * 0.8).clamp(4.0, 40.0)
                  : 16.0;

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue > 0 ? maxValue * 1.1 : 100,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = entries[group.x];
                        return BarTooltipItem(
                          '${entry.label}\n${moneyFormatter(entry.value)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          if (index % labelInterval != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entries[index].label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: leftReserved,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max || value == meta.min) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              moneyFormatter(value.round()),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue > 0 ? maxValue / 4 : 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < entries.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: entries[i].value.toDouble(),
                            color: theme.colorScheme.primary,
                            width: barWidth,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
