import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';

class DashboardHeatmap extends StatelessWidget {
  const DashboardHeatmap({
    super.key,
    required this.data,
    required this.moneyFormatter,
  });

  /// [7 days (Mon=0..Sun=6)][24 hours] average revenue in cents.
  final List<List<double>> data;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dayLabels = [
      l.heatmapMon,
      l.heatmapTue,
      l.heatmapWed,
      l.heatmapThu,
      l.heatmapFri,
      l.heatmapSat,
      l.heatmapSun,
    ];

    // Auto-detect operating hours: first/last hour with data ±1 padding
    int firstHour = 23;
    int lastHour = 0;
    double maxVal = 0;
    for (final row in data) {
      for (int h = 0; h < 24; h++) {
        if (row[h] > 0) {
          firstHour = math.min(firstHour, h);
          lastHour = math.max(lastHour, h);
          maxVal = math.max(maxVal, row[h]);
        }
      }
    }

    // Fallback if no data
    if (maxVal == 0) return const SizedBox.shrink();

    // Add ±1 padding
    firstHour = math.max(0, firstHour - 1);
    lastHour = math.min(23, lastHour + 1);

    // Fallback range
    if (firstHour > lastHour) {
      firstHour = 8;
      lastHour = 22;
    }

    final hours = List.generate(lastHour - firstHour + 1, (i) => firstHour + i);
    final primaryColor = theme.colorScheme.primary;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dashboardHeatmap,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Header row with hour labels
        Row(
          children: [
            const SizedBox(width: 32), // day label space
            for (final h in hours)
              Expanded(
                child: Text(
                  '$h',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Grid rows
        for (int d = 0; d < 7; d++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    dayLabels[d],
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                for (final h in hours)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Tooltip(
                        message:
                            '${dayLabels[d]} $h:00 — ${moneyFormatter(data[d][h].round())}',
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: data[d][h] > 0
                                ? primaryColor.withValues(
                                    alpha: data[d][h] / maxVal * 0.85 + 0.05)
                                : emptyColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l.heatmapLow,
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(width: 4),
            for (int i = 0; i < 5; i++)
              Container(
                width: 16,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: i == 0
                      ? emptyColor
                      : primaryColor.withValues(alpha: i / 4 * 0.85 + 0.05),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            const SizedBox(width: 4),
            Text(
              l.heatmapHigh,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
