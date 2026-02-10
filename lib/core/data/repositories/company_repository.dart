import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/company_model.dart';
import '../result.dart';

class CompanyRepository {
  CompanyRepository(this._db);
  final AppDatabase _db;

  Future<Result<CompanyModel>> create(CompanyModel model) async {
    try {
      await _db.into(_db.companies).insert(companyToCompanion(model));
      final entity = await (_db.select(_db.companies)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(companyFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create company', error: e, stackTrace: s);
      return Failure('Failed to create company: $e');
    }
  }

  Future<Result<CompanyModel>> getById(String id) async {
    try {
      final entity = await (_db.select(_db.companies)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (entity == null) return const Failure('Company not found');
      return Success(companyFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get company', error: e, stackTrace: s);
      return Failure('Failed to get company: $e');
    }
  }

  Future<Result<CompanyModel?>> getFirst() async {
    try {
      final entity = await (_db.select(_db.companies)
            ..where((t) => t.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();
      if (entity == null) return const Success(null);
      return Success(companyFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to get first company', error: e, stackTrace: s);
      return Failure('Failed to get first company: $e');
    }
  }

  Future<Result<CompanyModel>> update(CompanyModel model) async {
    try {
      await (_db.update(_db.companies)..where((t) => t.id.equals(model.id)))
          .write(CompaniesCompanion(
        name: Value(model.name),
        status: Value(model.status),
        businessId: Value(model.businessId),
        address: Value(model.address),
        phone: Value(model.phone),
        email: Value(model.email),
        vatNumber: Value(model.vatNumber),
        country: Value(model.country),
        city: Value(model.city),
        postalCode: Value(model.postalCode),
        timezone: Value(model.timezone),
        businessType: Value(model.businessType),
        defaultCurrencyId: Value(model.defaultCurrencyId),
        updatedAt: Value(DateTime.now()),
      ));
      final entity = await (_db.select(_db.companies)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(companyFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update company', error: e, stackTrace: s);
      return Failure('Failed to update company: $e');
    }
  }

  Future<Result<void>> updateAuthUserId(String companyId, String authUserId) async {
    try {
      await (_db.update(_db.companies)..where((t) => t.id.equals(companyId)))
          .write(CompaniesCompanion(
        authUserId: Value(authUserId),
        updatedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to update authUserId', error: e, stackTrace: s);
      return Failure('Failed to update authUserId: $e');
    }
  }

  Stream<CompanyModel?> watchFirst() {
    return (_db.select(_db.companies)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .watchSingleOrNull()
        .map((e) => e == null ? null : companyFromEntity(e));
  }
}
