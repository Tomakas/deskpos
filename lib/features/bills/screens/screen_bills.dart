import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/enums/sell_mode.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/register_session_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_table.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/session_helpers.dart' as helpers;
import '../widgets/dialog_bill_detail.dart';
import '../widgets/dialog_new_bill.dart';
import '../widgets/dialog_reservations_list.dart';
import '../widgets/floor_map_view.dart';

enum _SortField { table, total, lastOrder }

class ScreenBills extends ConsumerStatefulWidget {
  const ScreenBills({super.key});

  @override
  ConsumerState<ScreenBills> createState() => _ScreenBillsState();
}

class _ScreenBillsState extends ConsumerState<ScreenBills> {
  Set<BillStatus> _statusFilters = {BillStatus.opened};
  Set<String> _sectionFilters = {};
  _SortField _sortField = _SortField.table;
  bool _sortAscending = true;
  bool _isProcessing = false;
  bool _isCreatingBill = false;
  bool _showMap = false;
  bool _isPanelVisible = true;

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
                  selectedSectionIds: _sectionFilters,
                  onChanged: (ids) => setState(() => _sectionFilters = ids),
                  sortField: _sortField,
                  sortAscending: _sortAscending,
                  onSortChanged: (field, ascending) => setState(() {
                    _sortField = field;
                    _sortAscending = ascending;
                  }),
                  singleSelect: _showMap,
                  showSort: !_showMap,
                  isPanelVisible: _isPanelVisible,
                  onTogglePanel: () => setState(() => _isPanelVisible = !_isPanelVisible),
                ),
                Expanded(
                  child: _showMap
                      ? FloorMapView(
                          sectionId: _sectionFilters.length == 1 ? _sectionFilters.first : null,
                          onBillTap: (bill) => _openBillDetail(context, bill),
                          onTableTap: (table) => _createNewBillForTable(context, table),
                        )
                      : _BillsTable(
                          statusFilters: _statusFilters,
                          sectionFilters: _sectionFilters,
                          sortField: _sortField,
                          sortAscending: _sortAscending,
                          onBillTap: (bill) => _openBillDetail(context, bill),
                        ),
                ),
                if (!_showMap)
                  _StatusFilterBar(
                    selected: _statusFilters,
                    onChanged: (filters) => setState(() => _statusFilters = filters),
                  ),
              ],
            ),
          ),
          // Right panel – collapsible
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _isPanelVisible ? 290 : 0,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: SizedBox(
              width: 290,
              child: _RightPanel(
                activeUser: activeUser,
                loggedInUsers: loggedIn,
                canManageSettings: canManageSettings,
                hasSession: hasSession,
                sessionAsync: sessionAsync,
                showMap: _showMap,
                onToggleMap: () => setState(() => _showMap = !_showMap),
                onLogout: () => _logout(context),
                onSwitchUser: () => _showSwitchUserDialog(context),
                onNewBill: hasSession ? () => _createNewBill(context) : null,
                onQuickBill: hasSession ? () => _createQuickBill(context) : null,
                onToggleSession: () => _toggleSession(context, hasSession),
                onCashMovement: hasSession ? () => _showCashMovement(context) : null,
                onReservations: () => _showReservations(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await helpers.performLogout(context, ref);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSwitchUserDialog(BuildContext context) {
    ref.read(manualLockProvider.notifier).state = true;
  }

  void _openBillDetail(BuildContext context, BillModel bill) {
    showDialog(
      context: context,
      builder: (_) => DialogBillDetail(billId: bill.id),
    );
  }

  Future<void> _createNewBillForTable(BuildContext context, TableModel table) async {
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    if (session == null) return;

    final result = await showDialog<NewBillResult>(
      context: context,
      builder: (_) => DialogNewBill(initialTableId: table.id),
    );
    if (result == null || !context.mounted) return;
    await _createBillFromResult(context, result);
  }

  Future<void> _createNewBill(BuildContext context) async {
    final result = await showDialog<NewBillResult>(
      context: context,
      builder: (_) => const DialogNewBill(),
    );
    if (result == null || !context.mounted) return;
    await _createBillFromResult(context, result);
  }

  Future<void> _createQuickBill(BuildContext context) async {
    final register = await ref.read(activeRegisterProvider.future);
    if (!context.mounted) return;
    if (register?.sellMode == SellMode.retail) {
      context.go('/sell');
    } else {
      context.push('/sell');
    }
  }

  Future<void> _createBillFromResult(BuildContext context, NewBillResult result) async {
    if (_isCreatingBill) return;
    setState(() => _isCreatingBill = true);
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);

      final sessionAsync = ref.read(activeRegisterSessionProvider);
      final register = await ref.read(activeRegisterProvider.future);
      if (!mounted) return;
      final session = sessionAsync.value;
      final createResult = await billRepo.createBill(
        companyId: company.id,
        userId: user.id,
        currencyId: company.defaultCurrencyId,
        sectionId: result.sectionId,
        tableId: result.tableId,
        customerId: result.customerId,
        customerName: result.customerName,
        registerId: register?.id,
        registerSessionId: session?.id,
        isTakeaway: false,
        numberOfGuests: result.numberOfGuests,
      );

      if (createResult is Success<BillModel> && context.mounted) {
        if (result.navigateToSell) {
          context.push('/sell/${createResult.value.id}');
        }
      }
    } finally {
      if (mounted) setState(() => _isCreatingBill = false);
    }
  }

  Future<void> _toggleSession(BuildContext context, bool hasSession) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      if (hasSession) {
        await helpers.closeSession(context, ref);
      } else {
        await helpers.openSession(context, ref);
        // In retail mode, navigate to sell screen after opening session
        if (!mounted) return;
        final register = await ref.read(activeRegisterProvider.future);
        if (register?.sellMode == SellMode.retail && context.mounted) {
          context.go('/sell');
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showCashMovement(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await helpers.showCashJournalDialog(context, ref);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showReservations(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const DialogReservationsList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Tab Bar
// ---------------------------------------------------------------------------
class _SectionTabBar extends ConsumerWidget {
  const _SectionTabBar({
    required this.selectedSectionIds,
    required this.onChanged,
    required this.sortField,
    required this.sortAscending,
    required this.onSortChanged,
    this.singleSelect = false,
    this.showSort = true,
    required this.isPanelVisible,
    required this.onTogglePanel,
  });
  final Set<String> selectedSectionIds;
  final ValueChanged<Set<String>> onChanged;
  final _SortField sortField;
  final bool sortAscending;
  final void Function(_SortField field, bool ascending) onSortChanged;
  final bool singleSelect;
  final bool showSort;
  final bool isPanelVisible;
  final VoidCallback onTogglePanel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final sections = snap.data ?? [];

        if (sections.isNotEmpty) {
          final validSelected = sections.where((s) => selectedSectionIds.contains(s.id)).toList();
          if (validSelected.isEmpty) {
            // Auto-select first section if none selected
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onChanged({sections.first.id});
            });
          } else if (singleSelect && validSelected.length > 1) {
            // In single-select mode, reduce to one
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onChanged({validSelected.first.id});
            });
          }
        }

        final register = ref.watch(activeRegisterProvider).valueOrNull;
        final isGastro = register?.sellMode != SellMode.retail;
        final canPop = !isGastro && GoRouter.of(context).canPop();

        return Container(
          height: 48,
          padding: EdgeInsets.only(left: canPop ? 4 : 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              if (canPop) ...[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) context.pop();
                    },
                  ),
                ),
                const SizedBox(width: 4),
              ],
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilterChip(
                      showCheckmark: true,
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(sections[i].name, textAlign: TextAlign.center),
                      ),
                      selected: selectedSectionIds.contains(sections[i].id),
                      onSelected: (on) {
                        if (singleSelect) {
                          onChanged({sections[i].id});
                        } else {
                          final next = Set<String>.from(selectedSectionIds);
                          if (on) {
                            next.add(sections[i].id);
                          } else {
                            next.remove(sections[i].id);
                          }
                          onChanged(next);
                        }
                      },
                    ),
                  ),
                ),
              ],
              if (showSort) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: PopupMenuButton<_SortField>(
                    onSelected: (field) {
                      if (field == sortField) {
                        onSortChanged(field, !sortAscending);
                      } else {
                        onSortChanged(field, true);
                      }
                    },
                    itemBuilder: (_) => [
                      for (final entry in {
                        _SortField.table: l.sortByTable,
                        _SortField.total: l.sortByTotal,
                        _SortField.lastOrder: l.sortByLastOrder,
                      }.entries)
                        PopupMenuItem(
                          value: entry.key,
                          child: Row(
                            children: [
                              Expanded(child: Text(entry.value)),
                              if (entry.key == sortField)
                                Icon(
                                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                    ],
                    child: Chip(
                      label: Text(l.billsSorting),
                      avatar: Icon(
                        sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
              // Panel toggle ear – styled as a tab protruding from the panel
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTogglePanel,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    border: Border(
                      left: BorderSide(color: Theme.of(context).dividerColor),
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Icon(
                    isPanelVisible ? Icons.chevron_right : Icons.chevron_left,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
// Resolved bill row data for PosTable
// ---------------------------------------------------------------------------
class _ResolvedBill {
  const _ResolvedBill({
    required this.bill,
    required this.tableName,
    required this.customerName,
    required this.staffName,
    required this.lastOrderTime,
  });
  final BillModel bill;
  final String tableName;
  final String customerName;
  final String staffName;
  final DateTime? lastOrderTime;
}

// ---------------------------------------------------------------------------
// Bills Table
// ---------------------------------------------------------------------------
class _BillsTable extends ConsumerWidget {
  const _BillsTable({
    required this.statusFilters,
    this.sectionFilters = const {},
    required this.sortField,
    required this.sortAscending,
    required this.onBillTap,
  });
  final Set<BillStatus> statusFilters;
  final Set<String> sectionFilters;
  final _SortField sortField;
  final bool sortAscending;
  final ValueChanged<BillModel> onBillTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<BillModel>>(
      stream: ref.watch(billRepositoryProvider).watchByCompany(
        company.id,
        sectionIds: sectionFilters.isEmpty ? null : sectionFilters,
      ),
      builder: (context, billSnap) {
        final allBills = billSnap.data ?? [];
        // Refunded bills are shown under the "paid" filter
        final effectiveFilters = Set<BillStatus>.from(statusFilters);
        if (effectiveFilters.contains(BillStatus.paid)) {
          effectiveFilters.add(BillStatus.refunded);
        }
        final bills = allBills.where((b) => effectiveFilters.contains(b.status)).toList();

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

                return StreamBuilder<List<CustomerModel>>(
                  stream: ref.watch(customerRepositoryProvider).watchAll(company.id),
                  builder: (context, customerSnap) {
                    final customerMap = <String, CustomerModel>{};
                    for (final c in (customerSnap.data ?? [])) {
                      customerMap[c.id] = c;
                    }

                return StreamBuilder<Map<String, DateTime>>(
                  stream: ref.watch(orderRepositoryProvider).watchLastOrderTimesByCompany(company.id),
                  builder: (context, orderTimeSnap) {
                    final lastOrderTimes = orderTimeSnap.data ?? {};

                    // Apply sorting
                    bills.sort((a, b) {
                      int cmp;
                      switch (sortField) {
                        case _SortField.table:
                          final nameA = _resolveTableName(a, tableMap, l);
                          final nameB = _resolveTableName(b, tableMap, l);
                          cmp = nameA.compareTo(nameB);
                        case _SortField.total:
                          cmp = a.totalGross.compareTo(b.totalGross);
                        case _SortField.lastOrder:
                          final timeA = lastOrderTimes[a.id];
                          final timeB = lastOrderTimes[b.id];
                          if (timeA == null && timeB == null) {
                            cmp = 0;
                          } else if (timeA == null) {
                            cmp = -1;
                          } else if (timeB == null) {
                            cmp = 1;
                          } else {
                            cmp = timeA.compareTo(timeB);
                          }
                      }
                      return sortAscending ? cmp : -cmp;
                    });

                    final resolved = bills.map((bill) {
                      final customer = bill.customerId != null ? customerMap[bill.customerId] : null;
                      return _ResolvedBill(
                        bill: bill,
                        tableName: _resolveTableName(bill, tableMap, l),
                        customerName: customer != null
                            ? '${customer.firstName} ${customer.lastName}'
                            : bill.customerName ?? '',
                        staffName: userMap[bill.openedByUserId]?.username ?? '-',
                        lastOrderTime: lastOrderTimes[bill.id],
                      );
                    }).toList();

                    return PosTable<_ResolvedBill>(
                      columns: [
                        PosColumn(label: l.columnTable, flex: 2, cellBuilder: (r) => Text(r.tableName)),
                        PosColumn(label: l.sellCustomer, flex: 2, cellBuilder: (r) => Text(r.customerName)),
                        PosColumn(label: l.columnGuests, flex: 1, cellBuilder: (r) => Text(r.bill.numberOfGuests > 0 ? '${r.bill.numberOfGuests}' : '')),
                        PosColumn(
                          label: l.columnTotal,
                          flex: 2,
                          cellBuilder: (r) => r.bill.status == BillStatus.refunded
                              ? Text(
                                  ref.money(r.bill.totalGross),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : Text(ref.money(r.bill.totalGross)),
                        ),
                        PosColumn(
                          label: l.columnLastOrder,
                          flex: 2,
                          cellBuilder: (r) => _RelativeTimeCell(
                            time: r.lastOrderTime,
                            isOpened: r.bill.status == BillStatus.opened,
                          ),
                        ),
                        PosColumn(label: l.columnStaff, flex: 2, cellBuilder: (r) => Text(r.staffName)),
                      ],
                      items: resolved,
                      onRowTap: (r) => onBillTap(r.bill),
                      rowColor: (r) => r.bill.status.color(context).withValues(alpha: 0.08),
                    );
                  },
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

  String _resolveTableName(BillModel bill, Map<String, TableModel> tableMap, AppLocalizations l) {
    if (bill.isTakeaway) return '${bill.billNumber} — ${l.billsQuickBill}';
    if (bill.tableId == null) return '${bill.billNumber} — ${l.billDetailNoTable}';
    final table = tableMap[bill.tableId];
    return table?.name ?? '-';
  }
}

// ---------------------------------------------------------------------------
// Relative time cell with auto-refresh timer
// ---------------------------------------------------------------------------
class _RelativeTimeCell extends StatefulWidget {
  const _RelativeTimeCell({required this.time, required this.isOpened});
  final DateTime? time;
  final bool isOpened;

  @override
  State<_RelativeTimeCell> createState() => _RelativeTimeCellState();
}

class _RelativeTimeCellState extends State<_RelativeTimeCell> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _RelativeTimeCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time || oldWidget.isOpened != widget.isOpened) {
      _startTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (widget.time != null && widget.isOpened) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  String _formatRelativeTime(BuildContext context, DateTime time) {
    final l = context.l10n;
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l.billTimeJustNow;
    return formatDuration(diff,
        hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly);
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.time != null ? _formatRelativeTime(context, widget.time!) : '');
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
      (BillStatus.opened, l.billsFilterOpened, BillStatus.opened.color(context)),
      (BillStatus.paid, l.billsFilterPaid, BillStatus.paid.color(context)),
      (BillStatus.cancelled, l.billsFilterCancelled, BillStatus.cancelled.color(context)),
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
                  checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
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
    required this.showMap,
    required this.onToggleMap,
    required this.onLogout,
    required this.onSwitchUser,
    required this.onNewBill,
    required this.onQuickBill,
    required this.onToggleSession,
    required this.onCashMovement,
    required this.onReservations,
  });

  final UserModel? activeUser;
  final List<UserModel> loggedInUsers;
  final bool canManageSettings;
  final bool hasSession;
  final AsyncValue<RegisterSessionModel?> sessionAsync;
  final bool showMap;
  final VoidCallback onToggleMap;
  final VoidCallback onLogout;
  final VoidCallback onSwitchUser;
  final VoidCallback? onNewBill;
  final VoidCallback? onQuickBill;
  final VoidCallback onToggleSession;
  final VoidCallback? onCashMovement;
  final VoidCallback onReservations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.dividerColor)),
            color: theme.colorScheme.surfaceContainer,
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
          // Row 2: POKLADNÍ DENÍK | KATALOG
          _ButtonRow(
            left: l.billsCashJournal,
            right: l.moreCatalog,
            onLeft: onCashMovement,
            onRight: canManageSettings ? () => context.push('/catalog') : null,
          ),
          // Row 3: OBJEDNÁVKY | REZERVACE
          _ButtonRow(
            left: l.ordersTitle,
            right: l.moreReservations,
            onLeft: () => context.push('/orders'),
            onRight: onReservations,
          ),
          // Row 4: SKLAD | DALŠÍ (→ menu near button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: FilledButton.tonal(
                      onPressed: () => context.push('/inventory'),
                      child: Text(l.billsInventory, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: Builder(builder: (btnContext) {
                      return FilledButton.tonal(
                        onPressed: () => _showMoreMenu(
                          btnContext,
                          canManageSettings,
                        ),
                        child: Text(l.billsMore, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Row 5: MAPA/SEZNAM | UZÁVĚRKA
          _ButtonRow(
            left: showMap ? l.billsTableList : l.billsTableMap,
            right: l.registerSessionClose,
            onLeft: onToggleMap,
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
    ),
    // Cover the left border at the top 48px where the toggle ear sits
    Positioned(
      left: 0,
      top: 5,
      child: Container(
        width: 1,
        height: 38,
        color: theme.colorScheme.surfaceContainer,
      ),
    ),
  ],
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
                      style: PosButtonStyles.confirm(context),
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

void _showMoreMenu(BuildContext btnContext, bool canManageSettings) {
  final l = btnContext.l10n;
  final button = btnContext.findRenderObject()! as RenderBox;
  final overlay = Overlay.of(btnContext).context.findRenderObject()! as RenderBox;
  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<String>(
    context: btnContext,
    position: position,
    items: [
      if (canManageSettings)
        PopupMenuItem(value: 'statistics', height: 48, child: Text(l.moreStatistics)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreStatistics)),
      if (canManageSettings)
        PopupMenuItem(value: 'vouchers', height: 48, child: Text(l.vouchersTitle)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.vouchersTitle)),
      if (canManageSettings)
        PopupMenuItem(value: 'company-settings', height: 48, child: Text(l.moreCompanySettings)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreCompanySettings)),
      if (canManageSettings)
        PopupMenuItem(value: 'venue-settings', height: 48, child: Text(l.moreVenueSettings)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreVenueSettings)),
      if (canManageSettings)
        PopupMenuItem(value: 'register-settings', height: 48, child: Text(l.moreRegisterSettings)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreRegisterSettings)),
    ],
  ).then((value) {
    if (value == null || !btnContext.mounted) return;
    switch (value) {
      case 'statistics':
        btnContext.push('/statistics');
      case 'company-settings':
        btnContext.push('/settings/company');
      case 'venue-settings':
        btnContext.push('/settings/venue');
      case 'register-settings':
        btnContext.push('/settings/register');
      case 'vouchers':
        btnContext.push('/vouchers');
    }
  });
}

class _InfoPanel extends ConsumerWidget {
  const _InfoPanel({
    required this.activeUser,
    required this.loggedInUsers,
    required this.hasSession,
  });
  final UserModel? activeUser;
  final List<UserModel> loggedInUsers;
  final bool hasSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isSyncConnected = ref.watch(isSupabaseAuthenticatedProvider);
    final session = ref.watch(activeRegisterSessionProvider).valueOrNull;
    final register = ref.watch(activeRegisterProvider).valueOrNull;

    final company = ref.watch(currentCompanyProvider);

    final registerName = register != null
        ? (register.name.isNotEmpty ? register.name : register.code)
        : '-';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & time (ticks every second via Stream.periodic)
          StreamBuilder<DateTime>(
            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
            builder: (context, snap) {
              final now = snap.data ?? DateTime.now();
              return Text(
                '${ref.fmtDateWithDay(now)}  ${ref.fmtTimeSeconds(now)}',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
          const Divider(),
          // Active register
          _InfoRow(l.infoPanelRegisterName, registerName),
          const Divider(),
          // Status
          _InfoRow(l.infoPanelStatus, hasSession ? l.registerSessionActive : l.infoPanelStatusOffline),
          const SizedBox(height: 2),
          _InfoRow(l.infoPanelSync, isSyncConnected ? l.infoPanelSyncConnected : l.infoPanelSyncDisconnected),
          const Divider(),
          // Active user
          _InfoRow(l.infoPanelActiveUser, activeUser?.username ?? '-'),
          const SizedBox(height: 2),
          _InfoRow(l.infoPanelLoggedIn, loggedInUsers.where((u) => u.id != activeUser?.id).map((u) => u.username).join(', ')),
          if (session != null && company != null) ...[
            const Divider(),
            // Orders by PrepStatus
            StreamBuilder<List<OrderModel>>(
              stream: ref.watch(orderRepositoryProvider).watchByCompany(
                company.id,
                since: session.openedAt,
              ),
              builder: (context, snap) {
                final orders = snap.data ?? [];
                int count(PrepStatus s) => orders.where((o) => o.status == s).length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(l.prepStatusCreated, '${count(PrepStatus.created)}'),
                    const SizedBox(height: 2),
                    _InfoRow(l.prepStatusReady, '${count(PrepStatus.ready)}'),
                    const SizedBox(height: 2),
                    _InfoRow(l.prepStatusDelivered, '${count(PrepStatus.delivered)}'),
                    const SizedBox(height: 2),
                    _InfoRow(l.prepStatusCancelled, '${count(PrepStatus.cancelled)}'),
                  ],
                );
              },
            ),
            const Divider(),
            // Revenue stats
            StreamBuilder<List<BillModel>>(
              stream: ref.watch(billRepositoryProvider).watchByCompany(company.id),
              builder: (context, snap) {
                final allBills = snap.data ?? [];
                final sessionBills = allBills.where((b) =>
                    b.closedAt != null && b.closedAt!.isAfter(session.openedAt));
                final paidBills = sessionBills.where((b) => b.status == BillStatus.paid);
                final revenue = paidBills.fold(0, (sum, b) => sum + b.totalGross);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(l.infoPanelRevenue, ref.money(revenue)),
                    const SizedBox(height: 2),
                    _InfoRow(l.infoPanelSalesCount, '${paidBills.length}'),
                  ],
                );
              },
            ),
          ],
        ],
      ),
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
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: 4),
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

