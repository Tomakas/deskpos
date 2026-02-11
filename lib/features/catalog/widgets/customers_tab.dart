import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/search_utils.dart';
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
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold);
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
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _query = normalizeSearch(v)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => _showEditDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: Text(l.actionAdd),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(l.customerFirstName, style: headerStyle)),
                  Expanded(flex: 2, child: Text(l.customerLastName, style: headerStyle)),
                  Expanded(flex: 2, child: Text(l.customerEmail, style: headerStyle)),
                  Expanded(flex: 2, child: Text(l.customerPhone, style: headerStyle)),
                  Expanded(flex: 1, child: Text(l.customerPoints, style: headerStyle)),
                  Expanded(flex: 1, child: Text(l.customerCredit, style: headerStyle)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  return InkWell(
                    onTap: () => _showEditDialog(context, ref, c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(c.firstName, overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 2, child: Text(c.lastName, overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 2, child: Text(c.email ?? '-', overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 2, child: Text(c.phone ?? '-', overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 1, child: Text(c.points.toString(), overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 1, child: Text(
                            (c.credit / 100).toStringAsFixed(2).replaceAll('.', ','),
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(
                            width: 48,
                            child: IconButton(
                              icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                              tooltip: l.loyaltyCredit,
                              onPressed: () => _showCreditDialog(context, c),
                            ),
                          ),
                        ],
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
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, CustomerModel? existing) async {
    final l = context.l10n;
    final firstNameCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final pointsCtrl = TextEditingController(text: existing?.points.toString() ?? '0');
    final creditCtrl = TextEditingController(text: existing?.credit.toString() ?? '0');
    final totalSpentCtrl = TextEditingController(text: existing?.totalSpent.toString() ?? '0');

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
                  TextField(
                    controller: creditCtrl,
                    decoration: InputDecoration(labelText: l.customerCredit),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalSpentCtrl,
                    decoration: InputDecoration(labelText: l.customerTotalSpent),
                    keyboardType: TextInputType.number,
                  ),
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
    if (result != true || firstNameCtrl.text.trim().isEmpty || lastNameCtrl.text.trim().isEmpty) {
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
        credit: int.tryParse(creditCtrl.text.trim()) ?? 0,
        totalSpent: int.tryParse(totalSpentCtrl.text.trim()) ?? 0,
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
        credit: int.tryParse(creditCtrl.text.trim()) ?? 0,
        totalSpent: int.tryParse(totalSpentCtrl.text.trim()) ?? 0,
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
