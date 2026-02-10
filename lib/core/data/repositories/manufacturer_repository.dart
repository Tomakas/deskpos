import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/manufacturer_model.dart';
import 'base_company_scoped_repository.dart';

class ManufacturerRepository
    extends BaseCompanyScopedRepository<$ManufacturersTable, Manufacturer, ManufacturerModel> {
  ManufacturerRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ManufacturersTable, Manufacturer> get table => db.manufacturers;

  @override
  String get entityName => 'manufacturer';

  @override
  String get supabaseTableName => 'manufacturers';

  @override
  ManufacturerModel fromEntity(Manufacturer e) => manufacturerFromEntity(e);

  @override
  Insertable<Manufacturer> toCompanion(ManufacturerModel m) => manufacturerToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ManufacturerModel m) => manufacturerToSupabaseJson(m);

  @override
  Expression<bool> whereId($ManufacturersTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ManufacturersTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ManufacturersTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<Manufacturer> toUpdateCompanion(ManufacturerModel m) => ManufacturersCompanion(
        name: Value(m.name),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Manufacturer> toDeleteCompanion(DateTime now) => ManufacturersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}
