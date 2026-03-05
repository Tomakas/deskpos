import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/internal_account_model.dart';
import 'base_company_scoped_repository.dart';

class InternalAccountRepository
    extends BaseCompanyScopedRepository<$InternalAccountsTable, InternalAccount, InternalAccountModel> {
  InternalAccountRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$InternalAccountsTable, InternalAccount> get table => db.internalAccounts;

  @override
  String get entityName => 'internal account';

  @override
  String get supabaseTableName => 'internal_accounts';

  @override
  InternalAccountModel fromEntity(InternalAccount e) => internalAccountFromEntity(e);

  @override
  Insertable<InternalAccount> toCompanion(InternalAccountModel m) =>
      internalAccountToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(InternalAccountModel m) =>
      internalAccountToSupabaseJson(m);

  @override
  Expression<bool> whereId($InternalAccountsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($InternalAccountsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($InternalAccountsTable t) =>
      t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($InternalAccountsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<InternalAccount> toUpdateCompanion(InternalAccountModel m) =>
      InternalAccountsCompanion(
        name: Value(m.name),
        userId: Value(m.userId),
        isActive: Value(m.isActive),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<InternalAccount> toDeleteCompanion(DateTime now) =>
      InternalAccountsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Future<List<InternalAccountModel>> getAll(String companyId) async {
    final entities = await (db.select(db.internalAccounts)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return entities.map(internalAccountFromEntity).toList();
  }

  Future<List<InternalAccountModel>> getActive(String companyId) async {
    final entities = await (db.select(db.internalAccounts)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.deletedAt.isNull() &
              t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return entities.map(internalAccountFromEntity).toList();
  }
}
