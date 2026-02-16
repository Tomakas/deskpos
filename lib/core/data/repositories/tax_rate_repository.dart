import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/tax_rate_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class TaxRateRepository
    extends BaseCompanyScopedRepository<$TaxRatesTable, TaxRate, TaxRateModel> {
  TaxRateRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$TaxRatesTable, TaxRate> get table => db.taxRates;

  @override
  String get entityName => 'tax rate';

  @override
  String get supabaseTableName => 'tax_rates';

  @override
  TaxRateModel fromEntity(TaxRate e) => taxRateFromEntity(e);

  @override
  Insertable<TaxRate> toCompanion(TaxRateModel m) => taxRateToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(TaxRateModel m) => taxRateToSupabaseJson(m);

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

  Future<Result<void>> clearDefault(String companyId, {String? exceptId}) async {
    try {
      // 1. Find affected records before update
      final selectQuery = db.select(db.taxRates)
        ..where((t) =>
            t.companyId.equals(companyId) &
            t.isDefault.equals(true) &
            t.deletedAt.isNull());
      if (exceptId != null) {
        selectQuery.where((t) => t.id.equals(exceptId).not());
      }
      final affected = await selectQuery.get();
      if (affected.isEmpty) return const Success(null);

      // 2. Bulk update + 3. Enqueue in a single transaction
      await db.transaction(() async {
        final updateQuery = db.update(db.taxRates)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isDefault.equals(true) &
              t.deletedAt.isNull());
        if (exceptId != null) {
          updateQuery.where((t) => t.id.equals(exceptId).not());
        }
        await updateQuery.write(TaxRatesCompanion(
          isDefault: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));

        if (syncQueueRepo != null) {
          for (final entity in affected) {
            final updated = await (db.select(db.taxRates)
                  ..where((t) => t.id.equals(entity.id)))
                .getSingle();
            final model = taxRateFromEntity(updated);
            await syncQueueRepo!.enqueue(
              companyId: model.companyId,
              entityType: supabaseTableName,
              entityId: model.id,
              operation: 'update',
              payload: jsonEncode(taxRateToSupabaseJson(model)),
            );
          }
        }
      });
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to clear default tax rate', error: e, stackTrace: s);
      return Failure('Failed to clear default tax rate: $e');
    }
  }

  @override
  Future<TaxRateModel?> getById(String id) async {
    final entity = await (db.select(db.taxRates)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : taxRateFromEntity(entity);
  }
}
