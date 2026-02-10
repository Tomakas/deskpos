import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/tax_calc_type.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class TaxRatesTab extends ConsumerWidget {
  const TaxRatesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<TaxRateModel>>(
      stream: ref.watch(taxRateRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final taxRates = snap.data ?? [];
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
                    DataColumn(label: Text(l.fieldRate)),
                    DataColumn(label: Text(l.fieldDefault)),
                    DataColumn(label: Text(l.fieldActions)),
                  ],
                  rows: taxRates
                      .map((tr) => DataRow(cells: [
                            DataCell(Text(tr.label)),
                            DataCell(Text(_typeLabel(l, tr.type))),
                            DataCell(Text('${(tr.rate / 100).toStringAsFixed(0)}%')),
                            DataCell(Icon(
                              tr.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: tr.isDefault ? Colors.green : Colors.grey,
                              size: 20,
                            )),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditDialog(context, ref, tr),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _delete(context, ref, tr),
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

  String _typeLabel(dynamic l, TaxCalcType type) {
    return switch (type) {
      TaxCalcType.regular => l.taxTypeRegular,
      TaxCalcType.noTax => l.taxTypeNoTax,
      TaxCalcType.constant => l.taxTypeConstant,
      TaxCalcType.mixed => l.taxTypeMixed,
    };
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, TaxRateModel? existing) async {
    final l = context.l10n;
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final rateCtrl = TextEditingController(
        text: existing != null ? (existing.rate / 100).toStringAsFixed(0) : '');
    var type = existing?.type ?? TaxCalcType.regular;
    var isDefault = existing?.isDefault ?? false;

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
                  controller: labelCtrl,
                  decoration: InputDecoration(labelText: l.fieldName),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaxCalcType>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: l.fieldType),
                  items: TaxCalcType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_typeLabel(l, t)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rateCtrl,
                  decoration: InputDecoration(labelText: l.fieldRate),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l.fieldDefault),
                  value: isDefault,
                  onChanged: (v) => setDialogState(() => isDefault = v),
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

    if (result != true || labelCtrl.text.trim().isEmpty) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(taxRateRepositoryProvider);
    final now = DateTime.now();
    final rateInBps = ((int.tryParse(rateCtrl.text) ?? 0) * 100);

    if (existing != null) {
      if (isDefault) await repo.clearDefault(company.id, exceptId: existing.id);
      await repo.update(existing.copyWith(
        label: labelCtrl.text.trim(),
        type: type,
        rate: rateInBps,
        isDefault: isDefault,
      ));
    } else {
      final id = const Uuid().v7();
      if (isDefault) await repo.clearDefault(company.id, exceptId: id);
      await repo.create(TaxRateModel(
        id: id,
        companyId: company.id,
        label: labelCtrl.text.trim(),
        type: type,
        rate: rateInBps,
        isDefault: isDefault,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TaxRateModel taxRate) async {
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
      await ref.read(taxRateRepositoryProvider).delete(taxRate.id);
    }
  }
}
