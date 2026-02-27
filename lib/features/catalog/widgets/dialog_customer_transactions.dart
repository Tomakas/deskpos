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
    final headerStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return PosDialogShell(
      title: l.loyaltyTransactionHistory,
      showCloseButton: true,
      scrollable: true,
      maxWidth: 560,
      maxHeight: 520,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(width: 90, child: Text(l.cashJournalColumnTime, style: headerStyle)),
              Expanded(flex: 2, child: Text(l.customerPoints, style: headerStyle)),
              Expanded(flex: 2, child: Text(l.customerCredit, style: headerStyle)),
              Expanded(flex: 3, child: Text(l.cashMovementNote, style: headerStyle, textAlign: TextAlign.end)),
            ],
          ),
        ),
        const Divider(height: 1),
        // Data rows
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
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            ref.fmtDateTimeShort(tx.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: tx.pointsChange != 0
                              ? Text(
                                  '${tx.pointsChange > 0 ? '+' : ''}${tx.pointsChange}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: valueChangeColor(tx.pointsChange, context),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 2,
                          child: tx.creditChange != 0
                              ? Text(
                                  '${tx.creditChange > 0 ? '+' : ''}${ref.money(tx.creditChange)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: valueChangeColor(tx.creditChange, context),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            [
                              if (tx.reference != null) tx.reference!,
                              if (tx.note != null && tx.note!.isNotEmpty) tx.note!,
                            ].join(' · '),
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
