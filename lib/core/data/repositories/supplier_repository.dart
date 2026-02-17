import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/supplier_model.dart';
import 'base_company_scoped_repository.dart';

class SupplierRepository
    extends BaseCompanyScopedRepository<$SuppliersTable, Supplier, SupplierModel> {
  SupplierRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$SuppliersTable, Supplier> get table => db.suppliers;

  @override
  String get entityName => 'supplier';

  @override
  String get supabaseTableName => 'suppliers';

  @override
  SupplierModel fromEntity(Supplier e) => supplierFromEntity(e);

  @override
  Insertable<Supplier> toCompanion(SupplierModel m) => supplierToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(SupplierModel m) => supplierToSupabaseJson(m);

  @override
  Expression<bool> whereId($SuppliersTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($SuppliersTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($SuppliersTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($SuppliersTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.supplierName)];

  @override
  Insertable<Supplier> toUpdateCompanion(SupplierModel m) => SuppliersCompanion(
        supplierName: Value(m.supplierName),
        contactPerson: Value(m.contactPerson),
        email: Value(m.email),
        phone: Value(m.phone),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Supplier> toDeleteCompanion(DateTime now) => SuppliersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}
