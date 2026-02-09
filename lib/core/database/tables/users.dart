import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_users_company_updated', columns: {#companyId, #updatedAt})
class Users extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get authUserId => text().nullable()();
  TextColumn get username => text()();
  TextColumn get fullName => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get pinHash => text()();
  BoolColumn get pinEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get roleId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
