import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/manufacturer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

enum _ManufacturersSortField { name }

class ManufacturersTab extends ConsumerStatefulWidget {
  const ManufacturersTab({super.key});

  @override
  ConsumerState<ManufacturersTab> createState() => _ManufacturersTabState();
}

class _ManufacturersTabState extends ConsumerState<ManufacturersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Sort state
  _ManufacturersSortField _sortField = _ManufacturersSortField.name;
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

    return StreamBuilder<List<ManufacturerModel>>(
      stream: ref.watch(manufacturerRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final manufacturers = snap.data ?? [];
        final filtered = manufacturers.where((m) {
          if (_query.isEmpty) return true;
          return normalizeSearch(m.name).contains(_query);
        }).toList()
          ..sort((a, b) {
            final cmp = switch (_sortField) {
              _ManufacturersSortField.name => a.name.compareTo(b.name),
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
                PopupMenuButton<_ManufacturersSortField>(
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
                      _ManufacturersSortField.name: l.catalogSortName,
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
              child: PosTable<ManufacturerModel>(
                columns: [
                  PosColumn(label: l.fieldName, cellBuilder: (m) => HighlightedText(m.name, query: _query, overflow: TextOverflow.ellipsis)),
                ],
                items: filtered,
                onRowTap: (m) => _showEditDialog(context, ref, m),
                onRowLongPress: (m) async {
                  if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                  await ref.read(manufacturerRepositoryProvider).delete(m.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, WidgetRef ref, ManufacturerModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => PosDialogShell(
        title: existing == null ? l.actionAdd : l.actionEdit,
        maxWidth: 350,
        scrollable: true,
        bottomActions: PosDialogActions(
          leading: existing != null
              ? OutlinedButton(
                  style: PosButtonStyles.destructiveOutlined(context),
                  onPressed: () async {
                    if (!await confirmDelete(context, l) || !context.mounted) return;
                    await ref.read(manufacturerRepositoryProvider).delete(existing.id);
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
            decoration: InputDecoration(labelText: l.fieldName),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty || !mounted) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(manufacturerRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(name: nameCtrl.text.trim()));
    } else {
      await repo.create(ManufacturerModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

}
