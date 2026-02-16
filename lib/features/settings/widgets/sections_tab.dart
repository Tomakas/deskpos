import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_color_palette.dart';
import '../../../core/widgets/pos_table.dart';

class SectionsTab extends ConsumerWidget {
  const SectionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final sections = snap.data ?? [];
        return Column(
          children: [
            PosTableToolbar(
              trailing: [
                FilledButton.icon(
                  onPressed: () => _showEditDialog(context, ref, null),
                  icon: const Icon(Icons.add),
                  label: Text(l.actionAdd),
                ),
              ],
            ),
            Expanded(
              child: PosTable<SectionModel>(
                columns: [
                  PosColumn(label: l.fieldName, flex: 3, cellBuilder: (s) => Text(s.name, overflow: TextOverflow.ellipsis)),
                  PosColumn(
                    label: l.fieldColor,
                    flex: 1,
                    cellBuilder: (s) => s.color != null
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: parseHexColor(s.color),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : const Text('-'),
                  ),
                  PosColumn(
                    label: l.fieldActive,
                    flex: 1,
                    cellBuilder: (s) => Icon(
                      s.isActive ? Icons.check_circle : Icons.cancel,
                      color: boolIndicatorColor(s.isActive, context),
                      size: 20,
                    ),
                  ),
                  PosColumn(
                    label: l.fieldDefault,
                    flex: 1,
                    cellBuilder: (s) => Icon(
                      s.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: boolIndicatorColor(s.isDefault, context),
                      size: 20,
                    ),
                  ),
                  PosColumn(
                    label: l.fieldActions,
                    flex: 2,
                    cellBuilder: (s) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditDialog(context, ref, s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _delete(context, ref, s),
                        ),
                      ],
                    ),
                  ),
                ],
                items: sections,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, SectionModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    String? selectedColor = existing?.color;
    var isActive = existing?.isActive ?? true;
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
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l.fieldName),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l.fieldColor, style: Theme.of(ctx).textTheme.bodySmall),
                ),
                const SizedBox(height: 8),
                PosColorPalette(
                  selectedColor: selectedColor,
                  onColorSelected: (c) => setDialogState(() => selectedColor = c),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l.fieldActive),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
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

    if (result != true || nameCtrl.text.trim().isEmpty || !context.mounted) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(sectionRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      if (isDefault) await repo.clearDefault(company.id, exceptId: existing.id);
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        color: selectedColor,
        isActive: isActive,
        isDefault: isDefault,
      ));
    } else {
      final id = const Uuid().v7();
      if (isDefault) await repo.clearDefault(company.id, exceptId: id);
      await repo.create(SectionModel(
        id: id,
        companyId: company.id,
        name: nameCtrl.text.trim(),
        color: selectedColor,
        isActive: isActive,
        isDefault: isDefault,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, SectionModel section) async {
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
    if (confirmed != true || !context.mounted) return;
    await ref.read(sectionRepositoryProvider).delete(section.id);
  }
}
