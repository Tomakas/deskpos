import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../enums/stock_movement_direction.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/stock_movement_model.dart';
import 'sync_queue_repository.dart';

class StockMovementRepository {
  StockMovementRepository(this._db, {required this.syncQueueRepo});

  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  /// Inserts a stock movement and enqueues for sync.
  Future<StockMovementModel> createMovement(StockMovementModel model) async {
    await _db.transaction(() async {
      await _db.into(_db.stockMovements).insert(stockMovementToCompanion(model));
      await _enqueue('insert', model);
    });
    return model;
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
