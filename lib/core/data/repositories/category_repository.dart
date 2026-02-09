import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/category_model.dart';
import '../result.dart';

class CategoryRepository {
  CategoryRepository(this._db);
  final AppDatabase _db;

  Future<Result<CategoryModel>> create(CategoryModel model) async {
    try {
      await _db.into(_db.categories).insert(categoryToCompanion(model));
      final entity = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(categoryFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create category', error: e, stackTrace: s);
      return Failure('Failed to create category: $e');
    }
  }

  Future<Result<CategoryModel>> update(CategoryModel model) async {
    try {
      await (_db.update(_db.categories)..where((t) => t.id.equals(model.id))).write(
        CategoriesCompanion(
          name: Value(model.name),
          isActive: Value(model.isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(categoryFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update category', error: e, stackTrace: s);
      return Failure('Failed to update category: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete category', error: e, stackTrace: s);
      return Failure('Failed to delete category: $e');
    }
  }

  Stream<List<CategoryModel>> watchAll(String companyId) {
    return (_db.select(_db.categories)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(categoryFromEntity).toList());
  }
}
