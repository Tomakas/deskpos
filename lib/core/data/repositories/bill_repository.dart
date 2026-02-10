import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/bill_status.dart';
import '../enums/prep_status.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/bill_model.dart';
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
    required String billNumber,
    String? tableId,
    bool isTakeaway = false,
    int numberOfGuests = 0,
  }) async {
    try {
      final now = DateTime.now();
      final id = const Uuid().v7();
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
          subtotalGross += (item.salePriceAtt * item.quantity).round();
          taxTotal += (item.saleTaxAmount * item.quantity).round();
        }
      }

      final subtotalNet = subtotalGross - taxTotal;
      final totalGross = subtotalGross; // E2: no discounts, no rounding

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
  }) async {
    try {
      final now = DateTime.now();
      final paymentId = const Uuid().v7();

      await _db.into(_db.payments).insert(PaymentsCompanion.insert(
        id: paymentId,
        companyId: companyId,
        billId: billId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        paidAt: now,
        currencyId: currencyId,
      ));

      // Enqueue payment
      final paymentEntity = await (_db.select(_db.payments)
            ..where((t) => t.id.equals(paymentId)))
          .getSingle();
      await _enqueuePayment('insert', paymentFromEntity(paymentEntity));

      // Update bill paid amount and status
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

      // Cancel/void all orders
      final orders = await (_db.select(_db.orders)
            ..where((t) =>
                t.billId.equals(billId) &
                t.deletedAt.isNull()))
          .get();

      for (final order in orders) {
        if (order.status == PrepStatus.created) {
          await _cancelOrder(order.id, now);
        } else if (order.status == PrepStatus.inPrep || order.status == PrepStatus.ready) {
          await _voidOrder(order.id, now);
        }
      }

      // Update bill status
      await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
        BillsCompanion(
          status: const Value(BillStatus.cancelled),
          closedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

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

  Future<void> _cancelOrder(String orderId, DateTime now) async {
    await (_db.update(_db.orderItems)..where((t) => t.orderId.equals(orderId)))
        .write(OrderItemsCompanion(
      status: const Value(PrepStatus.cancelled),
      updatedAt: Value(now),
    ));
    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId)))
        .write(OrdersCompanion(
      status: const Value(PrepStatus.cancelled),
      updatedAt: Value(now),
    ));

    // Readback + enqueue order and items
    final orderEntity = await (_db.select(_db.orders)
          ..where((t) => t.id.equals(orderId)))
        .getSingle();
    await _enqueueOrder('update', orderFromEntity(orderEntity));
    final itemEntities = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId)))
        .get();
    for (final item in itemEntities) {
      await _enqueueOrderItem('update', orderItemFromEntity(item));
    }
  }

  Future<void> _voidOrder(String orderId, DateTime now) async {
    await (_db.update(_db.orderItems)..where((t) => t.orderId.equals(orderId)))
        .write(OrderItemsCompanion(
      status: const Value(PrepStatus.voided),
      updatedAt: Value(now),
    ));
    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId)))
        .write(OrdersCompanion(
      status: const Value(PrepStatus.voided),
      updatedAt: Value(now),
    ));

    // Readback + enqueue order and items
    final orderEntity = await (_db.select(_db.orders)
          ..where((t) => t.id.equals(orderId)))
        .getSingle();
    await _enqueueOrder('update', orderFromEntity(orderEntity));
    final itemEntities = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId)))
        .get();
    for (final item in itemEntities) {
      await _enqueueOrderItem('update', orderItemFromEntity(item));
    }
  }

  Future<String> generateBillNumber(String companyId) async {
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
}
