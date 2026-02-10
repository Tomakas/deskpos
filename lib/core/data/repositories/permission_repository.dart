import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/permission_model.dart';
import '../models/role_permission_model.dart';
import '../models/user_permission_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class PermissionRepository {
  PermissionRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

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
        // Get existing user permissions before soft-delete (for sync)
        final existingPerms = await (_db.select(_db.userPermissions)
              ..where((t) =>
                  t.companyId.equals(companyId) &
                  t.userId.equals(userId) &
                  t.deletedAt.isNull()))
            .get();

        // Soft-delete existing user permissions
        final now = DateTime.now();
        await (_db.update(_db.userPermissions)
              ..where((t) =>
                  t.companyId.equals(companyId) &
                  t.userId.equals(userId) &
                  t.deletedAt.isNull()))
            .write(UserPermissionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));

        // Enqueue deletes for existing permissions
        for (final ep in existingPerms) {
          final deletedEntity = await (_db.select(_db.userPermissions)
                ..where((t) => t.id.equals(ep.id)))
              .getSingle();
          await _enqueueUserPermission('delete', userPermissionFromEntity(deletedEntity));
        }

        // Get permissions for the role
        final rolePerms = await (_db.select(_db.rolePermissions)
              ..where((t) => t.roleId.equals(roleId) & t.deletedAt.isNull()))
            .get();

        // Create new user permissions
        for (final rp in rolePerms) {
          final newId = generateId();
          await _db.into(_db.userPermissions).insert(
                UserPermissionsCompanion.insert(
                  id: newId,
                  companyId: companyId,
                  userId: userId,
                  permissionId: rp.permissionId,
                  grantedBy: grantedBy,
                ),
              );
          final newEntity = await (_db.select(_db.userPermissions)
                ..where((t) => t.id.equals(newId)))
              .getSingle();
          await _enqueueUserPermission('insert', userPermissionFromEntity(newEntity));
        }
      });
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to apply role to user', error: e, stackTrace: s);
      return Failure('Failed to apply role to user: $e');
    }
  }

  Future<void> _enqueueUserPermission(String operation, UserPermissionModel model) async {
    if (syncQueueRepo == null) return;
    final json = userPermissionToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'user_permissions',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}
