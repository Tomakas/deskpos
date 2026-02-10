import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/unit_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/stock_level_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class StockLevelRepository {
  StockLevelRepository(this._db, {required this.syncQueueRepo});

  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  /// Gets or lazily creates a stock level for an item in a warehouse.
  Future<StockLevelModel> getOrCreate({
    required String companyId,
    required String warehouseId,
    required String itemId,
  }) async {
    final entity = await (_db.select(_db.stockLevels)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.warehouseId.equals(warehouseId) &
              t.itemId.equals(itemId) &
              t.deletedAt.isNull()))
        .getSingleOrNull();

    if (entity != null) return stockLevelFromEntity(entity);

    // Lazy init
    final now = DateTime.now();
    final model = StockLevelModel(
      id: const Uuid().v7(),
      companyId: companyId,
      warehouseId: warehouseId,
      itemId: itemId,
      quantity: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    await _db.into(_db.stockLevels).insert(stockLevelToCompanion(model));
    await _enqueue('insert', model);
    return model;
  }

  /// Adjusts quantity by a delta (positive = add, negative = subtract).
  Future<Result<StockLevelModel>> adjustQuantity({
    required String companyId,
    required String warehouseId,
    required String itemId,
    required double delta,
  }) async {
    try {
      final level = await getOrCreate(
        companyId: companyId,
        warehouseId: warehouseId,
        itemId: itemId,
      );

      final now = DateTime.now();
      final newQuantity = level.quantity + delta;

      await (_db.update(_db.stockLevels)..where((t) => t.id.equals(level.id))).write(
        StockLevelsCompanion(
          quantity: Value(newQuantity),
          updatedAt: Value(now),
        ),
      );

      final updated = level.copyWith(quantity: newQuantity, updatedAt: now);
      await _enqueue('update', updated);
      return Success(updated);
    } catch (e, s) {
      AppLogger.error('Failed to adjust stock level', error: e, stackTrace: s);
      return Failure('Failed to adjust stock level: $e');
    }
  }

  /// Sets absolute quantity for a stock level.
  Future<Result<StockLevelModel>> setQuantity({
    required String companyId,
    required String warehouseId,
    required String itemId,
    required double quantity,
  }) async {
    try {
      final level = await getOrCreate(
        companyId: companyId,
        warehouseId: warehouseId,
        itemId: itemId,
      );

      final now = DateTime.now();

      await (_db.update(_db.stockLevels)..where((t) => t.id.equals(level.id))).write(
        StockLevelsCompanion(
          quantity: Value(quantity),
          updatedAt: Value(now),
        ),
      );

      final updated = level.copyWith(quantity: quantity, updatedAt: now);
      await _enqueue('update', updated);
      return Success(updated);
    } catch (e, s) {
      AppLogger.error('Failed to set stock level', error: e, stackTrace: s);
      return Failure('Failed to set stock level: $e');
    }
  }

  /// Sets min_quantity for a stock level.
  Future<Result<StockLevelModel>> setMinQuantity({
    required String companyId,
    required String warehouseId,
    required String itemId,
    required double? minQuantity,
  }) async {
    try {
      final level = await getOrCreate(
        companyId: companyId,
        warehouseId: warehouseId,
        itemId: itemId,
      );

      final now = DateTime.now();

      await (_db.update(_db.stockLevels)..where((t) => t.id.equals(level.id))).write(
        StockLevelsCompanion(
          minQuantity: Value(minQuantity),
          updatedAt: Value(now),
        ),
      );

      final updated = level.copyWith(minQuantity: minQuantity, updatedAt: now);
      await _enqueue('update', updated);
      return Success(updated);
    } catch (e, s) {
      AppLogger.error('Failed to set min quantity', error: e, stackTrace: s);
      return Failure('Failed to set min quantity: $e');
    }
  }

  /// Watches all stock levels for a warehouse with item info via JOIN.
  Stream<List<StockLevelWithItem>> watchByWarehouse(String companyId, String warehouseId) {
    final query = _db.select(_db.stockLevels).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.stockLevels.itemId)),
    ])
      ..where(_db.stockLevels.companyId.equals(companyId) &
          _db.stockLevels.warehouseId.equals(warehouseId) &
          _db.stockLevels.deletedAt.isNull() &
          _db.items.deletedAt.isNull() &
          _db.items.isStockTracked.equals(true));

    return query.watch().map((rows) => rows.map((row) {
          final level = stockLevelFromEntity(row.readTable(_db.stockLevels));
          final item = row.readTable(_db.items);
          return StockLevelWithItem(
            stockLevel: level,
            itemName: item.name,
            unit: item.unit,
            purchasePrice: item.purchasePrice,
          );
        }).toList());
  }

  Future<void> _enqueue(String operation, StockLevelModel model) async {
    if (syncQueueRepo == null) return;
    final json = stockLevelToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'stock_levels',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

/// A stock level combined with item information for display.
class StockLevelWithItem {
  StockLevelWithItem({
    required this.stockLevel,
    required this.itemName,
    required this.unit,
    this.purchasePrice,
  });

  final StockLevelModel stockLevel;
  final String itemName;
  final UnitType unit;
  final int? purchasePrice;
}
