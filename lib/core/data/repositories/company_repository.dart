import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/company_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class CompanyRepository {
  CompanyRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<CompanyModel>> create(CompanyModel model) async {
    try {
      return await _db.transaction(() async {
        await _db.into(_db.companies).insert(companyToCompanion(model));
        final entity = await (_db.select(_db.companies)
              ..where((t) => t.id.equals(model.id)))
            .getSingle();
        final created = companyFromEntity(entity);
        await _enqueueCompany('insert', created);
        return Success(created);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create company', error: e, stackTrace: s);
      return Failure('Failed to create company: $e');
    }
  }

  Future<Result<CompanyModel>> getById(String id, {bool includeDeleted = false}) async {
    try {
      final query = _db.select(_db.companies)..where((t) => t.id.equals(id));
      if (!includeDeleted) {
        query.where((t) => t.deletedAt.isNull());
      }
      final entity = await query.getSingleOrNull();
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
      return await _db.transaction(() async {
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
        final updated = companyFromEntity(entity);
        await _enqueueCompany('update', updated);
        return Success(updated);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update company', error: e, stackTrace: s);
      return Failure('Failed to update company: $e');
    }
  }

  Future<Result<void>> updateAuthUserId(String companyId, String authUserId) async {
    try {
      return await _db.transaction(() async {
        await (_db.update(_db.companies)..where((t) => t.id.equals(companyId)))
            .write(CompaniesCompanion(
          authUserId: Value(authUserId),
          updatedAt: Value(DateTime.now()),
        ));
        final entity = await (_db.select(_db.companies)
              ..where((t) => t.id.equals(companyId)))
            .getSingle();
        await _enqueueCompany('update', companyFromEntity(entity));
        return const Success(null);
      });
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

  /// Pre-sync remote lookup — used during onboarding before initial sync.
  Future<({String id, String name})?> findRemoteByAuthUserId(String authUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase
          .from('companies')
          .select('id, name')
          .eq('auth_user_id', authUserId)
          .limit(1) as List<dynamic>;
      if (rows.isEmpty) return null;
      final row = rows.first as Map<String, dynamic>;
      return (id: row['id'] as String, name: row['name'] as String);
    } catch (e, s) {
      AppLogger.error('Failed to find remote company', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> _enqueueCompany(String operation, CompanyModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.id,
      entityType: 'companies',
      entityId: m.id,
      operation: operation,
      payload: jsonEncode(companyToSupabaseJson(m)),
    );
  }
}
