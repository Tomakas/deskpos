import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/internal_account_settlement_model.dart';
import 'base_company_scoped_repository.dart';

class InternalAccountSettlementRepository
    extends BaseCompanyScopedRepository<$InternalAccountSettlementsTable, InternalAccountSettlement, InternalAccountSettlementModel> {
  InternalAccountSettlementRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$InternalAccountSettlementsTable, InternalAccountSettlement> get table =>
      db.internalAccountSettlements;

  @override
  String get entityName => 'internal account settlement';

  @override
  String get supabaseTableName => 'internal_account_settlements';

  @override
  InternalAccountSettlementModel fromEntity(InternalAccountSettlement e) =>
      internalAccountSettlementFromEntity(e);

  @override
  Insertable<InternalAccountSettlement> toCompanion(InternalAccountSettlementModel m) =>
      internalAccountSettlementToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(InternalAccountSettlementModel m) =>
      internalAccountSettlementToSupabaseJson(m);

  @override
  Expression<bool> whereId($InternalAccountSettlementsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($InternalAccountSettlementsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($InternalAccountSettlementsTable t) =>
      t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($InternalAccountSettlementsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.desc(t.settledAt)];

  @override
  Insertable<InternalAccountSettlement> toUpdateCompanion(InternalAccountSettlementModel m) =>
      InternalAccountSettlementsCompanion(
        note: Value(m.note),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<InternalAccountSettlement> toDeleteCompanion(DateTime now) =>
      InternalAccountSettlementsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Future<List<InternalAccountSettlementModel>> getByAccount(String internalAccountId) async {
    final entities = await (db.select(db.internalAccountSettlements)
          ..where((t) =>
              t.internalAccountId.equals(internalAccountId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.settledAt)]))
        .get();
    return entities.map(internalAccountSettlementFromEntity).toList();
  }
}
