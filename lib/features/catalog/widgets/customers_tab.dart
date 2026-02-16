import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_table.dart';
import 'dialog_customer_credit.dart';

class CustomersTab extends ConsumerStatefulWidget {
  const CustomersTab({super.key});

  @override
  ConsumerState<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<CustomersTab> {
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

    return StreamBuilder<List<CustomerModel>>(
      stream: ref.watch(customerRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final customers = snap.data ?? [];
        final filtered = customers.where((c) {
          if (_query.isEmpty) return true;
          final q = _query;
          return normalizeSearch(c.firstName).contains(q)
              || normalizeSearch(c.lastName).contains(q)
              || (c.email != null && normalizeSearch(c.email!).contains(q))
              || (c.phone != null && normalizeSearch(c.phone!).contains(q));
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
              child: PosTable<CustomerModel>(
                columns: [
                  PosColumn(label: l.customerFirstName, flex: 2, cellBuilder: (c) => Text(c.firstName, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerLastName, flex: 2, cellBuilder: (c) => Text(c.lastName, overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerEmail, flex: 2, cellBuilder: (c) => Text(c.email ?? '-', overflow: TextOverflow.ellipsis)),
                  PosColumn(label: l.customerPhone, flex: 2, cellBuilder: (c) => Text(c.phone ?? '-', overflow: TextOverflow.ellipsis)),
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
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, CustomerModel? existing) async {
    final l = context.l10n;
    final firstNameCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final currency = ref.read(currentCurrencyProvider).value;
    final pointsCtrl = TextEditingController(text: existing?.points.toString() ?? '0');
    final creditCtrl = TextEditingController(text: minorUnitsToInputString(existing?.credit ?? 0, currency));
    final totalSpentCtrl = TextEditingController(text: minorUnitsToInputString(existing?.totalSpent ?? 0, currency));

    final theme = Theme.of(context);
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  TextField(
                    controller: pointsCtrl,
                    decoration: InputDecoration(labelText: l.customerPoints),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: creditCtrl,
                          decoration: InputDecoration(labelText: l.customerCredit),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      if (existing != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.account_balance_wallet_outlined),
                          tooltip: l.loyaltyCredit,
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showCreditDialog(context, existing);
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalSpentCtrl,
                    decoration: InputDecoration(labelText: l.customerTotalSpent),
                    keyboardType: TextInputType.number,
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(labelText: l.customerLastVisit),
                      child: Text(
                        existing.lastVisitDate != null
                            ? ref.fmtDateTime(existing.lastVisitDate!)
                            : '-',
                      ),
                    ),
                  ],
                ],
              ),
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
        points: int.tryParse(pointsCtrl.text.trim()) ?? 0,
        credit: parseMoney(creditCtrl.text.trim(), currency),
        totalSpent: parseMoney(totalSpentCtrl.text.trim(), currency),
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
        points: int.tryParse(pointsCtrl.text.trim()) ?? 0,
        credit: parseMoney(creditCtrl.text.trim(), currency),
        totalSpent: parseMoney(totalSpentCtrl.text.trim(), currency),
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  void _showCreditDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) => DialogCustomerCredit(customer: customer),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CustomerModel customer) async {
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
      await ref.read(customerRepositoryProvider).delete(customer.id);
    }
  }
}
