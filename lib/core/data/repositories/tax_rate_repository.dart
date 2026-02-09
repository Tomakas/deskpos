import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/tax_rate_model.dart';
import '../result.dart';

class TaxRateRepository {
  TaxRateRepository(this._db);
  final AppDatabase _db;

  Future<Result<TaxRateModel>> create(TaxRateModel model) async {
    try {
      await _db.into(_db.taxRates).insert(taxRateToCompanion(model));
      final entity = await (_db.select(_db.taxRates)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(taxRateFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create tax rate', error: e, stackTrace: s);
      return Failure('Failed to create tax rate: $e');
    }
  }

  Future<Result<TaxRateModel>> update(TaxRateModel model) async {
    try {
      await (_db.update(_db.taxRates)..where((t) => t.id.equals(model.id))).write(
        TaxRatesCompanion(
          label: Value(model.label),
          type: Value(model.type),
          rate: Value(model.rate),
          isDefault: Value(model.isDefault),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.taxRates)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(taxRateFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update tax rate', error: e, stackTrace: s);
      return Failure('Failed to update tax rate: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.taxRates)..where((t) => t.id.equals(id))).write(
        TaxRatesCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete tax rate', error: e, stackTrace: s);
      return Failure('Failed to delete tax rate: $e');
    }
  }

  Future<void> clearDefault(String companyId, {String? exceptId}) async {
    final query = _db.update(_db.taxRates)
      ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true) & t.deletedAt.isNull());
    if (exceptId != null) {
      query.where((t) => t.id.equals(exceptId).not());
    }
    await query.write(TaxRatesCompanion(
      isDefault: const Value(false),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<TaxRateModel?> getById(String id) async {
    final entity = await (_db.select(_db.taxRates)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : taxRateFromEntity(entity);
  }

  Stream<List<TaxRateModel>> watchAll(String companyId) {
    return (_db.select(_db.taxRates)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isDefault)]))
        .watch()
        .map((rows) => rows.map(taxRateFromEntity).toList());
  }
}
