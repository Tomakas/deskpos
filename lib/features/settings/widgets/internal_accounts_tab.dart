import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/internal_account_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

enum _SortField { name, active }

class InternalAccountsTab extends ConsumerStatefulWidget {
  const InternalAccountsTab({super.key});

  @override
  ConsumerState<InternalAccountsTab> createState() => _InternalAccountsTabState();
}

class _InternalAccountsTabState extends ConsumerState<InternalAccountsTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _SortField _sortField = _SortField.name;
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

    return StreamBuilder<List<InternalAccountModel>>(
      stream: ref.watch(internalAccountRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final accounts = snap.data ?? [];
        final filtered = accounts.where((a) {
          if (_query.isEmpty) return true;
          return normalizeSearch(a.name).contains(_query);
        }).toList()
          ..sort((a, b) {
            final cmp = switch (_sortField) {
              _SortField.name => a.name.compareTo(b.name),
              _SortField.active => (a.isActive ? 0 : 1).compareTo(b.isActive ? 0 : 1),
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
                PopupMenuButton<_SortField>(
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
                      _SortField.name: l.catalogSortName,
                      _SortField.active: l.fieldActive,
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
                            Text(entry.value,
                                style: entry.key == _sortField
                                    ? const TextStyle(fontWeight: FontWeight.bold)
                                    : null),
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
              child: PosTable<InternalAccountModel>(
                columns: [
                  PosColumn(
                    label: l.fieldName,
                    flex: 3,
                    cellBuilder: (a) =>
                        HighlightedText(a.name, query: _query, overflow: TextOverflow.ellipsis),
                  ),
                  PosColumn(
                    label: l.internalAccountUser,
                    flex: 2,
                    cellBuilder: (a) => a.userId != null
                        ? _UserName(userId: a.userId!)
                        : Text('—', overflow: TextOverflow.ellipsis),
                  ),
                  PosColumn(
                    label: l.fieldActive,
                    flex: 1,
                    cellBuilder: (a) => Icon(
                      a.isActive ? Icons.check_circle : Icons.cancel,
                      color: boolIndicatorColor(a.isActive, context),
                      size: 20,
                    ),
                  ),
                ],
                items: filtered,
                onRowTap: (a) => _showEditDialog(context, a),
                onRowLongPress: (a) async {
                  if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                  await ref.read(internalAccountRepositoryProvider).delete(a.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, InternalAccountModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var isActive = existing?.isActive ?? true;
    var isEmployee = existing?.userId != null;
    UserModel? selectedUser;

    // Pre-load users for employee picker
    final company = ref.read(currentCompanyProvider)!;
    final allUsers = await ref.read(userRepositoryProvider).getActiveUsers(company.id);
    final allAccounts = await ref.read(internalAccountRepositoryProvider).getAll(company.id);

    // User IDs that already have an internal account (exclude current account when editing)
    final takenUserIds = allAccounts
        .where((a) => a.userId != null && a.id != existing?.id)
        .map((a) => a.userId!)
        .toSet();
    final availableUsers = allUsers.where((u) => u.isActive && !takenUserIds.contains(u.id)).toList();

    // If editing an existing employee account, find the user
    if (existing?.userId != null) {
      selectedUser = allUsers.where((u) => u.id == existing!.userId).firstOrNull;
    }

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: existing == null ? l.actionAdd : l.actionEdit,
          maxWidth: 380,
          scrollable: true,
          bottomActions: PosDialogActions(
            leading: existing != null
                ? OutlinedButton(
                    style: PosButtonStyles.destructiveOutlined(ctx),
                    onPressed: () async {
                      if (!await confirmDelete(ctx, l) || !ctx.mounted) return;
                      await ref.read(internalAccountRepositoryProvider).delete(existing.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l.actionDelete),
                  )
                : null,
            actions: [
              OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
            ],
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilterChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(l.internalAccountAddGeneral, textAlign: TextAlign.center),
                      ),
                      selected: !isEmployee,
                      onSelected: (_) => setDialogState(() {
                        isEmployee = false;
                        selectedUser = null;
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilterChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(l.internalAccountAddEmployee, textAlign: TextAlign.center),
                      ),
                      selected: isEmployee,
                      onSelected: (_) => setDialogState(() {
                        isEmployee = true;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEmployee) ...[
              DropdownButtonFormField<UserModel>(
                initialValue: selectedUser,
                decoration: InputDecoration(labelText: l.internalAccountUser),
                items: availableUsers
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.fullName),
                        ))
                    .toList(),
                onChanged: (u) => setDialogState(() {
                  selectedUser = u;
                }),
              ),
            ] else ...[
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l.fieldName),
              ),
            ],
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

    if (result != true) return;
    if (!context.mounted) return;

    final name = isEmployee ? (selectedUser?.fullName ?? '') : nameCtrl.text.trim();
    if (name.isEmpty) return;

    // Prevent duplicate names (ignore current account when editing)
    final nameTaken = allAccounts.any((a) =>
        a.id != existing?.id &&
        a.name.trim().toLowerCase() == name.toLowerCase());
    if (nameTaken) return;

    final repo = ref.read(internalAccountRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: name,
        userId: isEmployee ? selectedUser?.id : null,
        isActive: isActive,
      ));
    } else {
      await repo.create(InternalAccountModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: name,
        userId: isEmployee ? selectedUser?.id : null,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }
}

class _UserName extends ConsumerWidget {
  const _UserName({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(userRepositoryProvider).getById(userId),
      builder: (context, snap) {
        if (snap.data == null) return const Text('—');
        return Text(snap.data!.fullName, overflow: TextOverflow.ellipsis);
      },
    );
  }
}
