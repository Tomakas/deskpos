import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import '../../shared/session_helpers.dart' as helpers;
import 'dialog_customer_credit.dart';
import 'dialog_customer_transactions.dart';

enum _CustomersSortField { lastName, points, credit, lastVisit }

class CustomersTab extends ConsumerStatefulWidget {
  const CustomersTab({super.key});

  @override
  ConsumerState<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<CustomersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Sort state
  _CustomersSortField _sortField = _CustomersSortField.lastName;
  bool _sortAsc = true;

  // Filter state
  bool _filterHasPoints = false;
  bool _filterHasCredit = false;

  bool get _hasActiveFilters => _filterHasPoints || _filterHasCredit;

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

    return StreamBuilder<List<CustomerModel>>(
      stream: ref.watch(customerRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final customers = snap.data ?? [];
        final filtered = customers.where((c) {
          if (_filterHasPoints && c.points <= 0) return false;
          if (_filterHasCredit && c.credit <= 0) return false;
          if (_query.isEmpty) return true;
          final q = _query;
          return normalizeSearch(c.firstName).contains(q)
              || normalizeSearch(c.lastName).contains(q)
              || (c.email != null && normalizeSearch(c.email!).contains(q))
              || (c.phone != null && normalizeSearch(c.phone!).contains(q));
        }).toList()
          ..sort((a, b) {
            final cmp = switch (_sortField) {
              _CustomersSortField.lastName => a.lastName.compareTo(b.lastName),
              _CustomersSortField.points => a.points.compareTo(b.points),
              _CustomersSortField.credit => a.credit.compareTo(b.credit),
              _CustomersSortField.lastVisit => (a.lastVisitDate ?? DateTime(0)).compareTo(b.lastVisitDate ?? DateTime(0)),
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
                  onPressed: () => _showFilterDialog(context, l),
                ),
                PopupMenuButton<_CustomersSortField>(
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
                      _CustomersSortField.lastName: l.catalogSortLastName,
                      _CustomersSortField.points: l.catalogSortPoints,
                      _CustomersSortField.credit: l.catalogSortCredit,
                      _CustomersSortField.lastVisit: l.catalogSortLastVisit,
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
              child: PosTable<CustomerModel>(
                columns: [
                  PosColumn(label: l.customerFirstName, flex: 2, cellBuilder: (c) => HighlightedText(c.firstName, query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerLastName, flex: 2, cellBuilder: (c) => HighlightedText(c.lastName, query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerEmail, flex: 2, cellBuilder: (c) => HighlightedText(c.email ?? '-', query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerPhone, flex: 2, cellBuilder: (c) => HighlightedText(c.phone ?? '-', query: _query, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerPoints, flex: 1, cellBuilder: (c) => Text(c.points.toString(), overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerCredit, flex: 1, cellBuilder: (c) => Text(
                    ref.moneyValue(c.credit),
                    overflow: TextOverflow.ellipsis,
                  )),
                  PosColumn(label: l.customerLastVisit, flex: 2, cellBuilder: (c) => Text(
                    c.lastVisitDate != null ? ref.fmtDate(c.lastVisitDate!) : '-',
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
                items: filtered,
                onRowTap: (c) => _showEditDialog(context, ref, c),
                onRowLongPress: (c) async {
                  if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                  await ref.read(customerRepositoryProvider).delete(c.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context, AppLocalizations l) async {
    var hasPoints = _filterHasPoints;
    var hasCredit = _filterHasCredit;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: l.filterTitle,
          maxWidth: 350,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.actionConfirm),
              ),
            ],
          ),
          children: [
            SwitchListTile(
              title: Text(l.catalogFilterHasPoints),
              value: hasPoints,
              onChanged: (v) => setDialogState(() => hasPoints = v),
            ),
            SwitchListTile(
              title: Text(l.catalogFilterHasCredit),
              value: hasCredit,
              onChanged: (v) => setDialogState(() => hasCredit = v),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _filterHasPoints = hasPoints;
      _filterHasCredit = hasCredit;
    });
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, CustomerModel? existing) async {
    final l = context.l10n;
    final firstNameCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: existing == null ? l.actionAdd : l.actionEdit,
          maxWidth: 400,
          scrollable: true,
          bottomActions: PosDialogActions(
            leading: existing != null
                ? OutlinedButton(
                    style: PosButtonStyles.destructiveOutlined(ctx),
                    onPressed: () async {
                      if (!await confirmDelete(ctx, l) || !ctx.mounted) return;
                      await ref.read(customerRepositoryProvider).delete(existing.id);
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
              controller: firstNameCtrl,
              decoration: InputDecoration(labelText: l.customerFirstName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameCtrl,
              decoration: InputDecoration(labelText: l.customerLastName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: l.customerEmail),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(labelText: l.customerPhone),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: InputDecoration(labelText: l.customerAddress),
            ),
            const SizedBox(height: 12),
            if (existing != null) ...[
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l.customerPoints),
                      child: Text(existing.points.toString()),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.history),
                    tooltip: l.loyaltyTransactionHistory,
                    onPressed: () => showDialog<void>(
                      context: ctx,
                      builder: (_) => DialogCustomerTransactions(customerId: existing.id),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l.customerCredit),
                      child: Text(ref.money(existing.credit)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    tooltip: l.loyaltyCredit,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showCreditDialog(context, existing);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l.customerTotalSpent),
                      child: Text(ref.money(existing.totalSpent)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l.customerLastVisit),
                      child: Text(
                        existing.lastVisitDate != null
                            ? ref.fmtDateTime(existing.lastVisitDate!)
                            : '-',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (result != true || firstNameCtrl.text.trim().isEmpty || lastNameCtrl.text.trim().isEmpty || !mounted) {
      return;
    }

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(customerRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
      ));
    } else {
      await repo.create(CustomerModel(
        id: const Uuid().v7(),
        companyId: company.id,
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        points: 0,
        credit: 0,
        totalSpent: 0,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  void _showCreditDialog(BuildContext context, CustomerModel customer) {
    if (helpers.requireActiveSession(context, ref) == null) return;
    showDialog(
      context: context,
      builder: (_) => DialogCustomerCredit(customer: customer),
    );
  }

}
