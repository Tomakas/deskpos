import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class CustomersTab extends ConsumerWidget {
  const CustomersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<CustomerModel>>(
      stream: ref.watch(customerRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final customers = snap.data ?? [];
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
                        columnSpacing: 16,
                        showCheckboxColumn: false,
                        columns: [
                          DataColumn(label: Text(l.customerFirstName)),
                          DataColumn(label: Text(l.customerLastName)),
                          DataColumn(label: Text(l.customerEmail)),
                          DataColumn(label: Text(l.customerPhone)),
                          DataColumn(label: Text(l.customerPoints)),
                          DataColumn(label: Text(l.customerCredit)),
                        ],
                        rows: customers
                            .map((c) => DataRow(
                                  onSelectChanged: (_) =>
                                      _showEditDialog(context, ref, c),
                                  cells: [
                                    DataCell(Text(c.firstName)),
                                    DataCell(Text(c.lastName)),
                                    DataCell(Text(c.email ?? '-')),
                                    DataCell(Text(c.phone ?? '-')),
                                    DataCell(Text(c.points.toString())),
                                    DataCell(Text(c.credit.toString())),
                                  ],
                                ))
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

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, CustomerModel? existing) async {
    final l = context.l10n;
    final firstNameCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final pointsCtrl = TextEditingController(text: existing?.points.toString() ?? '0');
    final creditCtrl = TextEditingController(text: existing?.credit.toString() ?? '0');
    final totalSpentCtrl = TextEditingController(text: existing?.totalSpent.toString() ?? '0');

    final theme = Theme.of(context);
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameCtrl,
                    decoration: InputDecoration(labelText: l.customerFirstName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameCtrl,
                    decoration: InputDecoration(labelText: l.customerLastName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: l.customerEmail),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: l.customerPhone),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(labelText: l.customerAddress),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pointsCtrl,
                    decoration: InputDecoration(labelText: l.customerPoints),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: creditCtrl,
                    decoration: InputDecoration(labelText: l.customerCredit),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalSpentCtrl,
                    decoration: InputDecoration(labelText: l.customerTotalSpent),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: Text(l.actionDelete, style: TextStyle(color: theme.colorScheme.error)),
              ),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
          ],
        ),
      ),
    );

    if (result == 'delete') {
      if (!context.mounted) return;
      await _delete(context, ref, existing!);
      return;
    }
    if (result != true || firstNameCtrl.text.trim().isEmpty || lastNameCtrl.text.trim().isEmpty) {
      return;
    }

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(customerRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        points: int.tryParse(pointsCtrl.text.trim()) ?? 0,
        credit: int.tryParse(creditCtrl.text.trim()) ?? 0,
        totalSpent: int.tryParse(totalSpentCtrl.text.trim()) ?? 0,
      ));
    } else {
      await repo.create(CustomerModel(
        id: const Uuid().v7(),
        companyId: company.id,
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        points: int.tryParse(pointsCtrl.text.trim()) ?? 0,
        credit: int.tryParse(creditCtrl.text.trim()) ?? 0,
        totalSpent: int.tryParse(totalSpentCtrl.text.trim()) ?? 0,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CustomerModel customer) async {
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
      await ref.read(customerRepositoryProvider).delete(customer.id);
    }
  }
}
