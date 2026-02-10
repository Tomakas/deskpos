import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class PaymentMethodsTab extends ConsumerWidget {
  const PaymentMethodsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<PaymentMethodModel>>(
      stream: ref.watch(paymentMethodRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final methods = snap.data ?? [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _showEditDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: Text(l.actionAdd),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                  columns: [
                    DataColumn(label: Text(l.fieldName)),
                    DataColumn(label: Text(l.fieldType)),
                    DataColumn(label: Text(l.fieldActive)),
                    DataColumn(label: Text(l.fieldActions)),
                  ],
                  rows: methods
                      .map((pm) => DataRow(cells: [
                            DataCell(Text(pm.name)),
                            DataCell(Text(_typeLabel(l, pm.type))),
                            DataCell(Icon(
                              pm.isActive ? Icons.check_circle : Icons.cancel,
                              color: pm.isActive ? Colors.green : Colors.grey,
                              size: 20,
                            )),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditDialog(context, ref, pm),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _delete(context, ref, pm),
                                ),
                              ],
                            )),
                          ]))
                      .toList(),
                    ),
                  ),
                );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _typeLabel(dynamic l, PaymentType type) {
    return switch (type) {
      PaymentType.cash => l.paymentTypeCash,
      PaymentType.card => l.paymentTypeCard,
      PaymentType.bank => l.paymentTypeBank,
      PaymentType.other => l.paymentTypeOther,
    };
  }

  Future<void> _showEditDialog(
      BuildContext context, WidgetRef ref, PaymentMethodModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var type = existing?.type ?? PaymentType.cash;
    var isActive = existing?.isActive ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l.fieldName),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PaymentType>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: l.fieldType),
                  items: PaymentType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_typeLabel(l, t)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l.fieldActive),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(paymentMethodRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        type: type,
        isActive: isActive,
      ));
    } else {
      await repo.create(PaymentMethodModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        type: type,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, PaymentMethodModel method) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(paymentMethodRepositoryProvider).delete(method.id);
    }
  }
}
