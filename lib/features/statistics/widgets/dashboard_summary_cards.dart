import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../models/dashboard_data.dart';

class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({
    super.key,
    required this.data,
    required this.showComparison,
    required this.onComparisonChanged,
    required this.moneyFormatter,
  });

  final DashboardData data;
  final bool showComparison;
  final ValueChanged<bool> onComparisonChanged;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilterChip(
            label: Text(l.dashboardShowComparison),
            selected: showComparison,
            onSelected: onComparisonChanged,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCard(
              context,
              label: l.dashboardRevenue,
              value: moneyFormatter(data.totalRevenue),
              prevValue: data.prevTotalRevenue,
              currentValue: data.totalRevenue,
            ),
            const SizedBox(width: 8),
            _buildCard(
              context,
              label: l.dashboardBillCount,
              value: '${data.billCount}',
              prevValue: data.prevBillCount,
              currentValue: data.billCount,
            ),
            const SizedBox(width: 8),
            _buildCard(
              context,
              label: l.dashboardAverage,
              value: moneyFormatter(data.averageBill),
              prevValue: data.prevAverageBill,
              currentValue: data.averageBill,
            ),
            const SizedBox(width: 8),
            _buildCard(
              context,
              label: l.dashboardTips,
              value: moneyFormatter(data.totalTips),
              prevValue: data.prevTotalTips,
              currentValue: data.totalTips,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String label,
    required String value,
    required int prevValue,
    required int currentValue,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
              if (showComparison) ...[
                const SizedBox(height: 8),
                _buildComparisonBadge(context, prevValue, currentValue),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonBadge(
    BuildContext context,
    int prevValue,
    int currentValue,
  ) {
    if (prevValue == 0 && currentValue == 0) {
      return Text(
        '0 %',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    if (prevValue == 0) {
      return Text(
        '+\u221e %',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: valueChangeColor(1, context),
            ),
      );
    }

    final change = ((currentValue - prevValue) / prevValue * 100).round();
    final prefix = change > 0 ? '+' : '';
    final color = change == 0
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : valueChangeColor(change, context);

    return Text(
      '$prefix$change %',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    );
  }
}
