import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

enum _SuppliersSortField { name }

class SuppliersTab extends ConsumerStatefulWidget {
  const SuppliersTab({super.key});

  @override
  ConsumerState<SuppliersTab> createState() => _SuppliersTabState();
}

class _SuppliersTabState extends ConsumerState<SuppliersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Sort state
  _SuppliersSortField _sortField = _SuppliersSortField.name;
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

    return StreamBuilder<List<SupplierModel>>(
      stream: ref.watch(supplierRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final suppliers = snap.data ?? [];
        final filtered = suppliers.where((s) {
          if (_query.isEmpty) return true;
          final q = _query;
          return normalizeSearch(s.supplierName).contains(q)
              || (s.contactPerson != null && normalizeSearch(s.contactPerson!).contains(q))
              || (s.email != null && normalizeSearch(s.email!).contains(q))
              || (s.phone != null && normalizeSearch(s.phone!).contains(q));
        }).toList()
          ..sort((a, b) {
            final cmp = switch (_sortField) {
              _SuppliersSortField.name => a.supplierName.compareTo(b.supplierName),
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
                PopupMenuButton<_SuppliersSortField>(
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
                      _SuppliersSortField.name: l.catalogSortName,
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
                  onPressed: () => _showEditDialog(context, ref, null),
                  icon: const Icon(Icons.add),
                  label: Text(l.actionAdd),
                ),
              ],
            ),
            Expanded(
              child: PosTable<SupplierModel>(
                columns: [
                  PosColumn(label: l.fieldSupplierName, flex: 3, cellBuilder: (s) => HighlightedText(s.supplierName, query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldContactPerson, flex: 2, cellBuilder: (s) => HighlightedText(s.contactPerson ?? '-', query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldEmail, flex: 2, cellBuilder: (s) => HighlightedText(s.email ?? '-', query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldPhone, flex: 2, cellBuilder: (s) => HighlightedText(s.phone ?? '-', query: _query, overflow: TextOverflow.ellipsis)),
                ],
                items: filtered,
                onRowTap: (s) => _showEditDialog(context, ref, s),
                onRowLongPress: (s) async {
                  if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                  await ref.read(supplierRepositoryProvider).delete(s.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, SupplierModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.supplierName ?? '');
    final contactCtrl = TextEditingController(text: existing?.contactPerson ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => PosDialogShell(
        title: existing == null ? l.actionAdd : l.actionEdit,
        maxWidth: 400,
        scrollable: true,
        bottomActions: PosDialogActions(
          leading: existing != null
              ? OutlinedButton(
                  style: PosButtonStyles.destructiveOutlined(context),
                  onPressed: () async {
                    if (!await confirmDelete(context, l) || !context.mounted) return;
                    await ref.read(supplierRepositoryProvider).delete(existing.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(l.actionDelete),
                )
              : null,
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.actionSave)),
          ],
        ),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: l.fieldSupplierName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contactCtrl,
            decoration: InputDecoration(labelText: l.fieldContactPerson),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(labelText: l.fieldEmail),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneCtrl,
            decoration: InputDecoration(labelText: l.fieldPhone),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty || !mounted) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(supplierRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        supplierName: nameCtrl.text.trim(),
        contactPerson: contactCtrl.text.trim().isNotEmpty ? contactCtrl.text.trim() : null,
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
      ));
    } else {
      await repo.create(SupplierModel(
        id: const Uuid().v7(),
        companyId: company.id,
        supplierName: nameCtrl.text.trim(),
        contactPerson: contactCtrl.text.trim().isNotEmpty ? contactCtrl.text.trim() : null,
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

}
