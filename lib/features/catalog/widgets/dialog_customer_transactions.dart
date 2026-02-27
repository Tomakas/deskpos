import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/customer_transaction_model.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogCustomerTransactions extends ConsumerWidget {
  const DialogCustomerTransactions({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.loyaltyTransactionHistory,
      showCloseButton: true,
      scrollable: true,
      maxWidth: 500,
      maxHeight: 520,
      children: [
        StreamBuilder<List<CustomerTransactionModel>>(
          stream: ref.watch(customerTransactionRepositoryProvider).watchByCustomer(customerId),
          builder: (context, snap) {
            final txs = snap.data ?? [];
            if (txs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('-', style: theme.textTheme.bodyMedium),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final tx in txs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            ref.fmtDateTimeShort(tx.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        if (tx.pointsChange != 0)
                          Expanded(
                            child: Text(
                              l.loyaltyPointsChange(
                                '${tx.pointsChange > 0 ? '+' : ''}${tx.pointsChange}',
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: valueChangeColor(tx.pointsChange, context),
                              ),
                            ),
                          ),
                        if (tx.creditChange != 0)
                          Expanded(
                            child: Text(
                              '${tx.creditChange > 0 ? '+' : ''}${ref.money(tx.creditChange)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: valueChangeColor(tx.creditChange, context),
                              ),
                            ),
                          ),
                        if (tx.pointsChange == 0 && tx.creditChange == 0)
                          const Expanded(child: SizedBox.shrink()),
                        if (tx.note != null && tx.note!.isNotEmpty)
                          Expanded(
                            child: Text(
                              tx.note!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
