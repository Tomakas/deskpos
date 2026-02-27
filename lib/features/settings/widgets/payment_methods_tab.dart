import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

enum _PaymentMethodsSortField { name, type }

class PaymentMethodsTab extends ConsumerStatefulWidget {
  const PaymentMethodsTab({super.key});

  @override
  ConsumerState<PaymentMethodsTab> createState() => _PaymentMethodsTabState();
}

class _PaymentMethodsTabState extends ConsumerState<PaymentMethodsTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  _PaymentMethodsSortField _sortField = _PaymentMethodsSortField.name;
  bool _sortAsc = true;

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

    return StreamBuilder<List<PaymentMethodModel>>(
      stream: ref.watch(paymentMethodRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final methods = snap.data ?? [];
        final filtered = methods.where((pm) {
          if (_query.isEmpty) return true;
          return normalizeSearch(pm.name).contains(_query);
        }).toList()
          ..sort((a, b) {
            final cmp = switch (_sortField) {
              _PaymentMethodsSortField.name => a.name.compareTo(b.name),
              _PaymentMethodsSortField.type => a.type.index.compareTo(b.type.index),
            };
            return _sortAsc ? cmp : -cmp;
          });
        return Column(
          children: [
            PosTableToolbar(
              searchController: _searchCtrl,
              searchHint: l.searchHint,
              onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
              trailing: [
                PopupMenuButton<_PaymentMethodsSortField>(
                  icon: const Icon(Icons.swap_vert),
                  onSelected: (field) {
                    if (field == _sortField) {
                      setState(() => _sortAsc = !_sortAsc);
                    } else {
                      setState(() {
                        _sortField = field;
                        _sortAsc = true;
                      });
                    }
                  },
                  itemBuilder: (_) => [
                    for (final entry in {
                      _PaymentMethodsSortField.name: l.catalogSortName,
                      _PaymentMethodsSortField.type: l.catalogSortType,
                    }.entries)
                      PopupMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            if (entry.key == _sortField)
                              Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16)
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Text(entry.value, style: entry.key == _sortField ? const TextStyle(fontWeight: FontWeight.bold) : null),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showEditDialog(context, null),
                  icon: const Icon(Icons.add),
                  label: Text(l.actionAdd),
                ),
              ],
            ),
            Expanded(
              child: PosTable<PaymentMethodModel>(
                columns: [
                  PosColumn(label: l.fieldName, flex: 3, cellBuilder: (pm) => HighlightedText(pm.name, query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldType, flex: 2, cellBuilder: (pm) => Text(_typeLabel(l, pm.type), overflow: TextOverflow.ellipsis)),
                  PosColumn(
                    label: l.fieldActive,
                    flex: 1,
                    cellBuilder: (pm) => Icon(
                      pm.isActive ? Icons.check_circle : Icons.cancel,
                      color: boolIndicatorColor(pm.isActive, context),
                      size: 20,
                    ),
                  ),
                ],
                items: filtered,
                onRowTap: (pm) => _showEditDialog(context, pm),
                onRowLongPress: (pm) async {
                  if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                  await ref.read(paymentMethodRepositoryProvider).delete(pm.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _typeLabel(AppLocalizations l, PaymentType type) {
    return switch (type) {
      PaymentType.cash => l.paymentTypeCash,
      PaymentType.card => l.paymentTypeCard,
      PaymentType.bank => l.paymentTypeBank,
      PaymentType.credit => l.paymentTypeCredit,
      PaymentType.voucher => l.paymentTypeVoucher,
      PaymentType.other => l.paymentTypeOther,
    };
  }

  Future<void> _showEditDialog(
      BuildContext context, PaymentMethodModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var type = existing?.type ?? PaymentType.cash;
    var isActive = existing?.isActive ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: existing == null ? l.actionAdd : l.actionEdit,
          maxWidth: 350,
          scrollable: true,
          bottomActions: PosDialogActions(
            leading: existing != null
                ? OutlinedButton(
                    style: PosButtonStyles.destructiveOutlined(ctx),
                    onPressed: () async {
                      if (!await confirmDelete(ctx, l) || !ctx.mounted) return;
                      await ref.read(paymentMethodRepositoryProvider).delete(existing.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l.actionDelete),
                  )
                : null,
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
            ],
          ),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;
    if (!context.mounted) return;

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

}
