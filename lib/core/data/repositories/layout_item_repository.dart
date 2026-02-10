import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/layout_item_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/layout_item_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class LayoutItemRepository {
  LayoutItemRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Stream<List<LayoutItemModel>> watchByRegister(String registerId, {int page = 0}) {
    return (_db.select(_db.layoutItems)
          ..where((t) =>
              t.registerId.equals(registerId) &
              t.page.equals(page) &
              t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map(layoutItemFromEntity).toList());
  }

  Future<Result<LayoutItemModel>> setCell({
    required String companyId,
    required String registerId,
    required int page,
    required int gridRow,
    required int gridCol,
    required LayoutItemType type,
    String? itemId,
    String? categoryId,
    String? label,
    String? color,
  }) async {
    try {
      final now = DateTime.now();
      String? deletedEntityId;

      // Check existing cell at this position
      final existing = await (_db.select(_db.layoutItems)
            ..where((t) =>
                t.registerId.equals(registerId) &
                t.page.equals(page) &
                t.gridRow.equals(gridRow) &
                t.gridCol.equals(gridCol) &
                t.deletedAt.isNull()))
          .getSingleOrNull();

      // Atomic: soft-delete old + insert new
      final id = const Uuid().v7();
      await _db.transaction(() async {
        if (existing != null) {
          await (_db.update(_db.layoutItems)..where((t) => t.id.equals(existing.id))).write(
            LayoutItemsCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
          deletedEntityId = existing.id;
        }

        await _db.into(_db.layoutItems).insert(LayoutItemsCompanion.insert(
          id: id,
          companyId: companyId,
          registerId: registerId,
          page: Value(page),
          gridRow: gridRow,
          gridCol: gridCol,
          type: type,
          itemId: Value(itemId),
          categoryId: Value(categoryId),
          label: Value(label),
          color: Value(color),
        ));
      });

      // Enqueue outside transaction
      if (deletedEntityId != null) {
        final deletedEntity = await (_db.select(_db.layoutItems)
              ..where((t) => t.id.equals(deletedEntityId!)))
            .getSingle();
        await _enqueueLayoutItem('delete', layoutItemFromEntity(deletedEntity));
      }

      final entity = await (_db.select(_db.layoutItems)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      final model = layoutItemFromEntity(entity);
      await _enqueueLayoutItem('insert', model);
      return Success(model);
    } catch (e, s) {
      AppLogger.error('Failed to set layout cell', error: e, stackTrace: s);
      return Failure('Failed to set layout cell: $e');
    }
  }

  Future<Result<void>> clearCell({
    required String registerId,
    required int page,
    required int gridRow,
    required int gridCol,
  }) async {
    try {
      final now = DateTime.now();
      final existing = await (_db.select(_db.layoutItems)
            ..where((t) =>
                t.registerId.equals(registerId) &
                t.page.equals(page) &
                t.gridRow.equals(gridRow) &
                t.gridCol.equals(gridCol) &
                t.deletedAt.isNull()))
          .getSingleOrNull();

      if (existing != null) {
        await (_db.update(_db.layoutItems)..where((t) => t.id.equals(existing.id))).write(
          LayoutItemsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        // Re-read deleted entity for sync payload
        final deletedEntity = await (_db.select(_db.layoutItems)
              ..where((t) => t.id.equals(existing.id)))
            .getSingle();
        await _enqueueLayoutItem('delete', layoutItemFromEntity(deletedEntity));
      }
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to clear layout cell', error: e, stackTrace: s);
      return Failure('Failed to clear layout cell: $e');
    }
  }

  Future<void> _enqueueLayoutItem(String operation, LayoutItemModel model) async {
    if (syncQueueRepo == null) return;
    final json = layoutItemToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'layout_items',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}
