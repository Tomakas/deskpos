import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/data/models/reservation_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_date_range_selector.dart';

class ReservationBarChart extends StatelessWidget {
  const ReservationBarChart({
    super.key,
    required this.reservations,
    required this.period,
    required this.dateFrom,
    required this.dateTo,
  });

  final List<ReservationModel> reservations;
  final DatePeriod period;
  final DateTime dateFrom;
  final DateTime dateTo;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final entries = _aggregate();

    if (entries.isEmpty) {
      return Center(child: Text(l.reservationChartNoData));
    }

    final maxValue = entries.fold<int>(0, (m, e) => math.max(m, e.count));

    return SizedBox(
      height: 280,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const leftReserved = 40.0;
          final chartWidth = constraints.maxWidth - leftReserved;

          final maxLabelLen = entries.fold<int>(0, (m, e) => math.max(m, e.label.length));
          final estLabelWidth = maxLabelLen * 6.0 + 8.0;
          final slotWidth = entries.isNotEmpty ? chartWidth / entries.length : 100.0;
          final labelInterval = (estLabelWidth / slotWidth).ceil().clamp(1, 10);
          final barWidth = entries.isNotEmpty
              ? (chartWidth / entries.length * 0.8).clamp(4.0, 40.0)
              : 16.0;

          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue > 0 ? maxValue * 1.2 : 5,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final entry = entries[group.x];
                    return BarTooltipItem(
                      '${entry.label}\n${entry.count}',
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
                    interval: maxValue > 4 ? (maxValue / 4).ceilToDouble() : 1,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min) {
                        return const SizedBox.shrink();
                      }
                      if (value != value.roundToDouble()) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          value.toInt().toString(),
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
                horizontalInterval: maxValue > 4 ? (maxValue / 4).ceilToDouble() : 1,
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
                        toY: entries[i].count.toDouble(),
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
    );
  }

  List<({String label, int count})> _aggregate() {
    if (reservations.isEmpty) return [];

    switch (period) {
      case DatePeriod.week:
        return _aggregateByDay();
      case DatePeriod.month:
        return _aggregateByDay();
      case DatePeriod.year:
        return _aggregateByMonth();
      case DatePeriod.custom:
        final days = dateTo.difference(dateFrom).inDays + 1;
        if (days <= 31) return _aggregateByDay();
        return _aggregateByWeek();
      case DatePeriod.day:
        return _aggregateByDay();
    }
  }

  List<({String label, int count})> _aggregateByDay() {
    final days = dateTo.difference(dateFrom).inDays + 1;
    final counts = <int, int>{};
    for (final r in reservations) {
      final dayIndex = r.reservationDate.difference(dateFrom).inDays;
      if (dayIndex >= 0 && dayIndex < days) {
        counts[dayIndex] = (counts[dayIndex] ?? 0) + 1;
      }
    }

    return [
      for (int i = 0; i < days; i++)
        (
          label: '${dateFrom.add(Duration(days: i)).day}',
          count: counts[i] ?? 0,
        ),
    ];
  }

  List<({String label, int count})> _aggregateByMonth() {
    const monthLabels = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final counts = <int, int>{};
    for (final r in reservations) {
      final m = r.reservationDate.month;
      counts[m] = (counts[m] ?? 0) + 1;
    }

    return [
      for (int m = 1; m <= 12; m++)
        (label: monthLabels[m], count: counts[m] ?? 0),
    ];
  }

  List<({String label, int count})> _aggregateByWeek() {
    // Group by ISO week starting from dateFrom
    final totalDays = dateTo.difference(dateFrom).inDays + 1;
    final weekCount = (totalDays / 7).ceil();
    final counts = <int, int>{};

    for (final r in reservations) {
      final dayIndex = r.reservationDate.difference(dateFrom).inDays;
      if (dayIndex >= 0 && dayIndex < totalDays) {
        final weekIndex = dayIndex ~/ 7;
        counts[weekIndex] = (counts[weekIndex] ?? 0) + 1;
      }
    }

    return [
      for (int w = 0; w < weekCount; w++)
        (
          label: '${dateFrom.add(Duration(days: w * 7)).day}/${dateFrom.add(Duration(days: w * 7)).month}',
          count: counts[w] ?? 0,
        ),
    ];
  }
}
