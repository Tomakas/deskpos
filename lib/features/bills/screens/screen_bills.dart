import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/enums/hardware_type.dart';
import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_table.dart';
import '../providers/z_report_providers.dart';
import '../widgets/dialog_bill_detail.dart';
import '../widgets/dialog_cash_journal.dart';
import '../widgets/dialog_cash_movement.dart';
import '../widgets/dialog_closing_session.dart';
import '../widgets/dialog_new_bill.dart';
import '../widgets/dialog_opening_cash.dart';
import '../widgets/dialog_z_report.dart';
import '../widgets/dialog_reservations_list.dart';
import '../widgets/dialog_shifts_list.dart';
import '../widgets/dialog_z_report_list.dart';
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
                onZReports: () => _showZReports(context),
                onShifts: () => _showShifts(context),
                onReservations: () => _showReservations(context),
              ),
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
    if (!context.mounted) return;
    context.go('/login');
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

      final register = await ref.read(activeRegisterProvider.future);
      final session = ref.read(activeRegisterSessionProvider).value;
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
          .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover)
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

      if (!context.mounted) return;

      // Warn about open bills before closing
      if (openBillsCount > 0) {
        final l = context.l10n;
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l.closingOpenBillsWarningTitle),
            content: Text(l.closingOpenBillsWarningMessage(openBillsCount, ref.money(openBillsAmount))),
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
        if (shouldContinue != true || !context.mounted) return;
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
      if (result == null || !context.mounted) return;

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

      // Cash handover: if mobile register with parent, transfer cash to parent session
      final register = await ref.read(activeRegisterProvider.future);
      if (register != null &&
          register.type == HardwareType.mobile &&
          register.parentRegisterId != null &&
          result.closingCash > 0) {
        final parentSession = await ref.read(registerSessionRepositoryProvider)
            .getActiveSession(company.id, registerId: register.parentRegisterId);
        if (parentSession != null) {
          final cashMovementRepo = ref.read(cashMovementRepositoryProvider);
          final registerName = register.name.isNotEmpty ? register.name : register.code;

          // Withdrawal from mobile register (on the now-closed session)
          await cashMovementRepo.create(
            companyId: company.id,
            registerSessionId: session.id,
            userId: user.id,
            type: CashMovementType.handover,
            amount: result.closingCash,
            reason: l.cashHandoverReason(registerName),
          );

          // Deposit on parent register session
          await cashMovementRepo.create(
            companyId: company.id,
            registerSessionId: parentSession.id,
            userId: user.id,
            type: CashMovementType.deposit,
            amount: result.closingCash,
            reason: l.cashHandoverReason(registerName),
          );
        }
      }
    } else {
      // --- Opening session ---
      final register = await ref.read(activeRegisterProvider.future);
      if (register == null) return;

      final sessionRepo = ref.read(registerSessionRepositoryProvider);
      final lastClosingCash = await sessionRepo.getLastClosingCash(company.id, registerId: register.id);

      if (!context.mounted) return;

      final openingCash = await showDialog<int>(
        context: context,
        builder: (_) => DialogOpeningCash(initialAmount: lastClosingCash),
      );
      if (openingCash == null || !context.mounted) return;

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
        .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover)
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

    if (!context.mounted) return;

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

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => DialogZReportList(
        sessions: summaries,
        onSessionSelected: (sessionId) async {
          Navigator.pop(context);
          final zReport = await zReportService.buildZReport(sessionId);
          if (zReport != null && context.mounted) {
            showDialog(
              context: context,
              builder: (_) => DialogZReport(data: zReport),
            );
          }
        },
        onVenueReport: (dateFrom, dateTo) async {
          Navigator.pop(context);
          final venueReport = await zReportService.buildVenueZReport(
            company.id, dateFrom, dateTo,
          );
          if (venueReport != null && context.mounted) {
            showDialog(
              context: context,
              builder: (_) => DialogZReport(data: venueReport),
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

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => DialogShiftsList(shifts: rows),
    );
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

        return Container(
          height: 48,
          padding: const EdgeInsets.only(left: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
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
    required this.onZReports,
    required this.onShifts,
    required this.onReservations,
  });

  final dynamic activeUser;
  final List loggedInUsers;
  final bool canManageSettings;
  final bool hasSession;
  final AsyncValue sessionAsync;
  final bool showMap;
  final VoidCallback onToggleMap;
  final VoidCallback onLogout;
  final VoidCallback onSwitchUser;
  final VoidCallback? onNewBill;
  final VoidCallback? onQuickBill;
  final VoidCallback onToggleSession;
  final VoidCallback? onCashMovement;
  final VoidCallback onZReports;
  final VoidCallback onShifts;
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
      case 'company-settings':
        btnContext.push('/settings/company');
      case 'venue-settings':
        btnContext.push('/settings/venue');
      case 'register-settings':
        btnContext.push('/settings/register');
      case 'z-reports':
        onZReports?.call();
      case 'shifts':
        onShifts?.call();
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
  final dynamic activeUser;
  final List loggedInUsers;
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
                    _InfoRow(l.prepStatusInPrep, '${count(PrepStatus.inPrep)}'),
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

