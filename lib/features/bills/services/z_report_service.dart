import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/repositories/bill_repository.dart';
import '../../../core/data/repositories/cash_movement_repository.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/repositories/payment_method_repository.dart';
import '../../../core/data/repositories/payment_repository.dart';
import '../../../core/data/repositories/register_session_repository.dart';
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
  });

  final BillRepository billRepo;
  final PaymentRepository paymentRepo;
  final PaymentMethodRepository paymentMethodRepo;
  final CashMovementRepository cashMovementRepo;
  final RegisterSessionRepository registerSessionRepo;
  final ShiftRepository shiftRepo;
  final UserRepository userRepo;
  final OrderRepository orderRepo;

  Future<ZReportData?> buildZReport(String sessionId) async {
    final session = await registerSessionRepo.getById(sessionId);
    if (session == null) return null;

    // Resolve who opened the session
    final openedByUser = await userRepo.getById(session.openedByUserId);
    final openedByName = openedByUser?.username ?? '-';

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

    // Resolve tips by user to usernames
    final tipsByUser = <String, (String, int)>{};
    for (final entry in tipsByUserId.entries) {
      final user = await userRepo.getById(entry.key);
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

    // Cash movements
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
      final user = await userRepo.getById(shift.userId);
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
    );
  }

  Future<List<ZReportSessionSummary>> getSessionSummaries(String companyId) async {
    final sessions = await registerSessionRepo.getClosedSessions(companyId);
    final summaries = <ZReportSessionSummary>[];

    for (final session in sessions) {
      final user = await userRepo.getById(session.openedByUserId);
      final userName = user?.username ?? '-';

      // Quick revenue: sum of paid bills totalGross in session range
      final allBills = await billRepo.getByCompany(companyId);
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
      ));
    }

    return summaries;
  }
}
