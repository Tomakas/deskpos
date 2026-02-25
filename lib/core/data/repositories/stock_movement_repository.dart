import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/stock_document_type.dart';
import '../enums/stock_movement_direction.dart';
import '../enums/unit_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/stock_movement_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class StockMovementRepository {
  StockMovementRepository(this._db, {required this.syncQueueRepo});

  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  /// Inserts a stock movement and enqueues for sync.
  Future<Result<StockMovementModel>> createMovement(StockMovementModel model) async {
    try {
      await _db.transaction(() async {
        await _db.into(_db.stockMovements).insert(stockMovementToCompanion(model));
        await _enqueue('insert', model);
      });
      return Success(model);
    } catch (e, s) {
      AppLogger.error('Failed to create stock movement', error: e, stackTrace: s);
      return Failure('Failed to create stock movement: $e');
    }
  }

  /// Watches all movements for a document.
  Stream<List<StockMovementModel>> watchByDocument(String documentId) {
    return (_db.select(_db.stockMovements)
          ..where((t) => t.stockDocumentId.equals(documentId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(stockMovementFromEntity).toList());
  }

  /// Gets all movements for an item (for future history view).
  Future<List<StockMovementModel>> getByItem(String companyId, String itemId) async {
    final entities = await (_db.select(_db.stockMovements)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.itemId.equals(itemId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return entities.map(stockMovementFromEntity).toList();
  }

  /// Gets movements by direction for a specific item (used for weighted average calculation).
  Future<List<StockMovementModel>> getInboundByItem(String companyId, String itemId) async {
    final entities = await (_db.select(_db.stockMovements)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.itemId.equals(itemId) &
              t.direction.equals(StockMovementDirection.inbound.name) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return entities.map(stockMovementFromEntity).toList();
  }

  /// Watches all movements for a company with item and document info via JOIN.
  Stream<List<StockMovementWithItem>> watchByCompany(
    String companyId, {
    String? itemId,
  }) {
    var whereExpr = _db.stockMovements.companyId.equals(companyId) &
        _db.stockMovements.deletedAt.isNull() &
        _db.items.deletedAt.isNull();

    if (itemId != null) {
      whereExpr = whereExpr & _db.stockMovements.itemId.equals(itemId);
    }

    final query = _db.select(_db.stockMovements).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.stockMovements.itemId)),
      leftOuterJoin(
        _db.stockDocuments,
        _db.stockDocuments.id.equalsExp(_db.stockMovements.stockDocumentId),
      ),
    ])
      ..where(whereExpr)
      ..orderBy([OrderingTerm.desc(_db.stockMovements.createdAt)]);

    return query.watch().map((rows) => rows.map((row) {
          final movement = stockMovementFromEntity(row.readTable(_db.stockMovements));
          final item = row.readTable(_db.items);
          final doc = row.readTableOrNull(_db.stockDocuments);
          return StockMovementWithItem(
            movement: movement,
            itemName: item.name,
            unit: item.unit,
            documentType: doc?.type,
            documentNumber: doc?.documentNumber,
            categoryId: item.categoryId,
          );
        }).toList());
  }

  Future<void> _enqueue(String operation, StockMovementModel model) async {
    if (syncQueueRepo == null) return;
    final json = stockMovementToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'stock_movements',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

/// A stock movement combined with item and document information for display.
class StockMovementWithItem {
  StockMovementWithItem({
    required this.movement,
    required this.itemName,
    required this.unit,
    this.documentType,
    this.documentNumber,
    this.categoryId,
  });

  final StockMovementModel movement;
  final String itemName;
  final UnitType unit;
  final StockDocumentType? documentType;
  final String? documentNumber;
  final String? categoryId;
}
