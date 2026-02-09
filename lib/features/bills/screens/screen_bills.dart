import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/pin_helper.dart';
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
  Set<BillStatus> _statusFilters = {BillStatus.opened};
  String? _sectionFilter;

  @override
  Widget build(BuildContext context) {
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
                _SectionTabBar(
                  selectedSectionId: _sectionFilter,
                  onChanged: (id) => setState(() => _sectionFilter = id),
                ),
                Expanded(
                  child: _BillsTable(
                    statusFilters: _statusFilters,
                    sectionFilter: _sectionFilter,
                    onBillTap: (bill) => _openBillDetail(context, bill),
                  ),
                ),
                _StatusFilterBar(
                  selected: _statusFilters,
                  onChanged: (filters) => setState(() => _statusFilters = filters),
                ),
              ],
            ),
          ),
          // Right panel (20%)
          SizedBox(
            width: 290,
            child: _RightPanel(
              activeUser: activeUser,
              loggedInUsers: loggedIn,
              canManageSettings: canManageSettings,
              hasSession: hasSession,
              sessionAsync: sessionAsync,
              onLogout: () => _logout(context),
              onSwitchUser: () => _showSwitchUserDialog(context),
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
    ref.read(activeUserProvider.notifier).state = null;
    ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
    context.go('/login');
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
    context.push('/sell');
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
      isTakeaway: false,
      numberOfGuests: result.numberOfGuests,
    );

    if (createResult is Success<BillModel> && mounted) {
      _openBillDetail(context, createResult.value);
    }
  }

  Future<void> _toggleSession(BuildContext context, bool hasSession) async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    if (hasSession) {
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

// ---------------------------------------------------------------------------
// Section Tab Bar
// ---------------------------------------------------------------------------
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
          child: Row(
            children: [
              SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  label: Text(l.billsSectionAll),
                  selected: selectedSectionId == null,
                  onSelected: (_) => onChanged(null),
                ),
              ),
              for (final section in sections) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilterChip(
                      showCheckmark: true,
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(section.name, textAlign: TextAlign.center),
                      ),
                      selected: selectedSectionId == section.id,
                      onSelected: (_) => onChanged(section.id),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  label: Text(l.billsSorting),
                  selected: false,
                  onSelected: null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bills Table
// ---------------------------------------------------------------------------
class _BillsTable extends ConsumerWidget {
  const _BillsTable({
    required this.statusFilters,
    this.sectionFilter,
    required this.onBillTap,
  });
  final Set<BillStatus> statusFilters;
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
        sectionId: sectionFilter,
      ),
      builder: (context, billSnap) {
        final allBills = billSnap.data ?? [];
        final bills = allBills.where((b) => statusFilters.contains(b.status)).toList();

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

                return StreamBuilder<Map<String, DateTime>>(
                  stream: ref.watch(orderRepositoryProvider).watchLastOrderTimesByCompany(company.id),
                  builder: (context, orderTimeSnap) {
                    final lastOrderTimes = orderTimeSnap.data ?? {};

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
                        Expanded(
                          child: bills.isEmpty
                              ? const SizedBox.shrink()
                              : ListView.builder(
                                  itemCount: bills.length,
                                  itemBuilder: (context, index) {
                                    final bill = bills[index];
                                    return _BillRow(
                                      bill: bill,
                                      tableName: _resolveTableName(bill, tableMap, l),
                                      staffName: userMap[bill.openedByUserId]?.fullName ?? '-',
                                      lastOrderTime: lastOrderTimes[bill.id],
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
      },
    );
  }

  String _resolveTableName(BillModel bill, Map<String, TableModel> tableMap, dynamic l) {
    if (bill.isTakeaway) return l.billsQuickBill;
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
    required this.lastOrderTime,
    required this.onTap,
  });
  final BillModel bill;
  final String tableName;
  final String staffName;
  final DateTime? lastOrderTime;
  final VoidCallback onTap;

  Color? _rowColor(BuildContext context) {
    return switch (bill.status) {
      BillStatus.opened => Colors.blue.withValues(alpha: 0.08),
      BillStatus.paid => Colors.green.withValues(alpha: 0.08),
      BillStatus.cancelled => Colors.pink.withValues(alpha: 0.08),
    };
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '<1min';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _rowColor(context),
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(tableName)),
            const Expanded(flex: 2, child: Text('')),
            Expanded(flex: 1, child: Text(bill.numberOfGuests > 0 ? '${bill.numberOfGuests}' : '')),
            Expanded(flex: 2, child: Text(bill.totalGross > 0 ? '${bill.totalGross ~/ 100},-' : '0,-')),
            Expanded(flex: 2, child: Text(lastOrderTime != null ? _formatRelativeTime(lastOrderTime!) : '')),
            Expanded(flex: 2, child: Text(staffName)),
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

// ---------------------------------------------------------------------------
// Status Filter Bar (multi-select toggles)
// ---------------------------------------------------------------------------
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selected,
    required this.onChanged,
  });
  final Set<BillStatus> selected;
  final ValueChanged<Set<BillStatus>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final filters = [
      (BillStatus.opened, l.billsFilterOpened, Colors.blue),
      (BillStatus.paid, l.billsFilterPaid, Colors.green),
      (BillStatus.cancelled, l.billsFilterCancelled, Colors.pink),
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  backgroundColor: filters[i].$3.withValues(alpha: 0.08),
                  selectedColor: filters[i].$3.withValues(alpha: 0.2),
                  checkmarkColor: filters[i].$3,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(filters[i].$2, textAlign: TextAlign.center),
                  ),
                  selected: selected.contains(filters[i].$1),
                  onSelected: (on) {
                    final next = Set<BillStatus>.from(selected);
                    if (on) {
                      next.add(filters[i].$1);
                    } else {
                      next.remove(filters[i].$1);
                    }
                    onChanged(next);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Right Panel (matches mockup: 4 button rows + info panel + bottom row)
// ---------------------------------------------------------------------------
class _RightPanel extends ConsumerWidget {
  const _RightPanel({
    required this.activeUser,
    required this.loggedInUsers,
    required this.canManageSettings,
    required this.hasSession,
    required this.sessionAsync,
    required this.onLogout,
    required this.onSwitchUser,
    required this.onNewBill,
    required this.onQuickBill,
    required this.onToggleSession,
  });

  final dynamic activeUser;
  final List loggedInUsers;
  final bool canManageSettings;
  final bool hasSession;
  final AsyncValue sessionAsync;
  final VoidCallback onLogout;
  final VoidCallback onSwitchUser;
  final VoidCallback? onNewBill;
  final VoidCallback? onQuickBill;
  final VoidCallback onToggleSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.dividerColor)),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Row 1: RYCHLÝ ÚČET | VYTVOŘIT ÚČET
          _ButtonRow(
            left: l.billsQuickBill,
            right: l.billsNewBill,
            onLeft: onQuickBill,
            onRight: onNewBill,
          ),
          // Row 2: POKLADNÍ DENÍK | PŘEHLED PRODEJE (disabled)
          _ButtonRow(
            left: l.billsCashJournal,
            right: l.billsSalesOverview,
            onLeft: null,
            onRight: null,
          ),
          // Row 3: SKLAD | DALŠÍ (→ popup menu)
          _MoreButtonRow(
            left: l.billsInventory,
            rightLabel: l.billsMore,
            canManageSettings: canManageSettings,
          ),
          // Row 4: MAPA (disabled) | UZÁVĚRKA
          _ButtonRow(
            left: l.billsTableMap,
            right: l.registerSessionClose,
            onLeft: null,
            onRight: onToggleSession,
            rightHighlight: !hasSession,
            rightLabel: hasSession ? l.registerSessionClose : l.registerSessionStart,
          ),
          // Info panel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _InfoPanel(
                activeUser: activeUser,
                loggedInUsers: loggedInUsers,
                hasSession: hasSession,
              ),
            ),
          ),
          const Divider(height: 1),
          // Bottom: PŘEPNOUT OBSLUHU | ODHLÁSIT
          _ButtonRow(
            left: l.actionSwitchUser,
            right: l.actionLogout,
            onLeft: onSwitchUser,
            onRight: onLogout,
            rightDanger: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.left,
    required this.right,
    required this.onLeft,
    required this.onRight,
    this.rightHighlight = false,
    this.rightDanger = false,
    this.rightLabel,
  });
  final String left;
  final String right;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final bool rightHighlight;
  final bool rightDanger;
  final String? rightLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: FilledButton.tonal(
                onPressed: onLeft,
                child: Text(left, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 54,
              child: rightHighlight
                  ? FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: onRight,
                      child: Text(rightLabel ?? right, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                    )
                  : rightDanger
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(color: Theme.of(context).colorScheme.error),
                          ),
                          onPressed: onRight,
                          child: Text(rightLabel ?? right, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        )
                      : FilledButton.tonal(
                          onPressed: onRight,
                          child: Text(rightLabel ?? right, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreButtonRow extends StatelessWidget {
  const _MoreButtonRow({
    required this.left,
    required this.rightLabel,
    required this.canManageSettings,
  });
  final String left;
  final String rightLabel;
  final bool canManageSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: FilledButton.tonal(
                onPressed: null,
                child: Text(left, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 54,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'settings':
                      context.push('/settings');
                    case 'dev':
                      context.push('/dev');
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'reports', enabled: false, height: 54, child: Text(l.moreReports)),
                  PopupMenuItem(value: 'statistics', enabled: false, height: 54, child: Text(l.moreStatistics)),
                  PopupMenuItem(value: 'reservations', enabled: false, height: 54, child: Text(l.moreReservations)),
                  PopupMenuItem(value: 'settings', height: 54, child: Text(l.moreSettings)),
                  if (canManageSettings)
                    PopupMenuItem(value: 'dev', height: 54, child: Text(l.moreDev)),
                ],
                constraints: const BoxConstraints(minWidth: 130),
                child: FilledButton.tonal(
                  onPressed: null,
                  child: Text(rightLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.activeUser,
    required this.loggedInUsers,
    required this.hasSession,
  });
  final dynamic activeUser;
  final List loggedInUsers;
  final bool hasSession;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE d.M.yyyy', 'cs');
    final timeFormat = DateFormat('HH:mm:ss', 'cs');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & time
          Text(
            '${dateFormat.format(now)}  ${timeFormat.format(now)}',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),
          // Status
          _InfoRow(l.infoPanelStatus, hasSession ? l.registerSessionActive : l.infoPanelStatusOffline),
          const Divider(),
          // Active user
          _InfoRow(l.infoPanelActiveUser, activeUser?.fullName ?? '-'),
          const SizedBox(height: 2),
          _InfoRow(l.infoPanelLoggedIn, loggedInUsers.map((u) => u.fullName).join(', ')),
          const Divider(),
          // Register total
          _InfoRow(l.infoPanelRegisterTotal, '-'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Switch User Dialog — 3 states: loggedIn list, newUser list, PIN numpad
// ---------------------------------------------------------------------------
enum _SwitchStep { loggedIn, newUser, pin }

class _SwitchUserDialog extends StatefulWidget {
  const _SwitchUserDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_SwitchUserDialog> createState() => _SwitchUserDialogState();
}

class _SwitchUserDialogState extends State<_SwitchUserDialog> {
  _SwitchStep _step = _SwitchStep.loggedIn;
  UserModel? _selectedUser;
  bool _isNewLogin = false;
  String _pin = '';
  String? _error;
  int? _lockSeconds;
  Timer? _lockTimer;

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 360,
        child: switch (_step) {
          _SwitchStep.loggedIn => _buildLoggedInList(context),
          _SwitchStep.newUser => _buildNewUserList(context),
          _SwitchStep.pin => _buildPinEntry(context),
        },
      ),
    );
  }

  // -- Step 1: Logged-in users -----------------------------------------------

  Widget _buildLoggedInList(BuildContext context) {
    final l = context.l10n;
    final session = widget.ref.read(sessionManagerProvider);
    final activeUser = session.activeUser;
    final company = widget.ref.read(currentCompanyProvider);
    final loggedIn = session.loggedInUsers.where((u) => u.id != activeUser?.id).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<UserModel>>(
        stream: company != null
            ? widget.ref.read(userRepositoryProvider).watchAll(company.id)
            : const Stream.empty(),
        builder: (context, snap) {
          final allUsers = snap.data ?? [];
          final hasNewUsers = allUsers.any((u) => !session.isLoggedIn(u.id));

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.switchUserTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              if (loggedIn.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l.switchUserSelectUser,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ...loggedIn.map((user) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _selectUser(user, isNew: false),
                          child: Text(user.fullName),
                        ),
                      ),
                    )),
              if (hasNewUsers) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.tonal(
                    onPressed: () => setState(() => _step = _SwitchStep.newUser),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add, size: 20),
                        const SizedBox(width: 8),
                        Text(l.loginTitle),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.actionClose),
              ),
            ],
          );
        },
      ),
    );
  }

  // -- Step 2: All non-logged-in users ---------------------------------------

  Widget _buildNewUserList(BuildContext context) {
    final l = context.l10n;
    final session = widget.ref.read(sessionManagerProvider);
    final company = widget.ref.read(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<UserModel>>(
        stream: widget.ref.read(userRepositoryProvider).watchAll(company.id),
        builder: (context, snap) {
          final allUsers = snap.data ?? [];
          final notLoggedIn = allUsers.where((u) => !session.isLoggedIn(u.id)).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.loginTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              if (notLoggedIn.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l.switchUserSelectUser,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ...notLoggedIn.map((user) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _selectUser(user, isNew: true),
                          child: Text(user.fullName),
                        ),
                      ),
                    )),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _step = _SwitchStep.loggedIn),
                child: Text(l.wizardBack),
              ),
            ],
          );
        },
      ),
    );
  }

  // -- Step 3: Numpad PIN entry ----------------------------------------------

  Widget _buildPinEntry(BuildContext context) {
    final l = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedUser!.fullName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // PIN dots
          SizedBox(
            height: 32,
            child: Text(
              '*' * _pin.length,
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Error / lockout
          if (_lockSeconds != null)
            Text(
              l.loginLockedOut(_lockSeconds!),
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            )
          else if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          const SizedBox(height: 16),
          // Numpad
          SizedBox(
            width: 280,
            child: Column(
              children: [
                _numpadRow(['1', '2', '3']),
                const SizedBox(height: 8),
                _numpadRow(['4', '5', '6']),
                const SizedBox(height: 8),
                _numpadRow(['7', '8', '9']),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _numpadButton(
                      child: const Icon(Icons.arrow_back),
                      onTap: _goBack,
                    ),
                    const SizedBox(width: 8),
                    _numpadButton(
                      child: const Text('0', style: TextStyle(fontSize: 24)),
                      onTap: () => _numpadTap('0'),
                    ),
                    const SizedBox(width: 8),
                    _numpadButton(
                      child: const Icon(Icons.backspace_outlined),
                      onTap: _numpadBackspace,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Numpad helpers --------------------------------------------------------

  Widget _numpadRow(List<String> digits) {
    return Row(
      children: digits.asMap().entries.map((e) {
        final w = _numpadButton(
          child: Text(e.value, style: const TextStyle(fontSize: 24)),
          onTap: () => _numpadTap(e.value),
        );
        if (e.key < digits.length - 1) {
          return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: w));
        }
        return Expanded(child: w);
      }).toList(),
    );
  }

  Widget _numpadButton({required Widget child, required VoidCallback onTap}) {
    return Expanded(
      child: SizedBox(
        height: 64,
        child: OutlinedButton(
          onPressed: _lockSeconds != null ? null : onTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.zero,
          ),
          child: child,
        ),
      ),
    );
  }

  // -- Actions ---------------------------------------------------------------

  void _selectUser(UserModel user, {required bool isNew}) {
    setState(() {
      _selectedUser = user;
      _isNewLogin = isNew;
      _pin = '';
      _error = null;
      _lockSeconds = null;
      _step = _SwitchStep.pin;
    });
    widget.ref.read(authServiceProvider).resetAttempts();
  }

  void _goBack() {
    setState(() {
      _selectedUser = null;
      _pin = '';
      _error = null;
      _step = _isNewLogin ? _SwitchStep.newUser : _SwitchStep.loggedIn;
    });
  }

  void _numpadTap(String digit) {
    if (_pin.length >= 6 || _lockSeconds != null) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    _onPinChanged();
  }

  void _numpadBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  void _onPinChanged() {
    if (_pin.length < 4 || _selectedUser == null || _lockSeconds != null) return;

    // Silent check (no brute-force counting)
    if (PinHelper.verifyPin(_pin, _selectedUser!.pinHash)) {
      _onSuccess();
      return;
    }

    // At max length (6) and still wrong — count as failed attempt
    if (_pin.length == 6) {
      final authService = widget.ref.read(authServiceProvider);
      final result = authService.authenticate(_pin, _selectedUser!.pinHash);
      switch (result) {
        case AuthSuccess():
          _onSuccess();
        case AuthLocked(remainingSeconds: final secs):
          _startLockTimer(secs);
        case AuthFailure(message: final msg):
          setState(() {
            _error = msg;
            _pin = '';
          });
      }
    }
  }

  void _onSuccess() {
    final session = widget.ref.read(sessionManagerProvider);
    final authService = widget.ref.read(authServiceProvider);
    authService.resetAttempts();

    if (_isNewLogin) {
      session.login(_selectedUser!);
    } else {
      session.switchTo(_selectedUser!.id);
    }
    widget.ref.read(activeUserProvider.notifier).state = session.activeUser;
    widget.ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
    if (mounted) Navigator.of(context).pop();
  }

  void _startLockTimer(int seconds) {
    _lockTimer?.cancel();
    setState(() {
      _lockSeconds = seconds;
      _error = null;
      _pin = '';
    });
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockSeconds = _lockSeconds! - 1;
        if (_lockSeconds! <= 0) {
          _lockSeconds = null;
          timer.cancel();
        }
      });
    });
  }
}
