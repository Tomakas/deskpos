import '../widgets/dialog_closing_session.dart';

class ZReportData {
  const ZReportData({
    required this.sessionId,
    required this.openedAt,
    this.closedAt,
    required this.openedByName,
    required this.duration,
    required this.paymentSummaries,
    required this.totalRevenue,
    required this.totalTips,
    required this.tipsByUser,
    required this.taxBreakdown,
    required this.totalDiscounts,
    required this.billsPaid,
    required this.billsCancelled,
    required this.billsRefunded,
    required this.openingCash,
    required this.closingCash,
    required this.expectedCash,
    required this.difference,
    required this.cashDeposits,
    required this.cashWithdrawals,
    required this.cashRevenue,
    required this.shiftDurations,
    required this.openBillsAtOpenCount,
    required this.openBillsAtOpenAmount,
    required this.openBillsAtCloseCount,
    required this.openBillsAtCloseAmount,
    this.registerBreakdowns = const [],
    this.registerName,
  });

  final String sessionId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedByName;
  final Duration duration;
  final List<PaymentTypeSummary> paymentSummaries;
  final int totalRevenue;
  final int totalTips;

  /// userId -> (username, tip amount in halere)
  final Map<String, (String username, int amount)> tipsByUser;

  final List<TaxBreakdownRow> taxBreakdown;
  final int totalDiscounts;
  final int billsPaid;
  final int billsCancelled;
  final int billsRefunded;

  /// All in halere
  final int openingCash;
  final int closingCash;
  final int expectedCash;
  final int difference;
  final int cashDeposits;
  final int cashWithdrawals;
  final int cashRevenue;

  /// userId -> (username, duration)
  final Map<String, (String username, Duration duration)> shiftDurations;

  final int openBillsAtOpenCount;
  final int openBillsAtOpenAmount;
  final int openBillsAtCloseCount;
  final int openBillsAtCloseAmount;

  /// Per-register breakdown (populated in venue reports)
  final List<RegisterBreakdown> registerBreakdowns;

  /// Name of the register for this session
  final String? registerName;
}

/// Per-register summary within a venue Z-report
class RegisterBreakdown {
  const RegisterBreakdown({
    required this.registerId,
    required this.registerName,
    required this.registerNumber,
    required this.paymentSummaries,
    required this.totalRevenue,
    required this.totalTips,
    required this.cashRevenue,
    required this.openingCash,
    required this.closingCash,
    required this.expectedCash,
    required this.difference,
    required this.billsPaid,
  });

  final String registerId;
  final String registerName;
  final int registerNumber;
  final List<PaymentTypeSummary> paymentSummaries;
  final int totalRevenue;
  final int totalTips;
  final int cashRevenue;
  final int openingCash;
  final int closingCash;
  final int expectedCash;
  final int difference;
  final int billsPaid;
}

class TaxBreakdownRow {
  const TaxBreakdownRow({
    required this.taxRatePercent,
    required this.netAmount,
    required this.taxAmount,
    required this.grossAmount,
  });

  /// In basis points (e.g. 2100 = 21%)
  final int taxRatePercent;

  /// All in halere
  final int netAmount;
  final int taxAmount;
  final int grossAmount;
}

class ZReportSessionSummary {
  const ZReportSessionSummary({
    required this.sessionId,
    required this.openedAt,
    this.closedAt,
    required this.userName,
    required this.totalRevenue,
    this.difference,
    this.registerName,
  });

  final String sessionId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String userName;
  final int totalRevenue;
  final int? difference;
  final String? registerName;
}
