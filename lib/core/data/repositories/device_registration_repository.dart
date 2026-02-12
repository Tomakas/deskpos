import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../models/device_registration_model.dart';

/// Local-only repository — device_registrations are NOT synced.
class DeviceRegistrationRepository {
  DeviceRegistrationRepository(this._db);
  final AppDatabase _db;

  Future<DeviceRegistrationModel?> getForCompany(String companyId) async {
    final entity = await (_db.select(_db.deviceRegistrations)
          ..where((t) => t.companyId.equals(companyId))
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : deviceRegistrationFromEntity(entity);
  }

  Future<DeviceRegistrationModel> bind({
    required String companyId,
    required String registerId,
  }) async {
    // Remove existing binding first (safe rebind)
    await unbind(companyId);

    final id = const Uuid().v7();
    final now = DateTime.now();
    await _db.into(_db.deviceRegistrations).insert(
      DeviceRegistrationsCompanion.insert(
        id: id,
        companyId: companyId,
        registerId: registerId,
        createdAt: now,
      ),
    );
    final entity = await (_db.select(_db.deviceRegistrations)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return deviceRegistrationFromEntity(entity);
  }

  Future<void> unbind(String companyId) async {
    await (_db.delete(_db.deviceRegistrations)
          ..where((t) => t.companyId.equals(companyId)))
        .go();
  }
}
