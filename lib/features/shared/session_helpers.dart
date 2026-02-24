import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/enums/bill_status.dart';
import '../../core/data/enums/cash_movement_type.dart';
import '../../core/data/enums/hardware_type.dart';
import '../../core/data/enums/payment_type.dart';
import '../../core/data/providers/auth_providers.dart';
import '../../core/data/providers/repository_providers.dart';
import '../../core/data/result.dart';
import '../../core/l10n/app_localizations_ext.dart';
import '../../core/utils/formatting_ext.dart';
import '../../core/widgets/pos_dialog_actions.dart';
import '../../core/widgets/pos_dialog_shell.dart';
import '../bills/widgets/dialog_cash_journal.dart';
import '../bills/widgets/dialog_cash_movement.dart';
import '../bills/widgets/dialog_closing_session.dart';
import '../bills/widgets/dialog_opening_cash.dart';

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
  final deposits = movements
      .where((m) => m.type == CashMovementType.deposit)
      .fold(0, (sum, m) => sum + m.amount);
  final withdrawals = movements
      .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover)
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
  final cashDeposits = cashMovements
      .where((m) => m.type == CashMovementType.deposit)
      .fold(0, (sum, m) => sum + m.amount);
  final cashWithdrawals = cashMovements
      .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover)
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
        children: [
          Text(l.closingOpenBillsWarningMessage(openBillsCount, ref.money(openBillsAmount))),
          const SizedBox(height: 24),
          PosDialogActions(
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
        ],
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

  final foreignCurrencyCash = <ForeignCurrencyCashData>[];
  for (final scc in sessionCurrencyCashList) {
    final cur = await currencyRepo.getById(scc.currencyId);
    if (cur == null) continue;
    final revenue = foreignRevenue[scc.currencyId] ?? 0;
    foreignCurrencyCash.add(ForeignCurrencyCashData(
      currencyId: scc.currencyId,
      code: cur.code,
      symbol: cur.symbol,
      decimalPlaces: cur.decimalPlaces,
      openingCash: scc.openingCash,
      expectedCash: scc.openingCash + revenue,
      cashRevenue: revenue,
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
      result.closingCash > 0) {
    final parentSession = await ref.read(registerSessionRepositoryProvider)
        .getActiveSession(company.id, registerId: register.parentRegisterId);
    if (!context.mounted) return;
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
      if (!context.mounted) return;

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

  // Create SessionCurrencyCash records for each foreign currency
  if (openResult is Success) {
    final newSession = (openResult as Success).value;
    for (final entry in result.foreignCash.entries) {
      await sessionCurrencyCashRepo.create(
        companyId: company.id,
        registerSessionId: newSession.id,
        currencyId: entry.key,
        openingCash: entry.value,
      );
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
