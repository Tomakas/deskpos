import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/purchase_price_strategy.dart';
import '../enums/stock_document_type.dart';
import '../enums/stock_movement_direction.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/stock_document_model.dart';
import '../models/stock_movement_model.dart';
import '../result.dart';
import 'stock_level_repository.dart';
import 'stock_movement_repository.dart';
import 'sync_queue_repository.dart';

/// Input for a single item line in a stock document.
class StockDocumentLine {
  StockDocumentLine({
    required this.itemId,
    required this.quantity,
    this.purchasePrice,
    this.purchasePriceStrategy,
  });

  final String itemId;
  final double quantity;
  final int? purchasePrice;
  final PurchasePriceStrategy? purchasePriceStrategy; // per-item override
}

class StockDocumentRepository {
  StockDocumentRepository(
    this._db, {
    required this.syncQueueRepo,
    required this.stockLevelRepo,
    required this.stockMovementRepo,
  });

  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;
  final StockLevelRepository stockLevelRepo;
  final StockMovementRepository stockMovementRepo;

  /// Creates a stock document with movements and adjusts stock levels.
  ///
  /// For receipts: direction = inbound, applies purchase price strategy.
  /// For waste/correction: direction = outbound (waste) or depends on sign (correction).
  Future<Result<StockDocumentModel>> createDocument({
    required String companyId,
    required String warehouseId,
    required String userId,
    required StockDocumentType type,
    PurchasePriceStrategy? documentStrategy,
    String? supplierId,
    String? note,
    required List<StockDocumentLine> lines,
  }) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        final docId = const Uuid().v7();
        final docNumber = await _generateDocumentNumber(companyId, type);

        // Determine direction based on document type
        final direction = type == StockDocumentType.receipt
            ? StockMovementDirection.inbound
            : StockMovementDirection.outbound;

        int totalAmount = 0;

        // Create the document
        final docModel = StockDocumentModel(
          id: docId,
          companyId: companyId,
          warehouseId: warehouseId,
          supplierId: supplierId,
          userId: userId,
          documentNumber: docNumber,
          type: type,
          purchasePriceStrategy: documentStrategy,
          note: note,
          totalAmount: 0, // will update after processing lines
          documentDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await _db.into(_db.stockDocuments).insert(stockDocumentToCompanion(docModel));

        // Process each line
        for (final line in lines) {
          final movementId = const Uuid().v7();
          final effectiveStrategy = line.purchasePriceStrategy ?? documentStrategy;

          final movement = StockMovementModel(
            id: movementId,
            companyId: companyId,
            stockDocumentId: docId,
            itemId: line.itemId,
            quantity: line.quantity,
            purchasePrice: line.purchasePrice,
            direction: direction,
            purchasePriceStrategy: effectiveStrategy,
            createdAt: now,
            updatedAt: now,
          );

          final movementResult = await stockMovementRepo.createMovement(movement);
          if (movementResult case Failure(:final message)) {
            throw Exception(message);
          }

          // Adjust stock level
          final delta = direction == StockMovementDirection.inbound
              ? line.quantity
              : -line.quantity;
          await stockLevelRepo.adjustQuantity(
            companyId: companyId,
            warehouseId: warehouseId,
            itemId: line.itemId,
            delta: delta,
          );

          // Apply purchase price strategy for receipts
          if (type == StockDocumentType.receipt && line.purchasePrice != null) {
            await _applyPurchasePriceStrategy(
              companyId: companyId,
              itemId: line.itemId,
              newPrice: line.purchasePrice!,
              quantity: line.quantity,
              strategy: effectiveStrategy ?? PurchasePriceStrategy.overwrite,
            );
          }

          // Accumulate total
          if (line.purchasePrice != null) {
            totalAmount += (line.purchasePrice! * line.quantity).round();
          }
        }

        // Update document total
        await (_db.update(_db.stockDocuments)..where((t) => t.id.equals(docId))).write(
          StockDocumentsCompanion(
            totalAmount: Value(totalAmount),
            updatedAt: Value(now),
          ),
        );

        final finalDoc = docModel.copyWith(totalAmount: totalAmount);
        await _enqueue('insert', finalDoc);

        return Success(finalDoc);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create stock document', error: e, stackTrace: s);
      return Failure('Failed to create stock document: $e');
    }
  }

  /// Creates an inventory document: processes differences between expected and actual quantities.
  Future<Result<StockDocumentModel>> createInventoryDocument({
    required String companyId,
    required String warehouseId,
    required String userId,
    required List<InventoryLine> inventoryLines,
    String? note,
  }) async {
    // Convert inventory lines to document lines with direction based on difference
    final lines = <StockDocumentLine>[];
    for (final inv in inventoryLines) {
      final diff = inv.actualQuantity - inv.currentQuantity;
      if (diff == 0) continue; // No change, skip

      lines.add(StockDocumentLine(
        itemId: inv.itemId,
        quantity: diff.abs(),
        purchasePrice: inv.purchasePrice,
      ));
    }

    if (lines.isEmpty) {
      return const Failure('No differences found');
    }

    // For inventory, we create movements directly since direction varies per line
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        final docId = const Uuid().v7();
        final docNumber = await _generateDocumentNumber(companyId, StockDocumentType.inventory);

        final docModel = StockDocumentModel(
          id: docId,
          companyId: companyId,
          warehouseId: warehouseId,
          userId: userId,
          documentNumber: docNumber,
          type: StockDocumentType.inventory,
          note: note,
          totalAmount: 0,
          documentDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await _db.into(_db.stockDocuments).insert(stockDocumentToCompanion(docModel));

        for (final inv in inventoryLines) {
          final diff = inv.actualQuantity - inv.currentQuantity;
          if (diff == 0) continue;

          final movementId = const Uuid().v7();
          final direction = diff > 0
              ? StockMovementDirection.inbound
              : StockMovementDirection.outbound;

          final movement = StockMovementModel(
            id: movementId,
            companyId: companyId,
            stockDocumentId: docId,
            itemId: inv.itemId,
            quantity: diff.abs(),
            purchasePrice: inv.purchasePrice,
            direction: direction,
            createdAt: now,
            updatedAt: now,
          );

          final movementResult = await stockMovementRepo.createMovement(movement);
          if (movementResult case Failure(:final message)) {
            throw Exception(message);
          }

          // Set absolute quantity (inventory sets the truth)
          await stockLevelRepo.setQuantity(
            companyId: companyId,
            warehouseId: warehouseId,
            itemId: inv.itemId,
            quantity: inv.actualQuantity,
          );
        }

        await _enqueue('insert', docModel);
        return Success(docModel);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create inventory document', error: e, stackTrace: s);
      return Failure('Failed to create inventory document: $e');
    }
  }

  /// Watches stock documents for a warehouse, ordered by date descending.
  Stream<List<StockDocumentModel>> watchByWarehouse(String companyId, String warehouseId) {
    return (_db.select(_db.stockDocuments)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.warehouseId.equals(warehouseId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.documentDate)]))
        .watch()
        .map((rows) => rows.map(stockDocumentFromEntity).toList());
  }

  /// Generates document number: R-001, W-001, I-001, C-001.
  Future<String> _generateDocumentNumber(String companyId, StockDocumentType type) async {
    final prefix = switch (type) {
      StockDocumentType.receipt => 'R',
      StockDocumentType.waste => 'W',
      StockDocumentType.inventory => 'I',
      StockDocumentType.correction => 'C',
    };

    final count = await (_db.selectOnly(_db.stockDocuments)
          ..addColumns([_db.stockDocuments.id.count()])
          ..where(_db.stockDocuments.companyId.equals(companyId) &
              _db.stockDocuments.type.equals(type.name)))
        .map((row) => row.read(_db.stockDocuments.id.count()) ?? 0)
        .getSingle();

    final number = (count + 1).toString().padLeft(3, '0');
    return '$prefix-$number';
  }

  /// Applies purchase price strategy to update item's purchase price.
  Future<void> _applyPurchasePriceStrategy({
    required String companyId,
    required String itemId,
    required int newPrice,
    required double quantity,
    required PurchasePriceStrategy strategy,
  }) async {
    final item = await (_db.select(_db.items)..where((t) => t.id.equals(itemId))).getSingleOrNull();
    if (item == null) return;

    final currentPrice = item.purchasePrice;
    int? updatedPrice;

    switch (strategy) {
      case PurchasePriceStrategy.overwrite:
        updatedPrice = newPrice;
        break;
      case PurchasePriceStrategy.keep:
        // Only set if no existing price
        if (currentPrice == null) {
          updatedPrice = newPrice;
        }
        break;
      case PurchasePriceStrategy.average:
        if (currentPrice == null) {
          updatedPrice = newPrice;
        } else {
          updatedPrice = ((currentPrice + newPrice) / 2).round();
        }
        break;
      case PurchasePriceStrategy.weightedAverage:
        if (currentPrice == null) {
          updatedPrice = newPrice;
        } else {
          // Get current stock level for weighting
          final stockLevel = await (_db.select(_db.stockLevels)
                ..where((t) =>
                    t.companyId.equals(companyId) &
                    t.itemId.equals(itemId) &
                    t.deletedAt.isNull()))
              .getSingleOrNull();

          // Current quantity already includes the new receipt (adjusted before this call)
          final totalQty = stockLevel?.quantity ?? quantity;
          final existingQty = totalQty - quantity;

          if (existingQty <= 0) {
            updatedPrice = newPrice;
          } else {
            updatedPrice =
                ((currentPrice * existingQty + newPrice * quantity) / totalQty).round();
          }
        }
        break;
    }

    if (updatedPrice != null && updatedPrice != currentPrice) {
      await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
          ItemsCompanion(
            purchasePrice: Value(updatedPrice),
            updatedAt: Value(now),
          ),
        );

        // Enqueue the item update for sync
        final updatedItem = await (_db.select(_db.items)..where((t) => t.id.equals(itemId))).getSingle();
        final itemModel = itemFromEntity(updatedItem);
        if (syncQueueRepo != null) {
          await syncQueueRepo!.enqueue(
            companyId: companyId,
            entityType: 'items',
            entityId: itemId,
            operation: 'update',
            payload: jsonEncode(itemToSupabaseJson(itemModel)),
          );
        }
      });
    }
  }

  Future<void> _enqueue(String operation, StockDocumentModel model) async {
    if (syncQueueRepo == null) return;
    final json = stockDocumentToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'stock_documents',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

/// Input for an inventory line (actual vs current quantity).
class InventoryLine {
  InventoryLine({
    required this.itemId,
    required this.currentQuantity,
    required this.actualQuantity,
    this.purchasePrice,
  });

  final String itemId;
  final double currentQuantity;
  final double actualQuantity;
  final int? purchasePrice;
}
