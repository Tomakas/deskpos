import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/cash_movement_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/repositories/bill_repository.dart';
import '../../../core/data/repositories/cash_movement_repository.dart';
import '../../../core/data/repositories/currency_repository.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/repositories/payment_method_repository.dart';
import '../../../core/data/repositories/payment_repository.dart';
import '../../../core/data/repositories/register_repository.dart';
import '../../../core/data/repositories/register_session_repository.dart';
import '../../../core/data/repositories/session_currency_cash_repository.dart';
import '../../../core/data/repositories/shift_repository.dart';
import '../../../core/data/repositories/user_repository.dart';
import '../models/z_report_data.dart';
import '../widgets/dialog_closing_session.dart';

class ZReportService {
  ZReportService({
    required this.billRepo,
    required this.paymentRepo,
    required this.paymentMethodRepo,
    required this.cashMovementRepo,
    required this.registerSessionRepo,
    required this.shiftRepo,
    required this.userRepo,
    required this.orderRepo,
    required this.registerRepo,
    required this.sessionCurrencyCashRepo,
    required this.currencyRepo,
  });

  final BillRepository billRepo;
  final PaymentRepository paymentRepo;
  final PaymentMethodRepository paymentMethodRepo;
  final CashMovementRepository cashMovementRepo;
  final RegisterSessionRepository registerSessionRepo;
  final ShiftRepository shiftRepo;
  final UserRepository userRepo;
  final OrderRepository orderRepo;
  final RegisterRepository registerRepo;
  final SessionCurrencyCashRepository sessionCurrencyCashRepo;
  final CurrencyRepository currencyRepo;

  Future<ZReportData?> buildZReport(String sessionId) async {
    final session = await registerSessionRepo.getById(sessionId, includeDeleted: true);
    if (session == null) return null;

    // Resolve who opened the session (may be soft-deleted)
    final openedByUser = await userRepo.getById(session.openedByUserId, includeDeleted: true);
    final openedByName = openedByUser?.username ?? '-';

    // Resolve register name (may be soft-deleted)
    final register = await registerRepo.getById(session.registerId, includeDeleted: true);
    final registerName = register != null
        ? (register.name.isNotEmpty ? register.name : register.code)
        : null;

    // Get all bills for company, filter by closedAt within session range
    final allBills = await billRepo.getByCompany(session.companyId);
    final sessionBills = allBills.where((b) =>
        b.closedAt != null && b.closedAt!.isAfter(session.openedAt) &&
        (session.closedAt == null || !b.closedAt!.isAfter(session.closedAt!))).toList();

    // Get all payment methods
    final allMethods = await paymentMethodRepo.getAll(session.companyId);
    final methodMap = {for (final m in allMethods) m.id: m};

    // Aggregate payments by method
    final paymentsByMethod = <String, (String name, int amount, int count, bool isCash)>{};
    int totalRevenue = 0;
    int totalTips = 0;
    final tipsByUserId = <String, int>{};

    for (final bill in sessionBills) {
      if (bill.status == BillStatus.cancelled) continue;
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

        // Track tips per user
        if (p.tipIncludedAmount > 0 && p.userId != null) {
          tipsByUserId[p.userId!] = (tipsByUserId[p.userId!] ?? 0) + p.tipIncludedAmount;
        }
      }
    }

    final paymentSummaries = paymentsByMethod.values
        .map((e) => PaymentTypeSummary(name: e.$1, amount: e.$2, count: e.$3, isCash: e.$4))
        .toList();

    // Resolve tips by user to usernames (may be soft-deleted)
    final tipsByUser = <String, (String, int)>{};
    for (final entry in tipsByUserId.entries) {
      final user = await userRepo.getById(entry.key, includeDeleted: true);
      final username = user?.username ?? '-';
      tipsByUser[entry.key] = (username, entry.value);
    }

    // Tax breakdown: for each paid bill → order items → group by saleTaxRateAtt
    final taxMap = <int, (int net, int tax, int gross)>{};
    final paidBills = sessionBills.where((b) => b.status == BillStatus.paid || b.status == BillStatus.refunded);
    for (final bill in paidBills) {
      final items = await orderRepo.getOrderItemsByBill(bill.id);
      for (final item in items) {
        if (item.status == PrepStatus.cancelled || item.status == PrepStatus.voided) continue;
        final rate = item.saleTaxRateAtt;
        final itemGross = (item.salePriceAtt * item.quantity).round();
        final itemTax = (item.saleTaxAmount * item.quantity).round();
        final itemNet = itemGross - itemTax;
        final existing = taxMap[rate];
        taxMap[rate] = (
          (existing?.$1 ?? 0) + itemNet,
          (existing?.$2 ?? 0) + itemTax,
          (existing?.$3 ?? 0) + itemGross,
        );
      }
    }
    final taxBreakdown = taxMap.entries
        .map((e) => TaxBreakdownRow(
              taxRatePercent: e.key,
              netAmount: e.value.$1,
              taxAmount: e.value.$2,
              grossAmount: e.value.$3,
            ))
        .toList()
      ..sort((a, b) => a.taxRatePercent.compareTo(b.taxRatePercent));

    // Discounts
    final totalDiscounts = sessionBills
        .where((b) => b.status == BillStatus.paid)
        .fold(0, (sum, b) => sum + b.discountAmount);

    // Bill counts
    final billsPaid = sessionBills.where((b) => b.status == BillStatus.paid).length;
    final billsCancelled = sessionBills.where((b) => b.status == BillStatus.cancelled).length;
    final billsRefunded = sessionBills.where((b) => b.status == BillStatus.refunded).length;

    // Cash movements (exclude handover — it's a post-close transfer, not session accounting)
    final cashMovements = await cashMovementRepo.getBySession(sessionId);
    final cashDeposits = cashMovements
        .where((m) => m.type == CashMovementType.deposit)
        .fold(0, (sum, m) => sum + m.amount);
    final cashWithdrawals = cashMovements
        .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense)
        .fold(0, (sum, m) => sum + m.amount);

    final openingCash = session.openingCash ?? 0;
    final cashRevenue = paymentSummaries
        .where((s) => s.isCash)
        .fold(0, (sum, s) => sum + s.amount);
    final expectedCash = openingCash + cashRevenue + cashDeposits - cashWithdrawals;
    final closingCash = session.closingCash ?? 0;
    final difference = session.difference ?? (closingCash - expectedCash);

    // Shifts
    final shifts = await shiftRepo.getBySession(sessionId);
    final shiftDurations = <String, (String, Duration)>{};
    for (final shift in shifts) {
      final user = await userRepo.getById(shift.userId, includeDeleted: true);
      final username = user?.username ?? '-';
      final end = shift.logoutAt ?? session.closedAt ?? DateTime.now();
      final dur = end.difference(shift.loginAt);
      final existing = shiftDurations[shift.userId];
      if (existing != null) {
        shiftDurations[shift.userId] = (username, existing.$2 + dur);
      } else {
        shiftDurations[shift.userId] = (username, dur);
      }
    }

    // Duration
    final sessionEnd = session.closedAt ?? DateTime.now();
    final duration = sessionEnd.difference(session.openedAt);

    // Foreign currency cash
    final foreignCurrencyCash = await _buildForeignCurrencyCash(
      sessionId, sessionBills, methodMap,
    );

    return ZReportData(
      sessionId: sessionId,
      openedAt: session.openedAt,
      closedAt: session.closedAt,
      openedByName: openedByName,
      duration: duration,
      paymentSummaries: paymentSummaries,
      totalRevenue: totalRevenue,
      totalTips: totalTips,
      tipsByUser: tipsByUser,
      taxBreakdown: taxBreakdown,
      totalDiscounts: totalDiscounts,
      billsPaid: billsPaid,
      billsCancelled: billsCancelled,
      billsRefunded: billsRefunded,
      openingCash: openingCash,
      closingCash: closingCash,
      expectedCash: expectedCash,
      difference: difference,
      cashDeposits: cashDeposits,
      cashWithdrawals: cashWithdrawals,
      cashRevenue: cashRevenue,
      shiftDurations: shiftDurations,
      openBillsAtOpenCount: session.openBillsAtOpenCount ?? 0,
      openBillsAtOpenAmount: session.openBillsAtOpenAmount ?? 0,
      openBillsAtCloseCount: session.openBillsAtCloseCount ?? 0,
      openBillsAtCloseAmount: session.openBillsAtCloseAmount ?? 0,
      registerName: registerName,
      foreignCurrencyCash: foreignCurrencyCash,
    );
  }

  /// Build a venue-wide Z-report aggregating all sessions in a date range.
  Future<ZReportData?> buildVenueZReport(
    String companyId,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    final closedSessions = await registerSessionRepo.getClosedSessions(companyId);
    final sessionsInRange = closedSessions.where((s) {
      final closedAt = s.closedAt;
      if (closedAt == null) return false;
      return !closedAt.isBefore(dateFrom) && !closedAt.isAfter(dateTo);
    }).toList();

    if (sessionsInRange.isEmpty) return null;

    // Resolve registers by ID (includeDeleted for historical data)
    final registerCache = <String, RegisterModel?>{};
    for (final s in sessionsInRange) {
      if (!registerCache.containsKey(s.registerId)) {
        registerCache[s.registerId] = await registerRepo.getById(s.registerId, includeDeleted: true);
      }
    }

    // Get all bills for company
    final allBills = await billRepo.getByCompany(companyId);
    // Index bills by registerSessionId for O(1) lookup
    final sessionIds = {for (final s in sessionsInRange) s.id};
    final billsBySession = <String, List<BillModel>>{};
    for (final b in allBills) {
      if (b.registerSessionId != null && sessionIds.contains(b.registerSessionId)) {
        billsBySession.putIfAbsent(b.registerSessionId!, () => []).add(b);
      }
    }

    // Get all payment methods
    final allMethods = await paymentMethodRepo.getAll(companyId);
    final methodMap = {for (final m in allMethods) m.id: m};

    // Aggregated totals
    final paymentsByMethod = <String, (String name, int amount, int count, bool isCash)>{};
    int totalRevenue = 0;
    int totalTips = 0;
    final tipsByUserId = <String, int>{};
    int totalDiscounts = 0;
    int billsPaid = 0;
    int billsCancelled = 0;
    int billsRefunded = 0;
    int totalOpeningCash = 0;
    int totalClosingCash = 0;
    int totalCashDeposits = 0;
    int totalCashWithdrawals = 0;
    final shiftDurations = <String, (String, Duration)>{};
    final taxMap = <int, (int net, int tax, int gross)>{};

    // Per-register data
    final registerPayments = <String, Map<String, (String name, int amount, int count, bool isCash)>>{};
    final registerRevenue = <String, int>{};
    final registerTips = <String, int>{};
    final registerBillsPaid = <String, int>{};

    // Cache cash movements per session (avoids redundant fetches in breakdown)
    final movementsCache = <String, List<CashMovementModel>>{};

    for (final session in sessionsInRange) {
      final regId = session.registerId;

      // Bills attributed to this session via registerSessionId (no double-counting)
      final sessionBills = billsBySession[session.id] ?? [];

      for (final bill in sessionBills) {
        if (bill.status == BillStatus.cancelled) {
          billsCancelled++;
          continue;
        }
        if (bill.status == BillStatus.refunded) billsRefunded++;
        if (bill.status == BillStatus.paid) {
          billsPaid++;
          totalDiscounts += bill.discountAmount;
          registerBillsPaid[regId] = (registerBillsPaid[regId] ?? 0) + 1;
        }

        final payments = await paymentRepo.getByBill(bill.id);
        for (final p in payments) {
          final method = methodMap[p.paymentMethodId];
          final methodName = method?.name ?? '-';
          final isCash = method?.type == PaymentType.cash;
          final cashReceived = p.amount + p.tipIncludedAmount;

          // Global aggregation
          final existing = paymentsByMethod[p.paymentMethodId];
          paymentsByMethod[p.paymentMethodId] = (
            methodName,
            (existing?.$2 ?? 0) + cashReceived,
            (existing?.$3 ?? 0) + 1,
            isCash,
          );
          totalRevenue += p.amount;
          totalTips += p.tipIncludedAmount;

          // Per-register aggregation
          registerPayments.putIfAbsent(regId, () => {});
          final regExisting = registerPayments[regId]![p.paymentMethodId];
          registerPayments[regId]![p.paymentMethodId] = (
            methodName,
            (regExisting?.$2 ?? 0) + cashReceived,
            (regExisting?.$3 ?? 0) + 1,
            isCash,
          );
          registerRevenue[regId] = (registerRevenue[regId] ?? 0) + p.amount;
          registerTips[regId] = (registerTips[regId] ?? 0) + p.tipIncludedAmount;

          if (p.tipIncludedAmount > 0 && p.userId != null) {
            tipsByUserId[p.userId!] = (tipsByUserId[p.userId!] ?? 0) + p.tipIncludedAmount;
          }
        }

        // Tax breakdown for paid/refunded bills
        if (bill.status == BillStatus.paid || bill.status == BillStatus.refunded) {
          final items = await orderRepo.getOrderItemsByBill(bill.id);
          for (final item in items) {
            if (item.status == PrepStatus.cancelled || item.status == PrepStatus.voided) continue;
            final rate = item.saleTaxRateAtt;
            final itemGross = (item.salePriceAtt * item.quantity).round();
            final itemTax = (item.saleTaxAmount * item.quantity).round();
            final itemNet = itemGross - itemTax;
            final existing = taxMap[rate];
            taxMap[rate] = (
              (existing?.$1 ?? 0) + itemNet,
              (existing?.$2 ?? 0) + itemTax,
              (existing?.$3 ?? 0) + itemGross,
            );
          }
        }
      }

      // Cash movements per session (exclude handover — post-close transfer)
      final cashMovements = await cashMovementRepo.getBySession(session.id);
      movementsCache[session.id] = cashMovements;
      final sessionDeposits = cashMovements
          .where((m) => m.type == CashMovementType.deposit)
          .fold(0, (sum, m) => sum + m.amount);
      final sessionWithdrawals = cashMovements
          .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense)
          .fold(0, (sum, m) => sum + m.amount);
      totalCashDeposits += sessionDeposits;
      totalCashWithdrawals += sessionWithdrawals;
      totalOpeningCash += session.openingCash ?? 0;
      totalClosingCash += session.closingCash ?? 0;

      // Shifts
      final shifts = await shiftRepo.getBySession(session.id);
      for (final shift in shifts) {
        final user = await userRepo.getById(shift.userId, includeDeleted: true);
        final username = user?.username ?? '-';
        final end = shift.logoutAt ?? session.closedAt ?? DateTime.now();
        final dur = end.difference(shift.loginAt);
        final existing = shiftDurations[shift.userId];
        if (existing != null) {
          shiftDurations[shift.userId] = (username, existing.$2 + dur);
        } else {
          shiftDurations[shift.userId] = (username, dur);
        }
      }
    }

    final paymentSummaries = paymentsByMethod.values
        .map((e) => PaymentTypeSummary(name: e.$1, amount: e.$2, count: e.$3, isCash: e.$4))
        .toList();

    // Resolve tips by user (may be soft-deleted)
    final tipsByUser = <String, (String, int)>{};
    for (final entry in tipsByUserId.entries) {
      final user = await userRepo.getById(entry.key, includeDeleted: true);
      final username = user?.username ?? '-';
      tipsByUser[entry.key] = (username, entry.value);
    }

    final taxBreakdown = taxMap.entries
        .map((e) => TaxBreakdownRow(
              taxRatePercent: e.key,
              netAmount: e.value.$1,
              taxAmount: e.value.$2,
              grossAmount: e.value.$3,
            ))
        .toList()
      ..sort((a, b) => a.taxRatePercent.compareTo(b.taxRatePercent));

    final totalCashRevenue = paymentSummaries
        .where((s) => s.isCash)
        .fold(0, (sum, s) => sum + s.amount);
    final totalExpectedCash = totalOpeningCash + totalCashRevenue + totalCashDeposits - totalCashWithdrawals;
    final totalDifference = totalClosingCash - totalExpectedCash;

    // Build per-register breakdowns
    final registerBreakdowns = <RegisterBreakdown>[];
    for (final session in sessionsInRange) {
      final regId = session.registerId;
      // Avoid duplicating if multiple sessions for same register
      if (registerBreakdowns.any((rb) => rb.registerId == regId)) continue;

      final reg = registerCache[regId];
      final regName = reg != null ? (reg.name.isNotEmpty ? reg.name : reg.code) : regId;
      final regNumber = reg?.registerNumber ?? 0;

      final regPaymentsByMethod = registerPayments[regId] ?? {};
      final regSummaries = regPaymentsByMethod.values
          .map((e) => PaymentTypeSummary(name: e.$1, amount: e.$2, count: e.$3, isCash: e.$4))
          .toList();
      final regCashRevenue = regSummaries
          .where((s) => s.isCash)
          .fold(0, (sum, s) => sum + s.amount);

      // Aggregate cash data across all sessions for this register (use cache)
      final regSessions = sessionsInRange.where((s) => s.registerId == regId).toList();
      int regOpeningCash = 0;
      int regClosingCash = 0;
      int regCashDeposits = 0;
      int regCashWithdrawals = 0;
      for (final rs in regSessions) {
        regOpeningCash += rs.openingCash ?? 0;
        regClosingCash += rs.closingCash ?? 0;
        final movements = movementsCache[rs.id] ?? [];
        regCashDeposits += movements
            .where((m) => m.type == CashMovementType.deposit)
            .fold(0, (sum, m) => sum + m.amount);
        regCashWithdrawals += movements
            .where((m) => m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense)
            .fold(0, (sum, m) => sum + m.amount);
      }
      final regExpectedCash = regOpeningCash + regCashRevenue + regCashDeposits - regCashWithdrawals;
      final regDifference = regClosingCash - regExpectedCash;

      registerBreakdowns.add(RegisterBreakdown(
        registerId: regId,
        registerName: regName,
        registerNumber: regNumber,
        paymentSummaries: regSummaries,
        totalRevenue: registerRevenue[regId] ?? 0,
        totalTips: registerTips[regId] ?? 0,
        cashRevenue: regCashRevenue,
        openingCash: regOpeningCash,
        closingCash: regClosingCash,
        expectedCash: regExpectedCash,
        difference: regDifference,
        billsPaid: registerBillsPaid[regId] ?? 0,
      ));
    }
    registerBreakdowns.sort((a, b) => a.registerNumber.compareTo(b.registerNumber));

    // Use earliest open / latest close for duration
    sessionsInRange.sort((a, b) => a.openedAt.compareTo(b.openedAt));
    final earliest = sessionsInRange.first.openedAt;
    final latest = sessionsInRange
        .where((s) => s.closedAt != null)
        .map((s) => s.closedAt!)
        .fold(earliest, (a, b) => b.isAfter(a) ? b : a);
    final duration = latest.difference(earliest);

    // Opened by: first session's opener (may be soft-deleted)
    final firstOpener = await userRepo.getById(sessionsInRange.first.openedByUserId, includeDeleted: true);

    // Foreign currency cash — aggregate across all sessions
    final foreignCurrencyCash = await _buildForeignCurrencyCashMultiSession(
      sessionsInRange.map((s) => s.id).toList(),
      allBills,
      methodMap,
    );

    return ZReportData(
      sessionId: 'venue-${dateFrom.millisecondsSinceEpoch}',
      openedAt: earliest,
      closedAt: latest,
      openedByName: firstOpener?.username ?? '-',
      duration: duration,
      paymentSummaries: paymentSummaries,
      totalRevenue: totalRevenue,
      totalTips: totalTips,
      tipsByUser: tipsByUser,
      taxBreakdown: taxBreakdown,
      totalDiscounts: totalDiscounts,
      billsPaid: billsPaid,
      billsCancelled: billsCancelled,
      billsRefunded: billsRefunded,
      openingCash: totalOpeningCash,
      closingCash: totalClosingCash,
      expectedCash: totalExpectedCash,
      difference: totalDifference,
      cashDeposits: totalCashDeposits,
      cashWithdrawals: totalCashWithdrawals,
      cashRevenue: totalCashRevenue,
      shiftDurations: shiftDurations,
      openBillsAtOpenCount: 0,
      openBillsAtOpenAmount: 0,
      openBillsAtCloseCount: 0,
      openBillsAtCloseAmount: 0,
      registerBreakdowns: registerBreakdowns,
      foreignCurrencyCash: foreignCurrencyCash,
    );
  }

  Future<List<ZReportSessionSummary>> getSessionSummaries(String companyId) async {
    final sessions = await registerSessionRepo.getClosedSessions(companyId);
    final allBills = await billRepo.getByCompany(companyId);
    final userCache = <String, String>{};
    final registerCache = <String, String>{};
    final summaries = <ZReportSessionSummary>[];

    for (final session in sessions) {
      if (!userCache.containsKey(session.openedByUserId)) {
        final user = await userRepo.getById(session.openedByUserId, includeDeleted: true);
        userCache[session.openedByUserId] = user?.username ?? '-';
      }
      final userName = userCache[session.openedByUserId]!;

      if (!registerCache.containsKey(session.registerId)) {
        final reg = await registerRepo.getById(session.registerId, includeDeleted: true);
        registerCache[session.registerId] = reg != null
            ? (reg.name.isNotEmpty ? reg.name : reg.code)
            : '-';
      }
      final registerName = registerCache[session.registerId]!;

      // Quick revenue: sum of paid bills totalGross in session range
      final sessionBills = allBills.where((b) =>
          b.closedAt != null && b.closedAt!.isAfter(session.openedAt) &&
          (session.closedAt == null || !b.closedAt!.isAfter(session.closedAt!)) &&
          b.status == BillStatus.paid).toList();
      final totalRevenue = sessionBills.fold(0, (sum, b) => sum + b.totalGross);

      summaries.add(ZReportSessionSummary(
        sessionId: session.id,
        openedAt: session.openedAt,
        closedAt: session.closedAt,
        userName: userName,
        totalRevenue: totalRevenue,
        difference: session.difference,
        registerName: registerName,
      ));
    }

    return summaries;
  }

  /// Build foreign currency cash summaries for a single session.
  Future<List<ForeignCurrencyCashSummary>> _buildForeignCurrencyCash(
    String sessionId,
    List<BillModel> sessionBills,
    Map<String, PaymentMethodModel> methodMap,
  ) async {
    final sccList = await sessionCurrencyCashRepo.getBySession(sessionId);
    if (sccList.isEmpty) return [];

    // Aggregate foreignAmount per currencyId from cash payments
    final foreignRevenue = <String, int>{};
    final foreignCount = <String, int>{};
    for (final bill in sessionBills) {
      if (bill.status == BillStatus.cancelled) continue;
      final payments = await paymentRepo.getByBill(bill.id);
      for (final p in payments) {
        if (p.foreignCurrencyId != null && p.foreignAmount != null) {
          final method = methodMap[p.paymentMethodId];
          if (method?.type == PaymentType.cash) {
            foreignRevenue[p.foreignCurrencyId!] =
                (foreignRevenue[p.foreignCurrencyId!] ?? 0) + p.foreignAmount!;
            foreignCount[p.foreignCurrencyId!] =
                (foreignCount[p.foreignCurrencyId!] ?? 0) + 1;
          }
        }
      }
    }

    final summaries = <ForeignCurrencyCashSummary>[];
    for (final scc in sccList) {
      final cur = await currencyRepo.getById(scc.currencyId);
      if (cur == null) continue;
      final revenue = foreignRevenue[scc.currencyId] ?? 0;
      final expected = scc.openingCash + revenue;
      final closing = scc.closingCash ?? 0;
      summaries.add(ForeignCurrencyCashSummary(
        currencyCode: cur.code,
        currencySymbol: cur.symbol,
        decimalPlaces: cur.decimalPlaces,
        openingCash: scc.openingCash,
        closingCash: closing,
        expectedCash: expected,
        difference: scc.difference ?? (closing - expected),
        cashRevenue: revenue,
        paymentCount: foreignCount[scc.currencyId] ?? 0,
      ));
    }
    return summaries;
  }

  /// Build foreign currency cash summaries aggregated across multiple sessions.
  Future<List<ForeignCurrencyCashSummary>> _buildForeignCurrencyCashMultiSession(
    List<String> sessionIds,
    List<BillModel> allBills,
    Map<String, PaymentMethodModel> methodMap,
  ) async {
    // Aggregate SessionCurrencyCash across sessions by currencyId
    final aggregated = <String, ({int opening, int closing, int? difference})>{};
    for (final sessionId in sessionIds) {
      final sccList = await sessionCurrencyCashRepo.getBySession(sessionId);
      for (final scc in sccList) {
        final existing = aggregated[scc.currencyId];
        aggregated[scc.currencyId] = (
          opening: (existing?.opening ?? 0) + scc.openingCash,
          closing: (existing?.closing ?? 0) + (scc.closingCash ?? 0),
          difference: null, // Will recompute
        );
      }
    }
    if (aggregated.isEmpty) return [];

    // Aggregate foreignAmount per currencyId from cash payments across session bills
    final sessionIdSet = sessionIds.toSet();
    final foreignRevenue = <String, int>{};
    final foreignCount = <String, int>{};
    for (final bill in allBills) {
      if (bill.status == BillStatus.cancelled) continue;
      if (bill.registerSessionId == null || !sessionIdSet.contains(bill.registerSessionId)) continue;
      final payments = await paymentRepo.getByBill(bill.id);
      for (final p in payments) {
        if (p.foreignCurrencyId != null && p.foreignAmount != null) {
          final method = methodMap[p.paymentMethodId];
          if (method?.type == PaymentType.cash) {
            foreignRevenue[p.foreignCurrencyId!] =
                (foreignRevenue[p.foreignCurrencyId!] ?? 0) + p.foreignAmount!;
            foreignCount[p.foreignCurrencyId!] =
                (foreignCount[p.foreignCurrencyId!] ?? 0) + 1;
          }
        }
      }
    }

    final summaries = <ForeignCurrencyCashSummary>[];
    for (final entry in aggregated.entries) {
      final cur = await currencyRepo.getById(entry.key);
      if (cur == null) continue;
      final revenue = foreignRevenue[entry.key] ?? 0;
      final expected = entry.value.opening + revenue;
      final closing = entry.value.closing;
      summaries.add(ForeignCurrencyCashSummary(
        currencyCode: cur.code,
        currencySymbol: cur.symbol,
        decimalPlaces: cur.decimalPlaces,
        openingCash: entry.value.opening,
        closingCash: closing,
        expectedCash: expected,
        difference: closing - expected,
        cashRevenue: revenue,
        paymentCount: foreignCount[entry.key] ?? 0,
      ));
    }
    return summaries;
  }
}
