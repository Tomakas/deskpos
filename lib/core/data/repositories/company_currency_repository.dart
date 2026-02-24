import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/company_currency_model.dart';
import 'base_company_scoped_repository.dart';

class CompanyCurrencyRepository
    extends BaseCompanyScopedRepository<$CompanyCurrenciesTable, CompanyCurrency, CompanyCurrencyModel> {
  CompanyCurrencyRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$CompanyCurrenciesTable, CompanyCurrency> get table => db.companyCurrencies;

  @override
  String get entityName => 'company currency';

  @override
  String get supabaseTableName => 'company_currencies';

  @override
  CompanyCurrencyModel fromEntity(CompanyCurrency e) => companyCurrencyFromEntity(e);

  @override
  Insertable<CompanyCurrency> toCompanion(CompanyCurrencyModel m) =>
      companyCurrencyToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(CompanyCurrencyModel m) =>
      companyCurrencyToSupabaseJson(m);

  @override
  Expression<bool> whereId($CompanyCurrenciesTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($CompanyCurrenciesTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($CompanyCurrenciesTable t) =>
      t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($CompanyCurrenciesTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.sortOrder)];

  @override
  Insertable<CompanyCurrency> toUpdateCompanion(CompanyCurrencyModel m) =>
      CompanyCurrenciesCompanion(
        currencyId: Value(m.currencyId),
        exchangeRate: Value(m.exchangeRate),
        isActive: Value(m.isActive),
        sortOrder: Value(m.sortOrder),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<CompanyCurrency> toDeleteCompanion(DateTime now) =>
      CompanyCurrenciesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<List<CompanyCurrencyModel>> watchActive(String companyId) {
    return (db.select(db.companyCurrencies)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(companyCurrencyFromEntity).toList());
  }

  Future<List<CompanyCurrencyModel>> getActive(String companyId) async {
    final entities = await (db.select(db.companyCurrencies)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return entities.map(companyCurrencyFromEntity).toList();
  }

  Future<CompanyCurrencyModel?> getByCurrencyId(String companyId, String currencyId) async {
    final entity = await (db.select(db.companyCurrencies)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.currencyId.equals(currencyId) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity != null ? companyCurrencyFromEntity(entity) : null;
  }
}
