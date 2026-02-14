import 'package:drift/drift.dart';
import 'package:uuid/v7.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/company_settings_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class CompanySettingsRepository
    extends BaseCompanyScopedRepository<$CompanySettingsTable, CompanySetting,
        CompanySettingsModel> {
  CompanySettingsRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$CompanySettingsTable, CompanySetting> get table => db.companySettings;

  @override
  String get entityName => 'company_settings';

  @override
  String get supabaseTableName => 'company_settings';

  @override
  CompanySettingsModel fromEntity(CompanySetting e) => companySettingsFromEntity(e);

  @override
  Insertable<CompanySetting> toCompanion(CompanySettingsModel m) =>
      companySettingsToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(CompanySettingsModel m) =>
      companySettingsToSupabaseJson(m);

  @override
  Expression<bool> whereId($CompanySettingsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($CompanySettingsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($CompanySettingsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.createdAt)];

  @override
  Insertable<CompanySetting> toUpdateCompanion(CompanySettingsModel m) =>
      CompanySettingsCompanion(
        requirePinOnSwitch: Value(m.requirePinOnSwitch),
        autoLockTimeoutMinutes: Value(m.autoLockTimeoutMinutes),
        loyaltyEarnRate: Value(m.loyaltyEarnRate),
        loyaltyPointValue: Value(m.loyaltyPointValue),
        locale: Value(m.locale),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<CompanySetting> toDeleteCompanion(DateTime now) => CompanySettingsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<CompanySettingsModel?> watchByCompany(String companyId) {
    return (db.select(db.companySettings)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..limit(1))
        .watchSingleOrNull()
        .map((e) => e == null ? null : companySettingsFromEntity(e));
  }

  Future<CompanySettingsModel?> getByCompany(String companyId) async {
    final entity = await (db.select(db.companySettings)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : companySettingsFromEntity(entity);
  }

  Future<CompanySettingsModel> getOrCreate(String companyId) async {
    final existing = await getByCompany(companyId);
    if (existing != null) return existing;

    final now = DateTime.now();
    final model = CompanySettingsModel(
      id: const UuidV7().generate(),
      companyId: companyId,
      createdAt: now,
      updatedAt: now,
    );
    final result = await create(model);
    return switch (result) {
      Success(value: final created) => created,
      Failure() => model,
    };
  }
}
