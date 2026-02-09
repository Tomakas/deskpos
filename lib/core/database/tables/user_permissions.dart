import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_user_permissions_company_updated', columns: {#companyId, #updatedAt})
class UserPermissions extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get userId => text()();
  TextColumn get permissionId => text()();
  TextColumn get grantedBy => text()();

  @override
  Set<Column> get primaryKey => {id};
}
