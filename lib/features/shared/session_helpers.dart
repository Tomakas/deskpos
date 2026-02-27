import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/data/enums/bill_status.dart';
import '../../core/data/enums/cash_movement_type.dart';
import '../../core/data/models/currency_model.dart';
import '../../core/data/models/register_session_model.dart';
import '../../core/data/models/session_currency_cash_model.dart';
import '../../core/data/enums/hardware_type.dart';
import '../../core/data/enums/payment_type.dart';
import '../../core/data/providers/auth_providers.dart';
import '../../core/data/providers/printing_providers.dart';
import '../../core/data/providers/repository_providers.dart';
import '../../core/data/result.dart';
import '../../core/l10n/app_localizations_ext.dart';
import '../../core/logging/app_logger.dart';
import '../../core/printing/receipt_data.dart';
import '../../core/utils/file_opener.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/formatting_ext.dart';
import '../../core/widgets/pos_dialog_actions.dart';
import '../../core/widgets/pos_dialog_shell.dart';
import '../bills/providers/z_report_providers.dart';
import '../bills/widgets/dialog_cash_journal.dart';
import '../bills/widgets/dialog_cash_movement.dart';
import '../bills/widgets/dialog_closing_session.dart';
import '../bills/widgets/dialog_opening_cash.dart';

/// Returns active session or shows info dialog and returns null.
RegisterSessionModel? requireActiveSession(BuildContext context, WidgetRef ref) {
  final session = ref.read(activeRegisterSessionProvider).valueOrNull;
  if (session != null) return session;
  final l = context.l10n;
  showDialog(
    context: context,
    builder: (_) => PosDialogShell(
      title: l.sessionRequiredTitle,
      showCloseButton: true,
      children: [
        Text(l.sessionRequiredMessage),
        const SizedBox(height: 16),
      ],
    ),
  );
  return null;
}

/// Performs logout: closes active shift, clears auth state, navigates to /login.
Future<void> performLogout(BuildContext context, WidgetRef ref) async {
  final session = ref.read(sessionManagerProvider);
  final activeUser = session.activeUser;
  if (activeUser != null) {
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final regSessionRepo = ref.read(registerSessionRepositoryProvider);
      final shiftRepo = ref.read(shiftRepositoryProvider);
      final regSession = await regSessionRepo.getActiveSession(company.id);
      if (!context.mounted) return;
      if (regSession != null) {
        final activeShift = await shiftRepo.getActiveShiftForUser(activeUser.id, regSession.id);
        if (activeShift != null) {
          await shiftRepo.closeShift(activeShift.id);
        }
      }
    }
  }
  session.logoutActive();
  if (!context.mounted) return;
  ref.read(activeUserProvider.notifier).state = null;
  ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
  if (!context.mounted) return;
  context.go('/login');
}

/// Shows the cash journal dialog and handles creating a new cash movement.
Future<void> showCashJournalDialog(BuildContext context, WidgetRef ref) async {
  final company = ref.read(currentCompanyProvider);
  final user = ref.read(activeUserProvider);
  final session = ref.read(activeRegisterSessionProvider).valueOrNull;
  if (company == null || user == null || session == null) return;

  final cashMovementRepo = ref.read(cashMovementRepositoryProvider);
  final movements = await cashMovementRepo.getBySession(session.id);
  if (!context.mounted) return;

  final openingCash = session.openingCash ?? 0;
  // Balance uses only base currency movements (currencyId == null)
  final deposits = movements
      .where((m) => m.type == CashMovementType.deposit && m.currencyId == null)
      .fold(0, (sum, m) => sum + m.amount);
  final withdrawals = movements
      .where((m) => (m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover) && m.currencyId == null)
      .fold(0, (sum, m) => sum + m.amount);

  final billRepo = ref.read(billRepositoryProvider);
  final allBills = await billRepo.getByCompany(company.id);
  if (!context.mounted) return;
  final sessionBills = allBills.where((b) =>
      b.closedAt != null && b.closedAt!.isAfter(session.openedAt)).toList();

  final paymentRepo = ref.read(paymentRepositoryProvider);
  final paymentMethodRepo = ref.read(paymentMethodRepositoryProvider);
  final allMethods = await paymentMethodRepo.getAll(company.id);
  if (!context.mounted) return;
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

  // Load foreign currencies from session snapshot (currencies are frozen at session open)
  final currencyRepo = ref.read(currencyRepositoryProvider);
  final sessionCurrencyCashRepo = ref.read(sessionCurrencyCashRepositoryProvider);
  final sessionCurrencyCashList = await sessionCurrencyCashRepo.getBySession(session.id);
  if (!context.mounted) return;

  final foreignCurrencies = <ForeignCurrencyOpening>[];
  final currencyMap = <String, CurrencyModel>{};
  for (final scc in sessionCurrencyCashList) {
    final cur = await currencyRepo.getById(scc.currencyId);
    if (cur == null) continue;
    foreignCurrencies.add(ForeignCurrencyOpening(
      currencyId: scc.currencyId,
      code: cur.code,
      symbol: cur.symbol,
      decimalPlaces: cur.decimalPlaces,
    ));
    currencyMap[scc.currencyId] = cur;
  }
  if (!context.mounted) return;

  final result = await showDialog<CashMovementResult>(
    context: context,
    builder: (_) => DialogCashJournal(
      movements: movements,
      sales: sales,
      currentBalance: currentBalance,
      openingCash: openingCash,
      openedAt: session.openedAt,
      foreignCurrencies: foreignCurrencies,
      currencyMap: currencyMap,
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
    currencyId: result.currencyId,
  );
}

/// Closes the active register session with full reconciliation flow.
Future<void> closeSession(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final company = ref.read(currentCompanyProvider);
  final user = ref.read(activeUserProvider);
  if (company == null || user == null) return;

  final sessionAsync = ref.read(activeRegisterSessionProvider);
  final session = sessionAsync.valueOrNull;
  if (session == null) return;

  // Build closing data
  final cashMovements = await ref.read(cashMovementRepositoryProvider).getBySession(session.id);
  if (!context.mounted) return;
  // Base currency only (currencyId == null)
  final cashDeposits = cashMovements
      .where((m) => m.type == CashMovementType.deposit && m.currencyId == null)
      .fold(0, (sum, m) => sum + m.amount);
  final cashWithdrawals = cashMovements
      .where((m) => (m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover) && m.currencyId == null)
      .fold(0, (sum, m) => sum + m.amount);

  // Payment summaries: get all bills paid during this session
  final billRepo = ref.read(billRepositoryProvider);
  final allBills = await billRepo.getByCompany(company.id);
  if (!context.mounted) return;
  final sessionBills = allBills.where((b) =>
      b.closedAt != null && b.closedAt!.isAfter(session.openedAt)).toList();

  final paymentRepo = ref.read(paymentRepositoryProvider);
  final paymentMethodRepo = ref.read(paymentMethodRepositoryProvider);
  final allMethods = await paymentMethodRepo.getAll(company.id);
  if (!context.mounted) return;
  final methodMap = {for (final m in allMethods) m.id: m};

  // Aggregate payments by method
  final paymentsByMethod = <String, (String name, int amount, int count, bool isCash)>{};
  int totalRevenue = 0;
  int totalTips = 0;

  final allPayments = await paymentRepo.getByBillIds(
    sessionBills.map((b) => b.id).toList(),
  );
  for (final p in allPayments) {
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

  if (!context.mounted) return;
  // Resolve who opened the session
  final userRepo = ref.read(userRepositoryProvider);
  final openedByUser = await userRepo.getById(session.openedByUserId, includeDeleted: true);
  if (!context.mounted) return;
  final openedByName = openedByUser?.username ?? '-';

  // Warn about open bills before closing
  if (openBillsCount > 0) {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => PosDialogShell(
        title: l.closingOpenBillsWarningTitle,
        scrollable: true,
        children: [
          Text(l.closingOpenBillsWarningMessage(openBillsCount, ref.money(openBillsAmount))),
          const SizedBox(height: 24),
        ],
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.closingOpenBillsContinue),
            ),
          ],
        ),
      ),
    );
    if (shouldContinue != true || !context.mounted) return;
  }

  // Build foreign currency cash data
  final sessionCurrencyCashRepo = ref.read(sessionCurrencyCashRepositoryProvider);
  final currencyRepo = ref.read(currencyRepositoryProvider);
  final sessionCurrencyCashList = await sessionCurrencyCashRepo.getBySession(session.id);
  if (!context.mounted) return;

  // Aggregate foreignAmount per currencyId from cash payments
  final foreignRevenue = <String, int>{};
  for (final p in allPayments) {
    if (p.foreignCurrencyId != null && p.foreignAmount != null) {
      final method = methodMap[p.paymentMethodId];
      if (method?.type == PaymentType.cash) {
        foreignRevenue[p.foreignCurrencyId!] =
            (foreignRevenue[p.foreignCurrencyId!] ?? 0) + p.foreignAmount!;
      }
    }
  }

  // Aggregate per-currency deposits/withdrawals from cash movements
  final foreignDeposits = <String, int>{};
  final foreignWithdrawals = <String, int>{};
  for (final m in cashMovements) {
    if (m.currencyId == null) continue;
    if (m.type == CashMovementType.deposit) {
      foreignDeposits[m.currencyId!] =
          (foreignDeposits[m.currencyId!] ?? 0) + m.amount;
    } else if (m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense) {
      foreignWithdrawals[m.currencyId!] =
          (foreignWithdrawals[m.currencyId!] ?? 0) + m.amount;
    }
  }

  final foreignCurrencyCash = <ForeignCurrencyCashData>[];
  for (final scc in sessionCurrencyCashList) {
    final cur = await currencyRepo.getById(scc.currencyId);
    if (cur == null) continue;
    final revenue = foreignRevenue[scc.currencyId] ?? 0;
    final fcDeposits = foreignDeposits[scc.currencyId] ?? 0;
    final fcWithdrawals = foreignWithdrawals[scc.currencyId] ?? 0;
    foreignCurrencyCash.add(ForeignCurrencyCashData(
      currencyId: scc.currencyId,
      code: cur.code,
      symbol: cur.symbol,
      decimalPlaces: cur.decimalPlaces,
      openingCash: scc.openingCash,
      expectedCash: scc.openingCash + revenue + fcDeposits - fcWithdrawals,
      cashRevenue: revenue,
      cashDeposits: fcDeposits,
      cashWithdrawals: fcWithdrawals,
    ));
  }
  if (!context.mounted) return;

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
    foreignCurrencyCash: foreignCurrencyCash,
  );

  final result = await showDialog<ClosingSessionResult>(
    context: context,
    builder: (_) => DialogClosingSession(data: closingData),
  );
  if (result == null || !context.mounted) return;

  // Close all shifts for this session
  final closeShiftsResult = await ref.read(shiftRepositoryProvider).closeAllForSession(session.id);
  if (closeShiftsResult is Failure || !context.mounted) return;

  final difference = result.closingCash - expectedCash;
  await ref.read(registerSessionRepositoryProvider).closeSession(
    session.id,
    closingCash: result.closingCash,
    expectedCash: expectedCash,
    difference: difference,
    openBillsAtCloseCount: openBillsCount,
    openBillsAtCloseAmount: openBillsAmount,
  );
  if (!context.mounted) return;

  // Save foreign currency closing data
  final sccById = {for (final scc in sessionCurrencyCashList) scc.currencyId: scc};
  final expectedByCurrency = {for (final fc in foreignCurrencyCash) fc.currencyId: fc.expectedCash};
  for (final entry in result.foreignClosingCash.entries) {
    final scc = sccById[entry.key];
    if (scc == null) continue;
    final expected = expectedByCurrency[entry.key] ?? 0;
    await sessionCurrencyCashRepo.updateClosing(
      scc.id,
      closingCash: entry.value,
      expectedCash: expected,
      difference: entry.value - expected,
    );
  }
  if (!context.mounted) return;

  // Cash handover: if mobile register with parent, transfer cash to parent session
  final register = await ref.read(activeRegisterProvider.future);
  if (!context.mounted) return;
  if (register != null &&
      register.type == HardwareType.mobile &&
      register.parentRegisterId != null &&
      (result.closingCash > 0 || result.foreignClosingCash.values.any((v) => v > 0))) {
    final parentSession = await ref.read(registerSessionRepositoryProvider)
        .getActiveSession(company.id, registerId: register.parentRegisterId);
    if (!context.mounted) return;
    if (parentSession != null) {
      final cashMovementRepo = ref.read(cashMovementRepositoryProvider);
      final registerName = register.name.isNotEmpty ? register.name : register.code;

      // Base currency handover
      if (result.closingCash > 0) {
        await cashMovementRepo.create(
          companyId: company.id,
          registerSessionId: session.id,
          userId: user.id,
          type: CashMovementType.handover,
          amount: result.closingCash,
          reason: l.cashHandoverReason(registerName),
        );
        if (!context.mounted) return;
        await cashMovementRepo.create(
          companyId: company.id,
          registerSessionId: parentSession.id,
          userId: user.id,
          type: CashMovementType.deposit,
          amount: result.closingCash,
          reason: l.cashHandoverReason(registerName),
        );
        if (!context.mounted) return;
      }

      // Foreign currency handover
      for (final entry in result.foreignClosingCash.entries) {
        if (entry.value <= 0) continue;
        await cashMovementRepo.create(
          companyId: company.id,
          registerSessionId: session.id,
          userId: user.id,
          type: CashMovementType.handover,
          amount: entry.value,
          currencyId: entry.key,
          reason: l.cashHandoverReason(registerName),
        );
        if (!context.mounted) return;
        await cashMovementRepo.create(
          companyId: company.id,
          registerSessionId: parentSession.id,
          userId: user.id,
          type: CashMovementType.deposit,
          amount: entry.value,
          currencyId: entry.key,
          reason: l.cashHandoverReason(registerName),
        );
        if (!context.mounted) return;
      }
    }
  }

  // Print Z-report if requested
  if (result.printReport && context.mounted) {
    try {
      final zReport = await ref.read(zReportServiceProvider).buildZReport(session.id);
      if (zReport != null && context.mounted) {
        final locale = ref.read(appLocaleProvider).value ?? 'cs';
        final labels = ZReportLabels(
          reportTitle: l.zReportTitle,
          session: l.zReportSessionInfo,
          openedAt: l.zReportOpenedAt,
          closedAt: l.zReportClosedAt,
          duration: l.zReportDuration,
          openedBy: l.zReportOpenedBy,
          revenueTitle: l.zReportRevenueByPayment,
          revenueTotal: l.zReportRevenueTotal,
          taxTitle: l.zReportTaxTitle,
          taxRate: l.zReportTaxRate,
          taxNet: l.zReportTaxNet,
          taxAmount: l.zReportTaxAmount,
          taxGross: l.zReportTaxGross,
          tipsTitle: l.zReportTipsTotal,
          tipsTotal: l.zReportTipsTotal,
          tipsByUser: l.zReportTipsByUser,
          discountsTitle: l.zReportDiscounts,
          discountsTotal: l.zReportDiscounts,
          billCountsTitle: l.zReportBillsPaid,
          billsPaid: l.zReportBillsPaid,
          billsCancelled: l.zReportBillsCancelled,
          billsRefunded: l.zReportBillsRefunded,
          openBillsAtOpen: l.zReportOpenBillsAtOpen,
          openBillsAtClose: l.zReportOpenBillsAtClose,
          cashTitle: l.zReportCashTitle,
          cashOpening: l.zReportCashOpening,
          cashRevenue: l.zReportCashRevenue,
          cashDeposits: l.zReportCashDeposits,
          cashWithdrawals: l.zReportCashWithdrawals,
          cashExpected: l.zReportCashExpected,
          cashClosing: l.zReportCashClosing,
          cashDifference: l.zReportCashDifference,
          shiftsTitle: l.zReportShiftsTitle,
          currencySymbol: ref.currencySymbol,
          locale: locale,
          formatDuration: (d) => formatDuration(d,
              hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly),
          currency: ref.read(currentCurrencyProvider).value,
        );
        final bytes = await ref.read(printingServiceProvider)
            .generateZReportPdf(zReport, labels);
        await FileOpener.shareBytes('z_report_${session.id}.pdf', bytes);
      }
    } catch (e, s) {
      AppLogger.error('Failed to print Z-report after closing', error: e, stackTrace: s);
    }
  }
}

/// Opens a new register session.
Future<void> openSession(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final company = ref.read(currentCompanyProvider);
  final user = ref.read(activeUserProvider);
  if (company == null || user == null) return;

  final register = await ref.read(activeRegisterProvider.future);
  if (!context.mounted) return;
  if (register == null) return;

  final sessionRepo = ref.read(registerSessionRepositoryProvider);
  final lastClosingCash = await sessionRepo.getLastClosingCash(company.id, registerId: register.id);

  // Load active foreign currencies + their last closing cash
  final companyCurrencyRepo = ref.read(companyCurrencyRepositoryProvider);
  final currencyRepo = ref.read(currencyRepositoryProvider);
  final sessionCurrencyCashRepo = ref.read(sessionCurrencyCashRepositoryProvider);
  final activeForeign = await companyCurrencyRepo.getActive(company.id);
  final foreignOpenings = <ForeignCurrencyOpening>[];
  for (final cc in activeForeign) {
    final cur = await currencyRepo.getById(cc.currencyId);
    if (cur == null) continue;
    final lastForeignClosing = await sessionCurrencyCashRepo.getLastClosingCash(
      company.id, cc.currencyId, registerId: register.id,
    );
    foreignOpenings.add(ForeignCurrencyOpening(
      currencyId: cc.currencyId,
      code: cur.code,
      symbol: cur.symbol,
      decimalPlaces: cur.decimalPlaces,
      lastClosingCash: lastForeignClosing,
    ));
  }

  if (!context.mounted) return;

  final result = await showDialog<OpeningCashResult>(
    context: context,
    builder: (_) => DialogOpeningCash(
      initialAmount: lastClosingCash,
      foreignCurrencies: foreignOpenings,
    ),
  );
  if (result == null || !context.mounted) return;

  final openingCash = result.baseCash;

  // Snapshot open bills at session open
  final allBillsForOpen = await ref.read(billRepositoryProvider).getByCompany(company.id);
  if (!context.mounted) return;
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
  if (!context.mounted) return;

  // If opening amount differs from previous closing cash -> create correction movement
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
    if (!context.mounted) return;
  }

  // Create SessionCurrencyCash records for ALL active foreign currencies
  if (openResult is Success) {
    final newSession = (openResult as Success).value;
    for (final fc in foreignOpenings) {
      final now = DateTime.now();
      await sessionCurrencyCashRepo.create(SessionCurrencyCashModel(
        id: const Uuid().v7(),
        companyId: company.id,
        registerSessionId: newSession.id,
        currencyId: fc.currencyId,
        openingCash: result.foreignCash[fc.currencyId] ?? 0,
        createdAt: now,
        updatedAt: now,
      ));
    }
    if (!context.mounted) return;

    // Create shift for current user after opening session
    await ref.read(shiftRepositoryProvider).create(
      companyId: company.id,
      registerSessionId: newSession.id,
      userId: user.id,
    );
  }
}
