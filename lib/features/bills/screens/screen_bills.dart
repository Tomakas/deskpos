import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/dialog_bill_detail.dart';
import '../widgets/dialog_new_bill.dart';

class ScreenBills extends ConsumerStatefulWidget {
  const ScreenBills({super.key});

  @override
  ConsumerState<ScreenBills> createState() => _ScreenBillsState();
}

class _ScreenBillsState extends ConsumerState<ScreenBills> {
  BillStatus _statusFilter = BillStatus.opened;
  String? _sectionFilter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final activeUser = ref.watch(activeUserProvider);
    final loggedIn = ref.watch(loggedInUsersProvider);
    final canManageSettings = ref.watch(hasPermissionProvider('settings.manage'));
    final sessionAsync = ref.watch(activeRegisterSessionProvider);
    final hasSession = sessionAsync.valueOrNull != null;

    return Scaffold(
      body: Row(
        children: [
          // Left panel (80%)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Section tabs
                _SectionTabBar(
                  selectedSectionId: _sectionFilter,
                  onChanged: (id) => setState(() => _sectionFilter = id),
                ),
                // Bills table
                Expanded(
                  child: _BillsTable(
                    statusFilter: _statusFilter,
                    sectionFilter: _sectionFilter,
                    onBillTap: (bill) => _openBillDetail(context, bill),
                  ),
                ),
                // Status filter bar
                _StatusFilterBar(
                  selected: _statusFilter,
                  onChanged: (status) => setState(() => _statusFilter = status),
                ),
              ],
            ),
          ),
          // Right panel (20%)
          SizedBox(
            width: 240,
            child: _RightPanel(
              l: l,
              activeUser: activeUser,
              loggedInUsers: loggedIn,
              canManageSettings: canManageSettings,
              hasSession: hasSession,
              onLogout: () => _logout(context),
              onSwitchUser: () => _showSwitchUserDialog(context),
              onSettings: canManageSettings ? () => context.push('/settings') : null,
              onNewBill: hasSession ? () => _createNewBill(context) : null,
              onQuickBill: hasSession ? () => _createQuickBill(context) : null,
              onToggleSession: () => _toggleSession(context, hasSession),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final session = ref.read(sessionManagerProvider);
    session.logoutActive();
    ref.read(activeUserProvider.notifier).state = session.activeUser;
    ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
    if (!session.isAuthenticated) {
      context.go('/login');
    }
  }

  void _showSwitchUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _SwitchUserDialog(ref: ref),
    );
  }

  void _openBillDetail(BuildContext context, BillModel bill) {
    showDialog(
      context: context,
      builder: (_) => DialogBillDetail(billId: bill.id),
    );
  }

  Future<void> _createNewBill(BuildContext context) async {
    final result = await showDialog<NewBillResult>(
      context: context,
      builder: (_) => const DialogNewBill(),
    );
    if (result == null || !mounted) return;

    await _createBillFromResult(context, result);
  }

  Future<void> _createQuickBill(BuildContext context) async {
    await _createBillFromResult(
      context,
      const NewBillResult(isTakeaway: true),
    );
  }

  Future<void> _createBillFromResult(BuildContext context, NewBillResult result) async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    final billRepo = ref.read(billRepositoryProvider);
    final billNumber = await billRepo.generateBillNumber(company.id);

    final createResult = await billRepo.createBill(
      companyId: company.id,
      userId: user.id,
      currencyId: company.defaultCurrencyId,
      billNumber: billNumber,
      tableId: result.tableId,
      isTakeaway: result.isTakeaway,
      numberOfGuests: result.numberOfGuests,
    );

    if (createResult is Success<BillModel> && mounted) {
      context.push('/sell/${createResult.value.id}');
    }
  }

  Future<void> _toggleSession(BuildContext context, bool hasSession) async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    if (hasSession) {
      // Close session
      final l = context.l10n;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(l.registerSessionConfirmClose),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
          ],
        ),
      );
      if (confirmed != true) return;

      final sessionAsync = ref.read(activeRegisterSessionProvider);
      final session = sessionAsync.valueOrNull;
      if (session != null) {
        await ref.read(registerSessionRepositoryProvider).closeSession(session.id);
      }
    } else {
      // Open session
      final register = await ref.read(activeRegisterProvider.future);
      if (register == null) return;

      await ref.read(registerSessionRepositoryProvider).openSession(
        companyId: company.id,
        registerId: register.id,
        userId: user.id,
      );
    }
  }
}

class _SectionTabBar extends ConsumerWidget {
  const _SectionTabBar({
    required this.selectedSectionId,
    required this.onChanged,
  });
  final String? selectedSectionId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final sections = snap.data ?? [];

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(l.billsSectionAll),
                  selected: selectedSectionId == null,
                  onSelected: (_) => onChanged(null),
                ),
                for (final section in sections) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(section.name),
                    selected: selectedSectionId == section.id,
                    onSelected: (_) => onChanged(section.id),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BillsTable extends ConsumerWidget {
  const _BillsTable({
    required this.statusFilter,
    this.sectionFilter,
    required this.onBillTap,
  });
  final BillStatus statusFilter;
  final String? sectionFilter;
  final ValueChanged<BillModel> onBillTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<BillModel>>(
      stream: ref.watch(billRepositoryProvider).watchByCompany(
        company.id,
        status: statusFilter,
        sectionId: sectionFilter,
      ),
      builder: (context, billSnap) {
        final bills = billSnap.data ?? [];

        // Load lookup data for tables and users
        return StreamBuilder<List<TableModel>>(
          stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
          builder: (context, tableSnap) {
            final tableMap = <String, TableModel>{};
            for (final t in (tableSnap.data ?? [])) {
              tableMap[t.id] = t;
            }

            return StreamBuilder<List<UserModel>>(
              stream: ref.watch(userRepositoryProvider).watchAll(company.id),
              builder: (context, userSnap) {
                final userMap = <String, UserModel>{};
                for (final u in (userSnap.data ?? [])) {
                  userMap[u.id] = u;
                }

                return Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: Row(
                        children: [
                          _HeaderCell(l.columnTable, flex: 2),
                          _HeaderCell(l.columnGuest, flex: 2),
                          _HeaderCell(l.columnGuests, flex: 1),
                          _HeaderCell(l.columnTotal, flex: 2),
                          _HeaderCell(l.columnLastOrder, flex: 2),
                          _HeaderCell(l.columnStaff, flex: 2),
                        ],
                      ),
                    ),
                    // Bill rows
                    Expanded(
                      child: bills.isEmpty
                          ? Center(
                              child: Text(
                                l.billsEmpty,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: bills.length,
                              itemBuilder: (context, index) {
                                final bill = bills[index];
                                return _BillRow(
                                  bill: bill,
                                  tableName: _resolveTableName(bill, tableMap, l),
                                  staffName: userMap[bill.openedByUserId]?.fullName ?? '-',
                                  onTap: () => onBillTap(bill),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _resolveTableName(BillModel bill, Map<String, TableModel> tableMap, dynamic l) {
    if (bill.isTakeaway) return l.billDetailTakeaway;
    if (bill.tableId == null) return l.billDetailNoTable;
    final table = tableMap[bill.tableId];
    return table?.name ?? '-';
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.bill,
    required this.tableName,
    required this.staffName,
    required this.onTap,
  });
  final BillModel bill;
  final String tableName;
  final String staffName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm', 'cs');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            // Table
            Expanded(
              flex: 2,
              child: Text(tableName),
            ),
            // Bill number
            Expanded(
              flex: 2,
              child: Text(bill.billNumber),
            ),
            // Guests
            Expanded(
              flex: 1,
              child: Text(bill.numberOfGuests > 0 ? '${bill.numberOfGuests}' : '-'),
            ),
            // Total
            Expanded(
              flex: 2,
              child: Text(bill.totalGross > 0 ? '${bill.totalGross ~/ 100} Kč' : '-'),
            ),
            // Time
            Expanded(
              flex: 2,
              child: Text(timeFormat.format(bill.openedAt)),
            ),
            // Staff
            Expanded(
              flex: 2,
              child: Text(staffName),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {required this.flex});
  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selected,
    required this.onChanged,
  });
  final BillStatus selected;
  final ValueChanged<BillStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final filters = [
      (BillStatus.opened, l.billsFilterOpened),
      (BillStatus.paid, l.billsFilterPaid),
      (BillStatus.cancelled, l.billsFilterCancelled),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            FilterChip(
              label: Text(filters[i].$2),
              selected: selected == filters[i].$1,
              onSelected: (_) => onChanged(filters[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.l,
    required this.activeUser,
    required this.loggedInUsers,
    required this.canManageSettings,
    required this.hasSession,
    required this.onLogout,
    required this.onSwitchUser,
    required this.onSettings,
    required this.onNewBill,
    required this.onQuickBill,
    required this.onToggleSession,
  });

  final dynamic l;
  final dynamic activeUser;
  final List loggedInUsers;
  final bool canManageSettings;
  final bool hasSession;
  final VoidCallback onLogout;
  final VoidCallback onSwitchUser;
  final VoidCallback? onSettings;
  final VoidCallback? onNewBill;
  final VoidCallback? onQuickBill;
  final VoidCallback onToggleSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.dividerColor)),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Register session toggle
                SizedBox(
                  height: 44,
                  child: hasSession
                      ? OutlinedButton(
                          onPressed: onToggleSession,
                          child: Text(l.registerSessionClose),
                        )
                      : FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: onToggleSession,
                          child: Text(l.registerSessionStart),
                        ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: FilledButton.tonal(
                    onPressed: onQuickBill,
                    child: Text(l.billsQuickBill),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: onNewBill,
                    child: Text(l.billsNewBill),
                  ),
                ),
                if (onSettings != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onSettings,
                      child: Text(l.settingsTitle),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          // Info panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  l.infoPanelStatus,
                  hasSession ? l.registerSessionActive : l.infoPanelStatusOffline,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  l.infoPanelActiveUser,
                  activeUser?.fullName ?? '-',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  l.infoPanelLoggedIn,
                  loggedInUsers.map((u) => u.fullName).join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onSwitchUser,
                    child: Text(l.actionSwitchUser),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    onPressed: onLogout,
                    child: Text(l.actionLogout),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _SwitchUserDialog extends StatefulWidget {
  const _SwitchUserDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_SwitchUserDialog> createState() => _SwitchUserDialogState();
}

class _SwitchUserDialogState extends State<_SwitchUserDialog> {
  String? _selectedUserId;
  final _pinCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final session = widget.ref.read(sessionManagerProvider);
    final activeUser = session.activeUser;
    final loggedIn = session.loggedInUsers;

    // If a user is selected, show PIN entry
    if (_selectedUserId != null) {
      final selectedUser = loggedIn.firstWhere((u) => u.id == _selectedUserId);
      return AlertDialog(
        title: Text(l.switchUserEnterPin(selectedUser.fullName)),
        content: TextField(
          controller: _pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.loginPinLabel,
            errorText: _error,
          ),
          onSubmitted: (_) => _verifyAndSwitch(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selectedUserId = null;
              _pinCtrl.clear();
              _error = null;
            }),
            child: Text(l.wizardBack),
          ),
          FilledButton(
            onPressed: _verifyAndSwitch,
            child: Text(l.loginButton),
          ),
        ],
      );
    }

    // Show user list
    return AlertDialog(
      title: Text(l.switchUserTitle),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.switchUserSelectUser),
            const SizedBox(height: 16),
            ...loggedIn.where((u) => u.id != activeUser?.id).map(
                  (user) => ListTile(
                    title: Text(user.fullName),
                    subtitle: Text(user.username),
                    onTap: () {
                      setState(() => _selectedUserId = user.id);
                    },
                  ),
                ),
            // New user login
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l.loginTitle),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionClose),
        ),
      ],
    );
  }

  void _verifyAndSwitch() {
    final session = widget.ref.read(sessionManagerProvider);
    final authService = widget.ref.read(authServiceProvider);
    final user = session.loggedInUsers.firstWhere((u) => u.id == _selectedUserId);

    final result = authService.authenticate(_pinCtrl.text, user.pinHash);
    switch (result) {
      case AuthSuccess():
        session.switchTo(user.id);
        widget.ref.read(activeUserProvider.notifier).state = session.activeUser;
        widget.ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
        if (mounted) Navigator.of(context).pop();
      case AuthFailure(message: final msg):
        setState(() {
          _error = msg;
          _pinCtrl.clear();
        });
      case AuthLocked(remainingSeconds: final secs):
        setState(() {
          _error = context.l10n.loginLockedOut(secs);
          _pinCtrl.clear();
        });
    }
  }
}
