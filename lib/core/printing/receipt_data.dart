import '../data/models/currency_model.dart';

class ReceiptData {
  const ReceiptData({
    required this.companyName,
    this.companyAddress,
    this.companyCity,
    this.companyPostalCode,
    this.companyBusinessId,
    this.companyVatNumber,
    this.companyPhone,
    this.companyEmail,
    required this.billNumber,
    this.tableName,
    required this.isTakeaway,
    required this.cashierName,
    required this.openedAt,
    this.closedAt,
    required this.items,
    required this.taxRows,
    required this.payments,
    required this.subtotalGross,
    required this.discountAmount,
    required this.totalGross,
    required this.roundingAmount,
    required this.currencySymbol,
    this.currency,
  });

  final String companyName;
  final String? companyAddress;
  final String? companyCity;
  final String? companyPostalCode;
  final String? companyBusinessId;
  final String? companyVatNumber;
  final String? companyPhone;
  final String? companyEmail;

  final String billNumber;
  final String? tableName;
  final bool isTakeaway;
  final String cashierName;
  final DateTime openedAt;
  final DateTime? closedAt;

  final List<ReceiptItemData> items;
  final List<ReceiptTaxRow> taxRows;
  final List<ReceiptPaymentData> payments;

  /// All amounts in minor units
  final int subtotalGross;
  final int discountAmount;
  final int totalGross;
  final int roundingAmount;

  final String currencySymbol;
  final CurrencyModel? currency;
}

class ReceiptItemData {
  const ReceiptItemData({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.taxRateBasisPoints,
    this.unitLabel = 'ks',
    this.discount = 0,
    this.voucherDiscount = 0,
    this.notes,
    this.modifiers = const [],
  });

  final String name;
  final double quantity;
  final int unitPrice;
  final int total;
  final int taxRateBasisPoints;
  final String unitLabel;
  final int discount;
  final int voucherDiscount;
  final String? notes;
  final List<ReceiptModifierData> modifiers;
}

class ReceiptModifierData {
  const ReceiptModifierData({
    required this.name,
    required this.unitPrice,
    this.quantity = 1.0,
  });

  final String name;
  final int unitPrice;
  final double quantity;
}

class ReceiptTaxRow {
  const ReceiptTaxRow({
    required this.taxRateBasisPoints,
    required this.net,
    required this.tax,
    required this.gross,
  });

  final int taxRateBasisPoints;
  final int net;
  final int tax;
  final int gross;
}

class ReceiptPaymentData {
  const ReceiptPaymentData({
    required this.methodName,
    required this.amount,
    this.tip = 0,
  });

  final String methodName;
  final int amount;
  final int tip;
}

class ReceiptLabels {
  const ReceiptLabels({
    required this.subtotal,
    required this.discount,
    required this.voucherDiscount,
    required this.total,
    required this.rounding,
    required this.taxTitle,
    required this.taxRate,
    required this.taxNet,
    required this.taxAmount,
    required this.taxGross,
    required this.payment,
    required this.tip,
    required this.billNumber,
    required this.table,
    required this.takeaway,
    required this.cashier,
    required this.date,
    required this.thankYou,
    required this.ico,
    required this.dic,
    required this.locale,
  });

  final String subtotal;
  final String discount;
  final String voucherDiscount;
  final String total;
  final String rounding;
  final String taxTitle;
  final String taxRate;
  final String taxNet;
  final String taxAmount;
  final String taxGross;
  final String payment;
  final String tip;
  final String billNumber;
  final String table;
  final String takeaway;
  final String cashier;
  final String date;
  final String thankYou;
  final String ico;
  final String dic;
  final String locale;
}

class ZReportLabels {
  const ZReportLabels({
    required this.reportTitle,
    required this.session,
    required this.openedAt,
    required this.closedAt,
    required this.duration,
    required this.openedBy,
    required this.revenueTitle,
    required this.revenueTotal,
    required this.taxTitle,
    required this.taxRate,
    required this.taxNet,
    required this.taxAmount,
    required this.taxGross,
    required this.tipsTitle,
    required this.tipsTotal,
    required this.tipsByUser,
    required this.discountsTitle,
    required this.discountsTotal,
    required this.billCountsTitle,
    required this.billsPaid,
    required this.billsCancelled,
    required this.billsRefunded,
    required this.openBillsAtOpen,
    required this.openBillsAtClose,
    required this.cashTitle,
    required this.cashOpening,
    required this.cashRevenue,
    required this.cashDeposits,
    required this.cashWithdrawals,
    required this.cashExpected,
    required this.cashClosing,
    required this.cashDifference,
    required this.shiftsTitle,
    required this.currencySymbol,
    required this.locale,
    required this.formatDuration,
    this.currency,
  });

  final String reportTitle;
  final String session;
  final String openedAt;
  final String closedAt;
  final String duration;
  final String openedBy;
  final String revenueTitle;
  final String revenueTotal;
  final String taxTitle;
  final String taxRate;
  final String taxNet;
  final String taxAmount;
  final String taxGross;
  final String tipsTitle;
  final String tipsTotal;
  final String tipsByUser;
  final String discountsTitle;
  final String discountsTotal;
  final String billCountsTitle;
  final String billsPaid;
  final String billsCancelled;
  final String billsRefunded;
  final String openBillsAtOpen;
  final String openBillsAtClose;
  final String cashTitle;
  final String cashOpening;
  final String cashRevenue;
  final String cashDeposits;
  final String cashWithdrawals;
  final String cashExpected;
  final String cashClosing;
  final String cashDifference;
  final String shiftsTitle;
  final String currencySymbol;
  final String locale;
  final String Function(Duration) formatDuration;
  final CurrencyModel? currency;
}
