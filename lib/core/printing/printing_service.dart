import 'dart:typed_data';

import '../data/enums/discount_type.dart';
import '../data/enums/prep_status.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/payment_method_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/table_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/result.dart';
import '../logging/app_logger.dart';
import '../../features/bills/models/z_report_data.dart';
import 'pdf_font_loader.dart';
import 'receipt_data.dart';
import 'receipt_pdf_builder.dart';
import 'z_report_pdf_builder.dart';

class PrintingService {
  PrintingService({
    required this.billRepo,
    required this.orderRepo,
    required this.paymentRepo,
    required this.paymentMethodRepo,
    required this.companyRepo,
    required this.tableRepo,
    required this.userRepo,
  });

  final BillRepository billRepo;
  final OrderRepository orderRepo;
  final PaymentRepository paymentRepo;
  final PaymentMethodRepository paymentMethodRepo;
  final CompanyRepository companyRepo;
  final TableRepository tableRepo;
  final UserRepository userRepo;

  Future<ReceiptData?> buildReceiptData(String billId) async {
    // 1. Get bill
    final billResult = await billRepo.getById(billId);
    if (billResult is! Success) {
      AppLogger.error('buildReceiptData: bill not found for $billId');
      return null;
    }
    final bill = (billResult as Success).value;

    // 2. Get company
    final companyResult = await companyRepo.getById(bill.companyId);
    if (companyResult is! Success) {
      AppLogger.error('buildReceiptData: company not found for ${bill.companyId}');
      return null;
    }
    final company = (companyResult as Success).value;

    // 3. Get order items (only active ones)
    final allItems = await orderRepo.getOrderItemsByBill(billId);
    final activeItems = allItems
        .where((i) =>
            i.status != PrepStatus.cancelled && i.status != PrepStatus.voided)
        .toList();

    // 4. Get payments
    final payments = await paymentRepo.getByBill(billId);

    // 5. Get payment method names
    final methodIds = payments.map((p) => p.paymentMethodId).toSet();
    final methods = <String, String>{};
    for (final methodId in methodIds) {
      final method = await paymentMethodRepo.getById(methodId);
      if (method != null) {
        methods[methodId] = method.name;
      }
    }

    // 6. Get table name
    String? tableName;
    if (bill.tableId != null) {
      final table = await tableRepo.getById(bill.tableId!);
      if (table != null) {
        tableName = table.name;
      }
    }

    // 7. Get cashier name
    String cashierName = '';
    final user = await userRepo.getById(bill.openedByUserId);
    if (user != null) {
      cashierName = user.fullName;
    }

    // 8. Build receipt items
    final receiptItems = <ReceiptItemData>[];
    for (final item in activeItems) {
      final itemTotal = (item.salePriceAtt * item.quantity).round();
      int itemDiscount = 0;
      if (item.discount > 0) {
        if (item.discountType == DiscountType.percent) {
          itemDiscount = (itemTotal * item.discount / 10000).round();
        } else {
          itemDiscount = item.discount;
        }
      }

      receiptItems.add(ReceiptItemData(
        name: item.itemName,
        quantity: item.quantity,
        unitPriceHalere: item.salePriceAtt,
        totalHalere: itemTotal - itemDiscount,
        taxRateBasisPoints: item.saleTaxRateAtt,
        discountHalere: itemDiscount,
        notes: item.notes,
      ));
    }

    // 9. Build tax breakdown
    final taxMap = <int, ({int net, int tax, int gross})>{};
    for (final item in activeItems) {
      final itemGross = (item.salePriceAtt * item.quantity).round();
      final itemTax = (item.saleTaxAmount * item.quantity).round();
      int itemDiscount = 0;
      if (item.discount > 0) {
        if (item.discountType == DiscountType.percent) {
          itemDiscount = (itemGross * item.discount / 10000).round();
        } else {
          itemDiscount = item.discount;
        }
      }
      final gross = itemGross - itemDiscount;
      final net = gross - itemTax;
      final rate = item.saleTaxRateAtt;

      final existing = taxMap[rate];
      if (existing != null) {
        taxMap[rate] = (
          net: existing.net + net,
          tax: existing.tax + itemTax,
          gross: existing.gross + gross,
        );
      } else {
        taxMap[rate] = (net: net, tax: itemTax, gross: gross);
      }
    }

    final taxRows = taxMap.entries.map((e) => ReceiptTaxRow(
          taxRateBasisPoints: e.key,
          netHalere: e.value.net,
          taxHalere: e.value.tax,
          grossHalere: e.value.gross,
        )).toList()
      ..sort((a, b) => a.taxRateBasisPoints.compareTo(b.taxRateBasisPoints));

    // 10. Build payment data
    final receiptPayments = payments
        .where((p) => p.amount > 0)
        .map((p) => ReceiptPaymentData(
              methodName: methods[p.paymentMethodId] ?? '?',
              amountHalere: p.amount,
              tipHalere: p.tipIncludedAmount,
            ))
        .toList();

    return ReceiptData(
      companyName: company.name,
      companyAddress: company.address,
      companyCity: company.city,
      companyPostalCode: company.postalCode,
      companyBusinessId: company.businessId,
      companyVatNumber: company.vatNumber,
      companyPhone: company.phone,
      companyEmail: company.email,
      billNumber: bill.billNumber,
      tableName: tableName,
      isTakeaway: bill.isTakeaway,
      cashierName: cashierName,
      openedAt: bill.openedAt,
      closedAt: bill.closedAt,
      items: receiptItems,
      taxRows: taxRows,
      payments: receiptPayments,
      subtotalGross: bill.subtotalGross,
      discountAmount: bill.discountAmount,
      totalGross: bill.totalGross,
      roundingAmount: bill.roundingAmount,
      currencySymbol: 'Kč',
    );
  }

  Future<Uint8List> generateReceiptPdf(
    ReceiptData data,
    ReceiptLabels labels,
  ) async {
    final fontLoader = PdfFontLoader.instance;
    final regular = await fontLoader.regular;
    final bold = await fontLoader.bold;

    final builder = ReceiptPdfBuilder(
      data: data,
      labels: labels,
      regular: regular,
      bold: bold,
    );

    return builder.build();
  }

  Future<Uint8List> generateZReportPdf(
    ZReportData data,
    ZReportLabels labels,
  ) async {
    final fontLoader = PdfFontLoader.instance;
    final regular = await fontLoader.regular;
    final bold = await fontLoader.bold;

    final builder = ZReportPdfBuilder(
      data: data,
      labels: labels,
      regular: regular,
      bold: bold,
    );

    return builder.build();
  }
}
