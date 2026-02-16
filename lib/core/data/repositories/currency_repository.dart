import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/currency_model.dart';
import '../result.dart';

class CurrencyRepository {
  CurrencyRepository(this._db);
  final AppDatabase _db;

  Future<Result<List<CurrencyModel>>> getAll() async {
    try {
      final entities = await (_db.select(_db.currencies)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      return Success(entities.map(currencyFromEntity).toList());
    } catch (e, s) {
      AppLogger.error('Failed to get currencies', error: e, stackTrace: s);
      return Failure('Failed to get currencies: $e');
    }
  }

  Future<CurrencyModel?> getById(String id) async {
    final entity = await (_db.select(_db.currencies)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return entity == null ? null : currencyFromEntity(entity);
  }
}
