import 'dart:typed_data';

import '../data/enums/discount_type.dart';
import '../data/enums/prep_area.dart';
import '../data/enums/prep_status.dart';
import '../data/enums/unit_type.dart';
import '../data/models/currency_model.dart';
import '../data/models/item_model.dart';
import '../data/models/order_item_model.dart';
import '../data/models/order_item_modifier_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/currency_repository.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/order_item_modifier_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/payment_method_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/table_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/result.dart';
import '../data/utils/tax_calculator.dart';
import '../logging/app_logger.dart';
import '../../features/bills/models/z_report_data.dart';
import 'inventory_pdf_builder.dart';
import 'order_ticket_data.dart';
import 'order_ticket_pdf_builder.dart';
import 'pdf_font_loader.dart';
import 'receipt_data.dart';
import 'receipt_pdf_builder.dart';
import 'stock_document_pdf_builder.dart';
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
    required this.currencyRepo,
    required this.itemRepo,
  });

  final BillRepository billRepo;
  final OrderRepository orderRepo;
  final PaymentRepository paymentRepo;
  final PaymentMethodRepository paymentMethodRepo;
  final CompanyRepository companyRepo;
  final TableRepository tableRepo;
  final UserRepository userRepo;
  final OrderItemModifierRepository orderItemModifierRepo;
  final CurrencyRepository currencyRepo;
  final ItemRepository itemRepo;

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
        .where((i) => i.status != PrepStatus.voided)
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

    // 9. Build tax breakdown (with modifiers, item discounts, voucher discounts, bill discounts)
    var accumulatedTax = TaxByRateResult.empty;
    for (final item in activeItems) {
      final baseGross = (item.salePriceAtt * item.quantity).round();
      int totalItemGross = baseGross;
      final itemMods = modsByItem[item.id] ?? [];
      final modComponents = <({int gross, int rate})>[];
      for (final mod in itemMods) {
        final modGross = (mod.unitPrice * mod.quantity * item.quantity).round();
        modComponents.add((gross: modGross, rate: mod.taxRate));
        totalItemGross += modGross;
      }
      int itemDiscount = 0;
      if (item.discount > 0) {
        if (item.discountType == DiscountType.percent) {
          itemDiscount = (totalItemGross * item.discount / 10000).round();
        } else {
          itemDiscount = item.discount;
        }
      }
      final itemTaxResult = TaxCalculator.computeItemTax(
        baseGross: baseGross,
        baseRate: item.saleTaxRateAtt,
        modifiers: modComponents,
        totalDiscount: itemDiscount + item.voucherDiscount,
      );
      accumulatedTax = accumulatedTax.merge(itemTaxResult);
    }

    // Apply bill-level discount (scale tax only by real discounts, not gift/deposit vouchers)
    int receiptBillDiscount = 0;
    if (bill.discountAmount > 0) {
      if (bill.discountType == DiscountType.percent) {
        receiptBillDiscount = (bill.subtotalGross * bill.discountAmount / 10000).round();
      } else {
        receiptBillDiscount = bill.discountAmount;
      }
    }
    final taxAdjustingDiscounts = (receiptBillDiscount + bill.loyaltyDiscountAmount).toInt();
    final finalTax = TaxCalculator.applyBillDiscount(
      itemTaxResult: accumulatedTax,
      subtotalGross: bill.subtotalGross,
      billDiscount: taxAdjustingDiscounts,
    );

    final taxRows = finalTax.byRate.entries.map((e) {
      final tax = e.value.tax;
      final gross = e.value.gross;
      return ReceiptTaxRow(
        taxRateBasisPoints: e.key,
        net: gross - tax,
        tax: tax,
        gross: gross,
      );
    }).toList()
      ..sort((a, b) => a.taxRateBasisPoints.compareTo(b.taxRateBasisPoints));

    // 10. Build payment data (resolve foreign currency info)
    final foreignCurrencyCache = <String, CurrencyModel?>{};
    final receiptPayments = <ReceiptPaymentData>[];
    for (final p in payments) {
      if (p.amount <= 0) continue;
      CurrencyModel? foreignCur;
      if (p.foreignCurrencyId != null) {
        if (!foreignCurrencyCache.containsKey(p.foreignCurrencyId!)) {
          foreignCurrencyCache[p.foreignCurrencyId!] =
              await currencyRepo.getById(p.foreignCurrencyId!);
        }
        foreignCur = foreignCurrencyCache[p.foreignCurrencyId!];
      }
      receiptPayments.add(ReceiptPaymentData(
        methodName: methods[p.paymentMethodId] ?? '?',
        amount: p.amount,
        tip: p.tipIncludedAmount,
        foreignCurrencyCode: foreignCur?.code,
        foreignCurrencySymbol: foreignCur?.symbol,
        foreignAmount: p.foreignAmount,
        foreignDecimalPlaces: foreignCur?.decimalPlaces,
        exchangeRate: p.exchangeRate,
      ));
    }

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
      discountAmount: bill.discountType == DiscountType.percent
          ? (bill.subtotalGross * bill.discountAmount / 10000).round()
          : bill.discountAmount,
      loyaltyDiscountAmount: bill.loyaltyDiscountAmount,
      voucherDiscountAmount: bill.voucherDiscountAmount,
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

  Future<Uint8List> generateStockDocumentPdf(
    StockDocumentPdfData data,
    StockDocumentPdfLabels labels,
  ) async {
    final fontLoader = PdfFontLoader.instance;
    final regular = await fontLoader.regular;
    final bold = await fontLoader.bold;

    return StockDocumentPdfBuilder(
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

  /// Builds order ticket data for newly created orders, split by prep area.
  ///
  /// Returns 0–2 tickets (kitchen, bar, or a single generic ticket).
  Future<List<OrderTicketData>> buildOrderTickets({
    required String billId,
    required List<String> orderIds,
    required String Function(UnitType) unitLocalizer,
    required String kitchenLabel,
    required String barLabel,
  }) async {
    if (orderIds.isEmpty) return [];

    // 1. Get table name from bill
    String? tableName;
    final billResult = await billRepo.getById(billId, includeDeleted: true);
    if (billResult is Success) {
      final bill = (billResult as Success).value;
      if (bill.isTakeaway) {
        tableName = null;
      } else if (bill.tableId != null) {
        final table = await tableRepo.getById(bill.tableId!, includeDeleted: true);
        if (table != null) tableName = table.name;
      }
    }

    // 2. Collect all order items across new orders
    final allOrderItems = <OrderItemModel>[];
    for (final orderId in orderIds) {
      final items = await orderRepo.getOrderItems(orderId);
      allOrderItems.addAll(items.where((i) => i.status != PrepStatus.voided));
    }

    // 3. Get order models to resolve order numbers
    final orders = await orderRepo.getOrdersByBillIds([billId]);
    final orderMap = {for (final o in orders) o.id: o};
    final firstOrder = orderIds
        .map((id) => orderMap[id])
        .whereType<OrderModel>()
        .firstOrNull;
    if (firstOrder == null) return [];

    final orderNumber = firstOrder.orderNumber;
    final createdAt = firstOrder.createdAt;

    // 4. Load item models to determine prepArea
    final uniqueItemIds = allOrderItems.map((oi) => oi.itemId).toSet();
    final catalogItems = <String, ItemModel>{};
    for (final itemId in uniqueItemIds) {
      final model = await itemRepo.getById(itemId, includeDeleted: true);
      if (model != null) catalogItems[itemId] = model;
    }

    // 5. Load modifiers for all order items
    final allOrderItemIds = allOrderItems.map((oi) => oi.id).toList();
    final allMods = await orderItemModifierRepo.getByOrderItemIds(allOrderItemIds);
    final modsByItem = <String, List<OrderItemModifierModel>>{};
    for (final mod in allMods) {
      modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
    }

    // 6. Build ticket items and group by effective area
    Set<String> effectiveAreas(PrepArea? pa) => switch (pa) {
      null => {'kitchen', 'bar'},
      PrepArea.all => {'kitchen', 'bar'},
      PrepArea.none => {},
      PrepArea.kitchen => {'kitchen'},
      PrepArea.bar => {'bar'},
    };

    final kitchenItems = <OrderTicketItem>[];
    final barItems = <OrderTicketItem>[];

    for (final oi in allOrderItems) {
      final catalogItem = catalogItems[oi.itemId];
      final areas = effectiveAreas(catalogItem?.prepArea);

      final mods = modsByItem[oi.id] ?? [];
      final ticketItem = OrderTicketItem(
        quantity: oi.quantity,
        unitLabel: unitLocalizer(oi.unit),
        name: oi.itemName,
        notes: oi.notes,
        modifiers: mods
            .map((m) => OrderTicketModifier(
                  quantity: m.quantity,
                  name: m.modifierItemName,
                ))
            .toList(),
      );

      if (areas.contains('kitchen')) kitchenItems.add(ticketItem);
      if (areas.contains('bar')) barItems.add(ticketItem);
    }

    // 7. Build tickets
    final tickets = <OrderTicketData>[];
    if (kitchenItems.isNotEmpty && barItems.isNotEmpty) {
      tickets.add(OrderTicketData(
        orderNumber: orderNumber,
        tableName: tableName,
        createdAt: createdAt,
        stationLabel: kitchenLabel,
        items: kitchenItems,
      ));
      tickets.add(OrderTicketData(
        orderNumber: orderNumber,
        tableName: tableName,
        createdAt: createdAt,
        stationLabel: barLabel,
        items: barItems,
      ));
    } else if (kitchenItems.isNotEmpty) {
      tickets.add(OrderTicketData(
        orderNumber: orderNumber,
        tableName: tableName,
        createdAt: createdAt,
        stationLabel: kitchenLabel,
        items: kitchenItems,
      ));
    } else if (barItems.isNotEmpty) {
      tickets.add(OrderTicketData(
        orderNumber: orderNumber,
        tableName: tableName,
        createdAt: createdAt,
        stationLabel: barLabel,
        items: barItems,
      ));
    }

    return tickets;
  }

  Future<Uint8List> generateOrderTicketPdf(
    OrderTicketData data,
    String locale,
  ) async {
    final fontLoader = PdfFontLoader.instance;
    final regular = await fontLoader.regular;
    final bold = await fontLoader.bold;

    return OrderTicketPdfBuilder(
      data: data,
      locale: locale,
      regular: regular,
      bold: bold,
    ).build();
  }
}
