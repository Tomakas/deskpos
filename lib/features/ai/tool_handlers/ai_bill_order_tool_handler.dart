import 'dart:convert';

import '../../../core/data/repositories/bill_repository.dart';
import '../../../core/data/repositories/order_repository.dart';
import '../../../core/data/repositories/payment_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles bill, order, and payment read-only AI tool calls.
class AiBillOrderToolHandler {
  AiBillOrderToolHandler({
    required BillRepository billRepo,
    required OrderRepository orderRepo,
    required PaymentRepository paymentRepo,
  })  : _billRepo = billRepo,
        _orderRepo = orderRepo,
        _paymentRepo = paymentRepo;

  final BillRepository _billRepo;
  final OrderRepository _orderRepo;
  final PaymentRepository _paymentRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_bills' => _listBills(args, companyId),
        'get_bill' => _getBill(args),
        'list_orders' => _listOrders(args),
        'get_order' => _getOrder(args),
        _ => AiCommandError('Unknown bill/order tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Bill/order tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // List bills
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listBills(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final status = args['status'] as String?;
    final days = (args['days'] as num?)?.toInt() ?? 30; // Default to 30 days for AI

    final since = DateTime.now().subtract(Duration(days: days));
    final to = DateTime.now();

    var bills = await _billRepo.getPaidOrRefundedInRange(companyId, since, to);

    // Filter by status if requested (beyond paid/refunded)
    if (status != null) {
      bills = bills.where((b) => b.status.name == status).toList();
    }

    // Limit to most recent 50 to avoid context overflow
    if (bills.length > 50) {
      bills = bills.sublist(0, 50);
    }

    final json = bills.map((b) {
      return {
        'id': b.id,
        'bill_number': b.billNumber,
        'status': b.status.name,
        'total_gross': b.totalGross,
        'paid_amount': b.paidAmount,
        'discount_amount': b.discountAmount,
        'guest_count': b.numberOfGuests,
        'is_takeaway': b.isTakeaway,
        'customer_id': b.customerId,
        'customer_name': b.customerName,
        'table_id': b.tableId,
        'section_id': b.sectionId,
        'opened_at': b.openedAt.toIso8601String(),
        'closed_at': b.closedAt?.toIso8601String(),
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'count': json.length,
      'bills': json,
    }));
  }

  // ---------------------------------------------------------------------------
  // Get bill detail (with orders, items, payments)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getBill(Map<String, dynamic> args) async {
    final billId = args['id'] as String?;
    if (billId == null) return AiCommandError('Missing required parameter: id');

    final result = await _billRepo.getById(billId);
    switch (result) {
      case Failure(:final message):
        return AiCommandError(message);
      case Success(:final value):
        final bill = value;

        // Get order items for this bill
        final items = await _orderRepo.getOrderItemsByBill(billId);
        final itemsJson = items.map((i) {
          return {
            'id': i.id,
            'item_name': i.itemName,
            'quantity': i.quantity,
            'unit_price': i.salePriceAtt,
            'tax_amount': i.saleTaxAmount,
            'discount': i.discount,
            'discount_type': i.discountType?.name,
            'status': i.status.name,
            'notes': i.notes,
          };
        }).toList();

        // Get payments
        final payments = await _paymentRepo.getByBill(billId);
        final paymentsJson = payments.map((p) {
          return {
            'id': p.id,
            'amount': p.amount,
            'payment_method_id': p.paymentMethodId,
            'tip': p.tipIncludedAmount,
            'paid_at': p.paidAt.toIso8601String(),
            if (p.cardLast4 != null) 'card_last4': p.cardLast4,
            if (p.foreignCurrencyId != null) ...{
              'foreign_currency_id': p.foreignCurrencyId,
              'foreign_amount': p.foreignAmount,
              'exchange_rate': p.exchangeRate,
            },
          };
        }).toList();

        return AiCommandSuccess(jsonEncode({
          'id': bill.id,
          'bill_number': bill.billNumber,
          'status': bill.status.name,
          'total_gross': bill.totalGross,
          'subtotal_gross': bill.subtotalGross,
          'tax_total': bill.taxTotal,
          'discount_amount': bill.discountAmount,
          'discount_type': bill.discountType?.name,
          'rounding_amount': bill.roundingAmount,
          'paid_amount': bill.paidAmount,
          'guest_count': bill.numberOfGuests,
          'is_takeaway': bill.isTakeaway,
          'customer_id': bill.customerId,
          'customer_name': bill.customerName,
          'table_id': bill.tableId,
          'section_id': bill.sectionId,
          'opened_by_user_id': bill.openedByUserId,
          'loyalty_points_earned': bill.loyaltyPointsEarned,
          'loyalty_points_used': bill.loyaltyPointsUsed,
          'loyalty_discount_amount': bill.loyaltyDiscountAmount,
          'voucher_discount_amount': bill.voucherDiscountAmount,
          'voucher_id': bill.voucherId,
          'opened_at': bill.openedAt.toIso8601String(),
          'closed_at': bill.closedAt?.toIso8601String(),
          'items': itemsJson,
          'payments': paymentsJson,
        }));
    }
  }

  // ---------------------------------------------------------------------------
  // List orders for a bill
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listOrders(Map<String, dynamic> args) async {
    final billId = args['bill_id'] as String?;
    if (billId == null) {
      return AiCommandError('Missing required parameter: bill_id');
    }

    final orders = await _orderRepo.getOrdersByBillIds([billId]);
    final json = orders.map((o) {
      return {
        'id': o.id,
        'order_number': o.orderNumber,
        'status': o.status.name,
        'item_count': o.itemCount,
        'subtotal_gross': o.subtotalGross,
        'tax_total': o.taxTotal,
        'is_storno': o.isStorno,
        'notes': o.notes,
        'created_by_user_id': o.createdByUserId,
        'created_at': o.createdAt.toIso8601String(),
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'bill_id': billId,
      'count': json.length,
      'orders': json,
    }));
  }

  // ---------------------------------------------------------------------------
  // Get order detail (with items)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getOrder(Map<String, dynamic> args) async {
    final orderId = args['id'] as String?;
    if (orderId == null) {
      return AiCommandError('Missing required parameter: id');
    }

    final items = await _orderRepo.getOrderItems(orderId);
    final itemsJson = items.map((i) {
      return {
        'id': i.id,
        'item_id': i.itemId,
        'item_name': i.itemName,
        'quantity': i.quantity,
        'unit_price': i.salePriceAtt,
        'unit': i.unit.name,
        'tax_rate': i.saleTaxRateAtt,
        'tax_amount': i.saleTaxAmount,
        'discount': i.discount,
        'discount_type': i.discountType?.name,
        'voucher_discount': i.voucherDiscount,
        'status': i.status.name,
        'notes': i.notes,
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'order_id': orderId,
      'item_count': items.length,
      'items': itemsJson,
    }));
  }
}
