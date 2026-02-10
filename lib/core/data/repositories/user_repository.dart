import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/user_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class UserRepository
    extends BaseCompanyScopedRepository<$UsersTable, User, UserModel> {
  UserRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$UsersTable, User> get table => db.users;

  @override
  String get entityName => 'user';

  @override
  String get supabaseTableName => 'users';

  @override
  UserModel fromEntity(User e) => userFromEntity(e);

  @override
  Insertable<User> toCompanion(UserModel m) => userToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(UserModel m) => userToSupabaseJson(m);

  @override
  Expression<bool> whereId($UsersTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($UsersTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($UsersTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.fullName)];

  @override
  Insertable<User> toUpdateCompanion(UserModel m) => UsersCompanion(
        username: Value(m.username),
        fullName: Value(m.fullName),
        email: Value(m.email),
        phone: Value(m.phone),
        pinHash: Value(m.pinHash),
        pinEnabled: Value(m.pinEnabled),
        roleId: Value(m.roleId),
        isActive: Value(m.isActive),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<User> toDeleteCompanion(DateTime now) => UsersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Future<Result<UserModel>> getByIdResult(String id) async {
    try {
      final entity = await (db.select(db.users)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (entity == null) return const Failure('User not found');
      return Success(userFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get user', error: e, stackTrace: s);
      return Failure('Failed to get user: $e');
    }
  }

  Future<List<UserModel>> getActiveUsers(String companyId) async {
    final entities = await (db.select(db.users)
          ..where(
              (t) => t.companyId.equals(companyId) & t.deletedAt.isNull() & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.fullName)]))
        .get();
    return entities.map(userFromEntity).toList();
  }

  Future<UserModel?> getByUsername(String companyId, String username) async {
    final entity = await (db.select(db.users)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.username.equals(username) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : userFromEntity(entity);
  }
}
