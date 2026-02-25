import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/tax_calc_type.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_table.dart';

class TaxRatesTab extends ConsumerStatefulWidget {
  const TaxRatesTab({super.key});

  @override
  ConsumerState<TaxRatesTab> createState() => _TaxRatesTabState();
}

class _TaxRatesTabState extends ConsumerState<TaxRatesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<TaxRateModel>>(
      stream: ref.watch(taxRateRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final taxRates = snap.data ?? [];
        final filtered = taxRates.where((tr) {
          if (_query.isEmpty) return true;
          return normalizeSearch(tr.label).contains(_query);
        }).toList();
        return Column(
          children: [
            PosTableToolbar(
              searchController: _searchCtrl,
              searchHint: l.searchHint,
              onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
              trailing: [
                FilledButton.icon(
                  onPressed: () => _showEditDialog(context, null),
                  icon: const Icon(Icons.add),
                  label: Text(l.actionAdd),
                ),
              ],
            ),
            Expanded(
              child: PosTable<TaxRateModel>(
                columns: [
                  PosColumn(label: l.fieldName, flex: 3, cellBuilder: (tr) => HighlightedText(tr.label, query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldType, flex: 2, cellBuilder: (tr) => Text(_typeLabel(l, tr.type), overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldRate, flex: 1, cellBuilder: (tr) => Text(ref.fmtPercent(tr.rate / 100, maxDecimals: 0), overflow: TextOverflow.ellipsis)),
                  PosColumn(
                    label: l.fieldDefault,
                    flex: 1,
                    cellBuilder: (tr) => Icon(
                      tr.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: boolIndicatorColor(tr.isDefault, context),
                      size: 20,
                    ),
                  ),
                  PosColumn(
                    label: l.fieldActions,
                    flex: 2,
                    cellBuilder: (tr) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditDialog(context, tr),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _delete(context, tr),
                        ),
                      ],
                    ),
                  ),
                ],
                items: filtered,
              ),
            ),
          ],
        );
      },
    );
  }

  String _typeLabel(AppLocalizations l, TaxCalcType type) {
    return switch (type) {
      TaxCalcType.regular => l.taxTypeRegular,
      TaxCalcType.noTax => l.taxTypeNoTax,
      TaxCalcType.constant => l.taxTypeConstant,
      TaxCalcType.mixed => l.taxTypeMixed,
    };
  }

  Future<void> _showEditDialog(BuildContext context, TaxRateModel? existing) async {
    final l = context.l10n;
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final rateCtrl = TextEditingController(
        text: existing != null ? (existing.rate / 100).toStringAsFixed(0) : '');
    var type = existing?.type ?? TaxCalcType.regular;
    var isDefault = existing?.isDefault ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: existing == null ? l.actionAdd : l.actionEdit,
          maxWidth: 350,
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
            const SizedBox(height: 24),
            PosDialogActions(
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
              ],
            ),
          ],
        ),
      ),
    );

    if (result != true || labelCtrl.text.trim().isEmpty) return;
    if (!context.mounted) return;

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

  Future<void> _delete(BuildContext context, TaxRateModel taxRate) async {
    if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
    await ref.read(taxRateRepositoryProvider).delete(taxRate.id);
  }
}
