import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
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

enum _TablesSortField { name, section, capacity }

class TablesTab extends ConsumerStatefulWidget {
  const TablesTab({super.key});

  @override
  ConsumerState<TablesTab> createState() => _TablesTabState();
}

class _TablesTabState extends ConsumerState<TablesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  _TablesSortField _sortField = _TablesSortField.name;
  bool _sortAsc = true;
  String? _filterSectionId;

  bool get _hasActiveFilters => _filterSectionId != null;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
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
              if (_filterSectionId != null && t.sectionId != _filterSectionId) return false;
              if (_query.isEmpty) return true;
              final q = _query;
              if (normalizeSearch(t.name).contains(q)) return true;
              final sectionName = sections
                  .where((s) => s.id == t.sectionId)
                  .firstOrNull
                  ?.name;
              if (sectionName != null && normalizeSearch(sectionName).contains(q)) return true;
              return false;
            }).toList()
              ..sort((a, b) {
                final cmp = switch (_sortField) {
                  _TablesSortField.name => a.name.compareTo(b.name),
                  _TablesSortField.section => (sections.where((s) => s.id == a.sectionId).firstOrNull?.name ?? '')
                      .compareTo(sections.where((s) => s.id == b.sectionId).firstOrNull?.name ?? ''),
                  _TablesSortField.capacity => a.capacity.compareTo(b.capacity),
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
                    IconButton(
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        color: _hasActiveFilters
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      onPressed: () => _showFilterDialog(context, l, sections),
                    ),
                    PopupMenuButton<_TablesSortField>(
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
                          _TablesSortField.name: l.catalogSortName,
                          _TablesSortField.section: l.fieldSection,
                          _TablesSortField.capacity: l.fieldCapacity,
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
                      onPressed: () => _showEditDialog(context, ref, sections, null),
                      icon: const Icon(Icons.add),
                      label: Text(l.actionAdd),
                    ),
                  ],
                ),
                Expanded(
                  child: PosTable<TableModel>(
                    columns: [
                      PosColumn(label: l.fieldName, flex: 3, cellBuilder: (t) => HighlightedText(t.name, query: _query, overflow: TextOverflow.ellipsis)),
                      PosColumn(
                        label: l.fieldSection,
                        flex: 2,
                        cellBuilder: (t) => HighlightedText(
                          sections.where((s) => s.id == t.sectionId).firstOrNull?.name ?? '-',
                          query: _query,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PosColumn(label: l.fieldCapacity, flex: 1, cellBuilder: (t) => Text('${t.capacity}', overflow: TextOverflow.ellipsis)),
                      PosColumn(
                        label: l.fieldActive,
                        flex: 1,
                        cellBuilder: (t) => Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            t.isActive ? Icons.check_circle : Icons.cancel,
                            color: boolIndicatorColor(t.isActive, context),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                    items: filtered,
                    onRowTap: (t) => _showEditDialog(context, ref, sections, t),
                    onRowLongPress: (t) async {
                      if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                      await ref.read(tableRepositoryProvider).delete(t.id);
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

  Future<void> _showFilterDialog(
    BuildContext context,
    AppLocalizations l,
    List<SectionModel> sections,
  ) async {
    var sectionId = _filterSectionId;
    var resetCount = 0;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: l.filterTitle,
          maxWidth: 400,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(
                onPressed: () {
                  setDialogState(() {
                    sectionId = null;
                    resetCount++;
                  });
                },
                child: Text(l.filterReset),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.actionClose),
              ),
            ],
          ),
          children: [
            Column(
              key: ValueKey(resetCount),
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: sectionId,
                  decoration: InputDecoration(labelText: l.fieldSection),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text(l.filterAll)),
                    ...sections.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => sectionId = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _filterSectionId = sectionId;
    });
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
                      await ref.read(tableRepositoryProvider).delete(existing.id);
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty || !mounted) return;

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

}
