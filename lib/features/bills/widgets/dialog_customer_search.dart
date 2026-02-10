import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

/// Sentinel value returned when user wants to remove the customer.
class _RemoveCustomer {
  const _RemoveCustomer();
}

/// Shows a dialog to search and select a customer.
/// Returns a [CustomerModel] if selected, `null` if cancelled,
/// or triggers removal if "Remove customer" is tapped.
Future<CustomerModel?> showCustomerSearchDialog(
  BuildContext context,
  WidgetRef ref, {
  bool showRemoveButton = false,
}) async {
  final result = await showDialog<Object>(
    context: context,
    builder: (_) => _DialogCustomerSearch(
      showRemoveButton: showRemoveButton,
    ),
  );
  if (result is _RemoveCustomer) {
    // Caller should interpret null customerId as "remove"
    return null;
  }
  if (result is CustomerModel) {
    return result;
  }
  // Dialog was dismissed — return special marker to distinguish from "remove"
  return null;
}

/// Shows a dialog to search and select a customer.
/// Returns:
/// - `CustomerModel` if a customer was selected
/// - Special `false` value if "Remove customer" was tapped
/// - `null` if dialog was dismissed
Future<Object?> showCustomerSearchDialogRaw(
  BuildContext context,
  WidgetRef ref, {
  bool showRemoveButton = false,
}) async {
  return showDialog<Object>(
    context: context,
    builder: (_) => _DialogCustomerSearch(
      showRemoveButton: showRemoveButton,
    ),
  );
}

class _DialogCustomerSearch extends ConsumerStatefulWidget {
  const _DialogCustomerSearch({this.showRemoveButton = false});
  final bool showRemoveButton;

  @override
  ConsumerState<_DialogCustomerSearch> createState() => _DialogCustomerSearchState();
}

class _DialogCustomerSearchState extends ConsumerState<_DialogCustomerSearch> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final repo = ref.watch(customerRepositoryProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.customerSearch,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l.customerSearch,
                  isDense: true,
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _query.isEmpty
                    ? StreamBuilder<List<CustomerModel>>(
                        stream: repo.watchAll(company.id),
                        builder: (context, snap) => _buildList(context, snap.data ?? []),
                      )
                    : StreamBuilder<List<CustomerModel>>(
                        stream: repo.search(company.id, _query),
                        builder: (context, snap) => _buildList(context, snap.data ?? []),
                      ),
              ),
              if (widget.showRemoveButton) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, const _RemoveCustomer()),
                  child: Text(l.customerRemove),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.actionCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<CustomerModel> customers) {
    if (customers.isEmpty) {
      return Center(
        child: Text(
          context.l10n.customerNone,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: customers.length,
      itemBuilder: (context, i) {
        final c = customers[i];
        return ListTile(
          title: Text('${c.firstName} ${c.lastName}'),
          subtitle: Text([c.email, c.phone].whereType<String>().join(' | ')),
          onTap: () => Navigator.pop(context, c),
        );
      },
    );
  }
}
