import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/discount_type.dart';
import '../enums/prep_status.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class OrderRepository {
  OrderRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<OrderModel>> createOrderWithItems({
    required String companyId,
    required String billId,
    required String userId,
    required String orderNumber,
    required List<_OrderItemInput> items,
    String? orderNotes,
  }) async {
    try {
      final now = DateTime.now();
      final orderId = const Uuid().v7();

      int subtotalGross = 0;
      int taxTotal = 0;

      await _db.transaction(() async {
        // Insert order
        await _db.into(_db.orders).insert(OrdersCompanion.insert(
          id: orderId,
          companyId: companyId,
          billId: billId,
          createdByUserId: userId,
          orderNumber: orderNumber,
          notes: Value(orderNotes),
          status: PrepStatus.created,
        ));

        // Insert order items
        for (final item in items) {
          final itemId = const Uuid().v7();
          final itemSubtotal = (item.salePriceAtt * item.quantity).round();
          final itemTax = (item.saleTaxAmount * item.quantity).round();
          subtotalGross += itemSubtotal;
          taxTotal += itemTax;

          await _db.into(_db.orderItems).insert(OrderItemsCompanion.insert(
            id: itemId,
            companyId: companyId,
            orderId: orderId,
            itemId: item.itemId,
            itemName: item.itemName,
            quantity: item.quantity,
            salePriceAtt: item.salePriceAtt,
            saleTaxRateAtt: item.saleTaxRateAtt,
            saleTaxAmount: item.saleTaxAmount,
            notes: Value(item.notes),
            status: PrepStatus.created,
          ));
        }

        // Update order totals
        final subtotalNet = subtotalGross - taxTotal;
        await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
          OrdersCompanion(
            itemCount: Value(items.length),
            subtotalGross: Value(subtotalGross),
            subtotalNet: Value(subtotalNet),
            taxTotal: Value(taxTotal),
            updatedAt: Value(now),
          ),
        );
      });

      final entity = await (_db.select(_db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      final order = orderFromEntity(entity);
      await _enqueueOrder('insert', order);

      // Enqueue all order items
      final itemEntities = await (_db.select(_db.orderItems)
            ..where((t) => t.orderId.equals(orderId)))
          .get();
      for (final item in itemEntities) {
        await _enqueueOrderItem('insert', orderItemFromEntity(item));
      }

      return Success(order);
    } catch (e, s) {
      AppLogger.error('Failed to create order', error: e, stackTrace: s);
      return Failure('Failed to create order: $e');
    }
  }

  Stream<List<OrderModel>> watchByBill(String billId) {
    return (_db.select(_db.orders)
          ..where((t) => t.billId.equals(billId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(orderFromEntity).toList());
  }

  Stream<List<OrderItemModel>> watchOrderItems(String orderId) {
    return (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(orderItemFromEntity).toList());
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final entities = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()))
        .get();
    return entities.map(orderItemFromEntity).toList();
  }

  Stream<Map<String, DateTime>> watchLastOrderTimesByCompany(String companyId) {
    return (_db.select(_db.orders)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull()))
        .watch()
        .map((rows) {
      final map = <String, DateTime>{};
      for (final row in rows) {
        final billId = row.billId;
        final createdAt = row.createdAt;
        if (!map.containsKey(billId) || createdAt.isAfter(map[billId]!)) {
          map[billId] = createdAt;
        }
      }
      return map;
    });
  }

  Future<Result<OrderModel>> updateStatus(String orderId, PrepStatus status) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          status: Value(status),
          updatedAt: Value(now),
        ),
      );
      // Update all items to matching status
      await (_db.update(_db.orderItems)..where((t) => t.orderId.equals(orderId)))
          .write(OrderItemsCompanion(
        status: Value(status),
        updatedAt: Value(now),
      ));
      final entity = await (_db.select(_db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      final order = orderFromEntity(entity);
      await _enqueueOrder('update', order);

      // Enqueue all order items (status changed in bulk)
      final itemEntities = await (_db.select(_db.orderItems)
            ..where((t) => t.orderId.equals(orderId)))
          .get();
      for (final item in itemEntities) {
        await _enqueueOrderItem('update', orderItemFromEntity(item));
      }

      return Success(order);
    } catch (e, s) {
      AppLogger.error('Failed to update order status', error: e, stackTrace: s);
      return Failure('Failed to update order status: $e');
    }
  }

  Future<Result<OrderModel>> cancelOrder(String orderId) async {
    try {
      final order = await (_db.select(_db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      if (order.status != PrepStatus.created) {
        return const Failure('Can only cancel orders in created state');
      }
      return updateStatus(orderId, PrepStatus.cancelled);
    } catch (e, s) {
      AppLogger.error('Failed to cancel order', error: e, stackTrace: s);
      return Failure('Failed to cancel order: $e');
    }
  }

  Future<Result<OrderModel>> voidOrder(String orderId) async {
    try {
      final order = await (_db.select(_db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      if (order.status != PrepStatus.inPrep && order.status != PrepStatus.ready) {
        return const Failure('Can only void orders in inPrep or ready state');
      }
      return updateStatus(orderId, PrepStatus.voided);
    } catch (e, s) {
      AppLogger.error('Failed to void order', error: e, stackTrace: s);
      return Failure('Failed to void order: $e');
    }
  }

  Future<Result<OrderModel>> startPreparation(String orderId) =>
      updateStatus(orderId, PrepStatus.inPrep);

  Future<Result<OrderModel>> markReady(String orderId) =>
      updateStatus(orderId, PrepStatus.ready);

  Future<Result<OrderModel>> markDelivered(String orderId) =>
      updateStatus(orderId, PrepStatus.delivered);

  Future<Result<void>> updateOrderNotes(String orderId, String? notes) async {
    try {
      await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          notes: Value(notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      await _enqueueOrder('update', orderFromEntity(entity));
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to update order notes', error: e, stackTrace: s);
      return Failure('Failed to update order notes: $e');
    }
  }

  Future<Result<void>> updateItemDiscount(
    String itemId,
    DiscountType discountType,
    int discount,
  ) async {
    try {
      await (_db.update(_db.orderItems)..where((t) => t.id.equals(itemId))).write(
        OrderItemsCompanion(
          discount: Value(discount),
          discountType: Value(discountType),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.orderItems)
            ..where((t) => t.id.equals(itemId)))
          .getSingle();
      await _enqueueOrderItem('update', orderItemFromEntity(entity));
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to update item discount', error: e, stackTrace: s);
      return Failure('Failed to update item discount: $e');
    }
  }

  Future<Result<void>> updateItemNotes(String itemId, String? notes) async {
    try {
      await (_db.update(_db.orderItems)..where((t) => t.id.equals(itemId))).write(
        OrderItemsCompanion(
          notes: Value(notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.orderItems)
            ..where((t) => t.id.equals(itemId)))
          .getSingle();
      await _enqueueOrderItem('update', orderItemFromEntity(entity));
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to update item notes', error: e, stackTrace: s);
      return Failure('Failed to update item notes: $e');
    }
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
}

class OrderItemInput {
  const OrderItemInput({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.salePriceAtt,
    required this.saleTaxRateAtt,
    required this.saleTaxAmount,
    this.notes,
  });

  final String itemId;
  final String itemName;
  final double quantity;
  final int salePriceAtt;
  final int saleTaxRateAtt;
  final int saleTaxAmount;
  final String? notes;
}

typedef _OrderItemInput = OrderItemInput;
