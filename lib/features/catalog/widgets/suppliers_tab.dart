import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_table.dart';

class SuppliersTab extends ConsumerStatefulWidget {
  const SuppliersTab({super.key});

  @override
  ConsumerState<SuppliersTab> createState() => _SuppliersTabState();
}

class _SuppliersTabState extends ConsumerState<SuppliersTab> {
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
        }).toList();
        return Column(
          children: [
            PosTableToolbar(
              searchController: _searchCtrl,
              searchHint: l.searchHint,
              onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
              trailing: [
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
                  PosColumn(label: l.fieldSupplierName, flex: 3, cellBuilder: (s) => Text(s.supplierName, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldContactPerson, flex: 2, cellBuilder: (s) => Text(s.contactPerson ?? '-', overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldEmail, flex: 2, cellBuilder: (s) => Text(s.email ?? '-', overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.fieldPhone, flex: 2, cellBuilder: (s) => Text(s.phone ?? '-', overflow: TextOverflow.ellipsis)),
                ],
                items: filtered,
                onRowTap: (s) => _showEditDialog(context, ref, s),
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

    final theme = Theme.of(context);
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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

  Future<void> _delete(BuildContext context, WidgetRef ref, SupplierModel supplier) async {
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
      await ref.read(supplierRepositoryProvider).delete(supplier.id);
    }
  }
}
