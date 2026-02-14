import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogMergeBill extends ConsumerWidget {
  const DialogMergeBill({super.key, required this.excludeBillId});
  final String excludeBillId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return PosDialogShell(
      title: l.mergeBillTitle,
      titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      maxWidth: 420,
      maxHeight: 500,
      children: [
        Text(
          l.mergeBillDescription,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Flexible(
          child: StreamBuilder<List<BillModel>>(
            stream: ref.watch(billRepositoryProvider).watchByCompany(
                  company.id,
                  status: BillStatus.opened,
                ),
            builder: (context, billSnap) {
              final bills = (billSnap.data ?? [])
                  .where((b) => b.id != excludeBillId)
                  .toList();

              if (bills.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l.mergeBillNoBills,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                );
              }

              return StreamBuilder<List<TableModel>>(
                stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
                builder: (context, tableSnap) {
                  final tables = tableSnap.data ?? [];
                  final tableMap = {for (final t in tables) t.id: t.name};

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final tableName = bill.tableId != null
                          ? tableMap[bill.tableId]
                          : null;
                      final label = tableName ?? bill.billNumber;

                      return ListTile(
                        title: Text(label),
                        subtitle: Text(bill.billNumber),
                        trailing: Text(
                          ref.money(bill.totalGross),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        onTap: () => Navigator.pop(context, bill.id),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
        ),
      ],
    );
  }
}
