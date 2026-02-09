import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/item_model.dart';
import '../result.dart';

class ItemRepository {
  ItemRepository(this._db);
  final AppDatabase _db;

  Future<Result<ItemModel>> create(ItemModel model) async {
    try {
      await _db.into(_db.items).insert(itemToCompanion(model));
      final entity = await (_db.select(_db.items)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(itemFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create item', error: e, stackTrace: s);
      return Failure('Failed to create item: $e');
    }
  }

  Future<Result<ItemModel>> update(ItemModel model) async {
    try {
      await (_db.update(_db.items)..where((t) => t.id.equals(model.id))).write(
        ItemsCompanion(
          categoryId: Value(model.categoryId),
          name: Value(model.name),
          description: Value(model.description),
          itemType: Value(model.itemType),
          sku: Value(model.sku),
          unitPrice: Value(model.unitPrice),
          saleTaxRateId: Value(model.saleTaxRateId),
          isSellable: Value(model.isSellable),
          isActive: Value(model.isActive),
          unit: Value(model.unit),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.items)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(itemFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update item', error: e, stackTrace: s);
      return Failure('Failed to update item: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete item', error: e, stackTrace: s);
      return Failure('Failed to delete item: $e');
    }
  }

  Stream<List<ItemModel>> watchAll(String companyId) {
    return (_db.select(_db.items)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(itemFromEntity).toList());
  }
}
