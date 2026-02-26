import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

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
  String? currentCustomerName,
  String? currentCustomerId,
}) async {
  final result = await showDialog<Object>(
    context: context,
    builder: (_) => _DialogCustomerAssign(
      showRemoveButton: showRemoveButton,
      currentCustomerName: currentCustomerName,
      currentCustomerId: currentCustomerId,
    ),
  );
  if (result is _RemoveCustomer) {
    return null;
  }
  if (result is CustomerModel) {
    return result;
  }
  return null;
}

/// Shows a DB customer search dialog (sub-dialog).
/// Returns [CustomerModel] if selected, `null` if cancelled.
Future<CustomerModel?> showCustomerDbSearchDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  return showDialog<CustomerModel>(
    context: context,
    builder: (_) => const _DialogCustomerDbSearch(),
  );
}

/// Shows a dialog to assign a customer (free-text or DB search).
/// Returns:
/// - `CustomerModel` if a customer was selected from DB
/// - `String` if free-text name was entered
/// - `_RemoveCustomer` sentinel if customer was removed
/// - `null` if dialog was dismissed
Future<Object?> showCustomerSearchDialogRaw(
  BuildContext context,
  WidgetRef ref, {
  bool showRemoveButton = false,
  String? currentCustomerName,
  String? currentCustomerId,
}) async {
  return showDialog<Object>(
    context: context,
    builder: (_) => _DialogCustomerAssign(
      showRemoveButton: showRemoveButton,
      currentCustomerName: currentCustomerName,
      currentCustomerId: currentCustomerId,
    ),
  );
}

// ---------------------------------------------------------------------------
// Main dialog: free-text input + DB search button + customer card
// ---------------------------------------------------------------------------

class _DialogCustomerAssign extends ConsumerStatefulWidget {
  const _DialogCustomerAssign({
    this.showRemoveButton = false,
    this.currentCustomerName,
    this.currentCustomerId,
  });
  final bool showRemoveButton;
  final String? currentCustomerName;
  final String? currentCustomerId;

  @override
  ConsumerState<_DialogCustomerAssign> createState() =>
      _DialogCustomerAssignState();
}

class _DialogCustomerAssignState extends ConsumerState<_DialogCustomerAssign> {
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  CustomerModel? _selectedCustomer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentCustomerId != null) {
      _loadCustomer(widget.currentCustomerId!);
    } else if (widget.currentCustomerName != null) {
      _nameCtrl.text = widget.currentCustomerName!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer(String customerId) async {
    setState(() => _isLoading = true);
    final customer = await ref.read(customerRepositoryProvider).getById(customerId);
    if (mounted) {
      setState(() {
        _selectedCustomer = customer;
        _isLoading = false;
        // Fallback to free-text name if customer not found (deleted, etc.)
        if (customer == null && widget.currentCustomerName != null) {
          _nameCtrl.text = widget.currentCustomerName!;
        }
      });
    }
  }

  Future<void> _openDbSearch() async {
    final result = await showDialog<CustomerModel>(
      context: context,
      builder: (_) => const _DialogCustomerDbSearch(),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedCustomer = result;
        _nameCtrl.clear();
      });
    }
  }

  void _save() {
    if (_selectedCustomer != null) {
      Navigator.pop(context, _selectedCustomer);
    } else {
      final name = _nameCtrl.text.trim();
      if (name.isNotEmpty) {
        Navigator.pop(context, name);
      } else if (widget.showRemoveButton) {
        // Had a customer before, now cleared → remove
        Navigator.pop(context, const _RemoveCustomer());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: l.billDetailCustomer,
      maxWidth: 420,
      scrollable: true,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          if (_selectedCustomer != null)
            _buildCustomerCard(context, theme)
          else
            TextField(
              controller: _nameCtrl,
              focusNode: _nameFocus,
              autofocus: widget.currentCustomerId == null,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: l.customerSearch,
                  onPressed: _openDbSearch,
                ),
                hintText: l.customerNameHint,
                isDense: true,
              ),
              onSubmitted: (_) => _save(),
            ),
        ],
        const SizedBox(height: 16),
      ],
      bottomActions: PosDialogActions(
        actions: [
          if (widget.showRemoveButton)
            OutlinedButton(
              style: PosButtonStyles.destructiveOutlined(context),
              onPressed: () =>
                  Navigator.pop(context, const _RemoveCustomer()),
              child: Text(l.customerRemove),
            ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: _save,
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, ThemeData theme) {
    final c = _selectedCustomer!;
    final contactInfo =
        [c.email, c.phone].whereType<String>().join(' | ');
    final loyaltyInfo = context.l10n.loyaltyCustomerInfo(
      c.points,
      ref.money(c.credit),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.firstName} ${c.lastName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (contactInfo.isNotEmpty)
                  Text(
                    contactInfo,
                    style: theme.textTheme.bodySmall,
                  ),
                Text(
                  loyaltyInfo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() => _selectedCustomer = null);
              _nameFocus.requestFocus();
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-dialog: DB customer search with fulltext
// ---------------------------------------------------------------------------

class _DialogCustomerDbSearch extends ConsumerStatefulWidget {
  const _DialogCustomerDbSearch();

  @override
  ConsumerState<_DialogCustomerDbSearch> createState() =>
      _DialogCustomerDbSearchState();
}

class _DialogCustomerDbSearchState
    extends ConsumerState<_DialogCustomerDbSearch> {
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

    return PosDialogShell(
      title: l.customerSearch,
      maxWidth: 420,
      maxHeight: 500,
      padding: const EdgeInsets.all(16),
      children: [
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
                  builder: (context, snap) =>
                      _buildList(context, snap.data ?? []),
                )
              : StreamBuilder<List<CustomerModel>>(
                  stream: repo.search(company.id, _query),
                  builder: (context, snap) =>
                      _buildList(context, snap.data ?? []),
                ),
        ),
        const SizedBox(height: 8),
      ],
      bottomActions: PosDialogActions(
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
        ],
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
        final contactInfo = [c.email, c.phone].whereType<String>().join(' | ');
        return ListTile(
          title: Text('${c.firstName} ${c.lastName}'),
          subtitle: contactInfo.isNotEmpty ? Text(contactInfo) : null,
          onTap: () => Navigator.pop(context, c),
        );
      },
    );
  }
}
