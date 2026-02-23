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
import '../models/payment_model.dart';
import '../result.dart';
import 'customer_repository.dart';
import 'order_repository.dart';
import 'sync_queue_repository.dart';

class BillRepository {
  BillRepository(this._db, {this.syncQueueRepo, this.orderRepo, this.customerRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;
  final OrderRepository? orderRepo;
  final CustomerRepository? customerRepo;

  Future<Result<BillModel>> createBill({
    required String companyId,
    required String userId,
    required String currencyId,
    String? sectionId,
    String? tableId,
    String? customerId,
    String? customerName,
    String? registerId,
    String? registerSessionId,
    bool isTakeaway = false,
    int numberOfGuests = 0,
  }) async {
    try {
      final now = DateTime.now();
      final id = const Uuid().v7();

      final bill = await _db.transaction(() async {
        final billNumber = await _generateBillNumber(companyId, registerId: registerId);
        await _db.into(_db.bills).insert(BillsCompanion.insert(
          id: id,
          companyId: companyId,
          customerId: Value(customerId),
          customerName: Value(customerId != null ? null : customerName),
          sectionId: Value(sectionId),
          tableId: Value(tableId),
          registerId: Value(registerId),
          lastRegisterId: Value(registerId),
          registerSessionId: Value(registerSessionId),
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
        final b = billFromEntity(entity);
        await _enqueueBill('insert', b);
        return b;
      });
      return Success(bill);
    } catch (e, s) {
      AppLogger.error('Failed to create bill', error: e, stackTrace: s);
      return Failure('Failed to create bill: $e');
    }
  }

  Future<Result<BillModel>> getById(String id, {bool includeDeleted = false}) async {
    try {
      final query = _db.select(_db.bills)..where((t) => t.id.equals(id));
      if (!includeDeleted) {
        query.where((t) => t.deletedAt.isNull());
      }
      final entity = await query.getSingleOrNull();
      if (entity == null) return const Failure('Bill not found');
      return Success(billFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get bill', error: e, stackTrace: s);
      return Failure('Failed to get bill: $e');
    }
  }

  Stream<BillModel?> watchById(String id, {bool includeDeleted = false}) {
    final query = _db.select(_db.bills)..where((t) => t.id.equals(id));
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    return query
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

  Future<List<BillModel>> getPaidInRange(String companyId, DateTime from, DateTime to) async {
    final entities = await (_db.select(_db.bills)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.status.equals(BillStatus.paid.name) &
              t.closedAt.isNotNull() &
              t.closedAt.isBiggerOrEqualValue(from) &
              t.closedAt.isSmallerOrEqualValue(to) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.closedAt)]))
        .get();
    return entities.map(billFromEntity).toList();
  }

  Future<List<BillModel>> getPaidOrRefundedInRange(String companyId, DateTime from, DateTime to) async {
    final entities = await (_db.select(_db.bills)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.status.isIn([BillStatus.paid.name, BillStatus.refunded.name]) &
              t.closedAt.isNotNull() &
              t.closedAt.isBiggerOrEqualValue(from) &
              t.closedAt.isSmallerOrEqualValue(to) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.closedAt)]))
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

  Stream<List<BillModel>> watchByCompany(String companyId, {BillStatus? status, Set<String>? sectionIds}) {
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
      if (sectionIds != null && sectionIds.isNotEmpty) {
        // Filter by sections: get table IDs in these sections
        final tables = await (_db.select(_db.tables)
              ..where((t) =>
                  t.companyId.equals(companyId) &
                  t.sectionId.isIn(sectionIds) &
                  t.deletedAt.isNull()))
            .get();
        final tableIds = tables.map((t) => t.id).toSet();
        bills = bills.where((b) {
          if (b.tableId != null) return tableIds.contains(b.tableId);
          return b.sectionId != null && sectionIds.contains(b.sectionId);
        }).toList();
      }
      return bills;
    });
  }

  Future<Result<BillModel>> updateTotals(String billId) async {
    try {
      return await _db.transaction(() async {
        // Get all active order items for this bill
        final orders = await (_db.select(_db.orders)
              ..where((t) =>
                  t.billId.equals(billId) &
                  t.deletedAt.isNull()))
            .get();
        final activeOrderIds = orders
            .where((o) =>
                o.status != PrepStatus.cancelled &&
                o.status != PrepStatus.voided &&
                !o.isStorno)
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

          // Batch-load modifiers for all active order items
          final activeItemIds = items.map((i) => i.id).toList();
          final allModifiers = activeItemIds.isEmpty
              ? <OrderItemModifier>[]
              : await (_db.select(_db.orderItemModifiers)
                    ..where((t) => t.orderItemId.isIn(activeItemIds) & t.deletedAt.isNull()))
                  .get();
          final modsByItem = <String, List<OrderItemModifier>>{};
          for (final mod in allModifiers) {
            modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
          }

          for (final item in items) {
            int itemSubtotal = (item.salePriceAtt * item.quantity).round();
            int itemTax = (item.saleTaxAmount * item.quantity).round();

            // Add modifier costs
            final itemMods = modsByItem[item.id] ?? [];
            for (final mod in itemMods) {
              itemSubtotal += (mod.unitPrice * mod.quantity * item.quantity).round();
              itemTax += (mod.taxAmount * mod.quantity * item.quantity).round();
            }

            // Apply item discount (on total including modifiers)
            int itemDiscount = 0;
            if (item.discount > 0) {
              if (item.discountType == DiscountType.percent) {
                itemDiscount = (itemSubtotal * item.discount / 10000).round();
              } else {
                itemDiscount = item.discount;
              }
            }

            subtotalGross += itemSubtotal - itemDiscount - item.voucherDiscount;
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
        final totalGross = subtotalGross - billDiscount - billEntity.loyaltyDiscountAmount - billEntity.voucherDiscountAmount + billEntity.roundingAmount;

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
      });
    } catch (e, s) {
      AppLogger.error('Failed to update bill totals', error: e, stackTrace: s);
      return Failure('Failed to update bill totals: $e');
    }
  }

  Future<Result<BillModel>> applyLoyaltyDiscount(
    String billId,
    int pointsToUse,
    int pointValue,
    String processedByUserId,
  ) async {
    try {
      final loyaltyDiscountAmount = pointsToUse * pointValue;

      final billEntity = await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            loyaltyPointsUsed: Value(pointsToUse),
            loyaltyDiscountAmount: Value(loyaltyDiscountAmount),
            updatedAt: Value(DateTime.now()),
          ),
        );
        final entity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        await _enqueueBill('update', billFromEntity(entity));
        return entity;
      });

      // Deduct points from customer
      if (billEntity.customerId != null && customerRepo != null) {
        final pointsResult = await customerRepo!.adjustPoints(
          customerId: billEntity.customerId!,
          delta: -pointsToUse,
          processedByUserId: processedByUserId,
          orderId: billId,
        );
        if (pointsResult case Failure(:final message)) {
          return Failure(message);
        }
      }

      // Recalculate totals
      return updateTotals(billId);
    } catch (e, s) {
      AppLogger.error('Failed to apply loyalty discount', error: e, stackTrace: s);
      return Failure('Failed to apply loyalty discount: $e');
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
    String? registerId,
    String? registerSessionId,
    int loyaltyEarnRate = 0,
  }) async {
    try {
      final now = DateTime.now();
      final paymentId = const Uuid().v7();
      int earnedPoints = 0;

      // Atomic: insert payment + update bill + store earned points + enqueue
      final updatedBill = await _db.transaction(() async {
        await _db.into(_db.payments).insert(PaymentsCompanion.insert(
          id: paymentId,
          companyId: companyId,
          billId: billId,
          registerId: Value(registerId),
          registerSessionId: Value(registerSessionId),
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
            lastRegisterId: registerId != null ? Value(registerId) : const Value.absent(),
            status: isPaid ? const Value(BillStatus.paid) : const Value.absent(),
            closedAt: isPaid ? Value(now) : const Value.absent(),
            updatedAt: Value(now),
          ),
        );

        // Calculate and store earned loyalty points (inside transaction for sync)
        if (isPaid && loyaltyEarnRate > 0) {
          final currentBill = await (_db.select(_db.bills)
                ..where((t) => t.id.equals(billId)))
              .getSingle();
          earnedPoints = (billFromEntity(currentBill).totalGross * loyaltyEarnRate) ~/ 10000;
          if (earnedPoints > 0) {
            await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
              BillsCompanion(
                loyaltyPointsEarned: Value(earnedPoints),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }

        final paymentEntity = await (_db.select(_db.payments)
              ..where((t) => t.id.equals(paymentId)))
            .getSingle();
        await _enqueuePayment('insert', paymentFromEntity(paymentEntity));

        final entity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        final b = billFromEntity(entity);
        await _enqueueBill('update', b);
        return b;
      });

      // Auto-earn points + tracking on full payment
      final isPaid = updatedBill.paidAmount >= updatedBill.totalGross;
      if (isPaid && updatedBill.customerId != null && customerRepo != null) {
        // Update totalSpent + lastVisitDate
        await customerRepo!.updateTrackingOnPayment(
          customerId: updatedBill.customerId!,
          billTotal: updatedBill.totalGross,
        );

        // Auto-earn loyalty points
        if (earnedPoints > 0) {
          await customerRepo!.adjustPoints(
            customerId: updatedBill.customerId!,
            delta: earnedPoints,
            processedByUserId: userId ?? '',
            orderId: billId,
          );
        }
      }

      return Success(updatedBill);
    } catch (e, s) {
      AppLogger.error('Failed to record payment', error: e, stackTrace: s);
      return Failure('Failed to record payment: $e');
    }
  }

  Future<Result<BillModel>> cancelBill(String billId, {String? userId}) async {
    try {
      final bill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();

      if (bill.status != BillStatus.opened) {
        return const Failure('Can only cancel opened bills');
      }

      final now = DateTime.now();

      final orders = await (_db.select(_db.orders)
            ..where((t) =>
                t.billId.equals(billId) &
                t.deletedAt.isNull()))
          .get();

      // Cancel/void orders via OrderRepository (handles stock reversal + sync enqueue)
      if (orderRepo != null) {
        for (final order in orders) {
          if (order.status == PrepStatus.created) {
            await orderRepo!.cancelOrder(order.id);
          } else if (order.status == PrepStatus.ready) {
            await orderRepo!.voidOrder(order.id);
          }
        }
      }

      // Update bill status + zero out discounts (atomic with enqueue)
      final cancelledBill = await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            status: const Value(BillStatus.cancelled),
            subtotalGross: const Value(0),
            subtotalNet: const Value(0),
            taxTotal: const Value(0),
            totalGross: const Value(0),
            discountAmount: const Value(0),
            discountType: const Value(null),
            loyaltyDiscountAmount: const Value(0),
            voucherDiscountAmount: const Value(0),
            roundingAmount: const Value(0),
            closedAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        final entity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        final b = billFromEntity(entity);
        await _enqueueBill('update', b);
        return b;
      });

      // Return redeemed loyalty points on cancel
      if (bill.loyaltyPointsUsed > 0 && bill.customerId != null && customerRepo != null) {
        await customerRepo!.adjustPoints(
          customerId: bill.customerId!,
          delta: bill.loyaltyPointsUsed,
          processedByUserId: userId ?? bill.openedByUserId,
          orderId: billId,
        );
      }

      return Success(cancelledBill);
    } catch (e, s) {
      AppLogger.error('Failed to cancel bill', error: e, stackTrace: s);
      return Failure('Failed to cancel bill: $e');
    }
  }

  Future<Result<BillModel>> updateMapPosition(
    String billId,
    int? posX,
    int? posY, {
    String? tableId,
    bool updateTable = false,
  }) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            mapPosX: Value(posX),
            mapPosY: Value(posY),
            tableId: updateTable ? Value(tableId) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
        final entity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        final bill = billFromEntity(entity);
        await _enqueueBill('update', bill);
        return Success(bill);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update bill map position', error: e, stackTrace: s);
      return Failure('Failed to update bill map position: $e');
    }
  }

  Future<Result<BillModel>> updateDiscount(
    String billId,
    DiscountType discountType,
    int discountAmount,
  ) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            discountType: Value(discountType),
            discountAmount: Value(discountAmount),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return updateTotals(billId);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update bill discount', error: e, stackTrace: s);
      return Failure('Failed to update bill discount: $e');
    }
  }

  Future<Result<BillModel>> applyVoucher({
    required String billId,
    required String voucherId,
    required int voucherDiscountAmount,
  }) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            voucherDiscountAmount: Value(voucherDiscountAmount),
            voucherId: Value(voucherId),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return updateTotals(billId);
      });
    } catch (e, s) {
      AppLogger.error('Failed to apply voucher', error: e, stackTrace: s);
      return Failure('Failed to apply voucher: $e');
    }
  }

  Future<Result<BillModel>> removeVoucher(String billId) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            voucherDiscountAmount: const Value(0),
            voucherId: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return updateTotals(billId);
      });
    } catch (e, s) {
      AppLogger.error('Failed to remove voucher', error: e, stackTrace: s);
      return Failure('Failed to remove voucher: $e');
    }
  }

  Future<Result<BillModel>> moveBill(
    String billId, {
    required String? tableId,
    required int numberOfGuests,
  }) async {
    try {
      return await _db.transaction(() async {
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
      });
    } catch (e, s) {
      AppLogger.error('Failed to move bill', error: e, stackTrace: s);
      return Failure('Failed to move bill: $e');
    }
  }

  Future<Result<BillModel>> updateCustomer(String billId, String? customerId) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            customerId: Value(customerId),
            customerName: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
        final entity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        final bill = billFromEntity(entity);
        await _enqueueBill('update', bill);
        return Success(bill);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update bill customer', error: e, stackTrace: s);
      return Failure('Failed to update bill customer: $e');
    }
  }

  Future<Result<BillModel>> updateCustomerName(String billId, String? name) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            customerName: Value(name),
            customerId: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
        final entity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingle();
        final bill = billFromEntity(entity);
        await _enqueueBill('update', bill);
        return Success(bill);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update bill customer name', error: e, stackTrace: s);
      return Failure('Failed to update bill customer name: $e');
    }
  }

  Future<Result<BillModel>> refundBill({
    required String billId,
    required String registerSessionId,
    required String userId,
    String? registerId,
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

      // Atomic: create negative payments + update bill + enqueue
      final refundedBill = await _db.transaction(() async {
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
            registerId: Value(registerId),
            registerSessionId: Value(registerSessionId),
            userId: Value(userId),
          ));

          if (cashMethodIds.contains(payment.paymentMethodId)) {
            cashRefundTotal += refundAmount;
          }
        }

        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            status: const Value(BillStatus.refunded),
            paidAmount: const Value(0),
            loyaltyPointsEarned: const Value(0),
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

        // Enqueue sync (inside transaction)
        for (final refundId in refundPaymentIds) {
          final entity = await (_db.select(_db.payments)
                ..where((t) => t.id.equals(refundId)))
              .getSingle();
          await _enqueuePayment('insert', paymentFromEntity(entity));
        }

        if (cashRefundTotal > 0) {
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
        final b = billFromEntity(entity);
        await _enqueueBill('update', b);
        return b;
      });

      // Reverse loyalty on refund
      if (bill.customerId != null && customerRepo != null) {
        // Return redeemed points
        if (bill.loyaltyPointsUsed > 0) {
          await customerRepo!.adjustPoints(
            customerId: bill.customerId!,
            delta: bill.loyaltyPointsUsed,
            processedByUserId: userId,
            orderId: billId,
          );
        }

        // Reverse earned points
        if (bill.loyaltyPointsEarned > 0) {
          await customerRepo!.adjustPoints(
            customerId: bill.customerId!,
            delta: -bill.loyaltyPointsEarned,
            processedByUserId: userId,
            orderId: billId,
          );
        }

        // Reverse totalSpent (without updating lastVisitDate)
        await customerRepo!.updateTrackingOnPayment(
          customerId: bill.customerId!,
          billTotal: -bill.totalGross,
          updateLastVisit: false,
        );
      }

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

      // Calculate proportional loyalty earned reversal
      final proportionalEarned = (bill.totalGross > 0 && bill.loyaltyPointsEarned > 0)
          ? (bill.loyaltyPointsEarned * refundAmount / bill.totalGross).round()
          : 0;
      final newLoyaltyPointsEarned = (bill.loyaltyPointsEarned - proportionalEarned).clamp(0, bill.loyaltyPointsEarned);
      final newPaidAmount = bill.paidAmount - refundAmount;
      final isFullyRefunded = newPaidAmount <= 0;

      final refundPaymentId = const Uuid().v7();

      // Atomic: create negative payment + void item + update bill + enqueue
      await _db.transaction(() async {
        await _db.into(_db.payments).insert(PaymentsCompanion.insert(
          id: refundPaymentId,
          companyId: bill.companyId,
          billId: billId,
          paymentMethodId: refundMethodId,
          amount: -refundAmount,
          paidAt: now,
          currencyId: bill.currencyId,
          registerId: Value(bill.lastRegisterId),
          registerSessionId: Value(registerSessionId),
          userId: Value(userId),
        ));

        // Void the item
        await (_db.update(_db.orderItems)..where((t) => t.id.equals(orderItemId))).write(
          OrderItemsCompanion(
            status: const Value(PrepStatus.voided),
            updatedAt: Value(now),
          ),
        );

        // Update bill paid amount + loyalty earned
        await (_db.update(_db.bills)..where((t) => t.id.equals(billId))).write(
          BillsCompanion(
            paidAmount: Value(newPaidAmount),
            loyaltyPointsEarned: Value(isFullyRefunded ? 0 : newLoyaltyPointsEarned),
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

        // Enqueue sync (inside transaction)
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
      });

      // Reverse loyalty on item refund
      if (bill.customerId != null && customerRepo != null) {
        // Proportional earned points reversal
        if (proportionalEarned > 0) {
          await customerRepo!.adjustPoints(
            customerId: bill.customerId!,
            delta: -proportionalEarned,
            processedByUserId: userId,
            orderId: billId,
          );
        }

        // If fully refunded, also return redeemed points
        if (isFullyRefunded && bill.loyaltyPointsUsed > 0) {
          await customerRepo!.adjustPoints(
            customerId: bill.customerId!,
            delta: bill.loyaltyPointsUsed,
            processedByUserId: userId,
            orderId: billId,
          );
        }

        // Reverse partial totalSpent
        await customerRepo!.updateTrackingOnPayment(
          customerId: bill.customerId!,
          billTotal: -refundAmount,
          updateLastVisit: false,
        );
      }

      // Recalculate totals (has its own transaction + enqueue)
      return updateTotals(billId);
    } catch (e, s) {
      AppLogger.error('Failed to refund item', error: e, stackTrace: s);
      return Failure('Failed to refund item: $e');
    }
  }

  Future<Result<BillModel>> mergeBill(String sourceBillId, String targetBillId) async {
    try {
      if (orderRepo == null) return const Failure('OrderRepository not available');

      // Move all orders from source to target
      final reassignResult = await orderRepo!.reassignOrdersToBill(sourceBillId, targetBillId);
      if (reassignResult case Failure(:final message)) {
        return Failure(message);
      }

      // Cancel source bill (atomic with enqueue)
      final now = DateTime.now();
      await _db.transaction(() async {
        await (_db.update(_db.bills)..where((t) => t.id.equals(sourceBillId))).write(
          BillsCompanion(
            status: const Value(BillStatus.cancelled),
            closedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        final sourceEntity = await (_db.select(_db.bills)
              ..where((t) => t.id.equals(sourceBillId)))
            .getSingle();
        await _enqueueBill('update', billFromEntity(sourceEntity));
      });

      // Recalculate target totals
      await updateTotals(targetBillId);

      final targetEntity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(targetBillId)))
          .getSingle();
      return Success(billFromEntity(targetEntity));
    } catch (e, s) {
      AppLogger.error('Failed to merge bill', error: e, stackTrace: s);
      return Failure('Failed to merge bill: $e');
    }
  }

  Future<Result<BillModel>> splitBill({
    required String sourceBillId,
    required String targetBillId,
    required List<({String orderItemId, double moveQuantity})> splitItems,
    required String userId,
    String? registerId,
  }) async {
    try {
      if (orderRepo == null) return const Failure('OrderRepository not available');

      // Get companyId from source bill
      final sourceBill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(sourceBillId)))
          .getSingle();

      // Move selected items to new order on target bill
      final splitResult = await orderRepo!.splitItemsToNewOrder(
        targetBillId: targetBillId,
        companyId: sourceBill.companyId,
        userId: userId,
        splitItems: splitItems,
        registerId: registerId,
      );
      if (splitResult case Failure(:final message)) {
        return Failure(message);
      }

      // Recalculate both bill totals
      await updateTotals(sourceBillId);
      await updateTotals(targetBillId);

      final targetEntity = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(targetBillId)))
          .getSingle();
      return Success(billFromEntity(targetEntity));
    } catch (e, s) {
      AppLogger.error('Failed to split bill', error: e, stackTrace: s);
      return Failure('Failed to split bill: $e');
    }
  }

  Future<String> _generateBillNumber(String companyId, {String? registerId}) async {
    // If we have a registerId, use register-based numbering: B{n}-{counter}
    if (registerId != null) {
      final register = await (_db.select(_db.registers)
            ..where((t) => t.id.equals(registerId)))
          .getSingleOrNull();
      if (register != null) {
        final regNum = register.registerNumber;
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final count = await (_db.select(_db.bills)
              ..where((t) =>
                  t.companyId.equals(companyId) &
                  t.registerId.equals(registerId) &
                  t.openedAt.isBiggerOrEqualValue(startOfDay) &
                  t.openedAt.isSmallerThanValue(endOfDay)))
            .get();

        final number = count.length + 1;
        return 'B$regNum-${number.toString().padLeft(3, '0')}';
      }
    }

    // Fallback: legacy numbering for bills without register
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
