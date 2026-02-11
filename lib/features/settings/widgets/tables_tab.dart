import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/search_utils.dart';

class TablesTab extends ConsumerStatefulWidget {
  const TablesTab({super.key});

  @override
  ConsumerState<TablesTab> createState() => _TablesTabState();
}

class _TablesTabState extends ConsumerState<TablesTab> {
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

    final tablesStream = ref.watch(tableRepositoryProvider).watchAll(company.id);
    final sectionsStream = ref.watch(sectionRepositoryProvider).watchAll(company.id);

    return StreamBuilder<List<TableModel>>(
      stream: tablesStream,
      builder: (context, tablesSnap) {
        return StreamBuilder<List<SectionModel>>(
          stream: sectionsStream,
          builder: (context, sectionsSnap) {
            final tables = tablesSnap.data ?? [];
            final sections = sectionsSnap.data ?? [];

            final filtered = tables.where((t) {
              if (_query.isEmpty) return true;
              final q = _query;
              if (normalizeSearch(t.name).contains(q)) return true;
              final sectionName = sections
                  .where((s) => s.id == t.sectionId)
                  .firstOrNull
                  ?.name;
              if (sectionName != null && normalizeSearch(sectionName).contains(q)) return true;
              return false;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: l.searchHint,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _query = normalizeSearch(v)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => _showEditDialog(context, ref, sections, null),
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
                        DataColumn(label: Text(l.fieldSection)),
                        DataColumn(label: Text(l.fieldCapacity)),
                        DataColumn(label: Text(l.fieldActive)),
                        DataColumn(label: Text(l.fieldActions)),
                      ],
                      rows: filtered
                          .map((t) => DataRow(cells: [
                                DataCell(Text(t.name)),
                                DataCell(Text(
                                  sections
                                          .where((s) => s.id == t.sectionId)
                                          .firstOrNull
                                          ?.name ??
                                      '-',
                                )),
                                DataCell(Text('${t.capacity}')),
                                DataCell(Icon(
                                  t.isActive ? Icons.check_circle : Icons.cancel,
                                  color: t.isActive ? Colors.green : Colors.grey,
                                  size: 20,
                                )),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () =>
                                          _showEditDialog(context, ref, sections, t),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _delete(context, ref, t),
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
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<SectionModel> sections,
    TableModel? existing,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final capacityCtrl = TextEditingController(text: '${existing?.capacity ?? 0}');
    var sectionId = existing?.sectionId;
    var isActive = existing?.isActive ?? true;

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
                DropdownButtonFormField<String?>(
                  initialValue: sectionId,
                  decoration: InputDecoration(labelText: l.fieldSection),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...sections.map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) => setDialogState(() => sectionId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityCtrl,
                  decoration: InputDecoration(labelText: l.fieldCapacity),
                  keyboardType: TextInputType.number,
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
    final repo = ref.read(tableRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        sectionId: sectionId,
        capacity: int.tryParse(capacityCtrl.text) ?? 0,
        isActive: isActive,
      ));
    } else {
      await repo.create(TableModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        sectionId: sectionId,
        capacity: int.tryParse(capacityCtrl.text) ?? 0,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TableModel table) async {
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
      await ref.read(tableRepositoryProvider).delete(table.id);
    }
  }
}
