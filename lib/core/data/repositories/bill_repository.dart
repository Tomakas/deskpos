import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/bill_status.dart';
import '../enums/cash_movement_type.dart';
import '../enums/discount_type.dart';
import '../enums/payment_type.dart';
import '../enums/prep_status.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/bill_model.dart';
import '../models/cash_movement_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class BillRepository {
  BillRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<BillModel>> createBill({
    required String companyId,
    required String userId,
    required String currencyId,
    String? tableId,
    bool isTakeaway = false,
    int numberOfGuests = 0,
  }) async {
    try {
      final now = DateTime.now();
      final id = const Uuid().v7();

      await _db.transaction(() async {
        final billNumber = await _generateBillNumber(companyId);
        await _db.into(_db.bills).insert(BillsCompanion.insert(
          id: id,
          companyId: companyId,
          tableId: Value(tableId),
          openedByUserId: userId,
          billNumber: billNumber,
          numberOfGuests: Value(numberOfGuests),
          isTakeaway: Value(isTakeaway),
          status: BillStatus.opened,
          currencyId: currencyId,
          openedAt: now,
        ));
      });

      // Enqueue outside transaction
      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      final bill = billFromEntity(entity);
      await _enqueueBill('insert', bill);
      return Success(bill);
    } catch (e, s) {
      AppLogger.error('Failed to create bill', error: e, stackTrace: s);
      return Failure('Failed to create bill: $e');
    }
  }

  Future<Result<BillModel>> getById(String id) async {
    try {
      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (entity == null) return const Failure('Bill not found');
      return Success(billFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get bill', error: e, stackTrace: s);
      return Failure('Failed to get bill: $e');
    }
  }

  Stream<BillModel?> watchById(String id) {
    return (_db.select(_db.bills)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((e) => e == null ? null : billFromEntity(e));
  }

  Future<List<BillModel>> getByCompany(String companyId) async {
    final entities = await (_db.select(_db.bills)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
        .get();
    return entities.map(billFromEntity).toList();
  }

  Stream<List<BillModel>> watchByStatus(String companyId, BillStatus status) {
    return (_db.select(_db.bills)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.status.equals(status.name) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
        .watch()
        .map((rows) => rows.map(billFromEntity).toList());
  }

  Stream<List<BillModel>> watchByCompany(String companyId, {BillStatus? status, String? sectionId}) {
    return (_db.select(_db.bills)
          ..where((t) {
            var expr = t.companyId.equals(companyId) & t.deletedAt.isNull();
            if (status != null) {
              expr = expr & t.status.equals(status.name);
            }
            return expr;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
        .watch()
        .asyncMap((rows) async {
      var bills = rows.map(billFromEntity).toList();
      if (sectionId != null) {
        // Filter by section: get table IDs in this section
        final tables = await (_db.select(_db.tables)
              ..where((t) =>
                  t.companyId.equals(companyId) &
                  t.sectionId.equals(sectionId) &
                  t.deletedAt.isNull()))
            .get();
        final tableIds = tables.map((t) => t.id).toSet();
        bills = bills.where((b) => b.tableId != null && tableIds.contains(b.tableId)).toList();
      }
      return bills;
    });
  }

  Future<Result<BillModel>> updateTotals(String billId) async {
    try {
      // Get all active order items for this bill
      final orders = await (_db.select(_db.orders)
            ..where((t) =>
                t.billId.equals(billId) &
                t.deletedAt.isNull()))
          .get();
      final activeOrderIds = orders
          .where((o) =>
              o.status != PrepStatus.cancelled &&
              o.status != PrepStatus.voided)
          .map((o) => o.id)
          .toSet();

      int subtotalGross = 0;
      int taxTotal = 0;

      if (activeOrderIds.isNotEmpty) {
        final items = await (_db.select(_db.orderItems)
              ..where((t) =>
                  t.orderId.isIn(activeOrderIds) &
                  t.deletedAt.isNull() &
                  t.status.isNotIn([PrepStatus.cancelled.name, PrepStatus.voided.name])))
            .get();

        for (final item in items) {
          final itemSubtotal = (item.salePriceAtt * item.quantity).round();
          final itemTax = (item.saleTaxAmount * item.quantity).round();

          // Apply item discount
          int itemDiscount = 0;
          if (item.discount > 0) {
            if (item.discountType == DiscountType.percent) {
              itemDiscount = (itemSubtotal * item.discount / 10000).round();
            } else {
              itemDiscount = item.discount;
            }
          }

          subtotalGross += itemSubtotal - itemDiscount;
          taxTotal += itemTax;
        }
      }

      // Read bill for bill-level discount
      final billEntity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();

      // Apply bill discount
      int billDiscount = 0;
      if (billEntity.discountAmount > 0) {
        if (billEntity.discountType == DiscountType.percent) {
          billDiscount = (subtotalGross * billEntity.discountAmount / 10000).round();
        } else {
          billDiscount = billEntity.discountAmount;
        }
      }

      final subtotalNet = subtotalGross - taxTotal;
      final totalGross = subtotalGross - billDiscount + billEntity.roundingAmount;

      await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
        BillsCompanion(
          subtotalGross: Value(subtotalGross),
          subtotalNet: Value(subtotalNet),
          taxTotal: Value(taxTotal),
          totalGross: Value(totalGross),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      final bill = billFromEntity(entity);
      await _enqueueBill('update', bill);
      return Success(bill);
    } catch (e, s) {
      AppLogger.error('Failed to update bill totals', error: e, stackTrace: s);
      return Failure('Failed to update bill totals: $e');
    }
  }

  Future<Result<BillModel>> recordPayment({
    required String companyId,
    required String billId,
    required String paymentMethodId,
    required String currencyId,
    required int amount,
    int tipAmount = 0,
    String? userId,
  }) async {
    try {
      final now = DateTime.now();
      final paymentId = const Uuid().v7();

      // Atomic: insert payment + update bill
      await _db.transaction(() async {
        await _db.into(_db.payments).insert(PaymentsCompanion.insert(
          id: paymentId,
          companyId: companyId,
          billId: billId,
          userId: Value(userId),
          paymentMethodId: paymentMethodId,
          amount: amount,
          paidAt: now,
          currencyId: currencyId,
          tipIncludedAmount: Value(tipAmount),
        ));

        final bill = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        final newPaidAmount = bill.paidAmount + amount;
        final isPaid = newPaidAmount >= bill.totalGross;

        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            paidAmount: Value(newPaidAmount),
            status: isPaid ? const Value(BillStatus.paid) : const Value.absent(),
            closedAt: isPaid ? Value(now) : const Value.absent(),
            updatedAt: Value(now),
          ),
        );
      });

      // Enqueue sync (outside transaction)
      final paymentEntity = await (_db.select(_db.payments)
            ..where((t) => t.id.equals(paymentId)))
          .getSingle();
      await _enqueuePayment('insert', paymentFromEntity(paymentEntity));

      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      final updatedBill = billFromEntity(entity);
      await _enqueueBill('update', updatedBill);
      return Success(updatedBill);
    } catch (e, s) {
      AppLogger.error('Failed to record payment', error: e, stackTrace: s);
      return Failure('Failed to record payment: $e');
    }
  }

  Future<Result<BillModel>> cancelBill(String billId) async {
    try {
      final bill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();

      if (bill.status != BillStatus.opened) {
        return const Failure('Can only cancel opened bills');
      }

      final now = DateTime.now();

      // Read orders before transaction (for enqueue after)
      final orders = await (_db.select(_db.orders)
            ..where((t) =>
                t.billId.equals(billId) &
                t.deletedAt.isNull()))
          .get();

      // Atomic: cancel/void orders + update bill
      await _db.transaction(() async {
        for (final order in orders) {
          if (order.status == PrepStatus.created) {
            await (_db.update(_db.orderItems)..where((t) => t.orderId.equals(order.id)))
                .write(OrderItemsCompanion(
              status: const Value(PrepStatus.cancelled),
              updatedAt: Value(now),
            ));
            await (_db.update(_db.orders)..where((t) => t.id.equals(order.id)))
                .write(OrdersCompanion(
              status: const Value(PrepStatus.cancelled),
              updatedAt: Value(now),
            ));
          } else if (order.status == PrepStatus.inPrep || order.status == PrepStatus.ready) {
            await (_db.update(_db.orderItems)..where((t) => t.orderId.equals(order.id)))
                .write(OrderItemsCompanion(
              status: const Value(PrepStatus.voided),
              updatedAt: Value(now),
            ));
            await (_db.update(_db.orders)..where((t) => t.id.equals(order.id)))
                .write(OrdersCompanion(
              status: const Value(PrepStatus.voided),
              updatedAt: Value(now),
            ));
          }
        }

        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            status: const Value(BillStatus.cancelled),
            closedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      });

      // Enqueue sync (outside transaction)
      for (final order in orders) {
        if (order.status == PrepStatus.created ||
            order.status == PrepStatus.inPrep ||
            order.status == PrepStatus.ready) {
          final orderEntity = await (_db.select(_db.orders)
                ..where((t) => t.id.equals(order.id)))
              .getSingle();
          await _enqueueOrder('update', orderFromEntity(orderEntity));
          final itemEntities = await (_db.select(_db.orderItems)
                ..where((t) => t.orderId.equals(order.id)))
              .get();
          for (final item in itemEntities) {
            await _enqueueOrderItem('update', orderItemFromEntity(item));
          }
        }
      }

      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      final cancelledBill = billFromEntity(entity);
      await _enqueueBill('update', cancelledBill);
      return Success(cancelledBill);
    } catch (e, s) {
      AppLogger.error('Failed to cancel bill', error: e, stackTrace: s);
      return Failure('Failed to cancel bill: $e');
    }
  }

  Future<Result<BillModel>> updateDiscount(
    String billId,
    DiscountType discountType,
    int discountAmount,
  ) async {
    try {
      await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
        BillsCompanion(
          discountType: Value(discountType),
          discountAmount: Value(discountAmount),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return updateTotals(billId);
    } catch (e, s) {
      AppLogger.error('Failed to update bill discount', error: e, stackTrace: s);
      return Failure('Failed to update bill discount: $e');
    }
  }

  Future<Result<BillModel>> moveBill(
    String billId, {
    required String? tableId,
    required int numberOfGuests,
  }) async {
    try {
      await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
        BillsCompanion(
          tableId: Value(tableId),
          numberOfGuests: Value(numberOfGuests),
          isTakeaway: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      final bill = billFromEntity(entity);
      await _enqueueBill('update', bill);
      return Success(bill);
    } catch (e, s) {
      AppLogger.error('Failed to move bill', error: e, stackTrace: s);
      return Failure('Failed to move bill: $e');
    }
  }

  Future<Result<BillModel>> refundBill({
    required String billId,
    required String registerSessionId,
    required String userId,
  }) async {
    try {
      final bill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();

      if (bill.status != BillStatus.paid) {
        return const Failure('Can only refund paid bills');
      }

      final now = DateTime.now();

      // Get existing payments
      final payments = await (_db.select(_db.payments)
            ..where((t) => t.billId.equals(billId) & t.deletedAt.isNull()))
          .get();

      // Get payment methods to identify cash
      final methodIds = payments.map((p) => p.paymentMethodId).toSet();
      final methods = await (_db.select(_db.paymentMethods)
            ..where((t) => t.id.isIn(methodIds)))
          .get();
      final cashMethodIds = methods
          .where((m) => m.type == PaymentType.cash)
          .map((m) => m.id)
          .toSet();

      final refundPaymentIds = <String>[];
      int cashRefundTotal = 0;

      // Atomic: create negative payments + update bill
      await _db.transaction(() async {
        for (final payment in payments) {
          final refundId = const Uuid().v7();
          refundPaymentIds.add(refundId);
          final refundAmount = payment.amount + payment.tipIncludedAmount;
          await _db.into(_db.payments).insert(PaymentsCompanion.insert(
            id: refundId,
            companyId: bill.companyId,
            billId: billId,
            paymentMethodId: payment.paymentMethodId,
            amount: -payment.amount,
            paidAt: now,
            currencyId: payment.currencyId,
            tipIncludedAmount: Value(-payment.tipIncludedAmount),
          ));

          if (cashMethodIds.contains(payment.paymentMethodId)) {
            cashRefundTotal += refundAmount;
          }
        }

        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            status: const Value(BillStatus.refunded),
            paidAmount: const Value(0),
            updatedAt: Value(now),
          ),
        );

        // Create cash movement for cash refunds
        if (cashRefundTotal > 0) {
          final movementId = const Uuid().v7();
          await _db.into(_db.cashMovements).insert(
            CashMovementsCompanion.insert(
              id: movementId,
              companyId: bill.companyId,
              registerSessionId: registerSessionId,
              userId: userId,
              type: CashMovementType.withdrawal,
              amount: cashRefundTotal,
              reason: const Value('Refund'),
            ),
          );
        }
      });

      // Enqueue sync (outside transaction)
      for (final refundId in refundPaymentIds) {
        final entity = await (_db.select(_db.payments)
              ..where((t) => t.id.equals(refundId)))
            .getSingle();
        await _enqueuePayment('insert', paymentFromEntity(entity));
      }

      if (cashRefundTotal > 0) {
        // Enqueue cash movement
        final movements = await (_db.select(_db.cashMovements)
              ..where((t) =>
                  t.registerSessionId.equals(registerSessionId) &
                  t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .get();
        if (movements.isNotEmpty) {
          await _enqueueCashMovement('insert', cashMovementFromEntity(movements.first));
        }
      }

      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      final refundedBill = billFromEntity(entity);
      await _enqueueBill('update', refundedBill);
      return Success(refundedBill);
    } catch (e, s) {
      AppLogger.error('Failed to refund bill', error: e, stackTrace: s);
      return Failure('Failed to refund bill: $e');
    }
  }

  Future<Result<BillModel>> refundItem({
    required String billId,
    required String orderItemId,
    required String registerSessionId,
    required String userId,
  }) async {
    try {
      final bill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();

      if (bill.status != BillStatus.paid) {
        return const Failure('Can only refund items from paid bills');
      }

      final item = await (_db.select(_db.orderItems)
            ..where((t) => t.id.equals(orderItemId)))
          .getSingle();

      final itemTotal = (item.salePriceAtt * item.quantity).round();
      int itemDiscount = 0;
      if (item.discount > 0) {
        if (item.discountType == DiscountType.percent) {
          itemDiscount = (itemTotal * item.discount / 10000).round();
        } else {
          itemDiscount = item.discount;
        }
      }
      final refundAmount = itemTotal - itemDiscount;

      final now = DateTime.now();

      // Find a cash payment method if available (for cash movement)
      final payments = await (_db.select(_db.payments)
            ..where((t) => t.billId.equals(billId) & t.deletedAt.isNull()))
          .get();
      final methodIds = payments.map((p) => p.paymentMethodId).toSet();
      final methods = await (_db.select(_db.paymentMethods)
            ..where((t) => t.id.isIn(methodIds)))
          .get();
      final cashMethodIds = methods
          .where((m) => m.type == PaymentType.cash)
          .map((m) => m.id)
          .toSet();

      // Use first payment method as the refund method
      final refundMethodId = payments.first.paymentMethodId;
      final isCash = cashMethodIds.contains(refundMethodId);

      final refundPaymentId = const Uuid().v7();

      // Atomic: create negative payment + void item + update bill
      await _db.transaction(() async {
        await _db.into(_db.payments).insert(PaymentsCompanion.insert(
          id: refundPaymentId,
          companyId: bill.companyId,
          billId: billId,
          paymentMethodId: refundMethodId,
          amount: -refundAmount,
          paidAt: now,
          currencyId: bill.currencyId,
        ));

        // Void the item
        await (_db.update(_db.orderItems)..where((t) => t.id.equals(orderItemId))).write(
          OrderItemsCompanion(
            status: const Value(PrepStatus.voided),
            updatedAt: Value(now),
          ),
        );

        // Update bill paid amount
        final newPaidAmount = bill.paidAmount - refundAmount;
        final isFullyRefunded = newPaidAmount <= 0;

        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            paidAmount: Value(newPaidAmount),
            status: isFullyRefunded
                ? const Value(BillStatus.refunded)
                : const Value.absent(),
            updatedAt: Value(now),
          ),
        );

        // Cash movement for cash refunds
        if (isCash) {
          final movementId = const Uuid().v7();
          await _db.into(_db.cashMovements).insert(
            CashMovementsCompanion.insert(
              id: movementId,
              companyId: bill.companyId,
              registerSessionId: registerSessionId,
              userId: userId,
              type: CashMovementType.withdrawal,
              amount: refundAmount,
              reason: const Value('Refund'),
            ),
          );
        }
      });

      // Enqueue sync (outside transaction)
      final paymentEntity = await (_db.select(_db.payments)
            ..where((t) => t.id.equals(refundPaymentId)))
          .getSingle();
      await _enqueuePayment('insert', paymentFromEntity(paymentEntity));

      final itemEntity = await (_db.select(_db.orderItems)
            ..where((t) => t.id.equals(orderItemId)))
          .getSingle();
      await _enqueueOrderItem('update', orderItemFromEntity(itemEntity));

      if (isCash) {
        final movements = await (_db.select(_db.cashMovements)
              ..where((t) =>
                  t.registerSessionId.equals(registerSessionId) &
                  t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .get();
        if (movements.isNotEmpty) {
          await _enqueueCashMovement('insert', cashMovementFromEntity(movements.first));
        }
      }

      // Recalculate totals
      await updateTotals(billId);

      final entity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      final updatedBill = billFromEntity(entity);
      await _enqueueBill('update', updatedBill);
      return Success(updatedBill);
    } catch (e, s) {
      AppLogger.error('Failed to refund item', error: e, stackTrace: s);
      return Failure('Failed to refund item: $e');
    }
  }

  Future<String> _generateBillNumber(String companyId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final count = await (_db.select(_db.bills)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.openedAt.isBiggerOrEqualValue(startOfDay) &
              t.openedAt.isSmallerThanValue(endOfDay)))
        .get();

    final number = count.length + 1;
    return 'B-${number.toString().padLeft(3, '0')}';
  }

  Future<void> _enqueueBill(String operation, BillModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.companyId,
      entityType: 'bills',
      entityId: m.id,
      operation: operation,
      payload: jsonEncode(billToSupabaseJson(m)),
    );
  }

  Future<void> _enqueueOrder(String operation, OrderModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.companyId,
      entityType: 'orders',
      entityId: m.id,
      operation: operation,
      payload: jsonEncode(orderToSupabaseJson(m)),
    );
  }

  Future<void> _enqueueOrderItem(String operation, OrderItemModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.companyId,
      entityType: 'order_items',
      entityId: m.id,
      operation: operation,
      payload: jsonEncode(orderItemToSupabaseJson(m)),
    );
  }

  Future<void> _enqueuePayment(String operation, PaymentModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.companyId,
      entityType: 'payments',
      entityId: m.id,
      operation: operation,
      payload: jsonEncode(paymentToSupabaseJson(m)),
    );
  }

  Future<void> _enqueueCashMovement(String operation, CashMovementModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.companyId,
      entityType: 'cash_movements',
      entityId: m.id,
      operation: operation,
      payload: jsonEncode(cashMovementToSupabaseJson(m)),
    );
  }
}
