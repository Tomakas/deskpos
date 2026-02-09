import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../models/register_model.dart';

class RegisterRepository {
  RegisterRepository(this._db);
  final AppDatabase _db;

  Future<RegisterModel?> getFirstActive(String companyId) async {
    final entity = await (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : registerFromEntity(entity);
  }

  Stream<RegisterModel?> watchFirstActive(String companyId) {
    return (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..limit(1))
        .watchSingleOrNull()
        .map((e) => e == null ? null : registerFromEntity(e));
  }
}
