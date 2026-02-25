import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../models/dashboard_data.dart';

class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({
    super.key,
    required this.data,
    required this.moneyFormatter,
  });

  final DashboardData data;
  final String Function(int) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Row(
      children: [
        _buildCard(
          context,
          label: l.dashboardRevenue,
          value: moneyFormatter(data.totalRevenue),
          prevDisplayValue: moneyFormatter(data.prevTotalRevenue),
          prevValue: data.prevTotalRevenue,
          currentValue: data.totalRevenue,
        ),
        const SizedBox(width: 8),
        _buildCard(
          context,
          label: l.dashboardBillCount,
          value: '${data.billCount}',
          prevDisplayValue: '${data.prevBillCount}',
          prevValue: data.prevBillCount,
          currentValue: data.billCount,
        ),
        const SizedBox(width: 8),
        _buildCard(
          context,
          label: l.dashboardAverage,
          value: moneyFormatter(data.averageBill),
          prevDisplayValue: moneyFormatter(data.prevAverageBill),
          prevValue: data.prevAverageBill,
          currentValue: data.averageBill,
        ),
        const SizedBox(width: 8),
        _buildCard(
          context,
          label: l.dashboardTips,
          value: moneyFormatter(data.totalTips),
          prevDisplayValue: moneyFormatter(data.prevTotalTips),
          prevValue: data.prevTotalTips,
          currentValue: data.totalTips,
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String label,
    required String value,
    required String prevDisplayValue,
    required int prevValue,
    required int currentValue,
  }) {
    final theme = Theme.of(context);
    final subtleColor = theme.colorScheme.onSurfaceVariant;

    String percentText;
    Color percentColor;

    if (prevValue == 0 && currentValue == 0) {
      percentText = '0 %';
      percentColor = subtleColor;
    } else if (prevValue == 0) {
      percentText = '+\u221e %';
      percentColor = valueChangeColor(1, context);
    } else {
      final change = ((currentValue - prevValue) / prevValue * 100).round();
      final prefix = change > 0 ? '+' : '';
      percentText = '$prefix$change %';
      percentColor = change == 0
          ? subtleColor
          : valueChangeColor(change, context);
    }

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: subtleColor),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.dashboardPrevPeriod,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: subtleColor),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prevDisplayValue,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: subtleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    percentText,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: percentColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
