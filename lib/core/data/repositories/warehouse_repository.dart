import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/warehouse_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class WarehouseRepository
    extends BaseCompanyScopedRepository<$WarehousesTable, Warehouse, WarehouseModel> {
  WarehouseRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$WarehousesTable, Warehouse> get table => db.warehouses;

  @override
  String get entityName => 'warehouse';

  @override
  String get supabaseTableName => 'warehouses';

  @override
  WarehouseModel fromEntity(Warehouse e) => warehouseFromEntity(e);

  @override
  Insertable<Warehouse> toCompanion(WarehouseModel m) => warehouseToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(WarehouseModel m) => warehouseToSupabaseJson(m);

  @override
  Expression<bool> whereId($WarehousesTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($WarehousesTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($WarehousesTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<Warehouse> toUpdateCompanion(WarehouseModel m) => WarehousesCompanion(
        name: Value(m.name),
        isDefault: Value(m.isDefault),
        isActive: Value(m.isActive),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Warehouse> toDeleteCompanion(DateTime now) => WarehousesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  /// Returns the default warehouse for a company.
  /// Creates one lazily if none exists.
  Future<WarehouseModel> getDefault(String companyId) async {
    final entity = await (db.select(db.warehouses)
          ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true) & t.deletedAt.isNull()))
        .getSingleOrNull();

    if (entity != null) return warehouseFromEntity(entity);

    // Lazy init: create default warehouse
    final now = DateTime.now();
    final model = WarehouseModel(
      id: const Uuid().v7(),
      companyId: companyId,
      name: 'Hlavní sklad',
      isDefault: true,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final result = await create(model);
    if (result case Success(value: final created)) {
      return created;
    }
    // Fallback: return the model even if sync enqueue failed
    return model;
  }
}
