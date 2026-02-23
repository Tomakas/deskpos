import 'dart:typed_data';

import '../data/enums/discount_type.dart';
import '../data/enums/prep_status.dart';
import '../data/enums/unit_type.dart';
import '../data/models/currency_model.dart';
import '../data/models/order_item_modifier_model.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/order_item_modifier_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/payment_method_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/table_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/result.dart';
import '../logging/app_logger.dart';
import '../../features/bills/models/z_report_data.dart';
import 'inventory_pdf_builder.dart';
import 'pdf_font_loader.dart';
import 'receipt_data.dart';
import 'receipt_pdf_builder.dart';
import 'voucher_pdf_builder.dart';
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
    required this.orderItemModifierRepo,
  });

  final BillRepository billRepo;
  final OrderRepository orderRepo;
  final PaymentRepository paymentRepo;
  final PaymentMethodRepository paymentMethodRepo;
  final CompanyRepository companyRepo;
  final TableRepository tableRepo;
  final UserRepository userRepo;
  final OrderItemModifierRepository orderItemModifierRepo;

  Future<ReceiptData?> buildReceiptData(String billId, {CurrencyModel? currency, String Function(UnitType)? unitLocalizer}) async {
    // 1. Get bill (includeDeleted: receipt may be reprinted after cancellation)
    final billResult = await billRepo.getById(billId, includeDeleted: true);
    if (billResult is! Success) {
      AppLogger.error('buildReceiptData: bill not found for $billId');
      return null;
    }
    final bill = (billResult as Success).value;

    // 2. Get company
    final companyResult = await companyRepo.getById(bill.companyId, includeDeleted: true);
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

    // 5. Get payment method names (may be soft-deleted since bill was paid)
    final methodIds = payments.map((p) => p.paymentMethodId).toSet();
    final methods = <String, String>{};
    for (final methodId in methodIds) {
      final method = await paymentMethodRepo.getById(methodId, includeDeleted: true);
      if (method != null) {
        methods[methodId] = method.name;
      }
    }

    // 6. Get table name (may be soft-deleted since bill was created)
    String? tableName;
    if (bill.tableId != null) {
      final table = await tableRepo.getById(bill.tableId!, includeDeleted: true);
      if (table != null) {
        tableName = table.name;
      }
    }

    // 7. Get cashier name (may be soft-deleted since bill was created)
    String cashierName = '';
    final user = await userRepo.getById(bill.openedByUserId, includeDeleted: true);
    if (user != null) {
      cashierName = user.fullName;
    }

    // 8. Build receipt items (with modifiers)
    // Load all modifiers in batch
    final allItemIds = activeItems.map((i) => i.id).toList();
    final allMods = await orderItemModifierRepo.getByOrderItemIds(allItemIds);
    final modsByItem = <String, List<OrderItemModifierModel>>{};
    for (final mod in allMods) {
      modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
    }

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

      final mods = modsByItem[item.id] ?? [];
      final receiptMods = mods.map((m) => ReceiptModifierData(
        name: m.modifierItemName,
        unitPrice: m.unitPrice,
        quantity: m.quantity,
      )).toList();

      receiptItems.add(ReceiptItemData(
        name: item.itemName,
        quantity: item.quantity,
        unitPrice: item.salePriceAtt,
        total: itemTotal - itemDiscount - item.voucherDiscount,
        taxRateBasisPoints: item.saleTaxRateAtt,
        unitLabel: unitLocalizer != null ? unitLocalizer(item.unit) : item.unit.name,
        discount: itemDiscount,
        voucherDiscount: item.voucherDiscount,
        notes: item.notes,
        modifiers: receiptMods,
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
          net: e.value.net,
          tax: e.value.tax,
          gross: e.value.gross,
        )).toList()
      ..sort((a, b) => a.taxRateBasisPoints.compareTo(b.taxRateBasisPoints));

    // 10. Build payment data
    final receiptPayments = payments
        .where((p) => p.amount > 0)
        .map((p) => ReceiptPaymentData(
              methodName: methods[p.paymentMethodId] ?? '?',
              amount: p.amount,
              tip: p.tipIncludedAmount,
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
      currencySymbol: currency?.symbol ?? '',
      currency: currency,
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

  Future<Uint8List> generateInventoryPdf(
    InventoryPdfData data,
    InventoryPdfLabels labels,
  ) async {
    final fontLoader = PdfFontLoader.instance;
    final regular = await fontLoader.regular;
    final bold = await fontLoader.bold;

    return InventoryPdfBuilder(
      data: data,
      labels: labels,
      regular: regular,
      bold: bold,
    ).build();
  }

  Future<Uint8List> generateVoucherPdf(
    VoucherPdfData data,
    VoucherPdfLabels labels,
  ) async {
    final fontLoader = PdfFontLoader.instance;
    final regular = await fontLoader.regular;
    final bold = await fontLoader.bold;

    return VoucherPdfBuilder(
      data: data,
      labels: labels,
      regular: regular,
      bold: bold,
    ).build();
  }
}
