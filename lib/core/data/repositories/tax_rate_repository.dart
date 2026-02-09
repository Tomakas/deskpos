import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../models/tax_rate_model.dart';
import 'base_company_scoped_repository.dart';

class TaxRateRepository
    extends BaseCompanyScopedRepository<$TaxRatesTable, TaxRate, TaxRateModel> {
  TaxRateRepository(super.db);

  @override
  TableInfo<$TaxRatesTable, TaxRate> get table => db.taxRates;

  @override
  String get entityName => 'tax rate';

  @override
  TaxRateModel fromEntity(TaxRate e) => taxRateFromEntity(e);

  @override
  Insertable<TaxRate> toCompanion(TaxRateModel m) => taxRateToCompanion(m);

  @override
  Expression<bool> whereId($TaxRatesTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($TaxRatesTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($TaxRatesTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.desc(t.isDefault)];

  @override
  Insertable<TaxRate> toUpdateCompanion(TaxRateModel m) => TaxRatesCompanion(
        label: Value(m.label),
        type: Value(m.type),
        rate: Value(m.rate),
        isDefault: Value(m.isDefault),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<TaxRate> toDeleteCompanion(DateTime now) => TaxRatesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Future<void> clearDefault(String companyId, {String? exceptId}) async {
    final query = db.update(db.taxRates)
      ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true) & t.deletedAt.isNull());
    if (exceptId != null) {
      query.where((t) => t.id.equals(exceptId).not());
    }
    await query.write(TaxRatesCompanion(
      isDefault: const Value(false),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<TaxRateModel?> getById(String id) async {
    final entity = await (db.select(db.taxRates)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : taxRateFromEntity(entity);
  }
}
