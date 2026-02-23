import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/discount_type.dart';
import '../enums/item_type.dart';
import '../enums/prep_status.dart';
import '../enums/stock_movement_direction.dart';
import '../enums/unit_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/order_item_model.dart';
import '../models/order_item_modifier_model.dart';
import '../models/order_model.dart';
import '../models/stock_movement_model.dart';
import '../result.dart';
import 'order_item_modifier_repository.dart';
import 'stock_level_repository.dart';
import 'stock_movement_repository.dart';
import 'sync_queue_repository.dart';

class OrderRepository {
  OrderRepository(
    this._db, {
    this.syncQueueRepo,
    this.stockLevelRepo,
    this.stockMovementRepo,
    this.orderItemModifierRepo,
  });
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;
  final StockLevelRepository? stockLevelRepo;
  final StockMovementRepository? stockMovementRepo;
  final OrderItemModifierRepository? orderItemModifierRepo;

  Future<Result<OrderModel>> createOrderWithItems({
    required String companyId,
    required String billId,
    required String userId,
    required String orderNumber,
    required List<OrderItemInput> items,
    String? orderNotes,
    String? registerId,
  }) async {
    try {
      final now = DateTime.now();
      final orderId = const Uuid().v7();

      int subtotalGross = 0;
      int taxTotal = 0;

      final order = await _db.transaction(() async {
        // Insert order
        await _db.into(_db.orders).insert(OrdersCompanion.insert(
          id: orderId,
          companyId: companyId,
          billId: billId,
          registerId: Value(registerId),
          createdByUserId: userId,
          orderNumber: orderNumber,
          notes: Value(orderNotes),
          status: PrepStatus.created,
        ));

        // Insert order items and their modifiers
        for (final item in items) {
          final itemId = const Uuid().v7();
          // Item base cost
          int itemSubtotal = (item.salePriceAtt * item.quantity).round();
          int itemTax = (item.saleTaxAmount * item.quantity).round();
          // Add modifier costs (each modifier × item quantity)
          for (final mod in item.modifiers) {
            itemSubtotal += (mod.unitPrice * mod.quantity * item.quantity).round();
            itemTax += (mod.taxAmount * mod.quantity * item.quantity).round();
          }
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
            unit: Value(item.unit),
            notes: Value(item.notes),
            status: PrepStatus.created,
          ));

          // Insert order item modifiers
          if (item.modifiers.isNotEmpty) {
            final modifierModels = item.modifiers.map((mod) => OrderItemModifierModel(
              id: const Uuid().v7(),
              companyId: companyId,
              orderItemId: itemId,
              modifierItemId: mod.modifierItemId,
              modifierGroupId: mod.modifierGroupId,
              modifierItemName: mod.modifierItemName,
              quantity: mod.quantity,
              unitPrice: mod.unitPrice,
              taxRate: mod.taxRate,
              taxAmount: mod.taxAmount,
              createdAt: now,
              updatedAt: now,
            )).toList();
            if (orderItemModifierRepo != null) {
              await orderItemModifierRepo!.createBatch(modifierModels);
            }
          }
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

        // Enqueue sync (inside transaction)
        final entity = await (_db.select(_db.orders)
              ..where((t) => t.id.equals(orderId)))
            .getSingle();
        final o = orderFromEntity(entity);
        await _enqueueOrder('insert', o);

        final itemEntities = await (_db.select(_db.orderItems)
              ..where((t) => t.orderId.equals(orderId)))
            .get();
        for (final item in itemEntities) {
          await _enqueueOrderItem('insert', orderItemFromEntity(item));
        }
        return o;
      });

      // Stock deduction for stock-tracked items
      await _deductStockForOrder(companyId, items);

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

  Future<List<OrderItemModel>> getOrderItemsByBill(String billId) async {
    final orders = await (_db.select(_db.orders)
          ..where((t) => t.billId.equals(billId) & t.deletedAt.isNull()))
        .get();
    if (orders.isEmpty) return [];
    final orderIds = orders.map((o) => o.id).toList();
    final entities = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.isIn(orderIds) & t.deletedAt.isNull()))
        .get();
    return entities.map(orderItemFromEntity).toList();
  }

  Future<List<OrderModel>> getOrdersByBillIds(List<String> billIds) async {
    if (billIds.isEmpty) return [];
    final entities = await (_db.select(_db.orders)
          ..where((t) => t.billId.isIn(billIds) & t.deletedAt.isNull()))
        .get();
    return entities.map(orderFromEntity).toList();
  }

  Future<List<OrderItemModel>> getOrderItemsByBillIds(List<String> billIds) async {
    if (billIds.isEmpty) return [];
    final orders = await (_db.select(_db.orders)
          ..where((t) => t.billId.isIn(billIds) & t.deletedAt.isNull()))
        .get();
    if (orders.isEmpty) return [];
    final orderIds = orders.map((o) => o.id).toList();
    final entities = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.isIn(orderIds) & t.deletedAt.isNull()))
        .get();
    return entities.map(orderItemFromEntity).toList();
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
      final (order, itemEntities) = await _db.transaction(() async {
        await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
          OrdersCompanion(
            status: Value(status),
            updatedAt: Value(now),
            prepStartedAt: status == PrepStatus.created ? Value(now) : const Value.absent(),
            readyAt: status == PrepStatus.ready ? Value(now) : const Value.absent(),
            deliveredAt: status == PrepStatus.delivered ? Value(now) : const Value.absent(),
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
        final o = orderFromEntity(entity);
        await _enqueueOrder('update', o);

        final items = await (_db.select(_db.orderItems)
              ..where((t) => t.orderId.equals(orderId)))
            .get();
        for (final item in items) {
          await _enqueueOrderItem('update', orderItemFromEntity(item));
        }
        return (o, items);
      });

      // Reverse stock deduction on cancel/void
      if (status == PrepStatus.cancelled || status == PrepStatus.voided) {
        await _reverseStockForOrder(order.companyId, itemEntities);
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
      if (order.status != PrepStatus.created && order.status != PrepStatus.ready) {
        return const Failure('Can only void orders in created or ready state');
      }
      return updateStatus(orderId, PrepStatus.voided);
    } catch (e, s) {
      AppLogger.error('Failed to void order', error: e, stackTrace: s);
      return Failure('Failed to void order: $e');
    }
  }

  Future<Result<OrderModel>> markReady(String orderId) =>
      updateStatus(orderId, PrepStatus.ready);

  Future<Result<OrderModel>> markDelivered(String orderId) =>
      updateStatus(orderId, PrepStatus.delivered);

  /// Updates the status of a single order item and derives the parent order
  /// status from all item statuses.
  Future<Result<OrderItemModel>> updateItemStatus(
    String itemId,
    String orderId,
    PrepStatus newStatus,
  ) async {
    try {
      final now = DateTime.now();

      // 1. Fetch and validate item
      final itemEntity = await (_db.select(_db.orderItems)
            ..where((t) => t.id.equals(itemId)))
          .getSingle();
      if (itemEntity.status == PrepStatus.voided ||
          itemEntity.status == PrepStatus.cancelled) {
        return const Failure('Item is already voided or cancelled');
      }

      return await _db.transaction(() async {
        // 2. Update item status + timestamp
        await (_db.update(_db.orderItems)..where((t) => t.id.equals(itemId)))
            .write(OrderItemsCompanion(
          status: Value(newStatus),
          updatedAt: Value(now),
          prepStartedAt: newStatus == PrepStatus.created
              ? Value(now)
              : const Value.absent(),
          readyAt: newStatus == PrepStatus.ready
              ? Value(now)
              : const Value.absent(),
          deliveredAt: newStatus == PrepStatus.delivered
              ? Value(now)
              : const Value.absent(),
        ));

        // 3. Stock reversal if cancelled/voided
        if (newStatus == PrepStatus.cancelled || newStatus == PrepStatus.voided) {
          await _reverseStockForSingleItem(
              itemEntity.companyId, itemEntity);
        }

        // 4. Derive order status from all items
        await _deriveOrderStatus(orderId);

        // 5. Enqueue item + order for sync
        final updatedItem = await (_db.select(_db.orderItems)
              ..where((t) => t.id.equals(itemId)))
            .getSingle();
        await _enqueueOrderItem('update', orderItemFromEntity(updatedItem));

        final updatedOrder = await (_db.select(_db.orders)
              ..where((t) => t.id.equals(orderId)))
            .getSingle();
        await _enqueueOrder('update', orderFromEntity(updatedOrder));

        return Success(orderItemFromEntity(updatedItem));
      });
    } catch (e, s) {
      AppLogger.error('Failed to update item status', error: e, stackTrace: s);
      return Failure('Failed to update item status: $e');
    }
  }

  /// Derives Order.status from the statuses of all its items.
  ///
  /// Rules (evaluated in order):
  /// 1. No active items + all voided → voided
  /// 2. No active items + all cancelled → cancelled
  /// 3. No active items + mix → voided
  /// 4. All active items delivered → delivered
  /// 5. All active items ready|delivered → ready
  /// 6. Otherwise → created
  ///
  /// Order-level timestamps are set on first transition to that status.
  Future<void> _deriveOrderStatus(String orderId) async {
    final now = DateTime.now();
    final allItems = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()))
        .get();

    if (allItems.isEmpty) return;

    final activeItems = allItems
        .where((i) =>
            i.status != PrepStatus.voided && i.status != PrepStatus.cancelled)
        .toList();

    PrepStatus derived;
    if (activeItems.isEmpty) {
      // All items are voided or cancelled
      final allVoided = allItems.every((i) => i.status == PrepStatus.voided);
      final allCancelled =
          allItems.every((i) => i.status == PrepStatus.cancelled);
      if (allCancelled) {
        derived = PrepStatus.cancelled;
      } else if (allVoided) {
        derived = PrepStatus.voided;
      } else {
        derived = PrepStatus.voided; // mix
      }
    } else if (activeItems.every((i) => i.status == PrepStatus.delivered)) {
      derived = PrepStatus.delivered;
    } else if (activeItems.every((i) =>
        i.status == PrepStatus.ready || i.status == PrepStatus.delivered)) {
      derived = PrepStatus.ready;
    } else {
      derived = PrepStatus.created;
    }

    // Read current order to set timestamps only on first transition
    final order = await (_db.select(_db.orders)
          ..where((t) => t.id.equals(orderId)))
        .getSingle();

    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        status: Value(derived),
        updatedAt: Value(now),
        prepStartedAt: derived == PrepStatus.created && order.prepStartedAt == null
            ? Value(now)
            : const Value.absent(),
        readyAt: derived == PrepStatus.ready && order.readyAt == null
            ? Value(now)
            : const Value.absent(),
        deliveredAt: derived == PrepStatus.delivered && order.deliveredAt == null
            ? Value(now)
            : const Value.absent(),
      ),
    );

    // Recalculate totals (exclude voided/cancelled items)
    await _recalculateOrderTotals(orderId);
  }

  Future<Result<OrderModel>> voidItem({
    required String orderId,
    required String orderItemId,
    required String companyId,
    required String userId,
    required String stornoOrderNumber,
    String? registerId,
  }) async {
    try {
      final now = DateTime.now();

      // 1. Fetch and validate original item
      final itemEntity = await (_db.select(_db.orderItems)
            ..where((t) => t.id.equals(orderItemId)))
          .getSingle();
      if (itemEntity.status == PrepStatus.voided || itemEntity.status == PrepStatus.cancelled) {
        return const Failure('Item is already voided or cancelled');
      }

      // 2. Fetch original order — validate not storno
      final orderEntity = await (_db.select(_db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      if (orderEntity.isStorno) {
        return const Failure('Cannot void items on storno orders');
      }

      return await _db.transaction(() async {
        // 3. Void original item
        await (_db.update(_db.orderItems)..where((t) => t.id.equals(orderItemId))).write(
          OrderItemsCompanion(
            status: const Value(PrepStatus.voided),
            updatedAt: Value(now),
          ),
        );

        // 4. Stock reversal for this single item
        await _reverseStockForSingleItem(companyId, itemEntity);

        // 5. Create storno order
        final stornoOrderId = const Uuid().v7();
        await _db.into(_db.orders).insert(OrdersCompanion.insert(
          id: stornoOrderId,
          companyId: companyId,
          billId: orderEntity.billId,
          registerId: Value(registerId),
          createdByUserId: userId,
          orderNumber: stornoOrderNumber,
          status: PrepStatus.delivered,
          isStorno: const Value(true),
          stornoSourceOrderId: Value(orderId),
        ));

        // 6. Create storno order item (copy of voided item)
        final stornoItemId = const Uuid().v7();
        await _db.into(_db.orderItems).insert(OrderItemsCompanion.insert(
          id: stornoItemId,
          companyId: companyId,
          orderId: stornoOrderId,
          itemId: itemEntity.itemId,
          itemName: itemEntity.itemName,
          quantity: itemEntity.quantity,
          salePriceAtt: itemEntity.salePriceAtt,
          saleTaxRateAtt: itemEntity.saleTaxRateAtt,
          saleTaxAmount: itemEntity.saleTaxAmount,
          unit: Value(itemEntity.unit),
          status: PrepStatus.delivered,
        ));

        // 6b. Copy modifiers from voided item to storno item
        final voidedMods = await (_db.select(_db.orderItemModifiers)
              ..where((t) => t.orderItemId.equals(orderItemId) & t.deletedAt.isNull()))
            .get();
        for (final mod in voidedMods) {
          final stornoModId = const Uuid().v7();
          await _db.into(_db.orderItemModifiers).insert(
            OrderItemModifiersCompanion.insert(
              id: stornoModId,
              companyId: companyId,
              orderItemId: stornoItemId,
              modifierItemId: mod.modifierItemId,
              modifierGroupId: mod.modifierGroupId,
              modifierItemName: Value(mod.modifierItemName),
              quantity: Value(mod.quantity),
              unitPrice: mod.unitPrice,
              taxRate: mod.taxRate,
              taxAmount: mod.taxAmount,
            ),
          );
          if (orderItemModifierRepo != null) {
            final modModel = OrderItemModifierModel(
              id: stornoModId,
              companyId: companyId,
              orderItemId: stornoItemId,
              modifierItemId: mod.modifierItemId,
              modifierGroupId: mod.modifierGroupId,
              modifierItemName: mod.modifierItemName,
              quantity: mod.quantity,
              unitPrice: mod.unitPrice,
              taxRate: mod.taxRate,
              taxAmount: mod.taxAmount,
              createdAt: now,
              updatedAt: now,
            );
            await syncQueueRepo?.enqueue(
              companyId: companyId,
              entityType: 'order_item_modifiers',
              entityId: stornoModId,
              operation: 'insert',
              payload: jsonEncode(orderItemModifierToSupabaseJson(modModel)),
            );
          }
        }

        // 7. Update storno order totals (including modifiers)
        int itemSubtotal = (itemEntity.salePriceAtt * itemEntity.quantity).round();
        int itemTax = (itemEntity.saleTaxAmount * itemEntity.quantity).round();
        for (final mod in voidedMods) {
          itemSubtotal += (mod.unitPrice * mod.quantity * itemEntity.quantity).round();
          itemTax += (mod.taxAmount * mod.quantity * itemEntity.quantity).round();
        }
        await (_db.update(_db.orders)..where((t) => t.id.equals(stornoOrderId))).write(
          OrdersCompanion(
            itemCount: const Value(1),
            subtotalGross: Value(itemSubtotal),
            subtotalNet: Value(itemSubtotal - itemTax),
            taxTotal: Value(itemTax),
            deliveredAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        // 8. Recalculate original order totals (exclude voided items)
        await _recalculateOrderTotals(orderId);

        // 9. Auto-void order if all items voided
        await _autoVoidOrderIfEmpty(orderId);

        // 10. Enqueue sync: voided item, storno order, storno item, original order
        final updatedItem = await (_db.select(_db.orderItems)..where((t) => t.id.equals(orderItemId))).getSingle();
        await _enqueueOrderItem('update', orderItemFromEntity(updatedItem));

        final stornoOrder = await (_db.select(_db.orders)..where((t) => t.id.equals(stornoOrderId))).getSingle();
        await _enqueueOrder('insert', orderFromEntity(stornoOrder));

        final stornoItem = await (_db.select(_db.orderItems)..where((t) => t.id.equals(stornoItemId))).getSingle();
        await _enqueueOrderItem('insert', orderItemFromEntity(stornoItem));

        final updatedOrder = await (_db.select(_db.orders)..where((t) => t.id.equals(orderId))).getSingle();
        await _enqueueOrder('update', orderFromEntity(updatedOrder));

        return Success(orderFromEntity(updatedOrder));
      });
    } catch (e, s) {
      AppLogger.error('Failed to void item', error: e, stackTrace: s);
      return Failure('Failed to void item: $e');
    }
  }

  /// Watch all orders for a company (optionally filtered by time range)
  Stream<List<OrderModel>> watchByCompany(String companyId, {DateTime? since}) {
    var query = _db.select(_db.orders)
      ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
    if (since != null) {
      query = query..where((t) => t.createdAt.isBiggerOrEqualValue(since));
    }
    query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(orderFromEntity).toList());
  }

  Future<List<OrderModel>> getByCompanyInRange(String companyId, DateTime from, DateTime to) async {
    final entities = await (_db.select(_db.orders)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.createdAt.isBiggerOrEqualValue(from) &
              t.createdAt.isSmallerOrEqualValue(to) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return entities.map(orderFromEntity).toList();
  }

  Future<Result<void>> updateOrderNotes(String orderId, String? notes) async {
    try {
      return await _db.transaction(() async {
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
      });
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
      return await _db.transaction(() async {
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
      });
    } catch (e, s) {
      AppLogger.error('Failed to update item discount', error: e, stackTrace: s);
      return Failure('Failed to update item discount: $e');
    }
  }

  Future<Result<void>> updateItemNotes(String itemId, String? notes) async {
    try {
      return await _db.transaction(() async {
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
      });
    } catch (e, s) {
      AppLogger.error('Failed to update item notes', error: e, stackTrace: s);
      return Failure('Failed to update item notes: $e');
    }
  }

  Future<Result<void>> reassignOrdersToBill(String sourceBillId, String targetBillId) async {
    try {
      final orders = await (_db.select(_db.orders)
            ..where((t) => t.billId.equals(sourceBillId) & t.deletedAt.isNull()))
          .get();
      final now = DateTime.now();
      await _db.transaction(() async {
        for (final order in orders) {
          await (_db.update(_db.orders)..where((t) => t.id.equals(order.id))).write(
            OrdersCompanion(
              billId: Value(targetBillId),
              updatedAt: Value(now),
            ),
          );
          final entity = await (_db.select(_db.orders)
                ..where((t) => t.id.equals(order.id)))
              .getSingle();
          await _enqueueOrder('update', orderFromEntity(entity));
        }
      });
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to reassign orders to bill', error: e, stackTrace: s);
      return Failure('Failed to reassign orders to bill: $e');
    }
  }

  Future<Result<void>> splitItemsToNewOrder({
    required String targetBillId,
    required String companyId,
    required String userId,
    required List<({String orderItemId, double moveQuantity})> splitItems,
    String? registerId,
  }) async {
    try {
      final now = DateTime.now();
      final newOrderId = const Uuid().v7();

      // Collect source order IDs before moving items (single batch query)
      final splitItemIds = splitItems.map((e) => e.orderItemId).toList();
      final itemEntities = await (_db.select(_db.orderItems)
            ..where((t) => t.id.isIn(splitItemIds)))
          .get();
      final sourceOrderIds = itemEntities.map((e) => e.orderId).toSet();

      await _db.transaction(() async {
        // Create new order on target bill
        await _db.into(_db.orders).insert(OrdersCompanion.insert(
          id: newOrderId,
          companyId: companyId,
          billId: targetBillId,
          createdByUserId: userId,
          orderNumber: 'S-${now.millisecondsSinceEpoch}',
          status: PrepStatus.delivered,
          registerId: Value(registerId),
        ));

        int subtotalGross = 0;
        int taxTotal = 0;
        int newItemCount = 0;
        final itemMap = {for (final e in itemEntities) e.id: e};

        for (final split in splitItems) {
          final original = itemMap[split.orderItemId]!;

          if (split.moveQuantity >= original.quantity) {
            // === FULL MOVE === (existing logic)
            await (_db.update(_db.orderItems)..where((t) => t.id.equals(split.orderItemId))).write(
              OrderItemsCompanion(orderId: Value(newOrderId), updatedAt: Value(now)),
            );
            final movedModel = orderItemFromEntity(original).copyWith(
              orderId: newOrderId,
              updatedAt: now,
            );
            await _enqueueOrderItem('update', movedModel);

            final itemSubtotal = (original.salePriceAtt * original.quantity).round();
            final itemTax = (original.saleTaxAmount * original.quantity).round();
            subtotalGross += itemSubtotal;
            taxTotal += itemTax;
          } else {
            // === PARTIAL SPLIT === (new)

            // 1. Reduce original quantity
            final newOrigQty = original.quantity - split.moveQuantity;
            await (_db.update(_db.orderItems)
              ..where((t) => t.id.equals(split.orderItemId))
            ).write(OrderItemsCompanion(
              quantity: Value(newOrigQty),
              updatedAt: Value(now),
            ));
            final updatedOriginal = orderItemFromEntity(
              await (_db.select(_db.orderItems)
                ..where((t) => t.id.equals(split.orderItemId))
              ).getSingle()
            );
            await _enqueueOrderItem('update', updatedOriginal);

            // 2. Create clone on new order
            final cloneId = const Uuid().v7();
            // Discount rule: % -> copy, absolute -> stays on original
            final cloneDiscount = original.discountType == DiscountType.percent
                ? original.discount : 0;
            final cloneDiscountType = original.discountType == DiscountType.percent
                ? Value(original.discountType) : const Value<DiscountType?>(null);

            await _db.into(_db.orderItems).insert(OrderItemsCompanion.insert(
              id: cloneId,
              companyId: companyId,
              orderId: newOrderId,
              itemId: original.itemId,
              itemName: original.itemName,
              quantity: split.moveQuantity,
              salePriceAtt: original.salePriceAtt,
              saleTaxRateAtt: original.saleTaxRateAtt,
              saleTaxAmount: original.saleTaxAmount,
              unit: Value(original.unit),
              discount: Value(cloneDiscount),
              discountType: cloneDiscountType,
              notes: Value(original.notes),
              status: PrepStatus.delivered,
            ));
            final cloneModel = orderItemFromEntity(
              await (_db.select(_db.orderItems)
                ..where((t) => t.id.equals(cloneId))
              ).getSingle()
            );
            await _enqueueOrderItem('insert', cloneModel);

            // 3. Clone modifiers (follow storno pattern)
            final mods = await (_db.select(_db.orderItemModifiers)
              ..where((t) => t.orderItemId.equals(split.orderItemId) & t.deletedAt.isNull())
            ).get();
            for (final mod in mods) {
              final modCloneId = const Uuid().v7();
              await _db.into(_db.orderItemModifiers).insert(
                OrderItemModifiersCompanion.insert(
                  id: modCloneId,
                  companyId: companyId,
                  orderItemId: cloneId,
                  modifierItemId: mod.modifierItemId,
                  modifierGroupId: mod.modifierGroupId,
                  modifierItemName: Value(mod.modifierItemName),
                  quantity: Value(mod.quantity),
                  unitPrice: mod.unitPrice,
                  taxRate: mod.taxRate,
                  taxAmount: mod.taxAmount,
                ),
              );
              await syncQueueRepo?.enqueue(
                companyId: companyId,
                entityType: 'order_item_modifiers',
                entityId: modCloneId,
                operation: 'insert',
                payload: jsonEncode(orderItemModifierToSupabaseJson(
                  OrderItemModifierModel(
                    id: modCloneId,
                    companyId: companyId,
                    orderItemId: cloneId,
                    modifierItemId: mod.modifierItemId,
                    modifierGroupId: mod.modifierGroupId,
                    modifierItemName: mod.modifierItemName,
                    quantity: mod.quantity,
                    unitPrice: mod.unitPrice,
                    taxRate: mod.taxRate,
                    taxAmount: mod.taxAmount,
                    createdAt: now,
                    updatedAt: now,
                  ),
                )),
              );
            }

            final moveQty = split.moveQuantity.clamp(0.0, original.quantity);
            final itemSubtotal = (original.salePriceAtt * moveQty).round();
            final itemTax = (original.saleTaxAmount * moveQty).round();
            subtotalGross += itemSubtotal;
            taxTotal += itemTax;
          }
          newItemCount++;
        }

        // Update new order totals
        final subtotalNet = subtotalGross - taxTotal;
        await (_db.update(_db.orders)..where((t) => t.id.equals(newOrderId))).write(
          OrdersCompanion(
            itemCount: Value(newItemCount),
            subtotalGross: Value(subtotalGross),
            subtotalNet: Value(subtotalNet),
            taxTotal: Value(taxTotal),
            updatedAt: Value(now),
          ),
        );

        // Enqueue new order
        final newOrderEntity = await (_db.select(_db.orders)
              ..where((t) => t.id.equals(newOrderId)))
            .getSingle();
        await _enqueueOrder('insert', orderFromEntity(newOrderEntity));

        // Check source orders: if any order lost ALL active items, cancel it
        for (final sourceOrderId in sourceOrderIds) {
          final remainingItems = await (_db.select(_db.orderItems)
                ..where((t) =>
                    t.orderId.equals(sourceOrderId) &
                    t.deletedAt.isNull() &
                    t.status.isNotIn([PrepStatus.cancelled.name, PrepStatus.voided.name])))
              .get();
          // Also exclude items with 0 quantity (shouldn't happen, but defensive)
          final activeRemaining = remainingItems.where((i) => i.quantity > 0).toList();
          if (activeRemaining.isEmpty) {
            await (_db.update(_db.orders)..where((t) => t.id.equals(sourceOrderId))).write(
              OrdersCompanion(
                status: const Value(PrepStatus.cancelled),
                itemCount: const Value(0),
                subtotalGross: const Value(0),
                subtotalNet: const Value(0),
                taxTotal: const Value(0),
                updatedAt: Value(now),
              ),
            );
            final entity = await (_db.select(_db.orders)
                  ..where((t) => t.id.equals(sourceOrderId)))
                .getSingle();
            await _enqueueOrder('update', orderFromEntity(entity));
          } else {
            // Recalculate source order totals
            int srcGross = 0;
            int srcTax = 0;
            for (final item in activeRemaining) {
              srcGross += (item.salePriceAtt * item.quantity).round();
              srcTax += (item.saleTaxAmount * item.quantity).round();
            }
            await (_db.update(_db.orders)..where((t) => t.id.equals(sourceOrderId))).write(
              OrdersCompanion(
                itemCount: Value(activeRemaining.length),
                subtotalGross: Value(srcGross),
                subtotalNet: Value(srcGross - srcTax),
                taxTotal: Value(srcTax),
                updatedAt: Value(now),
              ),
            );
            final entity = await (_db.select(_db.orders)
                  ..where((t) => t.id.equals(sourceOrderId)))
                .getSingle();
            await _enqueueOrder('update', orderFromEntity(entity));
          }
        }
      });
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to split items to new order', error: e, stackTrace: s);
      return Failure('Failed to split items to new order: $e');
    }
  }

  /// Reverses stock for a single order item (used by voidItem).
  Future<void> _reverseStockForSingleItem(String companyId, OrderItem item) async {
    if (stockLevelRepo == null || stockMovementRepo == null) return;

    final warehouse = await (_db.select(_db.warehouses)
          ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (warehouse == null) return;

    final itemDef = await (_db.select(_db.items)
          ..where((t) => t.id.equals(item.itemId)))
        .getSingleOrNull();
    if (itemDef == null || !itemDef.isStockTracked) return;

    if (itemDef.itemType == ItemType.recipe) {
      final recipes = await (_db.select(_db.productRecipes)
            ..where((t) => t.parentProductId.equals(itemDef.id) & t.deletedAt.isNull()))
          .get();
      for (final recipe in recipes) {
        final componentQty = recipe.quantityRequired * item.quantity;
        await _createStockMovement(
          companyId: companyId,
          warehouseId: warehouse.id,
          itemId: recipe.componentProductId,
          quantity: componentQty,
          direction: StockMovementDirection.inbound,
        );
      }
    } else {
      await _createStockMovement(
        companyId: companyId,
        warehouseId: warehouse.id,
        itemId: itemDef.id,
        quantity: item.quantity,
        direction: StockMovementDirection.inbound,
      );
    }
  }

  /// Recalculates order totals excluding voided/cancelled items.
  Future<void> _recalculateOrderTotals(String orderId) async {
    final items = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()
              & t.status.isNotIn([PrepStatus.cancelled.name, PrepStatus.voided.name])))
        .get();
    // Load modifiers for these items
    final itemIds = items.map((i) => i.id).toList();
    final allMods = itemIds.isEmpty
        ? <OrderItemModifier>[]
        : await (_db.select(_db.orderItemModifiers)
              ..where((t) => t.orderItemId.isIn(itemIds) & t.deletedAt.isNull()))
            .get();
    final modsByItem = <String, List<OrderItemModifier>>{};
    for (final mod in allMods) {
      modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
    }

    int gross = 0, tax = 0;
    for (final item in items) {
      gross += (item.salePriceAtt * item.quantity).round();
      tax += (item.saleTaxAmount * item.quantity).round();
      for (final mod in modsByItem[item.id] ?? <OrderItemModifier>[]) {
        gross += (mod.unitPrice * mod.quantity * item.quantity).round();
        tax += (mod.taxAmount * mod.quantity * item.quantity).round();
      }
    }
    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        itemCount: Value(items.length),
        subtotalGross: Value(gross),
        subtotalNet: Value(gross - tax),
        taxTotal: Value(tax),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Auto-voids an order if all its items are voided/cancelled.
  Future<void> _autoVoidOrderIfEmpty(String orderId) async {
    final activeItems = await (_db.select(_db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()
              & t.status.isNotIn([PrepStatus.cancelled.name, PrepStatus.voided.name])))
        .get();
    if (activeItems.isEmpty) {
      final now = DateTime.now();
      await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          status: const Value(PrepStatus.voided),
          itemCount: const Value(0),
          subtotalGross: const Value(0),
          subtotalNet: const Value(0),
          taxTotal: const Value(0),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Deducts stock for each stock-tracked item in the order.
  /// For recipes: decomposes into ingredients and deducts those.
  Future<void> _deductStockForOrder(
    String companyId,
    List<OrderItemInput> items,
  ) async {
    if (stockLevelRepo == null || stockMovementRepo == null) return;

    // Get default warehouse
    final warehouse = await (_db.select(_db.warehouses)
          ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (warehouse == null) return; // No warehouse yet, skip deduction

    for (final orderItem in items) {
      final item = await (_db.select(_db.items)
            ..where((t) => t.id.equals(orderItem.itemId)))
          .getSingleOrNull();
      if (item == null || !item.isStockTracked) continue;

      if (item.itemType == ItemType.recipe) {
        // Decompose recipe into ingredients
        final recipes = await (_db.select(_db.productRecipes)
              ..where((t) => t.parentProductId.equals(item.id) & t.deletedAt.isNull()))
            .get();
        for (final recipe in recipes) {
          final componentQty = recipe.quantityRequired * orderItem.quantity;
          await _createStockMovement(
            companyId: companyId,
            warehouseId: warehouse.id,
            itemId: recipe.componentProductId,
            quantity: componentQty,
            direction: StockMovementDirection.outbound,
          );
        }
      } else {
        await _createStockMovement(
          companyId: companyId,
          warehouseId: warehouse.id,
          itemId: item.id,
          quantity: orderItem.quantity,
          direction: StockMovementDirection.outbound,
        );
      }
    }
  }

  /// Reverses stock deduction when an order is cancelled or voided.
  Future<void> _reverseStockForOrder(
    String companyId,
    List<OrderItem> orderItemEntities,
  ) async {
    if (stockLevelRepo == null || stockMovementRepo == null) return;

    final warehouse = await (_db.select(_db.warehouses)
          ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (warehouse == null) return;

    for (final orderItem in orderItemEntities) {
      final item = await (_db.select(_db.items)
            ..where((t) => t.id.equals(orderItem.itemId)))
          .getSingleOrNull();
      if (item == null || !item.isStockTracked) continue;

      if (item.itemType == ItemType.recipe) {
        final recipes = await (_db.select(_db.productRecipes)
              ..where((t) => t.parentProductId.equals(item.id) & t.deletedAt.isNull()))
            .get();
        for (final recipe in recipes) {
          final componentQty = recipe.quantityRequired * orderItem.quantity;
          await _createStockMovement(
            companyId: companyId,
            warehouseId: warehouse.id,
            itemId: recipe.componentProductId,
            quantity: componentQty,
            direction: StockMovementDirection.inbound, // reverse
          );
        }
      } else {
        await _createStockMovement(
          companyId: companyId,
          warehouseId: warehouse.id,
          itemId: item.id,
          quantity: orderItem.quantity,
          direction: StockMovementDirection.inbound, // reverse
        );
      }
    }
  }

  /// Creates a stock movement (no document) and adjusts stock level.
  Future<void> _createStockMovement({
    required String companyId,
    required String warehouseId,
    required String itemId,
    required double quantity,
    required StockMovementDirection direction,
  }) async {
    final now = DateTime.now();
    final movementId = const Uuid().v7();

    final movement = StockMovementModel(
      id: movementId,
      companyId: companyId,
      itemId: itemId,
      quantity: quantity,
      direction: direction,
      createdAt: now,
      updatedAt: now,
    );

    final movementResult = await stockMovementRepo!.createMovement(movement);
    if (movementResult case Failure(:final message)) {
      throw Exception(message);
    }

    final delta = direction == StockMovementDirection.inbound ? quantity : -quantity;
    await stockLevelRepo!.adjustQuantity(
      companyId: companyId,
      warehouseId: warehouseId,
      itemId: itemId,
      delta: delta,
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
}

class OrderItemInput {
  const OrderItemInput({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.salePriceAtt,
    required this.saleTaxRateAtt,
    required this.saleTaxAmount,
    this.unit = UnitType.ks,
    this.notes,
    this.modifiers = const [],
  });

  final String itemId;
  final String itemName;
  final double quantity;
  final int salePriceAtt;
  final int saleTaxRateAtt;
  final int saleTaxAmount;
  final UnitType unit;
  final String? notes;
  final List<OrderItemModifierInput> modifiers;
}

class OrderItemModifierInput {
  const OrderItemModifierInput({
    required this.modifierItemId,
    required this.modifierItemName,
    required this.modifierGroupId,
    this.quantity = 1.0,
    required this.unitPrice,
    required this.taxRate,
    required this.taxAmount,
  });

  final String modifierItemId;
  final String modifierItemName;
  final String modifierGroupId;
  final double quantity;
  final int unitPrice;
  final int taxRate;
  final int taxAmount;
}
