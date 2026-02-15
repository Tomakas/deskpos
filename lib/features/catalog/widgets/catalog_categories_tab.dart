import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/category_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_table.dart';

class CatalogCategoriesTab extends ConsumerStatefulWidget {
  const CatalogCategoriesTab({super.key});

  @override
  ConsumerState<CatalogCategoriesTab> createState() => _CatalogCategoriesTabState();
}

class _CatalogCategoriesTabState extends ConsumerState<CatalogCategoriesTab> {
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

    return StreamBuilder<List<CategoryModel>>(
      stream: ref.watch(categoryRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final categories = snap.data ?? [];
        final filtered = categories.where((c) {
          if (_query.isEmpty) return true;
          return normalizeSearch(c.name).contains(_query);
        }).toList();
        return Column(
          children: [
            PosTableToolbar(
              searchController: _searchCtrl,
              searchHint: l.searchHint,
              onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
              trailing: [
                FilledButton.icon(
                  onPressed: () => _showEditDialog(context, ref, categories, null),
                  icon: const Icon(Icons.add),
                  label: Text(l.actionAdd),
                ),
              ],
            ),
            Expanded(
              child: PosTable<CategoryModel>(
                columns: [
                  PosColumn(label: l.fieldName, flex: 3, cellBuilder: (c) => Text(c.name, overflow: TextOverflow.ellipsis)),
                  PosColumn(
                    label: l.fieldParentCategory,
                    flex: 3,
                    cellBuilder: (c) => Text(
                      categories.where((p) => p.id == c.parentId).firstOrNull?.name ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PosColumn(
                    label: l.fieldActive,
                    flex: 1,
                    cellBuilder: (c) => Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        c.isActive ? Icons.check_circle : Icons.cancel,
                        color: boolIndicatorColor(c.isActive, context),
                        size: 20,
                      ),
                    ),
                  ),
                ],
                items: filtered,
                onRowTap: (c) => _showEditDialog(context, ref, categories, c),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> allCategories,
    CategoryModel? existing,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var isActive = existing?.isActive ?? true;
    var parentId = existing?.parentId;

    final parentOptions = allCategories.where((c) => c.id != existing?.id).toList();

    final theme = Theme.of(context);
    final result = await showDialog<Object>(
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
                  initialValue: parentId,
                  decoration: InputDecoration(labelText: l.fieldParentCategory),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...parentOptions
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setDialogState(() => parentId = v),
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
    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        isActive: isActive,
        parentId: parentId,
      ));
    } else {
      await repo.create(CategoryModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        isActive: isActive,
        parentId: parentId,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CategoryModel category) async {
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
      await ref.read(categoryRepositoryProvider).delete(category.id);
    }
  }
}
