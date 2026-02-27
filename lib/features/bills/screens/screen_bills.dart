import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/enums/sell_mode.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/company_settings_model.dart';
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
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_table.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/session_helpers.dart' as helpers;
import '../widgets/dialog_bill_detail.dart';
import '../widgets/dialog_new_bill.dart';
import '../widgets/floor_map_view.dart';

enum _SortField { table, total, lastOrder }

class ScreenBills extends ConsumerStatefulWidget {
  const ScreenBills({super.key});

  @override
  ConsumerState<ScreenBills> createState() => _ScreenBillsState();
}

class _ScreenBillsState extends ConsumerState<ScreenBills> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  Set<BillStatus> _statusFilters = {BillStatus.opened};
  Set<String> _sectionFilters = {};
  _SortField _sortField = _SortField.table;
  bool _sortAscending = true;
  bool _isProcessing = false;
  bool _isCreatingBill = false;
  bool _showMap = false;
  bool _isPanelVisible = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(activeUserProvider);
    final loggedIn = ref.watch(loggedInUsersProvider);
    final sessionAsync = ref.watch(activeRegisterSessionProvider);
    final hasSession = sessionAsync.valueOrNull != null;

    final l = context.l10n;

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
                if (!_showMap)
                  PosTableToolbar(
                    searchController: _searchCtrl,
                    searchHint: l.searchHint,
                    onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
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
                          query: _query,
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
                onSettings: () => context.push('/settings'),
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
                PopupMenuButton<_SortField>(
                  icon: const Icon(Icons.swap_vert),
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
                            if (entry.key == sortField)
                              Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16)
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(entry.value)),
                          ],
                        ),
                      ),
                  ],
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
// Lookup providers for bills table (avoids 5-deep nested StreamBuilders)
// ---------------------------------------------------------------------------
final _tablesLookupProvider = StreamProvider.autoDispose.family<Map<String, TableModel>, String>((ref, companyId) {
  return ref.watch(tableRepositoryProvider).watchAll(companyId).map((list) {
    return {for (final t in list) t.id: t};
  });
});

final _usersLookupProvider = StreamProvider.autoDispose.family<Map<String, UserModel>, String>((ref, companyId) {
  return ref.watch(userRepositoryProvider).watchAll(companyId).map((list) {
    return {for (final u in list) u.id: u};
  });
});

final _customersLookupProvider = StreamProvider.autoDispose.family<Map<String, CustomerModel>, String>((ref, companyId) {
  return ref.watch(customerRepositoryProvider).watchAll(companyId).map((list) {
    return {for (final c in list) c.id: c};
  });
});

final _lastOrderTimesProvider = StreamProvider.autoDispose.family<Map<String, DateTime>, String>((ref, companyId) {
  return ref.watch(orderRepositoryProvider).watchLastOrderTimesByCompany(companyId);
});

final _companySettingsProvider = StreamProvider.autoDispose.family<CompanySettingsModel?, String>((ref, companyId) {
  return ref.watch(companySettingsRepositoryProvider).watchByCompany(companyId);
});

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
    this.query = '',
    required this.onBillTap,
  });
  final Set<BillStatus> statusFilters;
  final Set<String> sectionFilters;
  final _SortField sortField;
  final bool sortAscending;
  final String query;
  final ValueChanged<BillModel> onBillTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    // Lookup data via Riverpod providers (flat, no nesting)
    final tableMap = ref.watch(_tablesLookupProvider(company.id)).valueOrNull ?? {};
    final userMap = ref.watch(_usersLookupProvider(company.id)).valueOrNull ?? {};
    final customerMap = ref.watch(_customersLookupProvider(company.id)).valueOrNull ?? {};
    final lastOrderTimes = ref.watch(_lastOrderTimesProvider(company.id)).valueOrNull ?? {};
    final settings = ref.watch(_companySettingsProvider(company.id)).valueOrNull;
    final warnMin = settings?.billAgeWarningMinutes ?? 15;
    final dangerMin = settings?.billAgeDangerMinutes ?? 30;
    final criticalMin = settings?.billAgeCriticalMinutes ?? 45;

    return StreamBuilder<List<BillModel>>(
      stream: ref.watch(billRepositoryProvider).watchByCompany(
        company.id,
        sectionIds: sectionFilters.isEmpty ? null : sectionFilters,
      ),
      builder: (context, billSnap) {
        var allBills = billSnap.data ?? [];

        // Scope to active register session when one exists
        final activeSession = ref.watch(activeRegisterSessionProvider).valueOrNull;
        if (activeSession != null) {
          allBills = allBills.where((b) => b.registerSessionId == activeSession.id).toList();
        }

        // Refunded bills are shown under the "paid" filter
        final effectiveFilters = Set<BillStatus>.from(statusFilters);
        if (effectiveFilters.contains(BillStatus.paid)) {
          effectiveFilters.add(BillStatus.refunded);
        }
        final bills = allBills.where((b) => effectiveFilters.contains(b.status)).toList();

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

        var resolved = bills.map((bill) {
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

        if (query.isNotEmpty) {
          resolved = resolved.where((r) {
            if (normalizeSearch(r.tableName).contains(query)) return true;
            if (normalizeSearch(r.customerName).contains(query)) return true;
            if (normalizeSearch(r.staffName).contains(query)) return true;
            return false;
          }).toList();
        }

        return PosTable<_ResolvedBill>(
          columns: [
            PosColumn(label: l.columnTable, flex: 2, cellBuilder: (r) => HighlightedText(r.tableName, query: query, overflow: TextOverflow.ellipsis)),
            PosColumn(label: l.sellCustomer, flex: 2, cellBuilder: (r) => HighlightedText(r.customerName, query: query, overflow: TextOverflow.ellipsis)),
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
                warningMin: warnMin,
                dangerMin: dangerMin,
                criticalMin: criticalMin,
              ),
            ),
            PosColumn(label: l.columnStaff, flex: 2, cellBuilder: (r) => HighlightedText(r.staffName, query: query, overflow: TextOverflow.ellipsis)),
          ],
          items: resolved,
          onRowTap: (r) => onBillTap(r.bill),
          rowColor: (r) => r.bill.status.color(context).withValues(alpha: 0.08),
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
  const _RelativeTimeCell({
    required this.time,
    required this.isOpened,
    required this.warningMin,
    required this.dangerMin,
    required this.criticalMin,
  });
  final DateTime? time;
  final bool isOpened;
  final int warningMin;
  final int dangerMin;
  final int criticalMin;

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
    final l = context.l10n;
    if (!widget.isOpened) {
      return Text(widget.time != null ? _formatRelativeTime(context, widget.time!) : '');
    }
    final color = billAgeColor(
      widget.time,
      warningMin: widget.warningMin,
      dangerMin: widget.dangerMin,
      criticalMin: widget.criticalMin,
    );
    final text = widget.time != null
        ? _formatRelativeTime(context, widget.time!)
        : l.billTimeNoOrder;
    return Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600));
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
    required this.onSettings,
  });

  final UserModel? activeUser;
  final List<UserModel> loggedInUsers;
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
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final canOrders = ref.watch(hasPermissionProvider('orders.view'));
    final canCatalog = ref.watch(hasAnyPermissionInGroupProvider('products'));
    final canInventory = ref.watch(hasAnyPermissionInGroupProvider('stock'));
    final canStats = ref.watch(hasAnyPermissionInGroupProvider('stats'));
    final canVouchers = ref.watch(hasAnyPermissionInGroupProvider('vouchers'));
    final canData = ref.watch(hasAnyPermissionInGroupProvider('data'));
    final canCompanySettings = ref.watch(hasAnyPermissionInGroupProvider('settings_company'));
    final canVenueSettings = ref.watch(hasAnyPermissionInGroupProvider('settings_venue'));
    final canRegisterSettings = ref.watch(hasAnyPermissionInGroupProvider('settings_register'));

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
            leftIcon: Icons.flash_on,
            rightIcon: Icons.note_add,
            onLeft: onQuickBill,
            onRight: onNewBill,
          ),
          // Row 2: POKLADNÍ DENÍK | KATALOG
          _ButtonRow(
            left: l.billsCashJournal,
            right: l.moreCatalog,
            leftIcon: Icons.payments,
            rightIcon: Icons.category,
            onLeft: onCashMovement,
            onRight: canCatalog ? () => context.push('/catalog') : null,
          ),
          // Row 3: OBJEDNÁVKY | NASTAVENÍ
          _ButtonRow(
            left: l.ordersTitle,
            right: l.settingsTitle,
            leftIcon: Icons.receipt_long,
            rightIcon: Icons.settings,
            onLeft: canOrders ? () => context.push('/orders') : null,
            onRight: canCompanySettings || canVenueSettings || canRegisterSettings
                ? onSettings
                : null,
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
                      onPressed: canInventory ? () => context.push('/inventory') : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warehouse, size: 18),
                          const SizedBox(width: 6),
                          Flexible(child: Text(l.billsInventory, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
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
                          canStats: canStats,
                          canVouchers: canVouchers,
                          canData: canData,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.more_horiz, size: 18),
                            const SizedBox(width: 6),
                            Flexible(child: Text(l.billsMore, style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Row 5: MAPA/SEZNAM | UZÁVĚRKA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: onToggleMap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(showMap ? Icons.list : Icons.map, size: 18),
                          const SizedBox(width: 6),
                          Flexible(child: Text(
                            showMap ? l.billsTableList : l.billsTableMap,
                            style: const TextStyle(fontSize: 12),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: hasSession
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              side: BorderSide(color: Theme.of(context).colorScheme.error),
                            ),
                            onPressed: onToggleSession,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock, size: 18),
                                const SizedBox(width: 6),
                                Flexible(child: Text(l.registerSessionClose, style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          )
                        : FilledButton(
                            style: PosButtonStyles.confirm(context),
                            onPressed: onToggleSession,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_open, size: 18),
                                const SizedBox(width: 6),
                                Flexible(child: Text(l.registerSessionStart, style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
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
            leftIcon: Icons.swap_horiz,
            rightIcon: Icons.logout,
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
    this.leftIcon,
    this.rightIcon,
    this.rightDanger = false,
  });
  final String left;
  final String right;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool rightDanger;

  static Widget _buildChild(String label, IconData? icon) {
    if (icon == null) {
      return Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

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
                child: _buildChild(left, leftIcon),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 54,
              child: rightDanger
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      onPressed: onRight,
                      child: _buildChild(right, rightIcon),
                    )
                  : FilledButton.tonal(
                      onPressed: onRight,
                      child: _buildChild(right, rightIcon),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showMoreMenu(
  BuildContext btnContext, {
  required bool canStats,
  required bool canVouchers,
  required bool canData,
}) {
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
      if (canStats) PopupMenuItem(value: 'statistics', height: 48, child: Row(children: [const Icon(Icons.bar_chart, size: 20), const SizedBox(width: 12), Text(l.moreStatistics)])),
      if (canVouchers) PopupMenuItem(value: 'vouchers', height: 48, child: Row(children: [const Icon(Icons.card_giftcard, size: 20), const SizedBox(width: 12), Text(l.vouchersTitle)])),
      PopupMenuItem(value: 'reservations', height: 48, child: Row(children: [const Icon(Icons.event_seat, size: 20), const SizedBox(width: 12), Text(l.moreReservations)])),
      if (canData) PopupMenuItem(value: 'data', height: 48, child: Row(children: [const Icon(Icons.sd_card, size: 20), const SizedBox(width: 12), Text(l.dataTitle)])),
    ],
  ).then((value) {
    if (value == null || !btnContext.mounted) return;
    switch (value) {
      case 'statistics':
        btnContext.push('/statistics');
      case 'vouchers':
        btnContext.push('/vouchers');
      case 'reservations':
        btnContext.push('/reservations');
      case 'data':
        btnContext.push('/data');
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
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    ref.fmtTimeSeconds(now),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    ref.fmtDateWithDay(now),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
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

