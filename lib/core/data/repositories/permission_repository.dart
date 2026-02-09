import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/permission_model.dart';
import '../models/role_permission_model.dart';
import '../models/user_permission_model.dart';
import '../result.dart';

class PermissionRepository {
  PermissionRepository(this._db);
  final AppDatabase _db;

  Future<Result<List<PermissionModel>>> getAll() async {
    try {
      final entities = await (_db.select(_db.permissions)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      return Success(entities.map(permissionFromEntity).toList());
    } catch (e, s) {
      AppLogger.error('Failed to get permissions', error: e, stackTrace: s);
      return Failure('Failed to get permissions: $e');
    }
  }

  Future<Result<List<RolePermissionModel>>> getRolePermissions(String roleId) async {
    try {
      final entities = await (_db.select(_db.rolePermissions)
            ..where((t) => t.roleId.equals(roleId) & t.deletedAt.isNull()))
          .get();
      return Success(entities.map(rolePermissionFromEntity).toList());
    } catch (e, s) {
      AppLogger.error('Failed to get role permissions', error: e, stackTrace: s);
      return Failure('Failed to get role permissions: $e');
    }
  }

  Future<Result<List<UserPermissionModel>>> getUserPermissions(
    String companyId,
    String userId,
  ) async {
    try {
      final entities = await (_db.select(_db.userPermissions)
            ..where((t) =>
                t.companyId.equals(companyId) &
                t.userId.equals(userId) &
                t.deletedAt.isNull()))
          .get();
      return Success(entities.map(userPermissionFromEntity).toList());
    } catch (e, s) {
      AppLogger.error('Failed to get user permissions', error: e, stackTrace: s);
      return Failure('Failed to get user permissions: $e');
    }
  }

  Stream<Set<String>> watchUserPermissionCodes(String companyId, String userId) {
    final query = _db.select(_db.userPermissions).join([
      innerJoin(
        _db.permissions,
        _db.permissions.id.equalsExp(_db.userPermissions.permissionId),
      ),
    ])
      ..where(_db.userPermissions.companyId.equals(companyId) &
          _db.userPermissions.userId.equals(userId) &
          _db.userPermissions.deletedAt.isNull());

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(_db.permissions).code).toSet();
    });
  }

  Future<Result<void>> applyRoleToUser({
    required String companyId,
    required String userId,
    required String roleId,
    required String grantedBy,
    required String Function() generateId,
  }) async {
    try {
      await _db.transaction(() async {
        // Soft-delete existing user permissions
        await (_db.update(_db.userPermissions)
              ..where((t) =>
                  t.companyId.equals(companyId) &
                  t.userId.equals(userId) &
                  t.deletedAt.isNull()))
            .write(UserPermissionsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));

        // Get permissions for the role
        final rolePerms = await (_db.select(_db.rolePermissions)
              ..where((t) => t.roleId.equals(roleId) & t.deletedAt.isNull()))
            .get();

        // Create new user permissions
        for (final rp in rolePerms) {
          await _db.into(_db.userPermissions).insert(
                UserPermissionsCompanion.insert(
                  id: generateId(),
                  companyId: companyId,
                  userId: userId,
                  permissionId: rp.permissionId,
                  grantedBy: grantedBy,
                ),
              );
        }
      });
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to apply role to user', error: e, stackTrace: s);
      return Failure('Failed to apply role to user: $e');
    }
  }
}
