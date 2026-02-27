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
  Future<Result<StockLevelModel>> getOrCreate({
    required String companyId,
    required String warehouseId,
    required String itemId,
  }) async {
    try {
      final entity = await (_db.select(_db.stockLevels)
            ..where((t) =>
                t.companyId.equals(companyId) &
                t.warehouseId.equals(warehouseId) &
                t.itemId.equals(itemId) &
                t.deletedAt.isNull()))
          .getSingleOrNull();

      if (entity != null) return Success(stockLevelFromEntity(entity));

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

      await _db.transaction(() async {
        await _db.into(_db.stockLevels).insert(stockLevelToCompanion(model));
        await _enqueue('insert', model);
      });
      return Success(model);
    } catch (e, s) {
      AppLogger.error('Failed to get or create stock level', error: e, stackTrace: s);
      return Failure('Failed to get or create stock level: $e');
    }
  }

  /// Adjusts quantity by a delta (positive = add, negative = subtract).
  Future<Result<StockLevelModel>> adjustQuantity({
    required String companyId,
    required String warehouseId,
    required String itemId,
    required double delta,
  }) async {
    try {
      return await _db.transaction(() async {
        final getResult = await getOrCreate(
          companyId: companyId,
          warehouseId: warehouseId,
          itemId: itemId,
        );
        switch (getResult) {
          case Failure(:final message):
            return Failure(message);
          case Success(value: final level):
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
        }
      });
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
      final getResult = await getOrCreate(
        companyId: companyId,
        warehouseId: warehouseId,
        itemId: itemId,
      );
      switch (getResult) {
        case Failure(:final message):
          return Failure(message);
        case Success(value: final level):
          return await _db.transaction(() async {
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
          });
      }
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
      final getResult = await getOrCreate(
        companyId: companyId,
        warehouseId: warehouseId,
        itemId: itemId,
      );
      switch (getResult) {
        case Failure(:final message):
          return Failure(message);
        case Success(value: final level):
          return await _db.transaction(() async {
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
          });
      }
    } catch (e, s) {
      AppLogger.error('Failed to set min quantity', error: e, stackTrace: s);
      return Failure('Failed to set min quantity: $e');
    }
  }

  /// Watches all stock level quantities for a warehouse (itemId → quantity).
  /// Unlike [watchByWarehouse], does NOT filter by isStockTracked — returns
  /// every stock_levels row for the warehouse so variants inherit parent tracking.
  Stream<Map<String, double>> watchStockMap(String companyId, String warehouseId) {
    final query = _db.select(_db.stockLevels)
      ..where((t) =>
          t.companyId.equals(companyId) &
          t.warehouseId.equals(warehouseId) &
          t.deletedAt.isNull());
    return query.watch().map((rows) {
      final map = <String, double>{};
      for (final row in rows) {
        map[row.itemId] = row.quantity;
      }
      return map;
    });
  }

  /// Watches all stock-tracked items for a warehouse, with stock levels via LEFT JOIN.
  Stream<List<StockLevelWithItem>> watchByWarehouse(String companyId, String warehouseId) {
    final query = _db.select(_db.items).join([
      leftOuterJoin(
        _db.stockLevels,
        _db.stockLevels.itemId.equalsExp(_db.items.id) &
            _db.stockLevels.warehouseId.equals(warehouseId) &
            _db.stockLevels.deletedAt.isNull(),
      ),
    ])
      ..where(
        _db.items.companyId.equals(companyId) &
        _db.items.isStockTracked.equals(true) &
        _db.items.deletedAt.isNull(),
      )
      ..orderBy([OrderingTerm.asc(_db.items.name)]);

    return query.watch().map((rows) => rows.map((row) {
          final item = row.readTable(_db.items);
          final level = row.readTableOrNull(_db.stockLevels);
          return StockLevelWithItem(
            stockLevel: level != null ? stockLevelFromEntity(level) : null,
            itemId: item.id,
            itemName: item.name,
            unit: item.unit,
            purchasePrice: item.purchasePrice,
            quantity: level?.quantity ?? 0.0,
            minQuantity: item.minQuantity,
            categoryId: item.categoryId,
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
    this.stockLevel,
    required this.itemId,
    required this.itemName,
    required this.unit,
    this.purchasePrice,
    required this.quantity,
    this.minQuantity,
    this.categoryId,
  });

  final StockLevelModel? stockLevel;
  final String itemId;
  final String itemName;
  final UnitType unit;
  final int? purchasePrice;
  final double quantity;
  final double? minQuantity;
  final String? categoryId;
}
