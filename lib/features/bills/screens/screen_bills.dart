import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/pin_helper.dart';
import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../providers/z_report_providers.dart';
import '../widgets/dialog_bill_detail.dart';
import '../widgets/dialog_cash_journal.dart';
import '../widgets/dialog_cash_movement.dart';
import '../widgets/dialog_closing_session.dart';
import '../widgets/dialog_new_bill.dart';
import '../widgets/dialog_opening_cash.dart';
import '../widgets/dialog_z_report.dart';
import '../widgets/dialog_shifts_list.dart';
import '../widgets/dialog_z_report_list.dart';

enum _SortField { table, total, lastOrder }

class ScreenBills extends ConsumerStatefulWidget {
  const ScreenBills({super.key});

  @override
  ConsumerState<ScreenBills> createState() => _ScreenBillsState();
}

class _ScreenBillsState extends ConsumerState<ScreenBills> {
  Set<BillStatus> _statusFilters = {BillStatus.opened};
  String? _sectionFilter;
  _SortField _sortField = _SortField.table;
  bool _sortAscending = true;
  bool _isProcessing = false;
  bool _isCreatingBill = false;

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
                  sortField: _sortField,
                  sortAscending: _sortAscending,
                  onSortChanged: (field, ascending) => setState(() {
                    _sortField = field;
                    _sortAscending = ascending;
                  }),
                ),
                Expanded(
                  child: _BillsTable(
                    statusFilters: _statusFilters,
                    sectionFilter: _sectionFilter,
                    sortField: _sortField,
                    sortAscending: _sortAscending,
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
              onCashMovement: hasSession ? () => _showCashMovement(context) : null,
              onZReports: () => _showZReports(context),
              onShifts: () => _showShifts(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final session = ref.read(sessionManagerProvider);
    final activeUser = session.activeUser;
    // Close active shift before logout
    if (activeUser != null) {
      final company = ref.read(currentCompanyProvider);
      if (company != null) {
        final regSession = await ref.read(registerSessionRepositoryProvider).getActiveSession(company.id);
        if (regSession != null) {
          final shiftRepo = ref.read(shiftRepositoryProvider);
          final activeShift = await shiftRepo.getActiveShiftForUser(activeUser.id, regSession.id);
          if (activeShift != null) {
            await shiftRepo.closeShift(activeShift.id);
          }
        }
      }
    }
    session.logoutActive();
    ref.read(activeUserProvider.notifier).state = null;
    ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
    if (mounted) context.go('/login');
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
    if (_isCreatingBill) return;
    setState(() => _isCreatingBill = true);
    try {
      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      final billRepo = ref.read(billRepositoryProvider);

      final createResult = await billRepo.createBill(
        companyId: company.id,
        userId: user.id,
        currencyId: company.defaultCurrencyId,
        tableId: result.tableId,
        customerId: result.customerId,
        isTakeaway: false,
        numberOfGuests: result.numberOfGuests,
      );

      if (createResult is Success<BillModel> && mounted) {
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
    final l = context.l10n;
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    if (hasSession) {
      // --- Closing session ---
      final sessionAsync = ref.read(activeRegisterSessionProvider);
      final session = sessionAsync.valueOrNull;
      if (session == null) return;

      // Build closing data
      final cashMovements = await ref.read(cashMovementRepositoryProvider).getBySession(session.id);
      final cashDeposits = cashMovements
          .where((m) => m.type == CashMovementType.deposit)
          .fold(0, (sum, m) => sum + m.amount);
      final cashWithdrawals = cashMovements
          .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense)
          .fold(0, (sum, m) => sum + m.amount);

      // Payment summaries: get all bills paid during this session
      final billRepo = ref.read(billRepositoryProvider);
      final allBills = await billRepo.getByCompany(company.id);
      final sessionBills = allBills.where((b) =>
          b.closedAt != null && b.closedAt!.isAfter(session.openedAt)).toList();

      final paymentRepo = ref.read(paymentRepositoryProvider);
      final paymentMethodRepo = ref.read(paymentMethodRepositoryProvider);
      final allMethods = await paymentMethodRepo.getAll(company.id);
      final methodMap = {for (final m in allMethods) m.id: m};

      // Aggregate payments by method
      final paymentsByMethod = <String, (String name, int amount, int count, bool isCash)>{};
      int totalRevenue = 0;
      int totalTips = 0;

      for (final bill in sessionBills) {
        final payments = await paymentRepo.getByBill(bill.id);
        for (final p in payments) {
          final method = methodMap[p.paymentMethodId];
          final methodName = method?.name ?? '-';
          final isCash = method?.type == PaymentType.cash;
          final cashReceived = p.amount + p.tipIncludedAmount;
          final existing = paymentsByMethod[p.paymentMethodId];
          paymentsByMethod[p.paymentMethodId] = (
            methodName,
            (existing?.$2 ?? 0) + cashReceived,
            (existing?.$3 ?? 0) + 1,
            isCash,
          );
          totalRevenue += p.amount;
          totalTips += p.tipIncludedAmount;
        }
      }

      final paymentSummaries = paymentsByMethod.values
          .map((e) => PaymentTypeSummary(name: e.$1, amount: e.$2, count: e.$3, isCash: e.$4))
          .toList();

      final openingCash = session.openingCash ?? 0;
      final cashRevenue = paymentSummaries
          .where((s) => s.isCash)
          .fold(0, (sum, s) => sum + s.amount);
      final expectedCash = openingCash + cashRevenue + cashDeposits - cashWithdrawals;

      final billsPaid = sessionBills.where((b) => b.status == BillStatus.paid).length;
      final billsCancelled = sessionBills.where((b) => b.status == BillStatus.cancelled).length;

      // Compute open bills across entire company
      final openBills = allBills.where((b) => b.status == BillStatus.opened).toList();
      final openBillsCount = openBills.length;
      final openBillsAmount = openBills.fold(0, (sum, b) => sum + b.totalGross);

      // Resolve who opened the session
      final userRepo = ref.read(userRepositoryProvider);
      final openedByUser = await userRepo.getById(session.openedByUserId);
      final openedByName = openedByUser?.username ?? '-';

      if (!mounted) return;

      // Warn about open bills before closing
      if (openBillsCount > 0) {
        final l = context.l10n;
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l.closingOpenBillsWarningTitle),
            content: Text(l.closingOpenBillsWarningMessage(openBillsCount, '${openBillsAmount ~/ 100} Kč')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l.closingOpenBillsContinue),
              ),
            ],
          ),
        );
        if (shouldContinue != true || !mounted) return;
      }

      final closingData = ClosingSessionData(
        sessionOpenedAt: session.openedAt,
        openedByUserName: openedByName,
        openingCash: openingCash,
        expectedCash: expectedCash,
        paymentSummaries: paymentSummaries,
        totalRevenue: totalRevenue,
        totalTips: totalTips,
        billsPaid: billsPaid,
        billsCancelled: billsCancelled,
        cashDeposits: cashDeposits,
        cashWithdrawals: cashWithdrawals,
        openBillsCount: openBillsCount,
        openBillsAmount: openBillsAmount,
      );

      final result = await showDialog<ClosingSessionResult>(
        context: context,
        builder: (_) => DialogClosingSession(data: closingData),
      );
      if (result == null || !mounted) return;

      // Close all shifts for this session
      await ref.read(shiftRepositoryProvider).closeAllForSession(session.id);

      final difference = result.closingCash - expectedCash;
      await ref.read(registerSessionRepositoryProvider).closeSession(
        session.id,
        closingCash: result.closingCash,
        expectedCash: expectedCash,
        difference: difference,
        openBillsAtCloseCount: openBillsCount,
        openBillsAtCloseAmount: openBillsAmount,
      );
    } else {
      // --- Opening session ---
      final register = await ref.read(activeRegisterProvider.future);
      if (register == null) return;

      final sessionRepo = ref.read(registerSessionRepositoryProvider);
      final lastClosingCash = await sessionRepo.getLastClosingCash(company.id);

      if (!mounted) return;

      final openingCash = await showDialog<int>(
        context: context,
        builder: (_) => DialogOpeningCash(initialAmount: lastClosingCash),
      );
      if (openingCash == null || !mounted) return;

      // Snapshot open bills at session open
      final allBillsForOpen = await ref.read(billRepositoryProvider).getByCompany(company.id);
      final openBillsForOpen = allBillsForOpen.where((b) => b.status == BillStatus.opened).toList();
      final openBillsForOpenAmount = openBillsForOpen.fold(0, (sum, b) => sum + b.totalGross);

      final openResult = await sessionRepo.openSession(
        companyId: company.id,
        registerId: register.id,
        userId: user.id,
        openingCash: openingCash,
        openBillsAtOpenCount: openBillsForOpen.length,
        openBillsAtOpenAmount: openBillsForOpenAmount,
      );

      // If opening amount differs from previous closing cash → create correction movement
      if (lastClosingCash != null && openingCash != lastClosingCash && openResult is Success) {
        final newSession = (openResult as Success).value;
        final diff = openingCash - lastClosingCash;
        await ref.read(cashMovementRepositoryProvider).create(
          companyId: company.id,
          registerSessionId: newSession.id,
          userId: user.id,
          type: diff > 0 ? CashMovementType.deposit : CashMovementType.withdrawal,
          amount: diff.abs(),
          reason: l.autoCorrection,
        );
      }

      // Create shift for current user after opening session
      if (openResult is Success) {
        final newSession = (openResult as Success).value;
        await ref.read(shiftRepositoryProvider).create(
          companyId: company.id,
          registerSessionId: newSession.id,
          userId: user.id,
        );
      }
    }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showCashMovement(BuildContext context) async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    if (company == null || user == null || session == null) return;

    final cashMovementRepo = ref.read(cashMovementRepositoryProvider);
    final movements = await cashMovementRepo.getBySession(session.id);

    // Compute current cash balance: opening + deposits - withdrawals + cash revenue
    final openingCash = session.openingCash ?? 0;
    final deposits = movements
        .where((m) => m.type == CashMovementType.deposit)
        .fold(0, (sum, m) => sum + m.amount);
    final withdrawals = movements
        .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense)
        .fold(0, (sum, m) => sum + m.amount);

    // Cash revenue from sales paid during this session
    final billRepo = ref.read(billRepositoryProvider);
    final allBills = await billRepo.getByCompany(company.id);
    final sessionBills = allBills.where((b) =>
        b.closedAt != null && b.closedAt!.isAfter(session.openedAt)).toList();

    final paymentRepo = ref.read(paymentRepositoryProvider);
    final paymentMethodRepo = ref.read(paymentMethodRepositoryProvider);
    final allMethods = await paymentMethodRepo.getAll(company.id);
    final cashMethodIds = allMethods
        .where((m) => m.type == PaymentType.cash)
        .map((m) => m.id)
        .toSet();

    int cashRevenue = 0;
    final sales = <CashJournalSale>[];
    final billNumberMap = {for (final b in sessionBills) b.id: b.billNumber};

    for (final bill in sessionBills) {
      final payments = await paymentRepo.getByBill(bill.id);
      for (final p in payments) {
        if (cashMethodIds.contains(p.paymentMethodId)) {
          final cashReceived = p.amount + p.tipIncludedAmount;
          cashRevenue += cashReceived;
          sales.add(CashJournalSale(
            createdAt: p.paidAt,
            amount: cashReceived,
            billNumber: billNumberMap[bill.id],
          ));
        }
      }
    }

    final currentBalance = openingCash + deposits - withdrawals + cashRevenue;

    if (!mounted) return;

    final result = await showDialog<CashMovementResult>(
      context: context,
      builder: (_) => DialogCashJournal(
        movements: movements,
        sales: sales,
        currentBalance: currentBalance,
        openingCash: openingCash,
        openedAt: session.openedAt,
      ),
    );
    if (result == null) return;

    await cashMovementRepo.create(
      companyId: company.id,
      registerSessionId: session.id,
      userId: user.id,
      type: result.type,
      amount: result.amount,
      reason: result.reason,
    );
  }

  Future<void> _showZReports(BuildContext context) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final zReportService = ref.read(zReportServiceProvider);
    final summaries = await zReportService.getSessionSummaries(company.id);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => DialogZReportList(
        sessions: summaries,
        onSessionSelected: (sessionId) async {
          Navigator.pop(context);
          final zReport = await zReportService.buildZReport(sessionId);
          if (zReport != null && mounted) {
            showDialog(
              context: context,
              builder: (_) => DialogZReport(data: zReport),
            );
          }
        },
      ),
    );
  }

  Future<void> _showShifts(BuildContext context) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final shiftRepo = ref.read(shiftRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);
    final shifts = await shiftRepo.getByCompany(company.id);

    final rows = <ShiftDisplayRow>[];
    for (final shift in shifts) {
      final user = await userRepo.getById(shift.userId);
      rows.add(ShiftDisplayRow(
        username: user?.username ?? '-',
        loginAt: shift.loginAt,
        logoutAt: shift.logoutAt,
      ));
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => DialogShiftsList(shifts: rows),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Tab Bar
// ---------------------------------------------------------------------------
class _SectionTabBar extends ConsumerWidget {
  const _SectionTabBar({
    required this.selectedSectionId,
    required this.onChanged,
    required this.sortField,
    required this.sortAscending,
    required this.onSortChanged,
  });
  final String? selectedSectionId;
  final ValueChanged<String?> onChanged;
  final _SortField sortField;
  final bool sortAscending;
  final void Function(_SortField field, bool ascending) onSortChanged;

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
    required this.sortField,
    required this.sortAscending,
    required this.onBillTap,
  });
  final Set<BillStatus> statusFilters;
  final String? sectionFilter;
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
        sectionId: sectionFilter,
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
                                      staffName: userMap[bill.openedByUserId]?.username ?? '-',
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

class _BillRow extends StatefulWidget {
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

  @override
  State<_BillRow> createState() => _BillRowState();
}

class _BillRowState extends State<_BillRow> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _BillRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lastOrderTime != widget.lastOrderTime) {
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
    if (widget.lastOrderTime != null && widget.bill.status == BillStatus.opened) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  Color? _rowColor(BuildContext context) {
    return switch (widget.bill.status) {
      BillStatus.opened => Colors.blue.withValues(alpha: 0.08),
      BillStatus.paid => Colors.green.withValues(alpha: 0.08),
      BillStatus.cancelled => Colors.pink.withValues(alpha: 0.08),
      BillStatus.refunded => Colors.orange.withValues(alpha: 0.08),
    };
  }

  String _formatRelativeTime(BuildContext context, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return context.l10n.billTimeJustNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _rowColor(context),
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(widget.tableName)),
            const Expanded(flex: 2, child: Text('')),
            Expanded(flex: 1, child: Text(widget.bill.numberOfGuests > 0 ? '${widget.bill.numberOfGuests}' : '')),
            Expanded(
              flex: 2,
              child: widget.bill.status == BillStatus.refunded
                  ? Text(
                      widget.bill.totalGross > 0 ? '${widget.bill.totalGross ~/ 100},-' : '0,-',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Text(widget.bill.totalGross > 0 ? '${widget.bill.totalGross ~/ 100},-' : '0,-'),
            ),
            Expanded(flex: 2, child: Text(widget.lastOrderTime != null ? _formatRelativeTime(context, widget.lastOrderTime!) : '')),
            Expanded(flex: 2, child: Text(widget.staffName)),
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
    required this.onCashMovement,
    required this.onZReports,
    required this.onShifts,
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
  final VoidCallback? onCashMovement;
  final VoidCallback onZReports;
  final VoidCallback onShifts;

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
          // Row 2: POKLADNÍ DENÍK | KATALOG
          _ButtonRow(
            left: l.billsCashJournal,
            right: l.moreCatalog,
            onLeft: onCashMovement,
            onRight: canManageSettings ? () => context.push('/catalog') : null,
          ),
          // Row 3: SKLAD | DALŠÍ (→ menu near button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: FilledButton.tonal(
                      onPressed: null,
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
                          onZReports: onZReports,
                          onShifts: onShifts,
                        ),
                        child: Text(l.billsMore, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      );
                    }),
                  ),
                ),
              ],
            ),
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

void _showMoreMenu(BuildContext btnContext, bool canManageSettings, {VoidCallback? onZReports, VoidCallback? onShifts}) {
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
        PopupMenuItem(value: 'z-reports', height: 48, child: Text(l.moreReports)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreReports)),
      if (canManageSettings)
        PopupMenuItem(value: 'shifts', height: 48, child: Text(l.moreShifts)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreShifts)),
      PopupMenuItem(enabled: false, height: 48, child: Text(l.moreStatistics)),
      PopupMenuItem(enabled: false, height: 48, child: Text(l.moreReservations)),
      if (canManageSettings)
        PopupMenuItem(value: 'company-settings', height: 48, child: Text(l.moreCompanySettings)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreCompanySettings)),
      if (canManageSettings)
        PopupMenuItem(value: 'register-settings', height: 48, child: Text(l.moreRegisterSettings)),
      if (!canManageSettings)
        PopupMenuItem(enabled: false, height: 48, child: Text(l.moreRegisterSettings)),
    ],
  ).then((value) {
    if (value == null || !btnContext.mounted) return;
    switch (value) {
      case 'company-settings':
        btnContext.push('/settings/company');
      case 'register-settings':
        btnContext.push('/settings/register');
      case 'z-reports':
        onZReports?.call();
      case 'shifts':
        onShifts?.call();
    }
  });
}

class _InfoPanel extends ConsumerWidget {
  const _InfoPanel({
    required this.activeUser,
    required this.loggedInUsers,
    required this.hasSession,
  });
  final dynamic activeUser;
  final List loggedInUsers;
  final bool hasSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE d.M.yyyy', 'cs');
    final timeFormat = DateFormat('HH:mm:ss', 'cs');
    final isSyncConnected = ref.watch(isSupabaseAuthenticatedProvider);
    final session = ref.watch(activeRegisterSessionProvider).valueOrNull;

    // Compute register total when session is active
    String registerTotal = '-';
    if (session != null) {
      final openingCash = session.openingCash ?? 0;
      registerTotal = '${openingCash ~/ 100} Kč';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & time (ticks every second via Stream.periodic)
          StreamBuilder<DateTime>(
            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
            builder: (context, snap) {
              final now = snap.data ?? DateTime.now();
              return Text(
                '${dateFormat.format(now)}  ${timeFormat.format(now)}',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
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
          const Divider(),
          // Register total
          _InfoRow(l.infoPanelRegisterTotal, registerTotal),
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
            width: 120,
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
                          child: Text(user.username),
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
                          child: Text(user.username),
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
            _selectedUser!.username,
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
                    Expanded(
                      child: _numpadButton(
                        child: const Icon(Icons.arrow_back),
                        onTap: _goBack,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _numpadButton(
                        child: const Text('0', style: TextStyle(fontSize: 24)),
                        onTap: () => _numpadTap('0'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _numpadButton(
                        child: const Icon(Icons.backspace_outlined),
                        onTap: _numpadBackspace,
                      ),
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
    return SizedBox(
      height: 64,
      child: OutlinedButton(
        onPressed: _lockSeconds != null ? null : onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }

  // -- Actions ---------------------------------------------------------------

  Future<void> _selectUser(UserModel user, {required bool isNew}) async {
    final previousUser = _selectedUser;
    setState(() {
      _selectedUser = user;
      _isNewLogin = isNew;
      _pin = '';
      _error = null;
      _lockSeconds = null;
    });
    if (previousUser?.id != user.id) {
      widget.ref.read(authServiceProvider).resetAttempts();
    }

    // New logins always require PIN
    if (isNew) {
      setState(() => _step = _SwitchStep.pin);
      return;
    }

    // For already-logged-in users, check if PIN can be skipped
    final company = widget.ref.read(currentCompanyProvider);
    if (company != null) {
      final settings = await widget.ref
          .read(companySettingsRepositoryProvider)
          .getByCompany(company.id);
      if (settings != null && !settings.requirePinOnSwitch) {
        _onSuccess();
        return;
      }
    }

    setState(() => _step = _SwitchStep.pin);
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

  Future<void> _onSuccess() async {
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

    // Create shift if register session is active and user has no open shift
    final company = widget.ref.read(currentCompanyProvider);
    if (company != null) {
      final regSession = await widget.ref.read(registerSessionRepositoryProvider).getActiveSession(company.id);
      if (regSession != null) {
        final shiftRepo = widget.ref.read(shiftRepositoryProvider);
        final existing = await shiftRepo.getActiveShiftForUser(_selectedUser!.id, regSession.id);
        if (existing == null) {
          await shiftRepo.create(
            companyId: company.id,
            registerSessionId: regSession.id,
            userId: _selectedUser!.id,
          );
        }
      }
    }

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
