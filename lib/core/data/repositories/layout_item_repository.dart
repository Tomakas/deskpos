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

class BulkCellInput {
  const BulkCellInput({
    required this.companyId,
    required this.registerId,
    required this.page,
    required this.gridRow,
    required this.gridCol,
    required this.type,
    this.itemId,
    this.categoryId,
    this.label,
    this.color,
  });

  final String companyId;
  final String registerId;
  final int page;
  final int gridRow;
  final int gridCol;
  final LayoutItemType type;
  final String? itemId;
  final String? categoryId;
  final String? label;
  final String? color;
}

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

      // Atomic: soft-delete old + insert new + enqueue
      final id = const Uuid().v7();
      final model = await _db.transaction(() async {
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

        if (deletedEntityId != null) {
          final deletedEntity = await (_db.select(_db.layoutItems)
                ..where((t) => t.id.equals(deletedEntityId!)))
              .getSingle();
          await _enqueueLayoutItem('delete', layoutItemFromEntity(deletedEntity));
        }

        final entity = await (_db.select(_db.layoutItems)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final m = layoutItemFromEntity(entity);
        await _enqueueLayoutItem('insert', m);
        return m;
      });

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
      return await _db.transaction(() async {
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
      });
    } catch (e, s) {
      AppLogger.error('Failed to clear layout cell', error: e, stackTrace: s);
      return Failure('Failed to clear layout cell: $e');
    }
  }

  Future<Result<int>> clearByRegister(String registerId) async {
    try {
      final now = DateTime.now();
      final existing = await (_db.select(_db.layoutItems)
            ..where((t) =>
                t.registerId.equals(registerId) &
                t.deletedAt.isNull()))
          .get();

      if (existing.isEmpty) return const Success(0);

      final ids = existing.map((e) => e.id).toList();

      await _db.transaction(() async {
        await (_db.update(_db.layoutItems)
              ..where((t) => t.id.isIn(ids)))
            .write(LayoutItemsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));

        for (final entity in existing) {
          final model = layoutItemFromEntity(entity);
          final updated = LayoutItemModel(
            id: model.id,
            companyId: model.companyId,
            registerId: model.registerId,
            page: model.page,
            gridRow: model.gridRow,
            gridCol: model.gridCol,
            type: model.type,
            itemId: model.itemId,
            categoryId: model.categoryId,
            label: model.label,
            color: model.color,
            createdAt: model.createdAt,
            updatedAt: now,
            deletedAt: now,
          );
          await _enqueueLayoutItem('delete', updated);
        }
      });

      return Success(ids.length);
    } catch (e, s) {
      AppLogger.error('Failed to clear layout by register', error: e, stackTrace: s);
      return Failure('Failed to clear layout by register: $e');
    }
  }

  Future<int?> getPageForCategory(String registerId, String categoryId) async {
    final result = await (_db.select(_db.layoutItems)
          ..where((t) =>
              t.registerId.equals(registerId) &
              t.type.equalsValue(LayoutItemType.category) &
              t.categoryId.equals(categoryId) &
              t.page.isBiggerThanValue(0) &
              t.gridRow.equals(0) &
              t.gridCol.equals(0) &
              t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return result?.page;
  }

  Future<Result<void>> bulkSetCells(List<BulkCellInput> cells) async {
    if (cells.isEmpty) return const Success(null);
    try {
      final ids = <String>[];
      await _db.transaction(() async {
        for (final cell in cells) {
          final id = const Uuid().v7();
          ids.add(id);
          await _db.into(_db.layoutItems).insert(LayoutItemsCompanion.insert(
            id: id,
            companyId: cell.companyId,
            registerId: cell.registerId,
            page: Value(cell.page),
            gridRow: cell.gridRow,
            gridCol: cell.gridCol,
            type: cell.type,
            itemId: Value(cell.itemId),
            categoryId: Value(cell.categoryId),
            label: Value(cell.label),
            color: Value(cell.color),
          ));
        }

        for (final id in ids) {
          final entity = await (_db.select(_db.layoutItems)
                ..where((t) => t.id.equals(id)))
              .getSingle();
          await _enqueueLayoutItem('insert', layoutItemFromEntity(entity));
        }
      });

      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to bulk set cells', error: e, stackTrace: s);
      return Failure('Failed to bulk set cells: $e');
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
