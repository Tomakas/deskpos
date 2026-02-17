import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/role_model.dart';
import '../result.dart';

class RoleRepository {
  RoleRepository(this._db);
  final AppDatabase _db;

  Future<Result<List<RoleModel>>> getAll() async {
    try {
      final entities = await (_db.select(_db.roles)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      return Success(entities.map(roleFromEntity).toList());
    } catch (e, s) {
      AppLogger.error('Failed to get roles', error: e, stackTrace: s);
      return Failure('Failed to get roles: $e');
    }
  }

  Future<Result<RoleModel>> getById(String id, {bool includeDeleted = false}) async {
    try {
      final query = _db.select(_db.roles)..where((t) => t.id.equals(id));
      if (!includeDeleted) {
        query.where((t) => t.deletedAt.isNull());
      }
      final entity = await query.getSingleOrNull();
      if (entity == null) return const Failure('Role not found');
      return Success(roleFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get role', error: e, stackTrace: s);
      return Failure('Failed to get role: $e');
    }
  }

  Stream<List<RoleModel>> watchAll() {
    return (_db.select(_db.roles)..where((t) => t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map(roleFromEntity).toList());
  }
}
