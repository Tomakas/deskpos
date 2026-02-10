import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/layout_item_type.dart';
import '../mappers/entity_mappers.dart';
import '../models/layout_item_model.dart';
import '../result.dart';

class LayoutItemRepository {
  LayoutItemRepository(this._db);
  final AppDatabase _db;

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

      // Delete existing cell at this position
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
      }

      // Insert new cell
      final id = const Uuid().v7();
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

      final entity = await (_db.select(_db.layoutItems)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return Success(layoutItemFromEntity(entity));
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
      }
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to clear layout cell', error: e, stackTrace: s);
      return Failure('Failed to clear layout cell: $e');
    }
  }
}
