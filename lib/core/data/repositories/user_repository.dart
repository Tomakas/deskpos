import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/user_model.dart';
import '../result.dart';

class UserRepository {
  UserRepository(this._db);
  final AppDatabase _db;

  Future<Result<UserModel>> create(UserModel model) async {
    try {
      await _db.into(_db.users).insert(userToCompanion(model));
      final entity = await (_db.select(_db.users)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(userFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create user', error: e, stackTrace: s);
      return Failure('Failed to create user: $e');
    }
  }

  Future<Result<UserModel>> getById(String id) async {
    try {
      final entity = await (_db.select(_db.users)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (entity == null) return const Failure('User not found');
      return Success(userFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get user', error: e, stackTrace: s);
      return Failure('Failed to get user: $e');
    }
  }

  Future<Result<UserModel>> update(UserModel model) async {
    try {
      await (_db.update(_db.users)..where((t) => t.id.equals(model.id))).write(
        UsersCompanion(
          username: Value(model.username),
          fullName: Value(model.fullName),
          email: Value(model.email),
          phone: Value(model.phone),
          pinHash: Value(model.pinHash),
          pinEnabled: Value(model.pinEnabled),
          roleId: Value(model.roleId),
          isActive: Value(model.isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.users)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(userFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update user', error: e, stackTrace: s);
      return Failure('Failed to update user: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.users)..where((t) => t.id.equals(id))).write(
        UsersCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete user', error: e, stackTrace: s);
      return Failure('Failed to delete user: $e');
    }
  }

  Stream<List<UserModel>> watchAll(String companyId) {
    return (_db.select(_db.users)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.fullName)]))
        .watch()
        .map((rows) => rows.map(userFromEntity).toList());
  }

  Future<List<UserModel>> getActiveUsers(String companyId) async {
    final entities = await (_db.select(_db.users)
          ..where(
              (t) => t.companyId.equals(companyId) & t.deletedAt.isNull() & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.fullName)]))
        .get();
    return entities.map(userFromEntity).toList();
  }

  Future<UserModel?> getByUsername(String companyId, String username) async {
    final entity = await (_db.select(_db.users)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.username.equals(username) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : userFromEntity(entity);
  }
}
